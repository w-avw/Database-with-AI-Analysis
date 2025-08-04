-- SQL schema for ChatGPT-Postgres-Grafana App

-- 1. Table to store parsed call data from .txt files
CREATE TABLE IF NOT EXISTS calls (
    db_id SERIAL PRIMARY KEY,         -- Unique DB record ID
    source_id BIGINT,                 -- Original ID from .txt file
    date_time TIMESTAMP,
    source_type TEXT,
    source TEXT,
    source_fleet TEXT,
    destination_type TEXT,
    destination TEXT,
    destination_fleet TEXT,
    service_type TEXT,
    service_type_info TEXT,
    ai_security TEXT,
    e2ee_security TEXT,
    disconnection_cause TEXT,
    duration_secs INTEGER,
    time_in_queue_secs INTEGER,
    priority INTEGER,
    source_location TEXT,
    cell_reselection TEXT,
    status TEXT,
    voice_recording TEXT,
    call_forwarding TEXT,
    source_nms TEXT,
    network_controller TEXT,
    utc_offset_minutes INTEGER
);

-- 2. Table for ChatGPT suggestions (optional, for future use)
CREATE TABLE IF NOT EXISTS suggestions (
    id SERIAL PRIMARY KEY,
    call_id INTEGER REFERENCES calls(db_id),
    suggestion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS calls_staging (LIKE calls INCLUDING ALL);
ALTER TABLE calls_staging DROP CONSTRAINT IF EXISTS calls_staging_pkey;

--
-- To import data using COPY, use the following command (in psql):
--
-- COPY calls (
--   source_id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet,
--   service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs,
--   time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding,
--   source_nms, network_controller, utc_offset_minutes
--) FROM '/tmp/data.txt' DELIMITER ';' NULL '' CSV HEADER;
--
-- This will auto-increment db_id and map the first column of your .txt file to source_id.
