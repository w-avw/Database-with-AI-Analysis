-- Table to store parsed call data from .txt files
CREATE TABLE IF NOT EXISTS calls (
    id BIGINT PRIMARY KEY,
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

-- Table for ChatGPT suggestions (optional, for future use)
CREATE TABLE IF NOT EXISTS suggestions (
    id SERIAL PRIMARY KEY,
    call_id BIGINT REFERENCES calls(id),
    suggestion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);