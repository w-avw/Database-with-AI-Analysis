#!/bin/bash
# Quick Data Viewer - Universal DB
# Simple script to view and query your data

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINER="mypg"
DB_USER="myuser"
DB_NAME="mydb"

echo -e "${BLUE}🔍 Universal DB - Data Viewer${NC}"
echo "============================"

if ! docker ps | grep -q "$CONTAINER"; then
    echo -e "${RED}❌ Database container is not running${NC}"
    exit 1
fi

while true; do
    echo -e "\n${YELLOW}Choose an option:${NC}"
    echo "1. View latest 10 records"
    echo "2. Search by source"
    echo "3. Records count by hour"
    echo "4. Custom SQL query"
    echo "5. Export to CSV"
    echo "6. Exit"
    
    read -p "Enter choice (1-6): " choice
    
    case $choice in
        1)
            echo -e "\n${YELLOW}📋 Latest 10 Records:${NC}"
            docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT id, date_time, source, destination, duration_secs FROM calls ORDER BY date_time DESC LIMIT 10;"
            ;;
        2)
            read -p "Enter source to search for: " source
            echo -e "\n${YELLOW}🔍 Records for source: $source${NC}"
            docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT id, date_time, source, destination, duration_secs FROM calls WHERE source ILIKE '%$source%' ORDER BY date_time DESC LIMIT 20;"
            ;;
        3)
            echo -e "\n${YELLOW}📊 Records count by hour:${NC}"
            docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT DATE_TRUNC('hour', date_time) as hour, COUNT(*) as count FROM calls GROUP BY hour ORDER BY hour DESC LIMIT 24;"
            ;;
        4)
            read -p "Enter SQL query: " query
            echo -e "\n${YELLOW}🗃️  Query result:${NC}"
            docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "$query"
            ;;
        5)
            echo -e "\n${YELLOW}📁 Exporting to CSV...${NC}"
            docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "COPY calls TO '/tmp/export.csv' DELIMITER ',' CSV HEADER;"
            docker cp "$CONTAINER:/tmp/export.csv" "./universal_db_export.csv"
            echo -e "${GREEN}✅ Exported to universal_db_export.csv${NC}"
            ;;
        6)
            echo -e "${GREEN}👋 Goodbye!${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac
done
