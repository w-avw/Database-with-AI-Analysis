class DocumentController {
    constructor(docxService) {
        this.docxService = docxService;
    }

    async generateDocument(req, res) {
        const { items } = req.body;

        try {
            const filePath = await this.docxService.createDocument(items);
            res.download(filePath);
        } catch (error) {
            console.error('Error generating document:', error);
            res.status(500).send('Error generating document');
        }
    }
}

module.exports = DocumentController;