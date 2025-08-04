#!/bin/bash
# Automated import of all .txt files in the data folder into the 'calls' table using PostgreSQL COPY
# Skips duplicate IDs (relies on PRIMARY KEY constraint)

set -e

DATA_DIR="Copilot/chatgpt-postgres-grafana-app/data"
CONTAINER="universal-db-postgres"
DB_USER="myuser"
DB_NAME="mydb"
TABLE="calls"
STAGING="calls_staging"

for file in "$DATA_DIR"/*.txt; do
  [ -e "$file" ] || continue

  # Clean file of NULL bytes and copy to container
  CLEAN_FILE="${file%.txt}_clean.txt"
  tr < "$file" -d '\000' > "$CLEAN_FILE"
  docker cp "$CLEAN_FILE" "$CONTAINER:/tmp/data.txt"

  # Truncate staging, import, then upsert
  docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "TRUNCATE $STAGING;"
  docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c \
    "COPY $STAGING FROM '/tmp/data.txt' DELIMITER ';' NULL '' CSV HEADER;"
  docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c \
    "INSERT INTO $TABLE SELECT * FROM $STAGING ON CONFLICT (id) DO NOTHING;"

  rm "$CLEAN_FILE"
done
