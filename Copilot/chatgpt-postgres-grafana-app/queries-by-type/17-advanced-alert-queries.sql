-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 ADVANCED ALERT QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 47. Critical Error Rate Alert (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Alert for critical error rates requiring immediate attention | Unit: Percentage | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Thresholds: 15 (warning) / 25 (critical) | Color mode: Background | Text size: Large
-- 💡 BEST PRACTICE: Enable alerting rules, use red background for critical, auto-refresh every 30s
SELECT 
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / GREATEST(COUNT(*), 1))::decimal, 2) as "Error Rate %" -- calculates current error rate percentage
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '15 minutes'; -- only includes records from last 15 minutes for immediate alert
-- Monitors error rate for immediate alerting when exceeding critical thresholds

-- 48. System Downtime Detection (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Detects potential system downtime based on call absence | Unit: Minutes Since Last Call | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and 60 | Thresholds: 5 (warning) / 10 (critical) | Color mode: Background | Text size: Large
-- 💡 BEST PRACTICE: Enable alerting for values > 5 minutes, use red background, auto-refresh every 30s
SELECT 
    ROUND(EXTRACT(EPOCH FROM (NOW() - MAX(date_time))) / 60.0) as "Minutes Since Last Call" -- calculates minutes since the most recent call
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL; -- only includes records with valid timestamps
-- Detects potential system downtime by monitoring time since last call

-- 49. Performance Degradation Alert (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Alerts for performance degradation across multiple metrics | Unit: Various | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Disable | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use conditional formatting for alert levels, enable alerting, auto-refresh every 60s
SELECT 
    'Error Rate Spike' as "Alert Type", -- identifies the type of performance issue
    'CRITICAL' as "Severity", -- sets alert severity level
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / GREATEST(COUNT(*), 1))::decimal, 2) as "Current Value (%)", -- shows current error rate
    '< 10%' as "Normal Range", -- shows expected normal range
    CASE 
        WHEN COUNT(*) = 0 THEN 'NO DATA'
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 20 THEN 'TRIGGER ALERT'
        ELSE 'NORMAL'
    END as "Status" -- determines if alert should be triggered
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '30 minutes' -- checks last 30 minutes for error rate
HAVING COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / GREATEST(COUNT(*), 1) > 10 -- only shows if error rate exceeds 10%

UNION ALL

SELECT 
    'High Average Duration' as "Alert Type", -- identifies the type of performance issue
    'WARNING' as "Severity", -- sets alert severity level
    ROUND(AVG(duration_secs), 2) as "Current Value (sec)", -- shows current average duration
    '< 300 sec' as "Normal Range", -- shows expected normal range
    CASE 
        WHEN AVG(duration_secs) IS NULL THEN 'NO DATA'
        WHEN AVG(duration_secs) > 600 THEN 'TRIGGER ALERT'
        ELSE 'NORMAL'
    END as "Status" -- determines if alert should be triggered
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '30 minutes' AND duration_secs IS NOT NULL -- checks last 30 minutes for duration
HAVING AVG(duration_secs) > 300 -- only shows if average duration exceeds 5 minutes

UNION ALL

SELECT 
    'Timeout Rate Spike' as "Alert Type", -- identifies the type of performance issue
    'WARNING' as "Severity", -- sets alert severity level
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / GREATEST(COUNT(*), 1))::decimal, 2) as "Current Value (%)", -- shows current timeout rate
    '< 5%' as "Normal Range", -- shows expected normal range
    CASE 
        WHEN COUNT(*) = 0 THEN 'NO DATA'
        WHEN COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*) > 10 THEN 'TRIGGER ALERT'
        ELSE 'NORMAL'
    END as "Status" -- determines if alert should be triggered
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '30 minutes' -- checks last 30 minutes for timeout rate
HAVING COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / GREATEST(COUNT(*), 1) > 5; -- only shows if timeout rate exceeds 5%
-- Monitors multiple performance metrics and generates alerts when thresholds are exceeded

-- 50. Source-Specific Alert Monitor (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Monitors individual sources for alert conditions | Unit: Source Alert Details | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Enable with 15 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Sort by severity, enable source-specific alerting, use color coding for alert levels
SELECT 
    calling_source_id as "Source ID", -- identifies the problematic source
    COUNT(*) as "Recent Calls", -- counts recent calls from this source
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*)::decimal), 2) as "Error Rate %", -- calculates source-specific error rate
    ROUND(AVG(duration_secs), 2) as "Avg Duration (sec)", -- calculates average duration for this source
    CASE 
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 50 THEN 'CRITICAL'
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 25 THEN 'WARNING'
        ELSE 'NORMAL'
    END as "Alert Level", -- determines alert level based on error rate
    MAX(date_time) as "Last Call Time" -- shows time of most recent call from this source
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '1 hour' AND calling_source_id IS NOT NULL -- checks last hour for each source
GROUP BY calling_source_id -- groups by source ID
HAVING COUNT(*) >= 3 -- only includes sources with at least 3 calls
    AND COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 20 -- only shows sources with error rate > 20%
