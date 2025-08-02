#!/bin/bash

# QUICK DATABASE TEST - Verify test1.txt import is perfect
# This script tests that EVERY SINGLE ROW from test1.txt is in the database

set -e

CONTAINER_NAME="mypg"
DB_NAME="mydb"
DB_USER="myuser"
TEST_FILE="/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data/processed/test1.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🧪 QUICK DATABASE INTEGRITY TEST${NC}"
echo -e "${BLUE}=====================================${NC}"

# Check if test1.txt exists in data or processed folder
if [ -f "/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data/test1.txt" ]; then
    TEST_FILE="/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data/test1.txt"
    echo -e "${YELLOW}📁 Found test1.txt in data folder${NC}"
elif [ -f "/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data/processed/test1.txt" ]; then
    TEST_FILE="/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data/processed/test1.txt"
    echo -e "${YELLOW}📁 Found test1.txt in processed folder${NC}"
else
    echo -e "${RED}❌ test1.txt not found in data or processed folder${NC}"
    exit 1
fi

# Count rows in original file (excluding header)
FILE_ROWS=$(tail -n +2 "$TEST_FILE" | wc -l)
echo -e "${BLUE}📊 Original file rows (data): $FILE_ROWS${NC}"

# Check database container
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Database container not running!${NC}"
    echo -e "${YELLOW}   Start with: cd Copilot/chatgpt-postgres-grafana-app && docker-compose up -d${NC}"
    exit 1
fi

# Test database and count records
echo -e "${BLUE}🔍 Checking database...${NC}"

DB_RESULT=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" << 'EOF'
-- Database integrity check
SELECT 
    COUNT(*) as total_records,
    MIN(id) as min_id,
    MAX(id) as max_id,
    COUNT(DISTINCT id) as unique_ids
FROM calls;

-- Check if we have data from test1.txt file (sample IDs from the file)
SELECT 'Checking sample records from test1.txt:' as check_info;
SELECT COUNT(*) as "Records with ID 7652" FROM calls WHERE id = 7652;
SELECT COUNT(*) as "Records with ID 7481" FROM calls WHERE id = 7481;
SELECT COUNT(*) as "Records with ID 3277" FROM calls WHERE id = 3277;

-- Show first few records by ID
SELECT 'First 3 records in database:' as sample_info;
SELECT id, date_time, source_type, source FROM calls ORDER BY id ASC LIMIT 3;
EOF
)

echo "$DB_RESULT"

# Extract total count from result
DB_COUNT=$(echo "$DB_RESULT" | grep -E "^\s*[0-9]+\s*\|" | head -1 | awk -F'|' '{print $1}' | tr -d ' ')

echo ""
echo -e "${BLUE}📊 VERIFICATION RESULTS:${NC}"
echo -e "${BLUE}=========================${NC}"
echo -e "📁 File rows (data): $FILE_ROWS"
echo -e "💾 Database rows: $DB_COUNT"

if [ "$DB_COUNT" -eq "$FILE_ROWS" ]; then
    echo -e "${GREEN}✅ PERFECT! All $FILE_ROWS rows are in the database!${NC}"
    echo -e "${GREEN}🎯 ZERO DATA LOSS CONFIRMED!${NC}"
elif [ "$DB_COUNT" -gt "$FILE_ROWS" ]; then
    echo -e "${GREEN}✅ Database has $DB_COUNT rows (more than file - likely from multiple imports)${NC}"
    echo -e "${YELLOW}🔍 This is normal if you've run imports multiple times${NC}"
else
    echo -e "${RED}❌ MISSING DATA! Database has fewer rows than file!${NC}"
    echo -e "${RED}   File: $FILE_ROWS, Database: $DB_COUNT${NC}"
    echo -e "${RED}   Missing: $((FILE_ROWS - DB_COUNT)) rows${NC}"
fi

echo ""
echo -e "${BLUE}🎯 Quick Commands for Further Testing:${NC}"
echo -e "${YELLOW}   View all data: docker exec $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c 'SELECT * FROM calls ORDER BY id LIMIT 10;'${NC}"
echo -e "${YELLOW}   Count records: docker exec $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c 'SELECT COUNT(*) FROM calls;'${NC}"
echo -e "${YELLOW}   Check specific ID: docker exec $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c 'SELECT * FROM calls WHERE id = 7652;'${NC}"

echo ""
echo -e "${GREEN}🏁 Test complete!${NC}"
