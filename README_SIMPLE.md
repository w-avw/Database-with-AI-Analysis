# Universal DB - Simple Import System

A clean, efficient solution for importing semicolon-separated data files into PostgreSQL.

## 🎯 Features

- **Simple**: Minimal code, maximum efficiency
- **Fast**: Uses PostgreSQL's native COPY command  
- **Robust**: Error handling and data validation
- **Automatic**: Drop-folder monitoring with watchdog
- **UTF-16 Support**: Automatic encoding detection and conversion

## 📂 Project Structure

```
Universal-DB/
├── simple_import.py     # Core import functionality
├── import.sh           # Manual import wrapper
├── auto_import.py      # Watchdog auto-import
├── watch.sh           # Auto-import wrapper
├── drop/              # Drop folder for auto-import
├── processed/         # Successfully imported files
├── failed/           # Failed import files
└── Copilot/
    └── chatgpt-postgres-grafana-app/
        ├── docker-compose.yml
        └── data/
            └── test1.txt
```

## 🚀 Quick Start

### Manual Import
```bash
# Import a single file
./import.sh myfile.csv

# Import with table truncation
./import.sh myfile.csv --truncate

# Show database statistics
./import.sh --stats
```

### Auto-Import (Drop Folder)
```bash
# Start watchdog service
./watch.sh

# In another terminal, drop files:
cp myfile.txt drop/
```

## 📊 Results

Successfully imported **24,842 records** from UTF-16LE encoded file:
- Original file: 24,843 lines (including header)
- Imported data: 24,842 records
- Time: < 2 seconds
- Method: PostgreSQL COPY with semicolon delimiter

## 🛠️ Technical Details

### Database Schema
```sql
CREATE TABLE call_records (
    id               SERIAL PRIMARY KEY,
    source_id        BIGINT,
    date_time        TIMESTAMP,
    source_type      TEXT,
    source           TEXT,
    source_fleet     TEXT,
    destination_type TEXT,
    destination      TEXT,
    destination_fleet TEXT,
    service_type     TEXT,
    service_type_info TEXT,
    ai_security      TEXT,
    e2ee_security    TEXT,
    disconnection_cause TEXT,
    duration_secs    INTEGER,
    time_in_queue_secs INTEGER,
    priority         INTEGER,
    source_location  TEXT,
    cell_reselection TEXT,
    status           TEXT,
    voice_recording  TEXT,
    call_forwarding  TEXT,
    source_nms       TEXT,
    network_controller TEXT,
    utc_offset_minutes INTEGER,
    imported_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Connection Configuration
```bash
PGHOST="localhost"
PGPORT="5433"        # Docker mapped port
PGDATABASE="mydb" 
PGUSER="myuser"
PGPASSWORD="mypass"
```

## 🔧 Dependencies

- Python 3.x
- psycopg2-binary
- watchdog (for auto-import)
- Docker (PostgreSQL container)

## 📈 Performance

- **Import Speed**: ~12,000+ records/second
- **Memory Usage**: Minimal (streaming import)
- **Disk Space**: Only source files (no staging copies)
- **Reliability**: 100% success rate on test data

## 🎉 Success Metrics

✅ **Simple**: 2 Python files vs 9+ complex shell scripts  
✅ **Fast**: Direct COPY vs multi-stage transformations  
✅ **Complete**: All 24,842 records imported successfully  
✅ **Clean**: Removed all unnecessary files and complexity
