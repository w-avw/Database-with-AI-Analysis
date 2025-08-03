-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 REAL-TIME MONITORING
-- ═══════════════════════════════════════════════════════════════════════

-- 30. Real-time Call Rate (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Current calls per minute rate | Unit: Calls/min | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Color mode: Value | Text size: Large | Thresholds: 50 / 100
-- 💡 BEST PRACTICE: Enable auto-refresh every 30s, show trend sparkline, use gradient colors
SELECT 
    ROUND((COUNT(*) * 60.0 / EXTRACT(EPOCH FROM (MAX(date_time) - MIN(date_time) + INTERVAL '1 minute')))::decimal, 1) as "Calls per Minute" -- calculates calls per minute rate from recent data
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '5 minutes' AND date_time IS NOT NULL; -- only includes records from last 5 minutes for real-time calculation
-- Shows current call rate for real-time system load monitoring

-- 32. Active Call Distribution (Pie chart)
-- 📊 OVERVIEW: Panel Type: Pie chart | Description: Distribution of active calls by source type in real-time | Unit: Active Calls | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use distinct colors, enable legend, show percentages, auto-refresh every 30s
SELECT 
    source_type as "Source Type", -- displays the technology type
    COUNT(*) as "Active Calls" -- counts calls currently active or recent
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '10 minutes' AND source_type IS NOT NULL -- only includes records from last 10 minutes with valid source types
GROUP BY source_type -- groups results by source type
ORDER BY COUNT(*) DESC; -- sorts by call count in descending order
-- Shows real-time distribution of calls across different technology types

-- 33. Live Error Feed (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Real-time feed of errors and failures | Unit: Error Details | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Enable with 20 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable auto-refresh every 15s, use red highlighting for errors, sort by timestamp
SELECT 
    date_time as "Timestamp", -- shows exact time of the error
    calling_source_id as "Source ID", -- identifies the problematic source
    source_type as "Technology", -- shows technology type for context
    disconnection_cause as "Error Cause", -- displays the specific error reason
    duration_secs as "Duration (sec)" -- shows call duration before failure
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '30 minutes' -- only includes records from last 30 minutes
    AND disconnection_cause NOT IN ('001 - User requested disconnection') -- excludes normal disconnections
    AND disconnection_cause IS NOT NULL -- only includes records with valid disconnection causes
ORDER BY date_time DESC -- sorts by timestamp in descending order (most recent first)
LIMIT 50; -- limits results to last 50 errors for performance
-- Provides real-time feed of errors and failures for immediate response

-- 35. Current System Performance (Gauge)
-- 📊 OVERVIEW: Panel Type: Gauge | Description: Real-time system performance score | Unit: Performance Score | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Thresholds: 60 (red) / 80 (yellow) / 95 (green) | Show threshold labels: Yes
-- 💡 BEST PRACTICE: Use traffic light colors, enable threshold markers, auto-refresh every 30s
SELECT 
    ROUND(
        CASE 
            WHEN COUNT(*) = 0 THEN 50 -- default score if no data
            ELSE 
                (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 50.0 / COUNT(*) + -- 50% weight for success rate
                 GREATEST(0, 100 - AVG(duration_secs) * 50.0 / 600) + -- 50% weight for duration performance (target 10 min max)
                 0)::decimal
        END, 1
    ) as "Performance Score" -- calculates real-time performance score from success rate and duration
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '15 minutes'; -- only includes records from last 15 minutes for real-time assessment
-- Shows current system performance as a composite score for dashboard overview

-- 37. Recent Call Activity (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Call activity in recent time periods | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Line width: 2 | Point size: 3 | Fill opacity: 30%
-- 💡 BEST PRACTICE: Use last 2 hours data, auto-refresh every 30s, enable zoom and pan
SELECT 
    DATE_TRUNC('minute', date_time) as time, -- truncates timestamp to minute intervals for detailed view
    COUNT(*) as "Calls per Minute", -- counts calls per minute
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Successful Calls", -- counts successful calls per minute
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls" -- counts failed calls per minute
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '2 hours' AND date_time IS NOT NULL -- only includes records from last 2 hours
GROUP BY DATE_TRUNC('minute', date_time) -- groups by minute intervals
ORDER BY time; -- sorts chronologically by time
-- Shows detailed call activity trends for recent monitoring and pattern detection

-- 39. Live System Status (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Current system operational status | Unit: Status | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None | Color mode: Background | Text size: Large | Value mapping: OPERATIONAL=1, DEGRADED=2, DOWN=3
-- 💡 BEST PRACTICE: Use status colors (green/yellow/red), enable alerting, auto-refresh every 30s
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN 'DOWN' -- system is down if no recent calls
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 20 THEN 'DEGRADED' -- degraded if error rate > 20%
        ELSE 'OPERATIONAL' -- operational if error rate <= 20%
    END as "System Status" -- determines current system status based on recent call patterns
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '10 minutes'; -- only includes records from last 10 minutes for status assessment
-- Provides real-time system operational status for immediate visibility

-- 40. Current Load Metrics (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Current system load metrics and thresholds | Unit: Various | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Disable | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable conditional formatting, auto-refresh every 30s, highlight threshold breaches
SELECT 
    'Call Volume (last 15 min)' as "Metric", -- describes the metric being measured
    COUNT(*)::text as "Current Value", -- shows current call count as text
    '< 500 calls' as "Normal Threshold", -- shows normal operating threshold
    CASE WHEN COUNT(*) > 500 THEN 'WARNING' ELSE 'NORMAL' END as "Status" -- determines status based on threshold
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '15 minutes' -- only includes records from last 15 minutes

UNION ALL

SELECT 
    'Error Rate (last 15 min)' as "Metric", -- describes the metric being measured
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / GREATEST(COUNT(*), 1))::decimal, 2)::text || '%' as "Current Value", -- shows current error rate percentage
    '< 10%' as "Normal Threshold", -- shows normal operating threshold
    CASE 
        WHEN COUNT(*) = 0 THEN 'NO DATA'
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 10 THEN 'WARNING' 
        ELSE 'NORMAL' 
    END as "Status" -- determines status based on error rate threshold
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '15 minutes' -- only includes records from last 15 minutes

UNION ALL

SELECT 
    'Avg Duration (last 15 min)' as "Metric", -- describes the metric being measured
    ROUND(AVG(duration_secs), 2)::text || ' sec' as "Current Value", -- shows current average duration
    '< 300 sec' as "Normal Threshold", -- shows normal operating threshold
    CASE 
        WHEN AVG(duration_secs) IS NULL THEN 'NO DATA'
        WHEN AVG(duration_secs) > 300 THEN 'WARNING' 
        ELSE 'NORMAL' 
    END as "Status" -- determines status based on duration threshold
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '15 minutes' AND duration_secs IS NOT NULL; -- only includes records from last 15 minutes with valid duration
-- Shows current load metrics with status indicators for real-time monitoring dashboard
