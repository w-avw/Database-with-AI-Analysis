-- ═══════════════════════════════════════════════════════════════════════
-- 📊 PRIORITY & QUEUE ANALYSIS
-- ═══════════════════════════════════════════════════════════════════════

-- 16. Priority Impact on Success Rate (XY Chart)
-- 📊 OVERVIEW: Panel Type: XY chart | Description: Correlation between call priority and success rate | Unit: Priority vs Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: X: None, Y: 0 and 100 | Pagination: None | Thresholds: 80 / 20 / for success rate | Value mapping: None
-- 💡 BEST PRACTICE: Use scatter plot style, enable zoom, add trend line, set point colors by success rate threshold
SELECT 
    priority as x, -- uses priority level as X-axis value
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0) as y -- calculates success rate percentage as Y-axis value
FROM call_records -- from the main call_records table
WHERE priority IS NOT NULL -- only includes records with valid priority data
GROUP BY priority; -- groups results by priority level
-- Shows relationship between call priority levels and their success rates for correlation analysis

-- 17. Queue Time vs Failure Correlation (XY Chart)
-- 📊 OVERVIEW: Panel Type: XY chart | Description: Correlation between queue time and call success/failure | Unit: Seconds vs Binary | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: X: None, Y: 0 and 1 | Pagination: None | Thresholds: None | Value mapping: 0=Fail, 1=Success
-- 💡 BEST PRACTICE: Use sampling for large datasets, enable data point details on hover, add correlation coefficient
SELECT 
    time_in_queue_secs as x, -- uses queue waiting time in seconds as X-axis value
    CASE WHEN disconnection_cause = '001 - User requested disconnection' THEN 1 ELSE 0 END as y -- converts success/failure to binary (1=success, 0=failure) for Y-axis
FROM call_records -- from the main call_records table
WHERE time_in_queue_secs IS NOT NULL -- only includes records with valid queue time data
    AND time_in_queue_secs > 0; -- and positive queue time values
-- Plots relationship between queue waiting time and call success to identify service quality patterns

-- 18. Call Duration Distribution (Histogram)
-- 📊 OVERVIEW: Panel Type: Histogram | Description: Distribution of call durations across all calls | Unit: Seconds | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use log scale for Y-axis if skewed, set min bucket size to 1 second, enable brush selection
SELECT duration_secs 
FROM call_records 
WHERE duration_secs IS NOT NULL AND duration_secs > 0; -- Returns all call durations for histogram visualization to show distribution patterns

-- Additional Queue Analysis Queries from the file:

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
