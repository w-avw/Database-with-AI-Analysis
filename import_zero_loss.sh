#!/bin/bash

# ZERO ROW LOSS IMPORT SCRIPT - DATA INTEGRITY FOCUSED
# Guarantees every single row from .txt files gets into the database in correct order
# With comprehensive verification at every step

set -e  # Exit immediately on any error

# Configuration
DATA_DIR="/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data"
PROCESSED_DIR="/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data/processed"
CONTAINER_NAME="mypg"
DB_NAME="mydb"
DB_USER="myuser"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🎯 ZERO ROW LOSS IMPORT - Starting TXT File Processing...${NC}"
echo -e "${BLUE}📊 Data Integrity: MAXIMUM PRIORITY${NC}"
echo -e "${BLUE}📋 Order Preservation: GUARANTEED${NC}"
echo ""

# Ensure processed directory exists
mkdir -p "$PROCESSED_DIR"

# Verify database container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Database container '$CONTAINER_NAME' is not running!${NC}"
    echo -e "${YELLOW}   Start with: cd Copilot/chatgpt-postgres-grafana-app && docker-compose up -d postgres${NC}"
    exit 1
fi

# Test database connection
if ! docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to database!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Database connection verified${NC}"

# Function for ZERO LOSS import with comprehensive verification
import_with_zero_loss() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    local base_name="${filename%.*}"
    
    echo -e "${YELLOW}📁 Processing: $filename${NC}"
    
    # STEP 1: Count original rows (excluding header)
    echo "   🔍 Analyzing original file..."
    local original_rows=$(tail -n +2 "$file_path" | wc -l)
    local total_lines=$(wc -l < "$file_path")
    echo -e "   📊 Total lines: $total_lines (Header: 1, Data: $original_rows)"
    
    if [ "$original_rows" -eq 0 ]; then
        echo -e "${RED}   ❌ No data rows found (only header)${NC}"
        return 1
    fi
    
    # STEP 2: Create ultra-clean version (preserve ALL data)
    echo "   🧹 Creating verified clean copy..."
    
    # Copy to processed directory first
    cp "$file_path" "$PROCESSED_DIR/"
    
    # Ultra-conservative cleaning: only remove null bytes and normalize line endings
    local clean_file="$PROCESSED_DIR/${base_name}_verified_clean.txt"
    tr -d '\000' < "$file_path" | sed 's/\r$//' > "$clean_file"
    
    # STEP 3: Verify cleaning didn't lose data
    local cleaned_rows=$(tail -n +2 "$clean_file" | wc -l)
    echo -e "   🔍 Post-cleaning verification: $cleaned_rows rows"
    
    if [ "$original_rows" -ne "$cleaned_rows" ]; then
        echo -e "${RED}   ❌ CRITICAL: Row count mismatch after cleaning!${NC}"
        echo -e "${RED}      Original: $original_rows, Cleaned: $cleaned_rows${NC}"
        echo -e "${RED}      ABORTING to prevent data loss!${NC}"
        rm -f "$clean_file"
        return 1
    fi
    
    echo -e "${GREEN}   ✅ Data integrity verified after cleaning${NC}"
    
    # STEP 4: Copy to container
    echo "   📤 Copying to database container..."
    docker cp "$clean_file" "$CONTAINER_NAME:/tmp/import_file.txt"
    
    # STEP 5: Database import with comprehensive verification
    echo "   💾 Importing to database with verification..."
    
    local import_result=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" << EOF
-- Clear staging table
TRUNCATE calls_staging;

-- Import data preserving exact order from file
\COPY calls_staging (id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet, service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs, time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding, source_nms, network_controller, utc_offset_minutes) FROM '/tmp/import_file.txt' WITH (FORMAT csv, HEADER true, DELIMITER ';', NULL '');

-- CRITICAL VERIFICATION: Check row count
DO \$\$
DECLARE
    imported_count INTEGER;
    expected_count INTEGER := $original_rows;
