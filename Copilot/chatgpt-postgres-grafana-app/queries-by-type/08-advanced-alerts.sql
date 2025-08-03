-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 ADVANCED ALERT QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 31. System Degradation Alerts (Alert list)
SELECT 
    CONCAT(source_fleet, ' - ', source_location) as "Alert Source",
    COUNT(*) as "Incident Count",
    STRING_AGG(DISTINCT disconnection_cause, ', ') as "Error Types",
    MAX(date_time) as "Last Occurrence"
FROM call_records 
WHERE disconnection_cause NOT IN ('001 - User requested disconnection')
    AND date_time >= NOW() - INTERVAL '6 hours'
    AND source_fleet IS NOT NULL
GROUP BY source_fleet, source_location
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;

-- 32. Interference Detection Summary (Text)
-- 📊 OVERVIEW: Panel Type: Text | Description: System status report with key metrics in markdown format | Unit: Text | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: Health status icons
-- 💡 BEST PRACTICE: Use markdown formatting, include health indicators, update in real-time
SELECT 
    CONCAT(
        '## System Status Report\n\n',
        '**Total Calls:** ', COUNT(*), '\n\n',
        '**Success Rate:** ', ROUND(COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*), 2), '%\n\n',
        '**Critical Errors:** ', COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%'), '\n\n',
        '**Interference Events:** ', COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%'), '\n\n',
        '**Network Health:** ', 
        CASE 
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 90 THEN '🟢 EXCELLENT'
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 80 THEN '🟡 GOOD'
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 70 THEN '🟠 WARNING'
            ELSE '🔴 CRITICAL'
        END
    ) as status_report
FROM call_records 
WHERE date_time >= NOW() - INTERVAL '24 hours'; -- Generates formatted text report with key system metrics and health status indicators for the last 24 hours

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
