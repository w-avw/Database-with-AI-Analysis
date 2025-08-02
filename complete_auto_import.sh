#!/bin/bash
# Universal DB - Complete Auto Import Script
# Imports ALL data from semicolon-separated .txt files automatically

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

CONTAINER="mypg"
DB_USER="myuser"
DB_NAME="mydb"
DATA_DIR="/workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/data"

echo -e "${BLUE}🚀 Universal DB - Complete Auto Import${NC}"
echo "======================================"

# Check if container is running
if ! docker ps | grep -q "$CONTAINER"; then
    echo -e "${RED}❌ Database container is not running${NC}"
    echo -e "${YELLOW}Starting database...${NC}"
    cd /workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app && docker-compose up -d
    sleep 5
fi

# Function to import a single file
import_file() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    
    echo -e "${YELLOW}📂 Processing: $filename${NC}"
    
    # Check file encoding and convert if needed
    file_encoding=$(file -b --mime-encoding "$file_path")
    echo -e "${YELLOW}🔍 File encoding: $file_encoding${NC}"
    
    # Always try to convert from UTF-16 since file detection might be incorrect
    echo -e "${YELLOW}🔧 Converting to UTF-8 and cleaning format...${NC}"
    
    # Try UTF-16LE first, then UTF-16BE if that fails
    if iconv -f UTF-16LE -t UTF-8 "$file_path" > "/tmp/converted_${filename}" 2>/dev/null; then
        echo -e "${GREEN}✅ Converted from UTF-16LE${NC}"
    elif iconv -f UTF-16BE -t UTF-8 "$file_path" > "/tmp/converted_${filename}" 2>/dev/null; then
        echo -e "${GREEN}✅ Converted from UTF-16BE${NC}"
    else
        echo -e "${YELLOW}⚠️  Using original file (might be UTF-8)${NC}"
        cp "$file_path" "/tmp/converted_${filename}"
    fi
    
    # Clean up spacing issues and format properly
    python3 -c "
import re
import sys

