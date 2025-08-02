# Layer 7: Automation

This layer provides fully automated, hands-off data processing with file system monitoring and service management.

## Components

### auto_import.py
- **Purpose**: Automated file processing watchdog
- **Function**:
  - Real-time directory monitoring
  - Automatic file processing and import
  - File lifecycle management (drop → processed/failed)
  - Error handling and recovery

### watch.sh
- **Purpose**: Simple wrapper for starting the watchdog
- **Function**:
  - Environment setup
  - Process management
  - User-friendly startup script

### service_manager.sh
- **Purpose**: Production service management
- **Function**:
  - Systemd service installation
  - Service lifecycle management
  - Logging and monitoring
  - Production deployment utilities

## Automation Features

### Real-Time Monitoring
```python
# Watches drop/ folder for new files
observer = Observer()
observer.schedule(event_handler, drop_dir, recursive=False)
```

### File Lifecycle
```
/drop/        → Files dropped here (monitored)
    ↓ (automatic processing)
/processed/   → Successfully imported files
/failed/      → Files that failed import
```

### Automatic Processing
1. **File Detection**: New file appears in drop/
2. **Waiting**: Ensures file is completely written
3. **Encoding**: Automatic UTF-16 to UTF-8 conversion
4. **Import**: Database import using Layer-3 engine
5. **Organization**: Move to processed/ or failed/

## Usage Options

### 1. Development Mode
```bash
# Interactive mode for testing
./watch.sh
```

### 2. Background Process
```bash
# Run in background
nohup ./watch.sh > /tmp/auto-import.log 2>&1 &
```

### 3. Production Service
```bash
# Install as systemd service
./service_manager.sh install

# Manage service
./service_manager.sh start
./service_manager.sh status
./service_manager.sh logs
```

## Service Management

### Installation
```bash
# Install and configure systemd service
./service_manager.sh install

# Service will auto-start on boot
# Logs to system journal
# Automatic restart on failure
```

### Monitoring
```bash
# Check service status
./service_manager.sh status

# View real-time logs
./service_manager.sh logs

# View service statistics
systemctl status universal-db-auto-import
```

## Directory Structure

### Required Directories
```
/drop/        → Drop new files here
/processed/   → Successfully imported files
/failed/      → Files that failed processing
```

### File Processing Flow
1. **Drop**: `cp myfile.txt drop/`
2. **Auto-detect**: System detects new file
3. **Process**: Encoding conversion if needed
4. **Import**: Database import
5. **Move**: File moved to processed/ or failed/

## Error Handling

### File-Level Errors
- Encoding conversion failures
- Invalid file formats
- Database connection issues
- Permission problems

### System-Level Recovery
- Automatic service restart
- Transaction rollback on errors
- Graceful handling of temporary issues
- Detailed error logging

## Configuration

### Environment Variables
```bash
# Drop folder location
DROP_DIR="/path/to/drop"

# Database connection (from Layer-1)
PGHOST=localhost
PGPORT=5433
PGDATABASE=mydb
```

### Monitoring Settings
- File watch timeout: 10 seconds
- Service restart delay: 10 seconds
- Log retention: System default
- Error retry attempts: 3

## Architecture Role

This layer provides:
- **Zero-Touch Operation**: Complete automation
- **Reliability**: Service-level reliability with restart
- **Scalability**: Handles high-volume file processing
- **Monitoring**: Comprehensive logging and status
- **Production Ready**: Systemd integration

## Performance

### Throughput
- **File Detection**: < 1 second
- **Processing**: Limited by file size and encoding
- **Import**: 12,000+ records/second (Layer-3)
- **Concurrent Files**: Processes one at a time (safe)

### Resource Usage
- **CPU**: Low (event-driven)
- **Memory**: < 100MB typical
- **Disk**: Temporary files during processing
- **Network**: Database connections only

## Dependencies
- watchdog (Python package)
- All lower layers (1-6)
- Optional: systemd (for service mode)

## Next Layer
→ Layer-8-Analytics: Analyzes the data imported by this automation
