-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 REAL-TIME MONITORING QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 26. Current Hour System Health (Gauge)
-- 📊 OVERVIEW: Panel Type: Gauge | Description: Real-time system health for current hour | Unit: Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 50 / 80 / Red-Yellow-Green | Value mapping: None
-- 💡 BEST PRACTICE: Use for real-time monitoring, set auto-refresh to 30s, enable threshold notifications
SELECT 
    COALESCE((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 0) as value
FROM call_records 
WHERE date_time >= DATE_TRUNC('hour', NOW() - INTERVAL '1 hour'); -- Calculates success rate for the current hour to monitor real-time system health

-- 27. Active Interference Events (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Active interference events in last hour | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 5 / 15 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use for alerting, enable trend indication, set warning color when increasing
SELECT COUNT(*) as value
FROM call_records 
WHERE (disconnection_cause LIKE '%timeout%' OR cell_reselection = 'Yes')
    AND date_time >= NOW() - INTERVAL '1 hour'; -- Counts recent interference events (timeouts and cell reselections) in the last hour for immediate alerting

-- 28. Network Load Distribution (Pie chart)
-- 📊 OVERVIEW: Panel Type: Pie chart | Description: Distribution of network load by technology type | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use distinct colors, enable hover interactions, set minimum slice percentage to reduce clutter
SELECT 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN 'SBS Network'
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP Network'
        ELSE 'Other'
    END as metric,
    COUNT(*) as value
FROM call_records 
WHERE source_location IS NOT NULL
GROUP BY 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN 'SBS Network'
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP Network'
        ELSE 'Other'
    END; -- Categorizes calls by network technology type to show distribution of load across different network types
