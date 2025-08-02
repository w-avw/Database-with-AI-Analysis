#!/bin/bash
# Universal DB + Grafana Setup Script
# Configura Grafana con PostgreSQL para análisis de datos de llamadas

echo "🚀 UNIVERSAL DB + GRAFANA INTEGRATION"
echo "====================================="
echo

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
    echo "✅ Environment variables loaded"
else
    echo "❌ .env file not found"
    exit 1
fi

echo "📦 Current Docker containers:"
docker ps -a

echo
echo "🛑 Stopping existing containers..."
docker-compose down

echo
echo "🐳 Starting PostgreSQL + Grafana services..."
docker-compose up -d

echo
echo "⏳ Waiting for services to start..."
sleep 15

# Check PostgreSQL
echo "🔍 Checking PostgreSQL connection..."
until docker exec universal-db-postgres pg_isready -U myuser; do
    echo "   PostgreSQL not ready yet, waiting..."
    sleep 5
done
echo "✅ PostgreSQL is ready!"

# Check Grafana
echo "🔍 Checking Grafana status..."
sleep 10
until curl -f http://localhost:3000/api/health 2>/dev/null; do
    echo "   Grafana not ready yet, waiting..."
    sleep 5
done
echo "✅ Grafana is ready!"

echo
echo "🗃️ Applying database optimizations for Grafana..."
if [ -f "../Layer-2-Database-Schema/grafana-indexes.sql" ]; then
    PGPASSWORD=$PGPASSWORD psql -h localhost -p 5433 -U myuser -d mydb -f ../Layer-2-Database-Schema/grafana-indexes.sql
    echo "✅ Database indexes created for optimal Grafana performance"
else
    echo "❌ Database optimization file not found"
fi

echo
echo "📊 Verifying data availability..."
RECORD_COUNT=$(PGPASSWORD=$PGPASSWORD psql -h localhost -p 5433 -U myuser -d mydb -t -c "SELECT COUNT(*) FROM call_records;" | tr -d ' ')
echo "   Total records available: $RECORD_COUNT"

if [ "$RECORD_COUNT" -gt 0 ]; then
    echo "✅ Data is available for analysis"
else
    echo "⚠️  No data found. You may need to import data first."
    echo "   Run: cd ../Layer-3-Core-Import-Engine && python3 simple_import.py"
fi

echo
echo "🎯 SETUP COMPLETE!"
echo "=================="
echo
echo "🌐 Grafana Web Interface: http://localhost:3000"
echo "👤 Username: admin"
echo "🔑 Password: admin123"
echo
echo "📊 PostgreSQL Database:"
echo "   Host: localhost:5433"
echo "   Database: mydb"
echo "   User: myuser"
echo "   Records: $RECORD_COUNT"
echo
echo "📈 Pre-configured Dashboard:"
echo "   - Call Analytics Dashboard (auto-provisioned)"
echo "   - PostgreSQL datasource (auto-configured)"
echo
echo "🚀 Next Steps:"
echo "1. Open Grafana: http://localhost:3000"
echo "2. Login with admin/admin123"
echo "3. Navigate to 'Universal DB - Call Analytics Dashboard'"
echo "4. Explore your $RECORD_COUNT call records!"
echo
echo "💡 Pro Tips:"
echo "   - Dashboard auto-refreshes every 30 seconds"
echo "   - Create custom panels using the query builder"
echo "   - Use time range selector for historical analysis"

# Attempt to open browser
if command -v "$BROWSER" &> /dev/null; then
    echo
    echo "🌐 Opening Grafana in browser..."
    "$BROWSER" "http://localhost:3000" 2>/dev/null &
elif command -v xdg-open &> /dev/null; then
    echo
    echo "🌐 Opening Grafana in browser..."
    xdg-open "http://localhost:3000" 2>/dev/null &
else
    echo
    echo "ℹ️  Please open http://localhost:3000 in your browser manually"
fi

echo
echo "✨ Grafana integration complete! Ready for data visualization!"
