# Layer 9 WordPress and Word Backend

This directory contains the backend implementation for the Layer 9 WordPress and Word integration project. The backend is built using Node.js and Express, providing an API for generating Word documents based on user input from the WordPress frontend.

## Project Structure

- **src/**: Contains the source code for the backend.
  - **server.js**: The main entry point for the Node.js backend, setting up the Express server and defining API endpoints.
  - **controllers/**: Contains the logic for processing requests.
    - **documentController.js**: Handles requests related to Word document generation.
  - **services/**: Contains business logic for document manipulation.
    - **docxService.js**: Uses the docxtemplater library to modify Word templates.
  - **middleware/**: Contains middleware functions.
    - **cors.js**: Configures CORS for handling cross-origin requests.

- **templates/**: Contains the Word template file used for generating documents.
  - **template.docx**: The base template with placeholders for dynamic content.

- **output/**: Directory for storing generated Word documents.
  - **.gitkeep**: Ensures the output directory is tracked by Git.

- **package.json**: Lists project dependencies and scripts for managing the Node.js application.

## Setup Instructions

1. **Install Dependencies**: Run `npm install` in the backend directory to install the required packages.
2. **Start the Server**: Use `node src/server.js` to start the Express server. The API will be available at `http://localhost:3000`.
3. **Access the API**: The main endpoint for generating Word documents is `/generate`. This endpoint accepts POST requests with a JSON body containing the items to be included in the document.

## Usage

- The backend processes requests from the WordPress frontend, allowing users to add or remove items dynamically.
- The generated Word document will be a copy of the template with the specified items and the current date.

## Additional Information

For more details on the implementation, refer to the individual files in the `src` directory.