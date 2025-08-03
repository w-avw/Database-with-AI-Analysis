-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 NETWORK CONTROLLER ANALYSIS - PUNTOS DE COMPARACIÓN
-- ═══════════════════════════════════════════════════════════════════════

-- 13. Controller Performance Comparison (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Performance comparison across network controllers | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use contrasting colors per metric, enable data labels, sort by total calls, add legend
SELECT 
    network_controller as metric, -- groups by network controller identifier
    COUNT(*) as "Total Calls", -- counts total calls per controller
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Successful", -- counts successful calls per controller
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') as "Timeouts", -- counts timeout incidents per controller
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%') as "Errors" -- counts error incidents per controller
FROM call_records -- from the main call_records table
WHERE network_controller IS NOT NULL -- only includes records with valid controller data
GROUP BY network_controller -- groups results by controller
ORDER BY COUNT(*) DESC; -- sorts by total calls, showing busiest controllers first
-- Compares performance metrics across different network controllers to identify best and worst performers

-- 14. ISSI vs VOIP Interference Comparison (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Technology comparison between ISSI and VOIP for interference analysis | Unit: Mixed | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 30 / 60 / for Failure Rate % | Value mapping: None
-- 💡 BEST PRACTICE: Use conditional formatting for failure rate, enable sorting, add percentage bars, highlight differences
SELECT 
    source_type as "Technology", -- displays the technology type (ISSI or VOIP)
    COUNT(*) as "Total Calls", -- counts total calls per technology
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts", -- counts speech timeout incidents per technology
    COUNT(*) FILTER (WHERE disconnection_cause = '013 - Expiry of timer') as "Timer Expiry", -- counts timer expiration incidents per technology
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections", -- counts cell reselection events per technology
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average call duration per technology
    ROUND(COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*), 2) as "Failure Rate %" -- calculates failure percentage per technology
FROM call_records -- from the main call_records table
GROUP BY source_type; -- groups results by technology type
-- Compares interference and performance metrics between ISSI and VOIP technologies to identify technology-specific issues

-- 15. Fleet Interference Analysis (Bar gauge)
-- 📊 OVERVIEW: Panel Type: Bar gauge | Description: Interference rate percentage by fleet | Unit: Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 20 / 40 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use percentage format, enable value labels, sort descending, use gradient colors
SELECT 
    source_fleet as metric, -- groups by fleet identifier
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%' OR cell_reselection = 'Yes') * 100.0 / NULLIF(COUNT(*), 0) as value -- calculates interference percentage (timeouts + reselections)
FROM call_records -- from the main call_records table
WHERE source_fleet IS NOT NULL -- only includes records with valid fleet data
    AND source_fleet != '' -- and non-empty fleet values
GROUP BY source_fleet -- groups results by fleet
HAVING COUNT(*) > 20 -- only includes fleets with more than 20 calls for statistical relevance
ORDER BY value DESC; -- sorts by interference rate, showing worst fleets first
-- Identifies fleets with highest interference rates by analyzing timeout and reselection patterns
