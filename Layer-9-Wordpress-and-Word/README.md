# Layer 9: WordPress and Word Integration

This project integrates a Word document generation feature into a WordPress site using a Node.js backend. The backend dynamically updates a Word template based on user input from the WordPress frontend.

## Project Structure

```
Layer-9-Wordpress-and-Word
├── backend
│   ├── src
│   │   ├── server.js               # Main entry point for the Node.js backend
│   │   ├── controllers              # Contains logic for processing requests
│   │   │   └── documentController.js
│   │   ├── services                 # Handles Word document manipulation
│   │   │   └── docxService.js
│   │   └── middleware               # Middleware for handling CORS
│   │       └── cors.js
│   ├── templates                    # Word template files
│   │   └── template.docx
│   ├── output                       # Directory for generated Word documents
│   │   └── .gitkeep
│   ├── package.json                 # Node.js project configuration
│   └── README.md                    # Documentation for the backend
├── wordpress
│   ├── plugins                      # WordPress plugins
│   │   └── word-integration
│   │       ├── word-integration.php # Main plugin file
│   │       ├── assets               # Plugin assets (JS and CSS)
│   │       │   ├── js
│   │       │   │   └── main.js
│   │       │   └── css
│   │       │       └── style.css
│   │       └── templates            # Plugin templates
│   │           └── control-panel.php
│   └── themes                       # WordPress themes
│       └── custom-theme
│           ├── functions.php        # Theme functions and setup
│           ├── index.php            # Main template file
│           └── style.css            # Theme styles
├── docker-compose.yml               # Docker configuration
└── README.md                        # Overview of the entire project
```

## Setup Instructions

1. **Clone the Repository**: Clone this repository to your local machine or server.

2. **Backend Setup**:
   - Navigate to the `backend` directory.
   - Run `npm install` to install the necessary dependencies.

3. **WordPress Setup**:
   - Copy the `wordpress` directory to your WordPress installation's `wp-content/plugins` directory.
   - Activate the "Word Integration" plugin from the WordPress admin panel.

4. **Run the Backend**:
   - Start the Node.js server by running `node src/server.js` in the `backend` directory.

5. **Access the Control Panel**:
   - Navigate to the control panel in your WordPress site to add/remove items and export the Word document.

## Usage Guidelines

- Use the buttons in the control panel to manage items and generate the Word document.
- The generated document will be a copy of the template with the specified items included.

## Contributing

Feel free to contribute to this project by submitting issues or pull requests. Your feedback and contributions are welcome!