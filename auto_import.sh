#!/bin/bash
# Auto Import Script - Universal DB
# Watches the data folder and automatically imports new .txt files

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DATA_DIR="Copilot/chatgpt-postgres-grafana-app/data"
WATCH_INTERVAL=5  # seconds

echo -e "${BLUE}👁️  Universal DB - Auto Import Watcher${NC}"
echo "Watching: $DATA_DIR"
echo "Press Ctrl+C to stop"
echo "==========================================="

# Function to count .txt files (excluding processed folder)
count_txt_files() {
    find "$DATA_DIR" -name "*.txt" -not -path "*/processed/*" | wc -l
}

# Initial count
last_count=$(count_txt_files)
echo -e "${YELLOW}Initial .txt files: $last_count${NC}"

while true; do
    current_count=$(count_txt_files)
    
    if [ "$current_count" -gt "$last_count" ]; then
        echo -e "\n${GREEN}🆕 New file(s) detected! Running import...${NC}"
        ./import_calls.sh
        last_count=$(count_txt_files)
        echo -e "${YELLOW}Continuing to watch...${NC}"
    fi
    
    sleep $WATCH_INTERVAL
done