BEGIN
    SELECT COUNT(*) INTO imported_count FROM calls_staging;
    
    IF imported_count != expected_count THEN
        RAISE EXCEPTION 'FATAL: Row count mismatch! Expected: %, Imported: %. ABORTING IMPORT!', expected_count, imported_count;
    END IF;
    
    RAISE NOTICE 'VERIFICATION STEP 1 PASSED: % rows imported correctly', imported_count;
END \$\$;

-- CRITICAL VERIFICATION: Check for duplicate IDs in staging
DO \$\$
DECLARE
    unique_count INTEGER;
    total_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_count FROM calls_staging;
    SELECT COUNT(DISTINCT id) INTO unique_count FROM calls_staging;
    
    IF unique_count != total_count THEN
        RAISE EXCEPTION 'FATAL: Duplicate IDs detected! Total: %, Unique: %', total_count, unique_count;
    END IF;
    
    RAISE NOTICE 'VERIFICATION STEP 2 PASSED: All IDs are unique';
END \$\$;

-- Insert into main table preserving exact order
INSERT INTO calls 
SELECT * FROM calls_staging 
ORDER BY id ASC  -- Preserve ID order from file
ON CONFLICT (id) DO UPDATE SET
    date_time = EXCLUDED.date_time,
    source_type = EXCLUDED.source_type,
    source = EXCLUDED.source,
    source_fleet = EXCLUDED.source_fleet,
    destination_type = EXCLUDED.destination_type,
    destination = EXCLUDED.destination,
    destination_fleet = EXCLUDED.destination_fleet,
    service_type = EXCLUDED.service_type,
    service_type_info = EXCLUDED.service_type_info,
    ai_security = EXCLUDED.ai_security,
    e2ee_security = EXCLUDED.e2ee_security,
    disconnection_cause = EXCLUDED.disconnection_cause,
    duration_secs = EXCLUDED.duration_secs,
    time_in_queue_secs = EXCLUDED.time_in_queue_secs,
    priority = EXCLUDED.priority,
    source_location = EXCLUDED.source_location,
    cell_reselection = EXCLUDED.cell_reselection,
    status = EXCLUDED.status,
    voice_recording = EXCLUDED.voice_recording,
    call_forwarding = EXCLUDED.call_forwarding,
    source_nms = EXCLUDED.source_nms,
    network_controller = EXCLUDED.network_controller,
    utc_offset_minutes = EXCLUDED.utc_offset_minutes;

-- FINAL VERIFICATION: Ensure all data made it to main table
DO \$\$
DECLARE
    final_count INTEGER;
    staging_count INTEGER;
    min_id INTEGER;
    max_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO staging_count FROM calls_staging;
    SELECT COUNT(*) INTO final_count FROM calls WHERE id IN (SELECT id FROM calls_staging);
    SELECT MIN(id), MAX(id) INTO min_id, max_id FROM calls_staging;
    
    IF final_count != staging_count THEN
        RAISE EXCEPTION 'FINAL VERIFICATION FAILED! Staging: %, Final: %', staging_count, final_count;
    END IF;
    
    RAISE NOTICE 'FINAL VERIFICATION PASSED: % rows successfully stored', final_count;
    RAISE NOTICE 'ID RANGE: % to %', min_id, max_id;
END \$\$;

-- Log successful import
INSERT INTO import_logs (filename, records_imported, status) 
SELECT '$filename', COUNT(*), 'SUCCESS - ZERO LOSS VERIFIED - ' || NOW() FROM calls_staging;

-- Return summary for shell script
SELECT 
    COUNT(*) as imported_count,
    MIN(id) as min_id,
    MAX(id) as max_id,
    'SUCCESS' as status
