#!/bin/bash
# Simple import wrapper for Docker PostgreSQL

export PGHOST="localhost"
export PGPORT="5433"
export PGDATABASE="mydb" 
export PGUSER="myuser"
export PGPASSWORD="mypass"

echo "🚀 Universal DB - Simple Import"
echo "================================"
echo "🔗 Connecting to PostgreSQL in Docker..."

# Run the Python importer with all arguments passed through
python3 ../Layer-3-Core-Import-Engine/simple_import.py "$@"
