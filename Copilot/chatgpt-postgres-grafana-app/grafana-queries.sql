-- 🚀 UNIVERSAL DB - COMPLETE GRAFANA ANALYTICS QUERIES
-- 📊 Advanced insights from 24,842 call records - ALL POSSIBLE ANALYTICS
-- 🎯 Each query includes the recommended visualization type

-- ═══════════════════════════════════════════════════════════════════════
-- 📈 BASIC OVERVIEW METRICS
-- ═══════════════════════════════════════════════════════════════════════

-- 1. Total Call Records (Stat)
SELECT COUNT(*) as value FROM call_records;

-- 2. Total Unique Sources (Stat)
SELECT COUNT(DISTINCT source) as value 
FROM call_records 
WHERE source IS NOT NULL;

-- 3. Total Unique Destinations (Stat)
SELECT COUNT(DISTINCT destination) as value 
FROM call_records 
WHERE destination IS NOT NULL;

-- 4. Average Call Duration (Gauge)
SELECT AVG(duration_secs) as value 
FROM call_records 
WHERE duration_secs IS NOT NULL;

-- 5. Total Call Time Hours (Stat)
SELECT ROUND(SUM(duration_secs)/3600, 2) as value 
FROM call_records 
WHERE duration_secs IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- 🕐 TIME SERIES ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 6. Calls Over Time by Hour (Time series)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE source_type = 'ISSI') as "ISSI Calls",
    COUNT(*) FILTER (WHERE source_type = 'VOIP') as "VOIP Calls"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- 7. Average Duration Over Time (Time series)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    AVG(duration_secs) as "Average Duration",
    MAX(duration_secs) as "Max Duration",
    MIN(duration_secs) as "Min Duration"
FROM call_records 
WHERE date_time IS NOT NULL AND duration_secs IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- 8. Call Success Rate Over Time (Time series)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*) as "Timeout Rate %",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%failure%') * 100.0 / COUNT(*) as "Failure Rate %"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 DISTRIBUTION ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 9. Source Type Distribution (Pie chart)
SELECT 
    source_type as metric, 
    COUNT(*) as value 
FROM call_records 
GROUP BY source_type 
ORDER BY COUNT(*) DESC;

-- 10. Call Duration Distribution (Histogram)
SELECT duration_secs 
FROM call_records 
WHERE duration_secs IS NOT NULL AND duration_secs > 0;

-- 11. Priority Distribution (Pie chart)
SELECT 
    priority::text as metric, 
    COUNT(*) as value 
FROM call_records 
WHERE priority IS NOT NULL 
GROUP BY priority 
ORDER BY priority;

-- 12. Duration Categories (Pie chart)
SELECT 
    CASE 
        WHEN duration_secs <= 5 THEN 'Very Short (≤5s)'
        WHEN duration_secs <= 15 THEN 'Short (6-15s)'
        WHEN duration_secs <= 60 THEN 'Medium (16-60s)'
        WHEN duration_secs <= 180 THEN 'Long (61-180s)'
        ELSE 'Very Long (>180s)'
    END as metric,
    COUNT(*) as value
FROM call_records 
WHERE duration_secs IS NOT NULL
GROUP BY 
    CASE 
        WHEN duration_secs <= 5 THEN 'Very Short (≤5s)'
        WHEN duration_secs <= 15 THEN 'Short (6-15s)'
        WHEN duration_secs <= 60 THEN 'Medium (16-60s)'
        WHEN duration_secs <= 180 THEN 'Long (61-180s)'
        ELSE 'Very Long (>180s)'
    END
ORDER BY 
    CASE 
        WHEN duration_secs <= 5 THEN 1
        WHEN duration_secs <= 15 THEN 2
        WHEN duration_secs <= 60 THEN 3
        WHEN duration_secs <= 180 THEN 4
        ELSE 5
    END;

