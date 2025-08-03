-- ═══════════════════════════════════════════════════════════════════════
-- 📈 ADVANCED SYSTEM DIAGNOSTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 24. System Load Analysis (Gauge)
-- 📊 OVERVIEW: Panel Type: Gauge | Description: Current system load based on call volume | Unit: Percentage | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Thresholds: 60 (yellow) / 80 (red) | Show threshold labels: Yes
-- 💡 BEST PRACTICE: Use traffic light colors, enable threshold markers, add current value display
SELECT 
    ROUND(
        (COUNT(*) FILTER (WHERE date_time >= NOW() - INTERVAL '1 hour') * 100.0 / 
        GREATEST(COUNT(*) FILTER (WHERE date_time >= NOW() - INTERVAL '24 hour') / 24.0, 1)::decimal), 1
    ) as "Current Load %" -- calculates current hour load as percentage of 24h average
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND date_time >= NOW() - INTERVAL '24 hour'; -- only includes records from last 24 hours
-- Shows current system load compared to average for capacity monitoring

-- 25. Network Health Score (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Overall network health based on success metrics | Unit: Score | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Thresholds: 70 / 85 / 95 | Color mode: Value | Text size: Large
-- 💡 BEST PRACTICE: Use gradient colors, show trend direction, add sparkline for historical context
SELECT 
    ROUND(
        (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 40.0 / COUNT(*) + -- 40% weight for success rate
         (100 - COUNT(*) FILTER (WHERE duration_secs > 300) * 30.0 / COUNT(*)) + -- 30% weight for duration performance
         (100 - COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 30.0 / COUNT(*))::decimal), 1 -- 30% weight for timeout performance
    ) as "Health Score" -- calculates composite health score from multiple metrics
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '24 hour'; -- only includes records from last 24 hours
-- Provides overall network health score based on weighted success, duration, and timeout metrics

-- 26. Performance Degradation Detection (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Detects performance degradation patterns | Unit: Various | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Enable with 15 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable conditional formatting, sort by severity, add alert indicators
SELECT 
    'Last 1 Hour' as "Time Period", -- displays time period for comparison
    COUNT(*) as "Call Count", -- counts calls in the period
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %" -- calculates timeout rate percentage
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '1 hour' -- only includes records from last hour

UNION ALL

SELECT 
    'Last 24 Hours' as "Time Period", -- displays time period for comparison
    COUNT(*) as "Call Count", -- counts calls in the period
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %" -- calculates timeout rate percentage
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '24 hour' -- only includes records from last 24 hours

UNION ALL

SELECT 
    'Last 7 Days' as "Time Period", -- displays time period for comparison
    COUNT(*) as "Call Count", -- counts calls in the period
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %" -- calculates timeout rate percentage
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '7 day'; -- only includes records from last 7 days
-- Compares performance metrics across different time periods to detect degradation trends

-- 27. Error Pattern Analysis (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Error patterns and their frequency distribution | Unit: Error Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Orientation: Horizontal | Show value: Yes | Bar width: 0.6
-- 💡 BEST PRACTICE: Use error-type colors, enable drill-down, sort by frequency
SELECT 
    CASE 
        WHEN disconnection_cause LIKE '%timeout%' THEN 'Timeout Errors' -- categorizes timeout-related errors
        WHEN disconnection_cause LIKE '%failure%' THEN 'System Failures' -- categorizes system failure errors
        WHEN disconnection_cause LIKE '%network%' THEN 'Network Issues' -- categorizes network-related errors
        WHEN disconnection_cause LIKE '%connection%' THEN 'Connection Problems' -- categorizes connection errors
        WHEN disconnection_cause = '001 - User requested disconnection' THEN 'Normal Disconnection' -- categorizes normal disconnections
        ELSE 'Other Errors' -- categorizes all other error types
    END as "Error Category", -- creates error categories for analysis
    COUNT(*) as "Error Count" -- counts occurrences of each error category
FROM call_records -- from the main call_records table
WHERE disconnection_cause IS NOT NULL -- only includes records with valid disconnection causes
GROUP BY 
    CASE 
        WHEN disconnection_cause LIKE '%timeout%' THEN 'Timeout Errors'
        WHEN disconnection_cause LIKE '%failure%' THEN 'System Failures'
        WHEN disconnection_cause LIKE '%network%' THEN 'Network Issues'
        WHEN disconnection_cause LIKE '%connection%' THEN 'Connection Problems'
        WHEN disconnection_cause = '001 - User requested disconnection' THEN 'Normal Disconnection'
        ELSE 'Other Errors'
    END -- groups by the same error categories
ORDER BY "Error Count" DESC; -- sorts by error count in descending order
-- Analyzes error patterns by categorizing and counting different types of disconnection causes

-- 28. Resource Utilization Trends (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Resource utilization over time based on call metrics | Unit: Percentage | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Line width: 2 | Fill opacity: 20% | Stack series: No
-- 💡 BEST PRACTICE: Use different colors per metric, enable legend, add moving averages
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals
    ROUND((COUNT(*) * 100.0 / 1000)::decimal, 1) as "Call Volume Utilization %", -- calculates call volume as percentage of capacity (assuming 1000 calls/hour capacity)
    ROUND((AVG(duration_secs) * 100.0 / 600)::decimal, 1) as "Duration Utilization %", -- calculates duration utilization as percentage of target (10 minutes)
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*))::decimal, 1) as "Error Rate %" -- calculates error rate percentage
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND date_time >= NOW() - INTERVAL '7 day' -- only includes records from last 7 days
GROUP BY DATE_TRUNC('hour', date_time) -- groups by hour intervals
ORDER BY time; -- sorts chronologically by time
-- Shows resource utilization trends across multiple metrics for capacity planning

-- 29. Critical System Alerts (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Critical alerts based on system thresholds | Unit: Various | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Enable with 10 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use alert colors, enable auto-refresh, sort by severity level
SELECT 
    'High Error Rate' as "Alert Type", -- defines alert type for identification
    'CRITICAL' as "Severity", -- sets severity level for prioritization
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*)::decimal), 2) as "Current Value (%)", -- calculates current error rate
    '< 5%' as "Threshold", -- shows acceptable threshold
    NOW() as "Last Updated" -- shows when alert was last calculated
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '1 hour' -- only includes records from last hour
HAVING COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 5 -- only shows if error rate exceeds 5%

UNION ALL

SELECT 
    'High Average Duration' as "Alert Type", -- defines alert type for identification
    'WARNING' as "Severity", -- sets severity level for prioritization
    ROUND(AVG(duration_secs), 2) as "Current Value (sec)", -- calculates current average duration
    '< 300 sec' as "Threshold", -- shows acceptable threshold
    NOW() as "Last Updated" -- shows when alert was last calculated
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '1 hour' AND duration_secs IS NOT NULL -- only includes records from last hour with valid duration
HAVING AVG(duration_secs) > 300 -- only shows if average duration exceeds 5 minutes

UNION ALL

SELECT 
    'Low Call Volume' as "Alert Type", -- defines alert type for identification
    'INFO' as "Severity", -- sets severity level for prioritization
    COUNT(*)::decimal as "Current Value (calls)", -- counts current call volume
    '> 10 calls/hour' as "Threshold", -- shows expected threshold
    NOW() as "Last Updated" -- shows when alert was last calculated
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '1 hour' -- only includes records from last hour
HAVING COUNT(*) < 10; -- only shows if call volume is below 10 calls per hour
-- Generates critical system alerts based on predefined thresholds for proactive monitoring
