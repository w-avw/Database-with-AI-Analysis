#!/bin/bash
# 🚀 UNIVERSAL DB - SYSTEM STARTUP
# Single command to start PostgreSQL + Grafana with complete verification

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# System configuration (based on working containers)
POSTGRES_CONTAINER="universal-db-postgres"
GRAFANA_CONTAINER="universal-db-grafana"
DB_USER="myuser"
DB_NAME="mydb"

echo -e "${BOLD}${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "                    🚀 UNIVERSAL DB - SYSTEM STARTUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
echo -e "${BLUE}Starting PostgreSQL + Grafana for Universal DB${NC}"
echo -e "${BLUE}Date: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo ""

# Simple print functions
print_step() { echo -e "${YELLOW}🔄 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

COMPOSE_DIR="../Layer-1-Infrastructure"
# Step 1: Start containers
print_step "Starting Universal DB Services"
echo ""

# Check if containers exist, create if missing
if ! docker ps -a --format '{{.Names}}' | grep -q "^$POSTGRES_CONTAINER$"; then
    print_info "PostgreSQL container not found. Creating containers with docker-compose..."
    (cd "$COMPOSE_DIR" && docker-compose up -d)
fi

if ! docker ps -a --format '{{.Names}}' | grep -q "^$GRAFANA_CONTAINER$"; then
    print_info "Grafana container not found. Creating containers with docker-compose..."
    (cd "$COMPOSE_DIR" && docker-compose up -d)
fi

# Start PostgreSQL
print_info "Starting PostgreSQL database..."
if docker start $POSTGRES_CONTAINER > /dev/null 2>&1; then
    print_success "PostgreSQL container started"
else
    print_error "Failed to start PostgreSQL container"
    print_info "Container may not exist. Check with: docker ps -a"
    exit 1
fi

# Start Grafana
print_info "Starting Grafana analytics..."
if docker start $GRAFANA_CONTAINER > /dev/null 2>&1; then
    print_success "Grafana container started"
else
    print_error "Failed to start Grafana container"
    print_info "Container may not exist. Check with: docker ps -a"
    exit 1
fi


# Step 2: Wait for services
print_step "Waiting for Services to Initialize"
echo ""

# Wait for PostgreSQL
print_info "Waiting for PostgreSQL to accept connections..."
for i in {1..30}; do
    if docker exec $POSTGRES_CONTAINER pg_isready -U $DB_USER > /dev/null 2>&1; then
        print_success "PostgreSQL ready and accepting connections"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "PostgreSQL failed to start within 30 seconds"
        exit 1
    fi
    sleep 1
done

# Wait for Grafana
print_info "Waiting for Grafana web interface..."
sleep 5
for i in {1..30}; do
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "Grafana web interface ready"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "Grafana failed to start within 30 seconds"
        exit 1
    fi
    sleep 1
done

echo ""

# Step 3: Verify data
print_step "Verifying Database and Data"
echo ""

# Check data
RECORD_COUNT=$(docker exec $POSTGRES_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM call_records;" 2>/dev/null | tr -d ' ' || echo "0")

if [ "$RECORD_COUNT" -gt 0 ]; then
    print_success "Database contains $RECORD_COUNT call records"
else
    print_error "No data found in call_records table"
    print_info "Import data using: cd ../Layer-3-Core-Import-Engine && python3 simple_import.py"
fi

echo ""

# Final status report
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}                        📊 SYSTEM READY${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}🎯 ACCESS INFORMATION:${NC}"
echo -e "   🌐 Grafana: ${GREEN}http://localhost:3000${NC}"
echo -e "   🔑 Login: ${YELLOW}admin/admin${NC}"
echo -e "   🗄️  Database Host: ${GREEN}universal-db-postgres:5432${NC} (myuser/mypass/mydb)"
echo -e "   📊 Records: ${GREEN}$RECORD_COUNT call records${NC}"
echo ""
echo -e "${BOLD}� RESOURCES:${NC}"
echo -e "   🔍 SQL Queries: ../Copilot/chatgpt-postgres-grafana-app/queries-by-type/"
echo -e "   💾 Backups: ../backups/"
echo ""
echo -e "${GREEN}🚀 Universal DB is ready for data analysis!${NC}"
echo ""

# Optional browser launch
if [ "${1:-}" = "--open" ] || [ "${1:-}" = "-o" ]; then
    if command -v "$BROWSER" &> /dev/null; then
        print_info "Opening Grafana in browser..."
        "$BROWSER" "http://localhost:3000" 2>/dev/null &
    fi
fi
