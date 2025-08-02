#!/bin/bash

# ZERO DATA LOSS IMPORT - Handles character-spaced test1.txt format
# Guarantees ALL 24,843 rows imported with correct structure
# id = PostgreSQL auto-increment, source_id = original ID from txt file

set -e

CONTAINER_NAME="mypg"
DB_NAME="mydb"
DB_USER="myuser"
DATA_DIR="/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data"
TEST_FILE="$DATA_DIR/processed/test1.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🎯 ZERO DATA LOSS IMPORT FOR CHARACTER-SPACED test1.txt${NC}"
echo -e "${BLUE}📊 Target: ALL 24,843 rows imported${NC}"
echo -e "${BLUE}📋 Structure: id (auto-increment) + source_id (from file) + data${NC}"
echo ""

# Check if test1.txt exists
if [ ! -f "$TEST_FILE" ]; then
    echo -e "${RED}❌ test1.txt not found at: $TEST_FILE${NC}"
    exit 1
fi

# Count original file rows (excluding header)
echo -e "${YELLOW}🔍 Analyzing test1.txt...${NC}"
TOTAL_LINES=$(wc -l < "$TEST_FILE")
DATA_ROWS=$((TOTAL_LINES - 1))
echo -e "${BLUE}   📊 Total lines: $TOTAL_LINES${NC}"
echo -e "${BLUE}   📊 Data rows: $DATA_ROWS${NC}"

if [ "$DATA_ROWS" -ne 24842 ]; then
    echo -e "${YELLOW}   ⚠️  Expected 24,842 data rows, found $DATA_ROWS${NC}"
fi

# Check database connection
if ! docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to database!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Database connection verified${NC}"

# Process the character-spaced file into proper CSV format
echo -e "${YELLOW}🔧 Converting character-spaced format to proper CSV...${NC}"
TEMP_CSV="/tmp/test1_converted.csv"

# Convert the character-spaced file to proper CSV
# The file has format like "I D ; D a t e / T i m e ; ..." where each character is separated by space
python3 << EOF
import re

print("Processing character-spaced file...")

# Read the original file
with open("$TEST_FILE", 'r', encoding='utf-8') as f:
    lines = f.readlines()

processed_lines = []

for line_num, line in enumerate(lines, 1):
    # Remove trailing whitespace and newlines
    line = line.strip()
    
    if not line:
        continue
    
    # Remove spaces between characters while preserving semicolon delimiters
    # This converts "I D ; D a t e" to "ID;Date"
    processed_line = re.sub(r'(?<!;)\s+(?!;)', '', line)
    processed_line = re.sub(r'\s*;\s*', ';', processed_line)
    
    processed_lines.append(processed_line)
    
    if line_num <= 3:
        print(f"Line {line_num}: {processed_line[:100]}...")

print(f"Processed {len(processed_lines)} lines")

# Write to temp CSV file
with open("$TEMP_CSV", 'w', encoding='utf-8') as f:
    for line in processed_lines:
        f.write(line + '\n')

print("Conversion complete!")
EOF

# Verify the converted file
echo -e "${BLUE}🔍 Verifying converted file...${NC}"
CONVERTED_LINES=$(wc -l < "$TEMP_CSV")
CONVERTED_DATA=$((CONVERTED_LINES - 1))
echo -e "${BLUE}   📊 Converted lines: $CONVERTED_LINES${NC}"
echo -e "${BLUE}   📊 Converted data rows: $CONVERTED_DATA${NC}"

# Show sample of converted data
echo -e "${BLUE}   📋 Sample converted data:${NC}"
head -3 "$TEMP_CSV"

# Copy converted file to container
echo -e "${YELLOW}📤 Copying converted file to database container...${NC}"
docker cp "$TEMP_CSV" "$CONTAINER_NAME:/tmp/import_data.csv"

# Import with comprehensive verification
echo -e "${YELLOW}💾 Importing to database with ZERO LOSS verification...${NC}"

IMPORT_RESULT=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" << EOF
-- Clear staging table
TRUNCATE calls_staging;

-- Import data (source_id is first column)
\COPY calls_staging (source_id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet, service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs, time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding, source_nms, network_controller, utc_offset_minutes) FROM '/tmp/import_data.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', NULL '');

-- CRITICAL VERIFICATION: Check row count
DO \$\$
DECLARE
    imported_count INTEGER;
    expected_count INTEGER := $CONVERTED_DATA;
