-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 STATE ANALYSIS & TRENDS
-- ═══════════════════════════════════════════════════════════════════════

-- 19. System State Timeline (State timeline)
-- 📊 OVERVIEW: Panel Type: State timeline | Description: System status over time based on failure rates | Unit: Status Code | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and 2 | Pagination: None | Thresholds: None | Value mapping: NORMAL=0, WARNING=1, CRITICAL=2
-- 💡 BEST PRACTICE: Use traffic light colors (Green/Yellow/Red), enable region selection, show state duration labels
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    CASE 
        WHEN COUNT(CASE WHEN disconnection_cause NOT IN ('001 - User requested disconnection') THEN 1 END) * 100.0 / COUNT(*) > 20 THEN 2
        WHEN COUNT(CASE WHEN disconnection_cause NOT IN ('001 - User requested disconnection') THEN 1 END) * 100.0 / COUNT(*) > 10 THEN 1
        ELSE 0
    END as "System Status"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- 20. Network Capacity Trend (Trend)
-- 📊 CONFIGURATION: Panel Type: Time series | Format: Time series | X-axis: Sequence (not time) | Display: Line
-- 🎯 SETTINGS: Line width: 2 | Point size: 5 | Show points: Auto | Connect nulls: Yes | Gradient fill: 20%
-- 💡 BEST PRACTICE: Use for capacity planning, add moving average, enable annotations for capacity changes
SELECT 
    ROW_NUMBER() OVER (ORDER BY DATE_TRUNC('hour', date_time)) as x,
    COUNT(*) as y
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY x;

-- Additional trend queries:

-- 6. Calls Over Time by Hour (Time series)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    COUNT(*) as "Total Calls",
    COUNT(CASE WHEN source_type = 'ISSI' THEN 1 END) as "ISSI Calls",
    COUNT(CASE WHEN source_type = 'VOIP' THEN 1 END) as "VOIP Calls"
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
    COUNT(CASE WHEN disconnection_cause = '001 - User requested disconnection' THEN 1 END) * 100.0 / COUNT(*) as "Success Rate %",
    COUNT(CASE WHEN disconnection_cause LIKE '%timeout%' THEN 1 END) * 100.0 / COUNT(*) as "Timeout Rate %",
    COUNT(CASE WHEN disconnection_cause LIKE '%failure%' THEN 1 END) * 100.0 / COUNT(*) as "Failure Rate %"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;
