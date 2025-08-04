# Universal-DB Project

## Quick Start

### 1. Start PostgreSQL Database
```bash
cd /workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app
docker build -t my-postgres -f docker/postgres/Dockerfile docker/postgres/
docker run --name mypg -p 5433:5432 -d my-postgres
```

### 2. Install Dependencies and Start App
```bash
npm install
npm start
```

### 3. Import Data
Place your `.txt` files in the `data/` folder, then run:
```bash
cd /workspaces/Universal-DB
./import_calls.sh
```

## Bulk Import Data with PostgreSQL COPY

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
   COPY calls (
     source_id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet,
     service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs,
     time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding,
     source_nms, network_controller, utc_offset_minutes
   ) FROM '/tmp/data.txt' DELIMITER ';' NULL '' CSV HEADER;
   ```

**To check your data:**
```sql
SELECT * FROM calls LIMIT 10;
```

**To list tables:**
```sql
\dt
```

**To describe a table:**
```sql
\d+ calls
```