-- ═══════════════════════════════════════════════════════════════════════
-- 🏢 FLEET & OPERATIONAL ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 13. Top Source Fleets Performance (Table)
SELECT 
    source_fleet as "Fleet", 
    COUNT(*) as "Total Calls",
    AVG(duration_secs) as "Avg Duration",
    MAX(duration_secs) as "Max Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %",
    COUNT(DISTINCT source) as "Unique Sources"
FROM call_records 
WHERE source_fleet IS NOT NULL AND source_fleet != '' 
GROUP BY source_fleet 
ORDER BY COUNT(*) DESC 
LIMIT 15;

-- 14. Fleet Activity Heatmap (Heatmap)
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    source_fleet as "Fleet",
    COUNT(*) as "Call Count"
FROM call_records
WHERE source_fleet IS NOT NULL AND date_time IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    source_fleet
ORDER BY 
    source_fleet,
    EXTRACT(hour FROM date_time);

-- 15. Destination Fleet Analysis (Bar chart)
SELECT 
    destination_fleet as metric,
    COUNT(*) as value
FROM call_records 
WHERE destination_fleet IS NOT NULL AND destination_fleet != ''
GROUP BY destination_fleet 
ORDER BY COUNT(*) DESC 
LIMIT 15;

-- ═══════════════════════════════════════════════════════════════════════
-- 🔒 SECURITY & QUALITY ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 16. Security Features Usage (Pie chart)
SELECT 
    CASE 
        WHEN ai_security = 'Yes' AND e2ee_security = 'Yes' THEN 'AI + E2EE'
        WHEN ai_security = 'Yes' THEN 'AI Only'
        WHEN e2ee_security = 'Yes' THEN 'E2EE Only'
        ELSE 'No Security'
    END as metric,
    COUNT(*) as value
FROM call_records 
GROUP BY 
    CASE 
        WHEN ai_security = 'Yes' AND e2ee_security = 'Yes' THEN 'AI + E2EE'
        WHEN ai_security = 'Yes' THEN 'AI Only'
        WHEN e2ee_security = 'Yes' THEN 'E2EE Only'
        ELSE 'No Security'
    END
ORDER BY COUNT(*) DESC;

-- 17. Voice Recording Usage (Gauge)
SELECT 
    COUNT(*) FILTER (WHERE voice_recording = 'Yes') * 100.0 / COUNT(*) as value
FROM call_records;

-- 18. Call Forwarding Analysis (Bar gauge)
SELECT 
    call_forwarding as metric,
    COUNT(*) as value
FROM call_records 
WHERE call_forwarding IS NOT NULL
GROUP BY call_forwarding;

-- ═══════════════════════════════════════════════════════════════════════
-- ❌ FAILURE & DISCONNECTION ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 19. Top Disconnection Causes (Bar chart)
SELECT 
    disconnection_cause as metric, 
    COUNT(*) as value 
FROM call_records 
WHERE disconnection_cause IS NOT NULL 
GROUP BY disconnection_cause 
ORDER BY COUNT(*) DESC 
LIMIT 10;

-- 20. Failure Analysis by Source Type (Bar chart)
SELECT 
    source_type as metric,
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') as "Timeouts",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%failure%') as "Failures",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Normal"
FROM call_records 
GROUP BY source_type;

-- 21. Disconnection Cause Timeline (State timeline)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    disconnection_cause as metric,
    COUNT(*) as value
FROM call_records 
WHERE date_time IS NOT NULL AND disconnection_cause IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time), disconnection_cause
ORDER BY time;

-- ═══════════════════════════════════════════════════════════════════════
-- 🌍 LOCATION & NETWORK ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 22. Network Controller Performance (Table)
SELECT 
    network_controller as "Controller", 
    COUNT(*) as "Total Calls",
    source_type as "Source Type",
    AVG(duration_secs) as "Avg Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %"
FROM call_records 
WHERE network_controller IS NOT NULL 
GROUP BY network_controller, source_type 
ORDER BY COUNT(*) DESC;

-- 23. Source Location Activity (Bar chart)
SELECT 
    source_location as metric,
    COUNT(*) as value
