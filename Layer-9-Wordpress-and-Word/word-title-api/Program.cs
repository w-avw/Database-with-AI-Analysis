using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml;
using Microsoft.AspNetCore.Http;
using OpenXmlPowerTools; // from OpenXmlPowerTools.NetCore

var builder = WebApplication.CreateBuilder(args);

// Add CORS services
builder.Services.AddCors();

var app = builder.Build();

// Enable CORS for all origins
app.UseCors(builder => builder
    .AllowAnyOrigin()
    .AllowAnyMethod()
    .AllowAnyHeader());

app.MapPost("/edit-and-download", async (HttpContext ctx) =>
{
    var payload = await ctx.Request.ReadFromJsonAsync<EditRequest>();
    if (payload is null || string.IsNullOrWhiteSpace(payload.NewTitle))
        return Results.BadRequest("Missing NewTitle");

    var templatePath = Environment.GetEnvironmentVariable("TEMPLATE_PATH")
                       ?? "/workspaces/Universal-DB/Layer-9-Wordpress-and-Word/backend/templates/original.docm";

    if (!File.Exists(templatePath))
        return Results.NotFound($"Template not found at: {templatePath}");

    Directory.CreateDirectory("out");
    var ext = (payload.DownloadAs?.ToLowerInvariant() == "docx") ? ".docx" : ".docm";
    var workPath = Path.Combine("out", $"copy-{Guid.NewGuid()}{ext}");
    File.Copy(templatePath, workPath, overwrite: true);

    try
    {
        using (var doc = WordprocessingDocument.Open(workPath, true))
        {
            // If the doc has tracked changes, accept them so TextReplacer can operate.
            // (This is the supported way in PowerTools.)
            RevisionAccepter.AcceptRevisions(doc);  // safe no-op if none

            // Replace the visible title text anywhere it appears (handles split runs).
            var originalTitle = payload.OriginalTitle
                ?? "PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA";
            TextReplacer.SearchAndReplace(doc, originalTitle, payload.NewTitle, matchCase: true);

            // Also update the document's Core Properties "Title" metadata.
            doc.PackageProperties.Title = payload.NewTitle; // standard Open XML core prop

            // If the caller wants DOCX instead of DOCM, convert container type (drops macro part).
            if (payload.DownloadAs?.ToLowerInvariant() == "docx")
                doc.ChangeDocumentType(WordprocessingDocumentType.Document); // DOCM -> DOCX
        }

        var mime = (ext == ".docx")
            ? "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            : "application/vnd.ms-word.document.macroEnabled.12";

        var bytes = await File.ReadAllBytesAsync(workPath);
        var downloadName = (payload.FileName?.Trim().Length > 0 ? payload.FileName : "edited") + ext;
        
        // Clean up temp file
        File.Delete(workPath);
        
        return Results.File(bytes, mime, downloadName);
    }
    catch (Exception ex)
    {
        // Clean up temp file on error
        if (File.Exists(workPath))
            File.Delete(workPath);
        
        return Results.Problem($"Error processing document: {ex.Message}");
    }
});

// Status endpoint for health checks
app.MapGet("/status", () => Results.Ok(new { 
    status = "OK", 
    templatePath = Environment.GetEnvironmentVariable("TEMPLATE_PATH") ?? "/workspaces/Universal-DB/Layer-9-Wordpress-and-Word/backend/templates/original.docm",
    timestamp = DateTime.UtcNow 
}));

app.Run();

record EditRequest(
    string NewTitle,
    string? OriginalTitle,
    string? DownloadAs,
    string? FileName
);
