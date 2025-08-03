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
SELECT duration_secs -- returns individual duration values for histogram binning
FROM call_records -- from the main call_records table
WHERE duration_secs IS NOT NULL AND duration_secs > 0; -- only includes records with valid positive duration values
-- Returns all call durations for histogram visualization to show distribution patterns

-- 27. Queue Time Analysis (Histogram)
-- 📊 OVERVIEW: Panel Type: Histogram | Description: Distribution of queue waiting times | Unit: Seconds | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use log scale for X-axis, set appropriate bucket size, enable zoom functionality
SELECT time_in_queue_secs -- returns individual queue time values for histogram binning
FROM call_records -- from the main call_records table
WHERE time_in_queue_secs IS NOT NULL AND time_in_queue_secs > 0; -- only includes records with valid positive queue time values
-- Returns all queue times for histogram visualization to show waiting time distribution patterns

-- 28. Queue vs Call Duration (XY Chart)
-- 📊 OVERVIEW: Panel Type: XY chart | Description: Scatter plot showing relationship between queue time and call duration | Unit: Seconds vs Seconds | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use sampling for performance, enable zoom, add correlation line, color by success rate
SELECT 
    time_in_queue_secs as "Queue Time", -- queue waiting time in seconds as X-axis value
    duration_secs as "Call Duration" -- call duration in seconds as Y-axis value
FROM call_records -- from the main call_records table
WHERE time_in_queue_secs IS NOT NULL -- only includes records with valid queue time data
    AND duration_secs IS NOT NULL -- and valid duration data
    AND time_in_queue_secs > 0 -- and positive queue time values
    AND duration_secs > 0; -- and positive duration values
-- Plots relationship between queue waiting time and actual call duration to identify service patterns

-- 29. Average Queue Time by Priority (Bar gauge)
-- 📊 OVERVIEW: Panel Type: Bar gauge | Description: Average queue waiting time for each priority level | Unit: Seconds | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and Auto | Pagination: None | Thresholds: 5 / 15 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Sort by priority level, use gradient colors, enable value labels, set appropriate thresholds
SELECT 
    priority::text as metric, -- converts priority to text for bar gauge labeling
    AVG(time_in_queue_secs) as value -- calculates average queue time for each priority level
FROM call_records -- from the main call_records table
WHERE priority IS NOT NULL AND time_in_queue_secs IS NOT NULL -- only includes records with valid priority and queue time data
GROUP BY priority -- groups results by priority level
ORDER BY priority; -- sorts results by priority level ascending
-- Calculates average queue waiting time for each priority level to identify service level differences
