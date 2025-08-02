# Layer 6: User Interfaces

This layer provides user-friendly interfaces for interacting with the Universal DB system.

## Components

### manual_import.sh
- **Purpose**: Simple command-line interface for manual operations
- **Function**:
  - Shell wrapper with environment setup
  - Direct access to import functionality
  - Configuration loading from Layer-1
  - User-friendly error messages

### interactive_cli.py
- **Purpose**: Advanced interactive menu system
- **Function**:
  - Menu-driven interface
  - Guided file processing and import
  - Database statistics and monitoring
  - Administrative operations (truncate, etc.)

## Interface Options

### 1. Simple Shell Interface
```bash
# Basic import operations
./manual_import.sh file.csv
./manual_import.sh file.csv --truncate
./manual_import.sh --stats
```

### 2. Interactive Menu System
```bash
# Full-featured interactive interface
python3 interactive_cli.py
```

Menu options:
1. 📂 Import single file
2. 📁 Process and import file (with encoding conversion)
3. 📊 Show database statistics
4. 🔧 Test database connection
5. 📋 Show recent imports
6. 🗑️ Truncate database (clear all data)
7. ❌ Exit

## Features

### User Experience
- **Guided Operations**: Step-by-step prompts
- **Visual Feedback**: Emojis and progress indicators
- **Error Handling**: Clear error messages and recovery suggestions
- **Safety Checks**: Confirmation prompts for destructive operations

### Administrative Functions
- Database connection testing
- Statistics and monitoring
- Recent import history
- Safe database truncation

### File Processing Integration
- Automatic encoding detection
- File validation
- Processing pipeline integration
- Real-time feedback

## Usage Examples

### Quick Import
```bash
# Fastest way to import a file
./manual_import.sh mydata.csv --truncate
```

### Interactive Session
```bash
# Full-featured interface
python3 interactive_cli.py

# Then follow menu prompts:
# 1. Select option 2 (Process and import)
# 2. Enter file path
# 3. Choose truncate option
# 4. View results
```

### Monitoring
```bash
# Check database status
./manual_import.sh --stats

# Or use interactive interface for detailed monitoring
```

## Architecture Role

This layer provides:
- **Accessibility**: Easy access for non-technical users
- **Safety**: Guided operations with confirmations
- **Visibility**: Clear feedback and monitoring
- **Flexibility**: Multiple interface options
- **Integration**: Seamless access to all lower layers

## User Types

### Casual Users
- Use `manual_import.sh` for simple operations
- Clear command-line syntax
- Minimal learning curve

### Power Users
- Use `interactive_cli.py` for advanced features
- Full system monitoring
- Administrative capabilities

### Automation
- Script `manual_import.sh` in batch operations
- Programmatic access to all functions

## Dependencies
- Layer-1-Infrastructure (database)
- Layer-3-Core-Import-Engine (import functionality)
- Layer-4-File-Processing (file handling)
- Layer-5-Connection-Management (database connections)

## Next Layer
→ Layer-7-Automation: Provides automatic, hands-off operations