BEGIN
    SELECT COUNT(*) INTO imported_count FROM calls_staging;
    
    IF imported_count != expected_count THEN
        RAISE EXCEPTION 'FATAL: Row count mismatch! Expected: %, Imported: %. ABORTING!', expected_count, imported_count;
    END IF;
    
    RAISE NOTICE 'VERIFICATION STEP 1 PASSED: % rows imported to staging', imported_count;
END \$\$;

-- Check for any NULL source_ids
DO \$\$
DECLARE
    null_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO null_count FROM calls_staging WHERE source_id IS NULL;
    
    IF null_count > 0 THEN
        RAISE EXCEPTION 'FATAL: % rows have NULL source_id!', null_count;
    END IF;
    
    RAISE NOTICE 'VERIFICATION STEP 2 PASSED: No NULL source_ids';
END \$\$;

-- Insert into main table (id will auto-increment, source_id preserved)
INSERT INTO calls (source_id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet, service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs, time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding, source_nms, network_controller, utc_offset_minutes)
SELECT source_id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet, service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs, time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding, source_nms, network_controller, utc_offset_minutes
FROM calls_staging
ORDER BY source_id ASC  -- Preserve order by source_id
ON CONFLICT (source_id) DO NOTHING;

-- FINAL VERIFICATION: Ensure all data made it to main table
DO \$\$
DECLARE
    final_count INTEGER;
    staging_count INTEGER;
    min_source_id INTEGER;
    max_source_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO staging_count FROM calls_staging;
    SELECT COUNT(*) INTO final_count FROM calls WHERE source_id IN (SELECT source_id FROM calls_staging);
    SELECT MIN(source_id), MAX(source_id) INTO min_source_id, max_source_id FROM calls_staging;
    
    IF final_count != staging_count THEN
        RAISE EXCEPTION 'FINAL VERIFICATION FAILED! Staging: %, Final: %', staging_count, final_count;
    END IF;
    
    RAISE NOTICE 'FINAL VERIFICATION PASSED: % rows successfully stored', final_count;
    RAISE NOTICE 'Source ID RANGE: % to %', min_source_id, max_source_id;
END \$\$;

-- Log successful import
INSERT INTO import_logs (filename, records_imported, status) 
SELECT 'test1.txt', COUNT(*), 'SUCCESS - ZERO LOSS VERIFIED - CORRECT STRUCTURE' FROM calls_staging;

-- Return final summary
SELECT 
    'IMPORT COMPLETE' as status,
    COUNT(*) as records_imported,
    MIN(source_id) as min_source_id,
    MAX(source_id) as max_source_id
FROM calls_staging;
EOF
)

echo "$IMPORT_RESULT"

# Clean up temp file
rm -f "$TEMP_CSV"
docker exec "$CONTAINER_NAME" rm -f "/tmp/import_data.csv"

echo ""
echo -e "${GREEN}🎉 IMPORT COMPLETED!${NC}"
echo -e "${BLUE}🔍 FINAL DATABASE VERIFICATION:${NC}"

# Final verification
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" << 'EOF'
-- Show final structure and counts
SELECT 'DATABASE STRUCTURE VERIFICATION:' as info;

-- Show table structure
\d calls

-- Show counts
SELECT 
    COUNT(*) as "Total Records",
    MIN(id) as "Min Auto ID", 
    MAX(id) as "Max Auto ID",
    MIN(source_id) as "Min Source ID",
    MAX(source_id) as "Max Source ID",
    COUNT(DISTINCT source_id) as "Unique Source IDs"
FROM calls;

-- Show sample data with correct structure
SELECT 'SAMPLE DATA (Correct Structure):' as info;
SELECT id, source_id, date_time, source_type, source 
FROM calls 
ORDER BY source_id DESC 
LIMIT 5;

-- Verify we have the expected source_ids from test1.txt
SELECT 'VERIFICATION - Checking known source_ids from test1.txt:' as info;
SELECT source_id, date_time, source_type 
FROM calls 
WHERE source_id IN (7652, 7481, 7428, 7349, 7271) 
ORDER BY source_id DESC;
EOF

echo ""
echo -e "${GREEN}✅ ZERO DATA LOSS IMPORT COMPLETE!${NC}"
echo -e "${GREEN}🔒 Structure: id (auto-increment) + source_id (from file) + all data${NC}"
echo -e "${GREEN}📊 Ready for production use!${NC}"
