-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 SYSTEM FAILURE ANALYTICS - CAUSAS DE CAÍDAS
-- ═══════════════════════════════════════════════════════════════════════

-- 6. System Failures Over Time (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: System failures and errors over time by category | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use different colors per series, enable tooltip sort, set point size 5, stack series for better visualization
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for grouping
    COUNT(*) FILTER (WHERE disconnection_cause = '034 - Error in SBS') as "SBS Errors", -- counts SBS system errors per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '016 - Unknown TETRA identity') as "TETRA Identity Errors", -- counts TETRA identity errors per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '019 - Call restoration of the other user failed') as "Restoration Failures", -- counts call restoration failures per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '014 - SwMI requested disconnection') as "SwMI Disconnections" -- counts SwMI disconnections per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Groups calls by hour and counts different types of system failures for time series analysis

-- 7. Failure Rate by Location (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Failure rate percentage by location and hour | Unit: Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 20 / 80 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use percentage unit, enable data labels, set bucket size to 1 hour, sort Y-axis alphabetically
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    SUBSTRING(source_location FROM 1 FOR 10) as "Location",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Failure Rate %"
FROM call_records
WHERE source_location IS NOT NULL AND date_time IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    SUBSTRING(source_location FROM 1 FOR 10)
HAVING COUNT(*) > 5
ORDER BY 
    SUBSTRING(source_location FROM 1 FOR 10),
    EXTRACT(hour FROM date_time); -- Creates heatmap showing failure percentage by location and hour, excluding normal user disconnections

-- 8. Critical System Alerts (Alert list)
-- 📊 OVERVIEW: Panel Type: Alert list | Description: Critical system alerts from last 24 hours | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: 50 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable unified alerting, set auto-refresh 30s, use alert severity mapping, show alert details
SELECT 
    source_location as "Location", -- shows the source location of the alert
    disconnection_cause as "Error Type", -- displays the type of error that occurred
    COUNT(*) as "Occurrence Count", -- counts how many times this error occurred at this location
    MAX(date_time) as "Last Occurrence" -- shows the most recent time this error happened
FROM call_records -- from the main call_records table
WHERE disconnection_cause IN ('034 - Error in SBS', '016 - Unknown TETRA identity', '019 - Call restoration of the other user failed') -- filters for only critical error types
    AND date_time >= NOW() - INTERVAL '24 hours' -- only includes records from the last 24 hours
GROUP BY source_location, disconnection_cause -- groups by location and error type combination
HAVING COUNT(*) > 3 -- only shows combinations with more than 3 occurrences
ORDER BY COUNT(*) DESC; -- sorts by frequency, showing most frequent errors first
-- Shows critical errors from last 24 hours grouped by location and error type, filtered for frequent occurrences
