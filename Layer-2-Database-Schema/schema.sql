-- Layer 2: Database Schema Definition
-- Universal DB Call Records Table Structure

-- Create the main table for call records
CREATE TABLE IF NOT EXISTS call_records (
    -- Primary key and record tracking
    id                  SERIAL PRIMARY KEY,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Core call identification
    source_id           BIGINT,
    date_time           TIMESTAMP,
    
    -- Source information
    source_type         TEXT,                    -- ISSI, VOIP, etc.
    source              TEXT,                    -- Calling party identifier
    source_fleet        TEXT,                    -- Fleet information
    source_location     TEXT,                    -- Geographic/cell location
    
    -- Destination information  
    destination_type    TEXT,                    -- GSSI, etc.
    destination         TEXT,                    -- Called party identifier
    destination_fleet   TEXT,                    -- Destination fleet info
    
    -- Service and call details
    service_type        TEXT,                    -- Voice, Data, etc.
    service_type_info   TEXT,                    -- Service-specific details
    
    -- Security and encryption
    ai_security         TEXT,                    -- AI security flag
    e2ee_security       TEXT,                    -- End-to-end encryption
    
    -- Call metrics and status
    duration_secs       INTEGER,                -- Call duration in seconds
    time_in_queue_secs  INTEGER,                -- Queue wait time
    priority            INTEGER,                -- Call priority level
    disconnection_cause TEXT,                   -- Reason call ended
    
    -- Network and technical details
    cell_reselection    TEXT,                   -- Cell reselection info
    status              TEXT,                   -- Call status
    voice_recording     TEXT,                   -- Recording flag
    call_forwarding     TEXT,                   -- Forwarding flag
    source_nms          TEXT,                   -- Network Management System
    network_controller  TEXT,                   -- Controller information
    utc_offset_minutes  INTEGER                 -- Timezone offset
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_call_records_date_time ON call_records(date_time);
CREATE INDEX IF NOT EXISTS idx_call_records_source ON call_records(source);
CREATE INDEX IF NOT EXISTS idx_call_records_destination ON call_records(destination);
CREATE INDEX IF NOT EXISTS idx_call_records_source_type ON call_records(source_type);
CREATE INDEX IF NOT EXISTS idx_call_records_imported_at ON call_records(imported_at);

-- Add comments for documentation
COMMENT ON TABLE call_records IS 'Telecommunications call records with comprehensive metadata';
COMMENT ON COLUMN call_records.source_id IS 'Original call identifier from source system';
COMMENT ON COLUMN call_records.date_time IS 'Call initiation timestamp';
COMMENT ON COLUMN call_records.duration_secs IS 'Total call duration in seconds';
COMMENT ON COLUMN call_records.imported_at IS 'When this record was imported into the system';
