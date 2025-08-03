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

-- 21. Most Problematic Sources (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Sources with highest failure rates and cell reselections | Unit: Count and Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: 20 rows | Thresholds: 20 / 80 / for Failure Rate % | Value mapping: None
SELECT 
    source as "Source",
    source_fleet as "Fleet",
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*))::numeric, 2) as "Failure Rate %",
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections"
FROM call_records 
WHERE source IS NOT NULL
GROUP BY source, source_fleet
HAVING COUNT(*) > 10
ORDER BY "Failure Rate %" DESC
LIMIT 20; -- Identifies sources with highest failure rates, sorted by problem frequency for troubleshooting priority
