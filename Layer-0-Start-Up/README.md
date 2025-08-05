# 🚀 Layer-0-Start-Up - Universal DB System Startup

## 🎯 Purpose

**Single entry point** for the entire Universal DB system. Automated startup for PostgreSQL + Grafana with data verification.

## 📁 Contents

- **`start-universal-db.sh`** - Main startup script
- **`stop-universal-db.sh`** - Safe shutdown script  
- **`QUICK-START.md`** - Usage guide

## 🚀 Usage

```bash
# Start system
./start-universal-db.sh

# Stop system  
./stop-universal-db.sh

# Start with browser launch
./start-universal-db.sh --open
```

## 🔄 What It Does

1. **Starts Containers**: PostgreSQL (`mypg`) + Grafana (`grafana`)
2. **Waits for Services**: Ensures both are ready for connections
3. **Verifies Data**: Checks call_records table and count
4. **Provides Status**: Complete system information

## 🎯 System Info

- **PostgreSQL**: localhost:5433 (myuser/mypass/mydb)
- **Grafana**: http://localhost:3000 (admin/admin)
- **Data**: 24,842 call records ready
- **SQL Queries**: ../Copilot/chatgpt-postgres-grafana-app/queries-by-type/

## 🛠️ Troubleshooting

```bash
# Check containers
docker ps -a

# Manual restart
docker restart mypg grafana

# Check logs
docker logs mypg
docker logs grafana
```

## ✅ Features

- **Simple**: One command startup
- **Reliable**: Service health verification
- **Fast**: Optimized for existing containers
- **Informative**: Clear status reporting

---
🚀 **Zero-configuration startup for Universal DB!**
