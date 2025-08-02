# Layer 5: Connection Management

This layer provides centralized database connection handling, configuration management, and connection pooling.

## Components

### import.sh
- **Purpose**: Shell wrapper for database connections
- **Function**:
  - Sets environment variables for database connection
  - Provides simple command-line interface
  - Coordinates between layers

### connection_manager.py
- **Purpose**: Advanced connection management and pooling
- **Function**:
  - Centralized configuration management
  - Connection testing and validation
  - Connection pooling for high-throughput scenarios
  - Environment configuration loading

## Connection Configuration

### Environment Variables
```bash
PGHOST=localhost
PGPORT=5433                # Docker mapped port
PGDATABASE=mydb
PGUSER=myuser
PGPASSWORD=mypass
```

### Configuration Sources
1. Environment variables
2. .env file from Layer-1-Infrastructure
3. Default fallback values

## Features

### Connection Testing
```python
db_config = DatabaseConfig()
if db_config.test_connection():
    print("✅ Database ready")
```

### Connection Pooling
```python
pool = ConnectionPool(db_config, max_connections=5)
conn = pool.get_connection()
# Use connection
pool.return_connection(conn)
```

### Secure Configuration
- Passwords masked in logs
- Configuration validation
- Error handling for connection failures

## Usage

### Simple Wrapper
```bash
# Use shell wrapper (recommended for manual operations)
./import.sh file.csv --truncate
./import.sh --stats
```

### Advanced Management
```python
# Direct Python usage (for automation)
from connection_manager import DatabaseConfig
config = DatabaseConfig()
conn = config.get_connection()
```

## Architecture Role

This layer provides:
- **Abstraction**: Hides connection complexity
- **Reliability**: Connection testing and validation
- **Performance**: Connection pooling for efficiency
- **Security**: Secure credential management
- **Flexibility**: Multiple configuration sources

## Connection Flow

```
Environment/Config → DatabaseConfig → Connection Pool → Layer-3-Import-Engine
```

## Error Handling

### Connection Failures
- Graceful error messages
- Automatic retry logic
- Configuration validation
- Fallback mechanisms

### Monitoring
- Connection status reporting
- Performance metrics
- Pool usage statistics

## Dependencies
- psycopg2-binary
- Layer-1-Infrastructure (database container)

## Next Layer
→ Layer-6-User-Interfaces: Provides user-friendly access to these connections
