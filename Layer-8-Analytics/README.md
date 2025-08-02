# Layer 8: Analytics

This layer provides comprehensive data analysis, reporting, and monitoring tools for the imported data.

## Components

### analytics.py
- **Purpose**: Comprehensive data analysis engine
- **Function**:
  - Basic statistics (record counts, date ranges, completeness)
  - Call pattern analysis (duration stats, top callers/called)
  - Temporal pattern analysis (hourly distributions)
  - Data quality reports (null/empty field detection)
  - JSON export capabilities

### monitor.py
- **Purpose**: Real-time database monitoring
- **Function**:
  - Live statistics dashboard
  - Recent import tracking
  - Database size monitoring
  - Connection monitoring
  - Auto-refresh display (5-second intervals)

### query_builder.py
- **Purpose**: Interactive SQL query interface
- **Function**:
  - Table structure exploration
  - Predefined useful queries
  - Custom SQL execution
  - Interactive query building
  - Results formatting and display

### generate_report.sh
- **Purpose**: User-friendly report generation menu
- **Function**:
  - Menu-driven interface
  - Report type selection
  - Environment configuration loading
  - Output management

## Analysis Capabilities

### Basic Statistics
```python
# Total records with completeness analysis
Total de registros: 24,842
Completitud de datos:
  - Número origen: 24,842 (100.0%)
  - Número destino: 24,842 (100.0%)
  - Duración: 24,842 (100.0%)
```

### Call Pattern Analysis
- **Duration Statistics**: Average, min, max, standard deviation
- **Top Callers**: Most active calling numbers
- **Top Destinations**: Most called numbers
- **Call Distribution**: By duration ranges, types, status

### Temporal Analysis
- **Hourly Patterns**: Call distribution by hour of day
- **Daily Patterns**: Calls by day of week
- **Time Series**: Trend analysis over time
- **Peak Hours**: Identification of busy periods

### Data Quality Assessment
- **Completeness**: Null and empty field detection
- **Consistency**: Data format validation
- **Duplicates**: Potential duplicate record identification
- **Outliers**: Unusual data pattern detection

## Usage Scenarios

### 1. Quick Analysis
```bash
# Basic statistics
./generate_report.sh
# Select option 2

# Or directly:
python3 analytics.py basic
```

### 2. Comprehensive Report
```bash
# Full analysis with export
python3 analytics.py full

# Generates:
# - Complete statistics
# - Pattern analysis
# - Quality report
# - JSON export file
```

### 3. Real-time Monitoring
```bash
# Live dashboard
python3 monitor.py

# Shows:
# - Current record count
# - Recent imports (last hour)
# - Database size
# - Active connections
```

### 4. Custom Analysis
```bash
# Interactive SQL interface
python3 query_builder.py

# Features:
# - Table structure viewing
# - Predefined queries
# - Custom SQL execution
```

## Predefined Queries

### 1. Communication Patterns
```sql
-- Top callers by volume
SELECT caller_number, COUNT(*) as call_count
FROM call_records 
GROUP BY caller_number 
ORDER BY call_count DESC
```

### 2. Duration Analysis
```sql
-- Calls by duration ranges
SELECT 
    CASE 
        WHEN duration < 30 THEN 'Short'
        WHEN duration < 180 THEN 'Medium'
        ELSE 'Long'
    END as range,
    COUNT(*)
FROM call_records
GROUP BY range
```

### 3. Temporal Patterns
```sql
-- Calls by day of week
SELECT 
    EXTRACT(DOW FROM created_at) as day,
    COUNT(*) as calls
FROM call_records
GROUP BY day
ORDER BY day
```

## Export Formats

### JSON Summary
```json
{
  "analysis_timestamp": "2024-01-15T10:30:00",
  "total_records": 24842,
  "unique_callers": 8234,
  "unique_called": 12456,
  "average_duration": 127.45
}
```

### Report Outputs
- **Console Display**: Formatted tables and statistics
- **JSON Files**: Machine-readable summaries
- **CSV Export**: Query results (via custom SQL)

## Performance Metrics

### Analysis Speed
- **Basic Stats**: < 1 second
- **Pattern Analysis**: 2-5 seconds
- **Full Analysis**: 10-30 seconds
- **Real-time Monitor**: 5-second refresh

### Resource Usage
- **Memory**: < 50MB for analysis
- **CPU**: Low (analysis is I/O bound)
- **Database Load**: Read-only queries, minimal impact

## Integration Points

### With Layer-7 (Automation)
- **Import Monitoring**: Track automated imports
- **Service Health**: Monitor automation service status
- **Error Analysis**: Analyze failed import patterns

### With Layer-5 (Connection Management)
- **Connection Reuse**: Same connection configuration
- **Environment Variables**: Shared database settings
- **Error Handling**: Consistent connection management

### With Layer-2 (Database Schema)
- **Schema Awareness**: Queries match table structure
- **Index Utilization**: Optimized for existing indexes
- **Data Types**: Proper handling of all field types

## Monitoring Features

### Real-time Dashboard
```
📊 ESTADÍSTICAS DE LA BASE DE DATOS
----------------------------------------
Total de registros:     24,842
Importados (1h):        0
Tamaño BD:              2.1 MB
Tamaño tabla:           1.8 MB
Conexiones activas:     3
```

### Health Checks
- Database connectivity
- Table accessibility
- Data consistency
- Import activity

## Advanced Features

### Custom Query Building
- **Interactive Interface**: Step-by-step query construction
- **Query History**: Save and reuse queries
- **Result Export**: Save results to files
- **Query Validation**: Syntax checking before execution

### Data Visualization
```python
# ASCII charts for distributions
10:00 │████████████████████ 1,245
11:00 │████████████████ 987
12:00 │██████████████████████ 1,456
```

## Architecture Role

This layer provides:
- **Business Intelligence**: Convert data into insights
- **Quality Assurance**: Monitor data integrity
- **Performance Monitoring**: Track system health
- **Decision Support**: Data-driven insights

## Dependencies
- psycopg2 (database connectivity)
- All lower layers for data access
- Optional: matplotlib/plotly for advanced visualization

## Configuration

### Environment Variables
```bash
# Database connection (from Layer-1)
PGHOST=localhost
PGPORT=5433
PGDATABASE=mydb
PGUSER=myuser
PGPASSWORD=mypass
```

### Analysis Settings
- Report refresh intervals
- Query timeout limits
- Export file locations
- Display formatting options

This completes the 8-layer architecture, providing a comprehensive data analysis and monitoring solution on top of the automated import system.
