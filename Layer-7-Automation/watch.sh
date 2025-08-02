#!/bin/bash
# Auto-import wrapper for Universal DB

export PGHOST="localhost"
export PGPORT="5433"
export PGDATABASE="mydb" 
export PGUSER="myuser"
export PGPASSWORD="mypass"

echo "🚀 Universal DB - Auto Import Watchdog"
echo "======================================="
echo "🔗 Database: $PGHOST:$PGPORT/$PGDATABASE"
echo ""

# Run the auto-import watchdog
python3 auto_import.py
