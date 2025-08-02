#!/bin/bash
# Universal DB - Fast TXT Import Script
# Automatically imports .txt files from data folder into PostgreSQL
set -e

# Configuration
DATA_DIR="Copilot/chatgpt-postgres-grafana-app/data"
PROCESSED_DIR="$DATA_DIR/processed"
CONTAINER="mypg"
DB_USER="myuser"
DB_NAME="mydb"
TABLE="calls"
STAGING="calls_staging"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Universal DB Import Process...${NC}"

# Create processed directory if it doesn't exist
mkdir -p "$PROCESSED_DIR"

# Check if container is running
if ! docker ps | grep -q "$CONTAINER"; then
    echo -e "${RED}❌ Container '$CONTAINER' is not running!${NC}"
    echo -e "${YELLOW}💡 Start it with: cd Copilot/chatgpt-postgres-grafana-app && docker-compose up -d${NC}"
    exit 1
fi

# Process each .txt file
processed_count=0
for file in "$DATA_DIR"/*.txt; do
    # Skip if no .txt files found
    [ -e "$file" ] || continue
    
    # Skip files in processed directory
    if [[ "$file" == *"/processed/"* ]]; then
        continue
    fi
    
    filename=$(basename "$file")
    echo -e "${YELLOW}📂 Processing: $filename${NC}"
    
    # Clean file (remove null bytes and fix encoding issues)
    CLEAN_FILE="${file%.txt}_clean.txt"
    tr < "$file" -d '\000' > "$CLEAN_FILE"
    
    # Copy to container
    echo "   📋 Copying to container..."
    docker cp "$CLEAN_FILE" "$CONTAINER:/tmp/data.txt"
    
    # Import process
    echo "   🔄 Importing to database..."
    
    # Truncate staging table
    docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "TRUNCATE $STAGING;" > /dev/null
    
    # Import to staging (with better error handling)
    if docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c \
        "COPY $STAGING (id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet, service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs, time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding, source_nms, network_controller, utc_offset_minutes) FROM '/tmp/data.txt' DELIMITER ';' NULL '' CSV HEADER;" > /dev/null 2>&1; then
        
        # Get record count
        record_count=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM $STAGING;" | tr -d ' ')
        
        # Upsert from staging to main table
        docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c \
            "INSERT INTO $TABLE SELECT * FROM $STAGING ON CONFLICT (id) DO NOTHING;" > /dev/null
        
        # Get final count
        final_count=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM $TABLE;" | tr -d ' ')
        
        echo -e "   ✅ Imported $record_count records (Total in DB: $final_count)"
        
        # Move to processed folder
        mv "$file" "$PROCESSED_DIR/"
        echo -e "   📁 Moved to processed folder"
        
        processed_count=$((processed_count + 1))
    else
        echo -e "${RED}   ❌ Failed to import $filename${NC}"
    fi
    
    # Cleanup
    rm -f "$CLEAN_FILE"
done

if [ $processed_count -eq 0 ]; then
    echo -e "${YELLOW}📭 No new .txt files found in $DATA_DIR${NC}"
else
    echo -e "${GREEN}🎉 Successfully processed $processed_count file(s)!${NC}"
    
    # Show database stats
    total_records=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM $TABLE;" | tr -d ' ')
    echo -e "${GREEN}📊 Total records in database: $total_records${NC}"
fi

echo -e "${GREEN}✨ Import process complete!${NC}"