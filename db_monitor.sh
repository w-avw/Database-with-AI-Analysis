#!/bin/bash
# Database Monitor Script - Universal DB
# Quick database status and monitoring

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINER="mypg"
DB_USER="myuser"
DB_NAME="mydb"

echo -e "${BLUE}📊 Universal DB - Database Monitor${NC}"
echo "=================================="

# Check container status
if docker ps | grep -q "$CONTAINER"; then
    echo -e "${GREEN}✅ Database container is running${NC}"
    
    # Get database stats
    echo -e "\n${YELLOW}📈 Database Statistics:${NC}"
    
    total_records=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM calls;" | tr -d ' ')
    echo "Total records: $total_records"
    
    if [ "$total_records" -gt 0 ]; then
        # Latest record
        latest_date=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT MAX(date_time) FROM calls;" | tr -d ' ')
        echo "Latest record: $latest_date"
        
        # Records by source type
        echo -e "\n${YELLOW}📋 Records by Source Type:${NC}"
        docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT source_type, COUNT(*) as count FROM calls GROUP BY source_type ORDER BY count DESC LIMIT 5;"
        
        # Recent activity (last 10 records)
        echo -e "\n${YELLOW}🕐 Recent Records:${NC}"
        docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT id, date_time, source, destination FROM calls ORDER BY date_time DESC LIMIT 10;"
    else
        echo -e "${YELLOW}⚠️  No data in database yet${NC}"
    fi
    
    # Database size
    echo -e "\n${YELLOW}💾 Database Size:${NC}"
    docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME')) as database_size;"
    
else
    echo -e "${RED}❌ Database container is not running${NC}"
    echo "Start it with: cd Copilot/chatgpt-postgres-grafana-app && docker-compose up -d"
fi
