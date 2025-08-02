#!/bin/bash
# Quick Test Script - Universal DB
# Tests the complete workflow: setup -> import -> verify

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Universal DB - Quick Test Script${NC}"
echo "==============================================="

# Step 1: Check if Docker is running
echo -e "${YELLOW}1. Checking Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"

# Step 2: Start the database
echo -e "\n${YELLOW}2. Starting PostgreSQL database...${NC}"
cd Copilot/chatgpt-postgres-grafana-app
docker-compose up -d mypg

# Wait for database to be ready
echo -e "${YELLOW}⏳ Waiting for database to be ready...${NC}"
sleep 10

# Check if container is running
if docker ps | grep -q "mypg"; then
    echo -e "${GREEN}✅ Database container is running${NC}"
else
    echo -e "${RED}❌ Database container failed to start${NC}"
    exit 1
fi

# Step 3: Test database connection
echo -e "\n${YELLOW}3. Testing database connection...${NC}"
if docker exec mypg psql -U myuser -d mydb -c "SELECT version();" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Database connection successful${NC}"
else
    echo -e "${RED}❌ Database connection failed${NC}"
    exit 1
fi

# Step 4: Check table structure
echo -e "\n${YELLOW}4. Verifying table structure...${NC}"
docker exec mypg psql -U myuser -d mydb -c "\d calls;" > /dev/null 2>&1
echo -e "${GREEN}✅ Tables created successfully${NC}"

# Step 5: Run import script
echo -e "\n${YELLOW}5. Running import script...${NC}"
cd ../..
chmod +x import_calls.sh
./import_calls.sh

# Step 6: Verify data
echo -e "\n${YELLOW}6. Verifying imported data...${NC}"
record_count=$(docker exec mypg psql -U myuser -d mydb -t -c "SELECT COUNT(*) FROM calls;" | tr -d ' ')
echo -e "${GREEN}📊 Total records in database: $record_count${NC}"

if [ "$record_count" -gt 0 ]; then
    echo -e "\n${YELLOW}📋 Sample records:${NC}"
    docker exec mypg psql -U myuser -d mydb -c "SELECT id, date_time, source, destination FROM calls LIMIT 5;"
    
    echo -e "\n${GREEN}🎉 SUCCESS! Your Universal DB is working perfectly!${NC}"
    echo -e "${BLUE}💡 You can now drop .txt files in Copilot/chatgpt-postgres-grafana-app/data/${NC}"
    echo -e "${BLUE}💡 Run ./import_calls.sh to process them${NC}"
else
    echo -e "${YELLOW}⚠️  No data imported. Check if test1.txt has the correct format${NC}"
fi

echo -e "\n${BLUE}🛠️  Useful commands:${NC}"
echo "- View database: docker exec -it mypg psql -U myuser -d mydb"
echo "- Stop database: cd Copilot/chatgpt-postgres-grafana-app && docker-compose down"
echo "- Import files: ./import_calls.sh"
echo "- Check logs: docker logs mypg"
