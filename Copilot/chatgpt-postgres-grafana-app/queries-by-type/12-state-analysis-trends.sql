-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 STATE ANALYSIS & TRENDS
-- ═══════════════════════════════════════════════════════════════════════

-- 19. System State Timeline (State timeline)
-- 📊 OVERVIEW: Panel Type: State timeline | Description: System status over time based on failure rates | Unit: Status Code | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and 2 | Pagination: None | Thresholds: None | Value mapping: NORMAL=0, WARNING=1, CRITICAL=2
-- 💡 BEST PRACTICE: Use traffic light colors (Green/Yellow/Red), enable region selection, show state duration labels
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for timeline grouping
    CASE 
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 20 THEN 'CRITICAL' -- marks as critical if failure rate > 20%
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 10 THEN 'WARNING' -- marks as warning if failure rate > 10%
        ELSE 'NORMAL' -- marks as normal if failure rate <= 10%
    END as "System Status" -- creates status categories for timeline visualization
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Creates timeline showing system health status over time based on calculated failure rates per hour

-- 20. Network Capacity Trend (Trend)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Network capacity trend showing call volume over time | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Line width: 2 | Point size: 5 | Show points: Auto | Connect nulls: Yes | Gradient fill: 20%
-- 💡 BEST PRACTICE: Use for capacity planning, add moving average, enable annotations for capacity changes
SELECT 
    ROW_NUMBER() OVER (ORDER BY DATE_TRUNC('hour', date_time)) as x, -- creates sequential numbers for X-axis (sequence instead of time)
    COUNT(*) as y -- counts calls per hour for Y-axis values
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY x; -- sorts results by sequence number
-- Shows network capacity trend as sequential data points for trend analysis and capacity planning

-- 6. Calls Over Time by Hour (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Call volume over time broken down by technology type | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use different colors per series, enable legend, stack series if needed, set point size 3
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for time series grouping
    COUNT(*) as "Total Calls", -- counts total calls per hour across all technologies
    COUNT(*) FILTER (WHERE source_type = 'ISSI') as "ISSI Calls", -- counts ISSI technology calls per hour
    COUNT(*) FILTER (WHERE source_type = 'VOIP') as "VOIP Calls" -- counts VOIP technology calls per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Shows call volume trends over time with breakdown by technology type for capacity analysis

-- 7. Average Duration Over Time (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Call duration statistics over time | Unit: Seconds | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use smooth lines, enable fill between min/max, add tooltips with detailed stats
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for time series grouping
    AVG(duration_secs) as "Average Duration", -- calculates average call duration per hour
    MAX(duration_secs) as "Max Duration", -- finds maximum call duration per hour
    MIN(duration_secs) as "Min Duration" -- finds minimum call duration per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with valid timestamps and duration
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Shows call duration trends over time with min/max ranges for quality analysis

-- 8. Call Success Rate Over Time (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Success and failure rates over time | Unit: Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 80 / 95 / for success rate | Value mapping: None
-- 💡 BEST PRACTICE: Use percentage format, add threshold lines, enable alerts for low success rates
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for time series grouping
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %", -- calculates success rate percentage per hour
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*) as "Timeout Rate %", -- calculates timeout rate percentage per hour
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%failure%') * 100.0 / COUNT(*) as "Failure Rate %" -- calculates failure rate percentage per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Shows success and failure rate trends over time for system performance monitoring

-- 38. Call Pattern Trends (Trend)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Sequential call pattern analysis for trend identification | Unit: Sequential Number vs Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use for pattern recognition, add moving average, enable zoom for detailed analysis
SELECT 
    ROW_NUMBER() OVER (ORDER BY DATE_TRUNC('hour', date_time)) as x, -- creates sequential row numbers for X-axis
    COUNT(*) as y -- counts calls per hour for Y-axis values
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY x; -- sorts results by sequence number
-- Creates sequential trend data for pattern analysis and forecasting
