
-- Universal DB Schema - ZERO DATA LOSS Design
-- Table to store parsed call data from .txt files with proper structure

-- 1. Main calls table (CORRECTED STRUCTURE)
CREATE TABLE IF NOT EXISTS calls (
    id SERIAL PRIMARY KEY,                -- PostgreSQL auto-incrementing primary key
    source_id BIGINT NOT NULL,            -- ID from .txt file (7652, 7481, etc.)
    date_time TIMESTAMP,                  -- Date/Time 
    source_type TEXT,                     -- Source type
    source TEXT,                          -- Source
    source_fleet TEXT,                    -- Source fleet
    destination_type TEXT,                -- Destination type
    destination TEXT,                     -- Destination
    destination_fleet TEXT,               -- Destination fleet
    service_type TEXT,                    -- Service type
    service_type_info TEXT,               -- Service type info.
    ai_security TEXT,                     -- AI security
    e2ee_security TEXT,                   -- E2EE security
    disconnection_cause TEXT,             -- Disconnection cause
    duration_secs INTEGER,                -- Duration (secs.)
    time_in_queue_secs INTEGER,           -- Time in queue (secs.)
    priority INTEGER,                     -- Priority
    source_location TEXT,                 -- Source location
    cell_reselection TEXT,                -- Cell reselection
    status TEXT,                          -- Status
    voice_recording TEXT,                 -- Voice recording
    call_forwarding TEXT,                 -- Call forwarding
    source_nms TEXT,                      -- Source NMS
    network_controller TEXT,              -- Network Controller
    utc_offset_minutes INTEGER,           -- UTC offset (minutes)
    UNIQUE(source_id)                     -- Prevent duplicate source_ids
);

-- 2. Staging table for bulk imports (same structure, no constraints)
CREATE TABLE IF NOT EXISTS calls_staging (
    id SERIAL,                            -- Auto-increment (not used for import)
    source_id BIGINT,                     -- ID from .txt file
    date_time TIMESTAMP,                  -- Date/Time 
    source_type TEXT,                     -- Source type
    source TEXT,                          -- Source
    source_fleet TEXT,                    -- Source fleet
    destination_type TEXT,                -- Destination type
    destination TEXT,                     -- Destination
    destination_fleet TEXT,               -- Destination fleet
    service_type TEXT,                    -- Service type
    service_type_info TEXT,               -- Service type info.
    ai_security TEXT,                     -- AI security
    e2ee_security TEXT,                   -- E2EE security
    disconnection_cause TEXT,             -- Disconnection cause
    duration_secs INTEGER,                -- Duration (secs.)
    time_in_queue_secs INTEGER,           -- Time in queue (secs.)
    priority INTEGER,                     -- Priority
    source_location TEXT,                 -- Source location
    cell_reselection TEXT,                -- Cell reselection
    status TEXT,                          -- Status
    voice_recording TEXT,                 -- Voice recording
    call_forwarding TEXT,                 -- Call forwarding
    source_nms TEXT,                      -- Source NMS
    network_controller TEXT,              -- Network Controller
    utc_offset_minutes INTEGER            -- UTC offset (minutes)
);

-- 3. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_calls_source_id ON calls(source_id);
CREATE INDEX IF NOT EXISTS idx_calls_datetime ON calls(date_time);
CREATE INDEX IF NOT EXISTS idx_calls_source ON calls(source);

-- 4. Optional: Table for import logs
CREATE TABLE IF NOT EXISTS import_logs (
    id SERIAL PRIMARY KEY,
    filename TEXT,
    import_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    records_imported INTEGER,
    status TEXT
);