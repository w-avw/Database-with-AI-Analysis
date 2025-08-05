#!/bin/bash
# 🛑 UNIVERSAL DB - COMPLETE SYSTEM SHUTDOWN
# Safely stops all Universal DB services

echo "🛑 UNIVERSAL DB - SYSTEM SHUTDOWN"
echo "=================================="

# Stop containers gracefully
echo "🔄 Stopping Grafana..."
docker stop grafana 2>/dev/null && echo "✅ Grafana stopped" || echo "⚠️  Grafana not running"

echo "🔄 Stopping PostgreSQL..."
docker stop mypg 2>/dev/null && echo "✅ PostgreSQL stopped" || echo "⚠️  PostgreSQL not running"

echo ""
echo "✅ Universal DB system shutdown complete!"
echo "🚀 To restart: ./start-universal-db.sh"
