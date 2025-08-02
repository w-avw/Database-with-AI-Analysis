-- Universal DB - Grafana Queries for Call Analytics
-- Use these queries in Grafana panels to create powerful visualizations

-- 1. Total Call Records (Single Stat)
SELECT COUNT(*) as value FROM call_records;

-- 2. Calls by Source Type (Pie Chart)
SELECT 
    source_type as metric, 
    COUNT(*) as value 
FROM call_records 
GROUP BY source_type 
ORDER BY COUNT(*) DESC;

-- 3. Average Call Duration (Single Stat with thresholds)
SELECT AVG(duration_secs) as value 
FROM call_records 
WHERE duration_secs IS NOT NULL;

-- 4. Top Source Fleets (Table)
SELECT 
    source_fleet, 
    COUNT(*) as call_count,
    AVG(duration_secs) as avg_duration
FROM call_records 
WHERE source_fleet IS NOT NULL AND source_fleet != '' 
GROUP BY source_fleet 
ORDER BY COUNT(*) DESC 
LIMIT 10;

-- 5. Call Duration Distribution (Histogram)
SELECT duration_secs 
FROM call_records 
WHERE duration_secs IS NOT NULL AND duration_secs > 0;

-- 6. Top Disconnection Causes (Bar Gauge)
SELECT 
    disconnection_cause, 
    COUNT(*) as value 
FROM call_records 
WHERE disconnection_cause IS NOT NULL 
GROUP BY disconnection_cause 
ORDER BY COUNT(*) DESC 
LIMIT 10;

-- 7. Service Types Analysis (Table)
SELECT 
    service_type, 
    COUNT(*) as calls, 
    AVG(duration_secs) as avg_duration,
    MAX(duration_secs) as max_duration,
    MIN(duration_secs) as min_duration
FROM call_records 
WHERE service_type IS NOT NULL 
GROUP BY service_type 
ORDER BY COUNT(*) DESC;

-- 8. Calls Over Time (Time Series) - if you have time data
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    COUNT(*) as calls
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- 9. Priority Distribution (Pie Chart)
SELECT 
    priority::text as metric, 
    COUNT(*) as value 
FROM call_records 
WHERE priority IS NOT NULL 
GROUP BY priority 
ORDER BY priority;

-- 10. Network Controller Usage (Table)
SELECT 
    network_controller, 
    COUNT(*) as calls,
    source_type,
    AVG(duration_secs) as avg_duration
FROM call_records 
WHERE network_controller IS NOT NULL 
GROUP BY network_controller, source_type 
ORDER BY COUNT(*) DESC;

-- 11. Long Duration Calls (Table) - Calls over 60 seconds
SELECT 
    source, 
    destination, 
    duration_secs, 
    disconnection_cause,
    service_type
FROM call_records 
WHERE duration_secs > 60 
ORDER BY duration_secs DESC 
LIMIT 20;

-- 12. Security Features Usage (Pie Chart)
SELECT 
    CASE 
        WHEN ai_security = 'Yes' AND e2ee_security = 'Yes' THEN 'AI + E2EE'
        WHEN ai_security = 'Yes' THEN 'AI Only'
        WHEN e2ee_security = 'Yes' THEN 'E2EE Only'
        ELSE 'None'
    END as security_type,
    COUNT(*) as value
FROM call_records 
GROUP BY 
    CASE 
        WHEN ai_security = 'Yes' AND e2ee_security = 'Yes' THEN 'AI + E2EE'
        WHEN ai_security = 'Yes' THEN 'AI Only'
        WHEN e2ee_security = 'Yes' THEN 'E2EE Only'
        ELSE 'None'
    END
ORDER BY COUNT(*) DESC;