FROM call_records 
WHERE source_location IS NOT NULL AND source_location != ''
GROUP BY source_location 
ORDER BY COUNT(*) DESC 
LIMIT 20;

-- 24. Cell Reselection Impact (Pie chart)
SELECT 
    cell_reselection as metric,
    COUNT(*) as value
FROM call_records 
WHERE cell_reselection IS NOT NULL
GROUP BY cell_reselection;

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 SERVICE TYPE & COMMUNICATION ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 25. Service Types Analysis (Table)
SELECT 
    service_type as "Service Type", 
    COUNT(*) as "Calls", 
    AVG(duration_secs) as "Avg Duration",
    MAX(duration_secs) as "Max Duration",
    MIN(duration_secs) as "Min Duration",
    STDDEV(duration_secs) as "Duration StdDev"
FROM call_records 
WHERE service_type IS NOT NULL 
GROUP BY service_type 
ORDER BY COUNT(*) DESC;

-- 26. Service Type Info Distribution (Bar chart)
SELECT 
    service_type_info as metric,
    COUNT(*) as value
FROM call_records 
WHERE service_type_info IS NOT NULL AND service_type_info != ''
GROUP BY service_type_info 
ORDER BY COUNT(*) DESC 
LIMIT 15;

-- ═══════════════════════════════════════════════════════════════════════
-- ⏱️ QUEUE & PERFORMANCE ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 27. Queue Time Analysis (Histogram)
SELECT time_in_queue_secs
FROM call_records 
WHERE time_in_queue_secs IS NOT NULL AND time_in_queue_secs > 0;

-- 28. Queue vs Call Duration (XY Chart)
SELECT 
    time_in_queue_secs as "Queue Time",
    duration_secs as "Call Duration"
FROM call_records 
WHERE time_in_queue_secs IS NOT NULL 
    AND duration_secs IS NOT NULL 
    AND time_in_queue_secs > 0
    AND duration_secs > 0;

-- 29. Average Queue Time by Priority (Bar gauge)
SELECT 
    priority::text as metric,
    AVG(time_in_queue_secs) as value
FROM call_records 
WHERE priority IS NOT NULL AND time_in_queue_secs IS NOT NULL
GROUP BY priority 
ORDER BY priority;

-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 HEATMAPS & PATTERN ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 30. Hourly Activity Heatmap (Heatmap)
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    CASE EXTRACT(dow FROM date_time)
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
GROUP BY 
    EXTRACT(hour FROM date_time),
    EXTRACT(dow FROM date_time)
ORDER BY 
    EXTRACT(dow FROM date_time),
    EXTRACT(hour FROM date_time);

-- 31. Duration Heatmap by Hour and Priority (Heatmap)
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    priority::text as "Priority",
    AVG(duration_secs) as "Avg Duration"
FROM call_records
WHERE date_time IS NOT NULL AND priority IS NOT NULL AND duration_secs IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    priority
ORDER BY 
    priority,
    EXTRACT(hour FROM date_time);

-- ═══════════════════════════════════════════════════════════════════════
-- 🏆 TOP PERFORMERS & OUTLIERS
-- ═══════════════════════════════════════════════════════════════════════

-- 32. Longest Calls (Table)
SELECT 
    source as "Source", 
    destination as "Destination", 
    duration_secs as "Duration (sec)", 
    disconnection_cause as "End Reason",
    service_type as "Service",
    source_fleet as "Fleet"
FROM call_records 
WHERE duration_secs > 60 
ORDER BY duration_secs DESC 
LIMIT 25;

-- 33. Most Active Sources (Table)
SELECT 
    source as "Source",
    COUNT(*) as "Total Calls",
    source_fleet as "Fleet",
    AVG(duration_secs) as "Avg Duration",
    MAX(duration_secs) as "Max Duration"
FROM call_records 
WHERE source IS NOT NULL
GROUP BY source, source_fleet
ORDER BY COUNT(*) DESC 
LIMIT 20;

