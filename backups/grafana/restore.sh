#!/bin/bash
# 🔄 Grafana Restore Script
# Restores Grafana dashboards and configuration from backup

echo "🚀 Universal DB - Grafana Restore"
echo "=================================="

BACKUP_DIR="/workspaces/Universal-DB/backups/grafana"
DB_FILE="grafana_backup_20250805_014040.db"
CONFIG_FILE="grafana_config_20250805_014048.ini"

if [[ ! -f "$BACKUP_DIR/$DB_FILE" ]]; then
    echo "❌ Backup database file not found: $DB_FILE"
    exit 1
fi

if [[ ! -f "$BACKUP_DIR/$CONFIG_FILE" ]]; then
    echo "❌ Backup config file not found: $CONFIG_FILE"
    exit 1
fi

echo "📋 Found backup files:"
echo "   📊 Database: $DB_FILE ($(du -h $BACKUP_DIR/$DB_FILE | cut -f1))"
echo "   ⚙️  Config: $CONFIG_FILE ($(du -h $BACKUP_DIR/$CONFIG_FILE | cut -f1))"
echo ""

read -p "🤔 Stop Grafana container and restore backup? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🛑 Stopping Grafana container..."
    docker stop grafana

    echo "💾 Restoring database backup..."
    docker cp "$BACKUP_DIR/$DB_FILE" grafana:/var/lib/grafana/grafana.db

    echo "⚙️  Restoring configuration..."
    docker cp "$BACKUP_DIR/$CONFIG_FILE" grafana:/etc/grafana/grafana.ini

    echo "🚀 Starting Grafana container..."
    docker start grafana

    echo ""
    echo "✅ Grafana restore completed!"
    echo "🌐 Access your dashboards at: http://localhost:3000"
    echo "🔑 Default login: admin/admin"
    echo ""
    echo "📊 Your dashboards should now be restored with:"
    echo "   • All 24,842 call records"
    echo "   • Basic Overview Metrics dashboard"
    echo "   • State Analysis & Trends dashboard"
    echo "   • PostgreSQL datasource configuration"
else
    echo "❌ Restore cancelled"
fi
