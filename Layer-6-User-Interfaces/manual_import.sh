#!/bin/bash
# Layer 6: User Interfaces - Manual Import Interface
# Simple command-line interface for manual data import operations

# Set working directory to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load database configuration
if [ -f "$PROJECT_ROOT/Layer-1-Infrastructure/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/Layer-1-Infrastructure/.env" | xargs)
    echo "🔧 Loaded configuration from Layer-1-Infrastructure/.env"
else
    # Default configuration
    export PGHOST="localhost"
    export PGPORT="5433"
    export PGDATABASE="mydb" 
    export PGUSER="myuser"
    export PGPASSWORD="mypass"
    echo "⚠️  Using default configuration"
fi

echo "🚀 Universal DB - Manual Import Interface"
echo "========================================="
echo "🔗 Database: $PGHOST:$PGPORT/$PGDATABASE"
echo ""

# Add Layer-3 to Python path
export PYTHONPATH="$PROJECT_ROOT/Layer-3-Core-Import-Engine:$PYTHONPATH"

# Run the import engine with all arguments
python3 "$PROJECT_ROOT/Layer-3-Core-Import-Engine/simple_import.py" "$@"

# Check result
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Import operation completed successfully"
    echo "💡 Use './manual_import.sh --stats' to view database statistics"
else
    echo ""
    echo "❌ Import operation failed"
    echo "💡 Check your file format and database connection"
    exit 1
fi
