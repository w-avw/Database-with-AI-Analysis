// Fetch Error Analysis with error handling
const errorRes = await fetch('https://didactic-space-succotash-4j5rv77xpp5fqg9p-5434.app.github.dev/api/analytics?query=error_analysis')
let errorAnalysis = []
try {
  errorAnalysis = await errorRes.json()
} catch (e) {
  errorAnalysis = { error: 'Invalid JSON response', details: await errorRes.text() }
}
workflow.errorAnalysis = errorAnalysis

// Fetch System Failure with error handling
const failureRes = await fetch('https://didactic-space-succotash-4j5rv77xpp5fqg9p-5434.app.github.dev/api/analytics?query=system_failure')
let systemFailure = []
try {
  systemFailure = await failureRes.json()
} catch (e) {
  systemFailure = { error: 'Invalid JSON response', details: await failureRes.text() }
}
workflow.systemFailure = systemFailure

return workflow
