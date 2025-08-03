-- ═══════════════════════════════════════════════════════════════════════
-- 📡 INTERFERENCE DETECTION - ANÁLISIS DE INTERFERENCIAS
-- ═══════════════════════════════════════════════════════════════════════

-- 9. Interference Pattern Analysis (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Interference patterns by timeout and reselection types | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use warm colors (red/orange/yellow), enable crosshair, show all values in tooltip, add trend lines
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for grouping
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts", -- counts speech timeout incidents per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '013 - Expiry of timer') as "Timer Expiry", -- counts timer expiration incidents per hour
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections" -- counts cell reselection events per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Tracks interference patterns over time by counting speech timeouts, timer expirations, and cell reselections per hour

-- 10. Cell Reselection Impact Analysis (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Impact of cell reselection on call failure rates | Unit: Count and Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use contrasting colors, enable data labels on bars, sort by failure rate, add percentage format
SELECT 
    cell_reselection as metric, -- groups by whether cell reselection occurred or not
    COUNT(*) as "Total Calls", -- counts total calls for each group
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls", -- counts failed calls excluding normal disconnections
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*))::numeric, 2) as "Failure Rate %" -- calculates failure percentage for each group
FROM call_records -- from the main call_records table
WHERE cell_reselection IS NOT NULL -- only includes records with valid cell reselection data
GROUP BY cell_reselection; -- groups results by cell reselection status
-- Compares failure rates between calls with and without cell reselection to analyze its impact on call success

-- 11. Location-Based Interference Hotspots (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Interference hotspots by location with timeout analysis | Unit: Count and Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: 15 rows | Thresholds: 20 / 80 / for Timeout Rate % | Value mapping: None
-- 💡 BEST PRACTICE: Use gradient colors for rate columns, enable row selection, add search box, set conditional formatting
SELECT 
    source_location as "Location", -- displays the source location of calls
    COUNT(*) as "Total Calls", -- counts total calls from each location
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts", -- counts speech timeout incidents per location
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections", -- counts cell reselection events per location
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*))::numeric, 2) as "Timeout Rate %" -- calculates timeout percentage for each location
FROM call_records -- from the main call_records table
WHERE source_location IS NOT NULL -- only includes records with valid location data
GROUP BY source_location -- groups results by location
HAVING COUNT(*) > 50 -- only includes locations with more than 50 calls for statistical relevance
ORDER BY "Timeout Rate %" DESC -- sorts by timeout rate, showing worst locations first
LIMIT 15; -- limits to top 15 problematic locations
-- Identifies locations with highest interference activity by analyzing timeout rates and cell reselections

-- 12. Network Quality Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Average call duration by hour and network type | Unit: Seconds | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 30 / 120 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use seconds unit, set bucket size to 1 hour, enable hover tooltip, normalize by row
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END as "Network Type",
    AVG(duration_secs)::numeric as "Avg Call Duration"
FROM call_records
WHERE source_location IS NOT NULL AND date_time IS NOT NULL AND duration_secs IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END
ORDER BY 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END,
    EXTRACT(hour FROM date_time); -- Creates heatmap showing average call duration by network type and hour to identify quality patterns
