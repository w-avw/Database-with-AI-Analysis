# Layer 2: Database Schema

This layer defines the data structure and organization within the PostgreSQL database.

## Components

### schema.sql
- **Purpose**: Complete database schema definition
- **Function**:
  - Creates `call_records` table with proper data types
  - Establishes primary keys and indexes
  - Includes comprehensive field documentation
  - Optimizes for query performance

## Schema Design

### Table Structure
```sql
call_records (
    id SERIAL PRIMARY KEY,              -- Auto-increment identifier
    source_id BIGINT,                   -- Original call ID
    date_time TIMESTAMP,                -- Call timestamp
    source TEXT,                        -- Calling party
    destination TEXT,                   -- Called party
    duration_secs INTEGER,              -- Call duration
    imported_at TIMESTAMP              -- Import tracking
    -- ... 24 total fields
)
```

### Performance Indexes
- `date_time`: For time-based queries
- `source`: For caller analysis
- `destination`: For called party analysis
- `source_type`: For service type filtering
- `imported_at`: For import tracking

## Data Mapping

Maps semicolon-separated fields to structured columns:
```
ID;Date/Time;Source type;Source;...
↓
source_id, date_time, source_type, source, ...
```

## Architecture Role

This layer provides:
- **Structure**: Organized data storage
- **Performance**: Optimized for telecommunications data
- **Integrity**: Data type validation
- **Scalability**: Indexed for large datasets

## Usage

```bash
# Apply schema
psql -U myuser -d mydb -f schema.sql

# Verify schema
psql -U myuser -d mydb -c "\d call_records"
```

## Dependencies
- Layer-1-Infrastructure (PostgreSQL database)

## Next Layer
→ Layer-3-Core-Import-Engine: Populates this schema with data