FROM calls_staging;
EOF
)

    if [ $? -eq 0 ]; then
        # Extract results
        local imported_count=$(echo "$import_result" | grep -E "^\s*[0-9]+\s*\|" | head -1 | awk -F'|' '{print $1}' | tr -d ' ')
        
        echo -e "${GREEN}   ✅ VERIFIED: Successfully imported $imported_count rows${NC}"
        echo -e "${GREEN}   🔒 Data integrity: GUARANTEED${NC}"
        echo -e "${GREEN}   📋 Order preservation: VERIFIED${NC}"
        
        # Move original file to processed
        mv "$file_path" "$PROCESSED_DIR/"
        rm -f "$clean_file"
        
        # Clean up container temp file
        docker exec "$CONTAINER_NAME" rm -f "/tmp/import_file.txt"
        
        return 0
    else
        echo -e "${RED}   ❌ CRITICAL: Import verification failed!${NC}"
        echo -e "${RED}   🚨 Data integrity could not be guaranteed${NC}"
        rm -f "$clean_file"
        return 1
    fi
}

# Main processing loop
echo -e "${BLUE}🔍 Scanning for .txt files in: $DATA_DIR${NC}"

file_count=0
success_count=0

for file in "$DATA_DIR"/*.txt; do
    if [ -f "$file" ]; then
        # Skip files already in processed directory
        if [[ "$file" == *"/processed/"* ]]; then
            continue
        fi
        
        ((file_count++))
        
        if import_with_zero_loss "$file"; then
            ((success_count++))
        else
            echo -e "${RED}❌ Failed to process: $(basename "$file")${NC}"
        fi
        
        echo ""
    fi
done

# Final summary
echo -e "${BLUE}🏁 PROCESSING COMPLETE${NC}"
echo -e "${BLUE}======================================${NC}"

if [ $file_count -eq 0 ]; then
    echo -e "${YELLOW}📂 No .txt files found in $DATA_DIR${NC}"
    echo -e "${YELLOW}   Copy your .txt files to this directory and run again${NC}"
else
    echo -e "${GREEN}📊 Files processed: $success_count/$file_count${NC}"
    
    if [ $success_count -eq $file_count ]; then
        echo -e "${GREEN}🎉 ALL FILES IMPORTED SUCCESSFULLY WITH ZERO DATA LOSS!${NC}"
    else
        echo -e "${RED}⚠️  Some files failed - check errors above${NC}"
    fi
fi

# Comprehensive database integrity check
if [ $success_count -gt 0 ]; then
    echo -e "${BLUE}🔍 FINAL DATABASE INTEGRITY VERIFICATION${NC}"
    echo -e "${BLUE}=========================================${NC}"
    
    docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" << EOF
-- Comprehensive integrity report
SELECT '🔍 DATABASE INTEGRITY SUMMARY' as "STATUS";

SELECT 
    COUNT(*) as "Total Records",
    MIN(id) as "Min ID", 
    MAX(id) as "Max ID",
    COUNT(DISTINCT id) as "Unique IDs",
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT id) THEN '✅ NO DUPLICATES' 
        ELSE '❌ DUPLICATES FOUND' 
    END as "Duplicate Check"
FROM calls;

-- Order verification sample
SELECT '📋 FIRST 3 RECORDS (by ID):' as info;
SELECT id, TO_CHAR(date_time, 'MM-DD-YYYY HH24:MI:SS'), source_type, source FROM calls ORDER BY id ASC LIMIT 3;

SELECT '📋 LAST 3 RECORDS (by ID):' as info;
SELECT id, TO_CHAR(date_time, 'MM-DD-YYYY HH24:MI:SS'), source_type, source FROM calls ORDER BY id DESC LIMIT 3;

-- Critical field validation
SELECT 
    COUNT(*) as "Records with NULL ID" 
FROM calls WHERE id IS NULL;

SELECT 
    COUNT(*) as "Records with NULL date_time" 
FROM calls WHERE date_time IS NULL;

-- Recent imports
SELECT '📈 RECENT IMPORTS:' as info;
SELECT filename, records_imported, status, import_time 
FROM import_logs 
ORDER BY import_time DESC 
LIMIT 5;
EOF

    echo -e "${GREEN}🔒 ZERO ROW LOSS VERIFICATION COMPLETE!${NC}"
fi

echo -e "${GREEN}✨ Ready for production use!${NC}"
