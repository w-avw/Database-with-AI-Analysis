# Bulk Import Data with PostgreSQL COPY

For fast and reliable import of your `;`-delimited data files, use the PostgreSQL `COPY` command from inside your database container:

1. Copy your data file into the container:
   ```bash
   docker cp /path/to/your/data.txt mypg:/tmp/data.txt
   ```

2. Enter the container and start psql:
   ```bash
   docker exec -it mypg bash
   psql -U myuser -d mydb
   ```

3. Run the COPY command (adjust table and file path as needed):
   ```sql
   COPY your_table FROM '/tmp/data.txt' DELIMITER ';' NULL '';
   ```

If your file has a header row, add `CSV HEADER`:
   ```sql
   COPY your_table FROM '/tmp/data.txt' DELIMITER ';' NULL '' CSV HEADER;
   ```

**To check your data:**
```sql
SELECT * FROM your_table LIMIT 10;
```

**To list tables:**
```sql
\dt
```

**To describe a table:**
```sql
\d+ your_table
```

# 🚀 Universal DB - Fast TXT File Processing

**A PostgreSQL database system for automatically processing .txt files in CSV format.**

Perfect for demos and quick deployment - get up and running in under 2 minutes!

## ⚡ Quick Start (2 Steps!)

### 1. Run the Test Script
```bash
chmod +x quick_test.sh
./quick_test.sh
```

### 2. Import Your Files
```bash
# Drop your .txt files in the data folder
cp your_file.txt Copilot/chatgpt-postgres-grafana-app/data/

# Run import
./import_calls.sh
```

**That's it!** Your data is now in PostgreSQL database `mydb`.

## 📂 File Format

Your .txt files should be semicolon-delimited CSV with these columns:
```
ID;Date/Time;Source type;Source;Source fleet;Destination type;Destination;Destination fleet;Service type;Service type info.;AI security;E2EE security;Disconnection cause;Duration (secs.);Time in queue (secs.);Priority;Source location;Cell reselection;Status;Voice recording;Call forwarding;Source NMS;Network Controller;UTC offset (minutes)
```

## 🛠️ Available Scripts

| Script | Purpose |
|--------|---------|
| `./quick_test.sh` | Complete setup and test |
| `./import_calls.sh` | Manual import of .txt files |
| `./auto_import.sh` | Auto-watch folder for new files |
| `./db_monitor.sh` | View database statistics |

## 🔍 Database Access

```bash
# Connect to database
docker exec -it mypg psql -U myuser -d mydb

# Quick queries
SELECT COUNT(*) FROM calls;
SELECT * FROM calls LIMIT 10;
```

## 📊 Workflow

1. **Drop** .txt file in `Copilot/chatgpt-postgres-grafana-app/data/`
2. **Run** `./import_calls.sh` (or use auto-watcher)
3. **Data** automatically parsed into PostgreSQL
4. **Files** moved to `processed/` folder

## 🚨 Troubleshooting

- **Container not running?** → `cd Copilot/chatgpt-postgres-grafana-app && docker-compose up -d`
- **Permission denied?** → `chmod +x *.sh`
- **Import failing?** → Check file format matches header exactly

## ⚙️ Configuration

- **Database:** PostgreSQL 
- **Container:** `mypg`
- **Credentials:** `myuser`/`mypass`
- **Database:** `mydb`
- **Port:** `5433`

---

**🎯 Perfect for demos and production workloads!**

<!--
  Project Overview:
  - Integrates PostgreSQL, ChatGPT API, and Grafana for data storage, analysis, and visualization.
  - Automates ingestion of .txt files into the database.
  - Provides API endpoints for chatbot and analytics integration.
-->

This project integrates a PostgreSQL database with the ChatGPT API and Grafana for data visualization. The application is designed to fetch data from the database, interact with the ChatGPT API for insights, and visualize the results using Grafana.

## Project Structure

```
chatgpt-postgres-grafana-app
├── src
│   ├── index.js            # Entry point of the application
│   ├── db
│   │   ├── connection.js   # Database connection logic
│   │   └── queries.js      # Database query functions
│   ├── chatgpt
│   │   └── api.js          # ChatGPT API interaction
│   ├── grafana
│   │   └── datasource.js    # Grafana datasource configuration
│   └── utils
│       └── logger.js       # Logging utility
├── docker
│   └── postgres
│       ├── Dockerfile      # Dockerfile for PostgreSQL
│       └── init.sql        # SQL initialization script
├── docker-compose.yml       # Docker Compose configuration
├── package.json             # NPM dependencies and scripts
├── .env.example             # Environment variable template
└── README.md                # Project documentation
```

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd chatgpt-postgres-grafana-app
   ```

2. **Install dependencies:**
   ```
   npm install
   ```

3. **Configure environment variables:**
   Copy `.env.example` to `.env` and fill in the required values, such as database connection details and API keys.

4. **Build and run the Docker containers:**
   ```
   docker-compose up --build
   ```

5. **Access the application:**
   The application will be running on the specified port. You can access it via your web browser.

## Usage

- The application connects to a PostgreSQL database to store and retrieve data.
- It interacts with the ChatGPT API to get suggestions and improvements based on the data.
- Grafana is configured to visualize the data stored in the PostgreSQL database.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.