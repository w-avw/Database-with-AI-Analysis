-- Universal DB - Database initialization script
-- This script will be executed when PostgreSQL container starts

-- Create the call_records table if it doesn't exist
CREATE TABLE IF NOT EXISTS call_records (
    id SERIAL PRIMARY KEY,
    caller_number VARCHAR(50),
    called_number VARCHAR(50),
    call_duration VARCHAR(20),
    call_status VARCHAR(30),
    call_type VARCHAR(30),
    source_fleet VARCHAR(50),
    destination_fleet VARCHAR(50),
    call_id VARCHAR(100),
    call_reference VARCHAR(100),
    source_type VARCHAR(30),
    destination_type VARCHAR(30),
    source_unit VARCHAR(50),
    destination_unit VARCHAR(50),
    call_time VARCHAR(50),
    date_time TIMESTAMP,
    duration_secs INTEGER,
    disconnection_cause VARCHAR(100),
    call_priority VARCHAR(20),
    emergency_type VARCHAR(50),
    location_info VARCHAR(200),
    network_info VARCHAR(100),
    call_direction VARCHAR(20),
    service_type VARCHAR(50),
    additional_data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_caller_number ON call_records(caller_number);
CREATE INDEX IF NOT EXISTS idx_called_number ON call_records(called_number);
CREATE INDEX IF NOT EXISTS idx_call_status ON call_records(call_status);
CREATE INDEX IF NOT EXISTS idx_created_at ON call_records(created_at);

-- Insert a sample record to test the setup
INSERT INTO call_records (
    caller_number, 
    called_number, 
    call_duration, 
    call_status,
    call_type
) VALUES (
    'TEST_SETUP', 
    'GRAFANA_READY', 
    '0', 
    'CONNECTED',
    'SETUP_TEST'
) ON CONFLICT DO NOTHING;