-- 34. Most Called Destinations (Table)
SELECT 
    destination as "Destination",
    COUNT(*) as "Incoming Calls",
    destination_fleet as "Fleet",
    AVG(duration_secs) as "Avg Duration"
FROM call_records 
WHERE destination IS NOT NULL
GROUP BY destination, destination_fleet
ORDER BY COUNT(*) DESC 
LIMIT 20;

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 ADVANCED COMPARATIVE ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 35. ISSI vs VOIP Performance Comparison (Table)
SELECT 
    source_type as "Type",
    COUNT(*) as "Total Calls",
    AVG(duration_secs) as "Avg Duration", 
    MAX(duration_secs) as "Max Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %",
    AVG(time_in_queue_secs) as "Avg Queue Time",
    COUNT(*) FILTER (WHERE voice_recording = 'Yes') * 100.0 / COUNT(*) as "Recording Rate %"
FROM call_records 
GROUP BY source_type;

-- 36. UTC Offset Analysis (Bar chart)
SELECT 
    utc_offset_minutes::text as metric,
    COUNT(*) as value
FROM call_records 
WHERE utc_offset_minutes IS NOT NULL
GROUP BY utc_offset_minutes 
ORDER BY COUNT(*) DESC;

-- ═══════════════════════════════════════════════════════════════════════
-- 💡 OPERATIONAL INSIGHTS & EFFICIENCY
-- ═══════════════════════════════════════════════════════════════════════

-- 37. Efficiency Metrics by Fleet (Gauge)
SELECT 
    source_fleet as metric,
    AVG(duration_secs) / NULLIF(AVG(time_in_queue_secs + duration_secs), 0) * 100 as value
FROM call_records 
WHERE source_fleet IS NOT NULL 
    AND time_in_queue_secs IS NOT NULL 
    AND duration_secs IS NOT NULL
GROUP BY source_fleet
ORDER BY value DESC;

-- 38. Call Pattern Trends (Trend)
SELECT 
    ROW_NUMBER() OVER (ORDER BY DATE_TRUNC('hour', date_time)) as x,
    COUNT(*) as y
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY x;

-- 39. Priority vs Duration Relationship (XY Chart)
SELECT 
    priority as x,
    duration_secs as y
FROM call_records 
WHERE priority IS NOT NULL AND duration_secs IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- 🎪 ADVANCED STATISTICAL ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 40. Duration Statistics by Source Type (Table)
SELECT 
    source_type as "Source Type",
    COUNT(*) as "Count",
    AVG(duration_secs) as "Mean",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_secs) as "Median",
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_secs) as "95th Percentile",
    STDDEV(duration_secs) as "Std Deviation",
    MIN(duration_secs) as "Min",
    MAX(duration_secs) as "Max"
FROM call_records 
WHERE duration_secs IS NOT NULL
GROUP BY source_type;

-- 41. Call Volume Percentiles (Bar gauge)
SELECT 
    'P50' as metric, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hourly_calls) as value
FROM (
    SELECT COUNT(*) as hourly_calls 
    FROM call_records 
    WHERE date_time IS NOT NULL 
    GROUP BY DATE_TRUNC('hour', date_time)
) t
UNION ALL
SELECT 
    'P95' as metric, PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY hourly_calls) as value
FROM (
    SELECT COUNT(*) as hourly_calls 
    FROM call_records 
    WHERE date_time IS NOT NULL 
    GROUP BY DATE_TRUNC('hour', date_time)
) t;

-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 ALERT-WORTHY QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 42. High Failure Rate Sources (Alert list)
SELECT 
    source as "Source",
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE disconnection_cause NOT LIKE '%User requested%') * 100.0 / COUNT(*) as "Failure Rate %"
FROM call_records 
WHERE source IS NOT NULL
GROUP BY source
HAVING COUNT(*) > 10 AND COUNT(*) FILTER (WHERE disconnection_cause NOT LIKE '%User requested%') * 100.0 / COUNT(*) > 20
ORDER BY "Failure Rate %" DESC;