ORDER BY "Error Rate %" DESC -- sorts by error rate to show most problematic sources first
LIMIT 20; -- limits to top 20 problematic sources
-- Monitors individual sources for alert conditions and generates source-specific alerts

-- 51. Capacity Threshold Alert (Gauge)
-- 📊 OVERVIEW: Panel Type: Gauge | Description: Alert when system capacity approaches limits | Unit: Capacity Percentage | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Thresholds: 70 (warning) / 85 (critical) / 95 (emergency) | Show threshold labels: Yes
-- 💡 BEST PRACTICE: Use traffic light colors, enable alerting at 70%, auto-refresh every 30s
SELECT 
    ROUND((COUNT(*) * 100.0 / 1000)::decimal, 1) as "Capacity Utilization %" -- calculates current capacity utilization (assuming 1000 calls/hour capacity)
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '1 hour'; -- checks last hour for capacity calculation
-- Monitors system capacity and alerts when approaching predefined limits

-- 52. Network Anomaly Detection (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Detects network anomalies based on statistical deviation | Unit: Anomaly Score | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 10 | Thresholds: 3 (warning) / 5 (critical) | Color mode: Background | Text size: Large
-- 💡 BEST PRACTICE: Use z-score calculation, enable alerting for scores > 3, auto-refresh every 60s
WITH recent_stats AS (
    SELECT 
        COUNT(*) as recent_calls, -- counts calls in recent period
        AVG(duration_secs) as recent_avg_duration -- calculates recent average duration
    FROM call_records 
    WHERE date_time >= NOW() - INTERVAL '1 hour' AND duration_secs IS NOT NULL
),
historical_stats AS (
    SELECT 
        AVG(call_count) as historical_avg_calls, -- calculates historical average call count
        STDDEV(call_count) as historical_stddev_calls, -- calculates historical standard deviation for calls
        AVG(avg_duration) as historical_avg_duration, -- calculates historical average duration
        STDDEV(avg_duration) as historical_stddev_duration -- calculates historical standard deviation for duration
    FROM (
        SELECT 
            DATE_TRUNC('hour', date_time) as hour,
            COUNT(*) as call_count, -- counts calls per hour for historical analysis
            AVG(duration_secs) as avg_duration -- calculates average duration per hour
        FROM call_records 
        WHERE date_time >= NOW() - INTERVAL '7 day' AND date_time < NOW() - INTERVAL '1 hour' AND duration_secs IS NOT NULL
        GROUP BY DATE_TRUNC('hour', date_time)
    ) hourly_stats
)
SELECT 
    ROUND(
        GREATEST(
            ABS(r.recent_calls - h.historical_avg_calls) / GREATEST(h.historical_stddev_calls, 1), -- z-score for call count anomaly
            ABS(r.recent_avg_duration - h.historical_avg_duration) / GREATEST(h.historical_stddev_duration, 1) -- z-score for duration anomaly
        ), 2
    ) as "Anomaly Score" -- calculates maximum z-score as anomaly indicator
FROM recent_stats r, historical_stats h; -- joins recent and historical statistics
-- Detects network anomalies using statistical analysis compared to historical patterns

-- 53. Real-time Alert Summary (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Summary of all active alerts in the system | Unit: Alert Summary | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Disable | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use alert colors, enable auto-refresh every 30s, sort by severity
SELECT 
    'High Error Rate' as "Alert Name", -- identifies the alert type
    'ACTIVE' as "Status", -- shows current alert status
    'System' as "Category", -- categorizes the alert
    'Error rate exceeded 10% threshold' as "Description", -- provides alert description
    NOW() as "Last Updated" -- shows when alert was last evaluated
FROM call_records 
WHERE date_time >= NOW() - INTERVAL '15 minutes'
GROUP BY 1,2,3,4,5
HAVING COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 10

UNION ALL

SELECT 
    'System Downtime' as "Alert Name", -- identifies the alert type
    'ACTIVE' as "Status", -- shows current alert status
    'System' as "Category", -- categorizes the alert
    'No calls received in last 10 minutes' as "Description", -- provides alert description
    NOW() as "Last Updated" -- shows when alert was last evaluated
FROM (SELECT MAX(date_time) as last_call FROM call_records WHERE date_time IS NOT NULL) lc
WHERE lc.last_call < NOW() - INTERVAL '10 minutes'

UNION ALL

SELECT 
    'High Capacity Usage' as "Alert Name", -- identifies the alert type
    'ACTIVE' as "Status", -- shows current alert status
    'Capacity' as "Category", -- categorizes the alert
    'Capacity utilization exceeded 70%' as "Description", -- provides alert description
    NOW() as "Last Updated" -- shows when alert was last evaluated
FROM call_records 
WHERE date_time >= NOW() - INTERVAL '1 hour'
GROUP BY 1,2,3,4,5
HAVING COUNT(*) > 700 -- assuming 1000 calls/hour capacity, 70% = 700 calls

ORDER BY "Category", "Alert Name"; -- sorts alerts by category and name
-- Provides comprehensive summary of all active system alerts for dashboard overview
