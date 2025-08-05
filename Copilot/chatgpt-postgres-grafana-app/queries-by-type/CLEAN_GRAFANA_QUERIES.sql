-- ════════════════════════════════════════════════════════════════════════
-- 1. BAR CHART - Call Traffic by Hour and Day
-- ════════════════════════════════════════════════════════════════════════
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour",
    CASE EXTRACT(DOW FROM date_time)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as "Day",
    COUNT(*) as "Call Count"
FROM call_records
WHERE date_time IS NOT NULL
GROUP BY EXTRACT(HOUR FROM date_time), EXTRACT(DOW FROM date_time)
ORDER BY EXTRACT(DOW FROM date_time), EXTRACT(HOUR FROM date_time);

-- ════════════════════════════════════════════════════════════════════════
-- 2. HORIZONTAL BAR CHART - Failure Rate by Location
-- ════════════════════════════════════════════════════════════════════════
SELECT
    SUBSTRING(source_location FROM 1 FOR 15) as "Location",
    ROUND(
        (COUNT(CASE WHEN disconnection_cause NOT IN ('001 - User requested disconnection') THEN 1 END) * 100.0 / 
         NULLIF(COUNT(*), 0))::numeric, 
        1
    ) as "Failure Rate %"
FROM call_records
WHERE source_location IS NOT NULL 
    AND TRIM(source_location) != ''
GROUP BY SUBSTRING(source_location FROM 1 FOR 15)
HAVING COUNT(*) >= 20
ORDER BY "Failure Rate %" DESC;

-- ════════════════════════════════════════════════════════════════════════
-- 3. HEATMAP - Call Duration by Network Type and Hour
-- ════════════════════════════════════════════════════════════════════════
SELECT
    EXTRACT(HOUR FROM date_time) as "Hour",
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END as "Network Type",
    ROUND(AVG(duration_secs)::numeric, 1) as "Avg Call Duration"
FROM call_records
WHERE source_location IS NOT NULL 
    AND duration_secs IS NOT NULL
    AND duration_secs > 0
GROUP BY 
    EXTRACT(HOUR FROM date_time),
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END
HAVING COUNT(*) >= 5
ORDER BY "Network Type", "Hour";