try:
    with open('/tmp/converted_${filename}', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    cleaned_lines = []
    for line in lines:
        line = line.strip()
        if not line:  # Skip empty lines
            continue
            
        # Remove extra spaces between characters (common in UTF-16 conversions)
        line = re.sub(r'([a-zA-Z0-9])\\s+([a-zA-Z0-9])', r'\\1\\2', line)
        line = re.sub(r'\\s+;\\s+', ';', line)
        line = re.sub(r'^\\s+', '', line)
        line = re.sub(r'\\s+$', '', line)
        
        # Fix date format if needed (e.g., '03-03-202511:59:36PM' -> '03-03-2025 11:59:36PM')
        line = re.sub(r';(\\d{2}-\\d{2}-\\d{4})(\\d{1,2}:\\d{2}:\\d{2})', r';\\1 \\2', line)
        
        cleaned_lines.append(line)
    
    with open('/tmp/cleaned_${filename}', 'w', encoding='utf-8') as f:
        for line in cleaned_lines:
            f.write(line + '\\n')
    
    print('File cleaned successfully')
except Exception as e:
    print(f'Error: {e}')
    sys.exit(1)
"
    
    working_file="/tmp/cleaned_${filename}"
    
    # Get file statistics
    total_lines=$(wc -l < "$working_file")
    data_lines=$((total_lines - 1))  # Exclude header
    
    echo -e "${YELLOW}📊 File Analysis:${NC}"
    echo "   📋 Total lines: $total_lines"
    echo "   📊 Data rows to import: $data_lines"
    
    # Show sample data
    echo -e "${YELLOW}📋 Sample Data (first 3 lines):${NC}"
    head -3 "$working_file"
    
    # Copy to container
    echo -e "${YELLOW}📤 Copying to database container...${NC}"
    docker cp "$working_file" "$CONTAINER:/tmp/import_data.csv"
    
    # Import to database with complete error handling
    echo -e "${YELLOW}💾 Importing ALL data to database...${NC}"
    
    import_result=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
        -- Clear staging table
        TRUNCATE TABLE calls_staging;
        
        -- Import from CSV with header handling
        COPY calls_staging (
            source_id, date_time, source_type, source, source_fleet, 
            destination_type, destination, destination_fleet, service_type, 
            service_type_info, ai_security, e2ee_security, disconnection_cause, 
            duration_secs, time_in_queue_secs, priority, source_location, 
            cell_reselection, status, voice_recording, call_forwarding, 
            source_nms, network_controller, utc_offset_minutes
        ) 
        FROM '/tmp/import_data.csv' 
        WITH (FORMAT CSV, DELIMITER ';', HEADER true);
        
        -- Get staging count
        SELECT 'STAGING_COUNT: ' || COUNT(*) FROM calls_staging;
    " 2>&1)
    
    echo "$import_result"
    
    # Extract staging count
    staging_count=$(echo "$import_result" | grep "STAGING_COUNT:" | cut -d':' -f2 | tr -d ' ')
    
    if [ -z "$staging_count" ] || [ "$staging_count" -eq 0 ]; then
        echo -e "${RED}❌ No data loaded to staging table${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Loaded $staging_count rows to staging${NC}"
    
    # Transfer from staging to main table
    echo -e "${YELLOW}🔄 Transferring to main calls table...${NC}"
    
    transfer_result=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
        -- Insert from staging to main table
        INSERT INTO calls (
            source_id, date_time, source_type, source, source_fleet, 
            destination_type, destination, destination_fleet, service_type, 
            service_type_info, ai_security, e2ee_security, disconnection_cause, 
            duration_secs, time_in_queue_secs, priority, source_location, 
            cell_reselection, status, voice_recording, call_forwarding, 
            source_nms, network_controller, utc_offset_minutes
        )
        SELECT 
            CASE WHEN source_id::text ~ '^[0-9]+$' THEN source_id::bigint ELSE NULL END,
            CASE 
                WHEN date_time ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}' THEN
                    TO_TIMESTAMP(date_time, 'DD-MM-YYYY HH12:MI:SS AM')
                ELSE NULL
            END,
            NULLIF(source_type, ''),
            NULLIF(source, ''),
            NULLIF(source_fleet, ''),
            NULLIF(destination_type, ''),
            NULLIF(destination, ''),
            NULLIF(destination_fleet, ''),
            NULLIF(service_type, ''),
            NULLIF(service_type_info, ''),
            NULLIF(ai_security, ''),
            NULLIF(e2ee_security, ''),
            NULLIF(disconnection_cause, ''),
            CASE WHEN duration_secs ~ '^[0-9]+$' THEN duration_secs::integer ELSE NULL END,
            CASE WHEN time_in_queue_secs ~ '^[0-9]+$' THEN time_in_queue_secs::integer ELSE NULL END,
            CASE WHEN priority ~ '^[0-9]+$' THEN priority::integer ELSE NULL END,
            NULLIF(source_location, ''),
            NULLIF(cell_reselection, ''),
            NULLIF(status, ''),
            NULLIF(voice_recording, ''),
            NULLIF(call_forwarding, ''),
            NULLIF(source_nms, ''),
            NULLIF(network_controller, ''),
            CASE WHEN utc_offset_minutes ~ '^-?[0-9]+$' THEN utc_offset_minutes::integer ELSE NULL END
        FROM calls_staging
        WHERE source_id IS NOT NULL 
          AND source_id != '' 
          AND source_id ~ '^[0-9]+$'
        ON CONFLICT (source_id) DO NOTHING;
        
        -- Get final count
        SELECT 'TOTAL_IMPORTED: ' || COUNT(*) FROM calls;
    " 2>&1)
    
    echo "$transfer_result"
    
    # Extract final count
    total_imported=$(echo "$transfer_result" | grep "TOTAL_IMPORTED:" | cut -d':' -f2 | tr -d ' ')
    
    echo -e "${GREEN}✅ Import completed!${NC}"
    echo -e "${GREEN}📊 Total records now in database: $total_imported${NC}"
    
    # Log the import
    docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
        INSERT INTO import_logs (filename, records_imported, status) 
        VALUES ('$filename', $total_imported, 'SUCCESS');
    " > /dev/null 2>&1
    
    # Cleanup temporary files
    if [[ "$file_encoding" == *"utf-16"* ]]; then
        rm -f "/tmp/converted_${filename}" "/tmp/cleaned_${filename}"
    fi
    
    return 0
}

# Main execution
echo -e "${YELLOW}🔍 Scanning for .txt files in $DATA_DIR${NC}"

if [ ! -d "$DATA_DIR" ]; then
    echo -e "${RED}❌ Data directory not found: $DATA_DIR${NC}"
    exit 1
fi

file_count=0
for file in "$DATA_DIR"/*.txt; do
    if [ -f "$file" ]; then
        import_file "$file"
        if [ $? -eq 0 ]; then
            ((file_count++))
            echo -e "${GREEN}✅ Successfully processed: $(basename "$file")${NC}"
        else
            echo -e "${RED}❌ Failed to process: $(basename "$file")${NC}"
        fi
        echo "----------------------------------------"
    fi
done

if [ $file_count -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No .txt files found in $DATA_DIR${NC}"
else
    echo -e "${GREEN}🎉 Successfully processed $file_count file(s)${NC}"
fi

echo -e "${BLUE}✅ Complete import process finished!${NC}"