-- ════════════════════════════════════════════════════════════════════════
-- 4. TIME SERIES - System Failure Analytics
-- ════════════════════════════════════════════════════════════════════════
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Successful Calls",
    COUNT(*) FILTER (WHERE disconnection_cause != '001 - User requested disconnection') as "Failed Calls",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Success Rate %",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%SBS%' OR disconnection_cause LIKE '%Error%') as "System Errors",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%' OR disconnection_cause LIKE '%timer%') as "Timeout Failures",
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselection Events"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- ════════════════════════════════════════════════════════════════════════
-- 5. HEATMAP - Interference Detection by Location and Hour
-- ════════════════════════════════════════════════════════════════════════
SELECT
    EXTRACT(HOUR FROM date_time) as "Hour",
    SUBSTRING(source_location FROM 1 FOR 12) as "Location",
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts",
    COUNT(*) FILTER (WHERE disconnection_cause = '013 - Expiry of timer') as "Timer Expiry",
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Timeout Rate %",
    ROUND(((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%' OR disconnection_cause LIKE '%timer%' OR cell_reselection = 'Yes') * 100.0 / NULLIF(COUNT(*), 0)))::numeric, 2) as "Interference Score"
FROM call_records
WHERE source_location IS NOT NULL 
    AND TRIM(source_location) != ''
GROUP BY 
    EXTRACT(HOUR FROM date_time),
    SUBSTRING(source_location FROM 1 FOR 12)
HAVING COUNT(*) >= 5
ORDER BY "Interference Score" DESC, "Hour";

-- ════════════════════════════════════════════════════════════════════════
-- 6. TABLE - Base Station Occupancy Analysis
-- ════════════════════════════════════════════════════════════════════════
SELECT
    SUBSTRING(source_location FROM 1 FOR 10) as "Base Station",
    source_fleet as "Fleet",
    COUNT(*) as "Total Calls",
    ROUND(AVG(duration_secs), 1) as "Avg Duration",
    CASE 
        WHEN COUNT(*) > 500 THEN 'HIGH_OCCUPANCY'
        WHEN COUNT(*) > 100 THEN 'MEDIUM_OCCUPANCY'
        WHEN COUNT(*) > 10 THEN 'LOW_OCCUPANCY'
        ELSE 'AVAILABLE'
    END as "Status",
    ROUND((COUNT(*) / 1000.0 * 100)::numeric, 1) as "Utilization %",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Success Rate %"
FROM call_records
WHERE source_location IS NOT NULL 
    AND TRIM(source_location) != ''
GROUP BY 
    SUBSTRING(source_location FROM 1 FOR 10),
    source_fleet
HAVING COUNT(*) > 0
ORDER BY "Total Calls" DESC;

-- ════════════════════════════════════════════════════════════════════════
-- 7. TABLE - System Maintenance Analytics
-- ════════════════════════════════════════════════════════════════════════
SELECT
    network_controller as "Controller",
    SUBSTRING(source_location FROM 1 FOR 8) as "Location",
    COUNT(*) as "Total Calls",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Health Score %",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%' OR disconnection_cause LIKE '%SBS%') as "System Errors",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') as "Timeout Issues",
    ROUND(AVG(duration_secs), 1) as "Avg Call Duration",
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections",
    ROUND(((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 50.0 / NULLIF(COUNT(*), 0)) + 
           (COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%' OR disconnection_cause LIKE '%SBS%') * 30.0 / NULLIF(COUNT(*), 0)) +
           (COUNT(*) FILTER (WHERE cell_reselection = 'Yes') * 20.0 / NULLIF(COUNT(*), 0)))::numeric, 1) as "Maintenance Priority",
    CASE 
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / NULLIF(COUNT(*), 0)) > 30 THEN 'URGENT_MAINTENANCE'
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / NULLIF(COUNT(*), 0)) > 15 THEN 'SCHEDULED_MAINTENANCE'
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / NULLIF(COUNT(*), 0)) > 5 THEN 'MONITORING'
        ELSE 'HEALTHY'
    END as "Maintenance Status"
FROM call_records
WHERE network_controller IS NOT NULL
    AND source_location IS NOT NULL
GROUP BY 
    network_controller,
    SUBSTRING(source_location FROM 1 FOR 8)
HAVING COUNT(*) >= 10
ORDER BY "Maintenance Priority" DESC;

-- ════════════════════════════════════════════════════════════════════════
-- 8. TIME SERIES / TABLE - System Health Overview
-- ════════════════════════════════════════════════════════════════════════
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour",
    CASE EXTRACT(DOW FROM date_time)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'  
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as "Day",
    COUNT(*) as "Total Requests",
    COUNT(DISTINCT SUBSTRING(source_location FROM 1 FOR 10)) as "Active Bases",
    COUNT(DISTINCT source_fleet) as "Active Fleets",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Overall Health %",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%' OR disconnection_cause LIKE '%timer%' OR cell_reselection = 'Yes') as "Interference Events",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%' OR disconnection_cause LIKE '%timer%' OR cell_reselection = 'Yes') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Interference Rate %",
    ROUND(AVG(duration_secs), 1) as "Avg Call Duration",
    CASE 
        WHEN COUNT(*) > 500 THEN 'HIGH_LOAD'
        WHEN COUNT(*) > 200 THEN 'MEDIUM_LOAD'
        WHEN COUNT(*) > 50 THEN 'LOW_LOAD'
        ELSE 'MINIMAL_LOAD'
    END as "System_Load",
    CASE 
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0)) >= 90 THEN 'EXCELLENT'
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0)) >= 80 THEN 'GOOD'
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0)) >= 70 THEN 'ACCEPTABLE'
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0)) >= 50 THEN 'POOR'
        ELSE 'CRITICAL'
    END as "System_Status"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY 
    EXTRACT(HOUR FROM date_time), 
    EXTRACT(DOW FROM date_time)
ORDER BY 
    EXTRACT(DOW FROM date_time), 
    EXTRACT(HOUR FROM date_time);

-- ════════════════════════════════════════════════════════════════════════
-- 9. STAT PANELS - Key System Metrics (Single Values)
-- ════════════════════════════════════════════════════════════════════════

-- Overall System Health (STAT)
SELECT 
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Overall Health %"
FROM call_records;

-- Total Active Base Stations (STAT)
SELECT 
    COUNT(DISTINCT SUBSTRING(source_location FROM 1 FOR 10)) as "Active Bases"
FROM call_records
WHERE source_location IS NOT NULL;

-- Current System Status (STAT)
SELECT 
    CASE 
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0)) >= 80 THEN 'GOOD'
        WHEN (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0)) >= 50 THEN 'ACCEPTABLE'
        ELSE 'NEEDS_ATTENTION'
    END as "System Status"
FROM call_records;
