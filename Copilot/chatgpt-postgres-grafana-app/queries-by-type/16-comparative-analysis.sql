-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 COMPARATIVE ANALYSIS
-- ═══════════════════════════════════════════════════════════════════════

-- 41. Technology Performance Comparison (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Performance comparison between different technologies | Unit: Various Metrics | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Orientation: Vertical | Show value: Yes | Bar width: 0.8
-- 💡 BEST PRACTICE: Use contrasting colors for each technology, enable legend, group related metrics
SELECT 
    source_type as "Technology", -- displays the technology type for comparison
    COUNT(*) as "Total Calls", -- counts total calls for each technology
    ROUND(AVG(duration_secs), 2) as "Avg Duration (sec)", -- calculates average call duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %", -- calculates timeout rate percentage
    ROUND((COUNT(*) FILTER (WHERE duration_secs > 300) * 100.0 / COUNT(*)::decimal), 2) as "Long Call Rate %" -- calculates percentage of calls longer than 5 minutes
FROM call_records -- from the main call_records table
WHERE source_type IS NOT NULL -- only includes records with valid source types
GROUP BY source_type -- groups results by technology type
ORDER BY "Total Calls" DESC; -- sorts by total call volume in descending order
-- Compares performance metrics across different technology types for technology assessment

-- 42. Time Period Performance Comparison (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Performance comparison across different time periods | Unit: Various Metrics | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Disable | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable conditional formatting, use color coding for trends, highlight significant changes
SELECT 
    'Last Hour' as "Time Period", -- identifies the time period for comparison
    COUNT(*) as "Call Count", -- counts calls in the period
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %" -- calculates timeout rate percentage
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '1 hour' -- only includes records from last hour

UNION ALL

SELECT 
    'Last 24 Hours' as "Time Period", -- identifies the time period for comparison
    COUNT(*) as "Call Count", -- counts calls in the period
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %" -- calculates timeout rate percentage
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '24 hour' -- only includes records from last 24 hours

UNION ALL

SELECT 
    'Last Week' as "Time Period", -- identifies the time period for comparison
    COUNT(*) as "Call Count", -- counts calls in the period
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %" -- calculates timeout rate percentage
FROM call_records -- from the main call_records table
WHERE date_time >= NOW() - INTERVAL '7 day' -- only includes records from last 7 days

UNION ALL

SELECT 
    'All Time' as "Time Period", -- identifies the time period for comparison
    COUNT(*) as "Call Count", -- counts calls in the period
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*)::decimal), 2) as "Timeout Rate %" -- calculates timeout rate percentage
FROM call_records; -- includes all records for historical comparison
-- Compares system performance across different time periods to identify trends and changes

-- 43. Source ID Performance Ranking (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Ranking of source IDs by performance metrics | Unit: Ranking Score | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Enable with 25 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Sort by performance score, use color gradients, enable source ID filtering
SELECT 
    calling_source_id as "Source ID", -- displays the source identifier
    COUNT(*) as "Total Calls", -- counts total calls from this source
    ROUND(AVG(duration_secs), 2) as "Avg Duration (sec)", -- calculates average call duration
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 2) as "Success Rate %", -- calculates success rate percentage
    ROUND(
        (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 60.0 / COUNT(*) + -- 60% weight for success rate
         GREATEST(0, 40 - AVG(duration_secs) * 40.0 / 600))::decimal, 2 -- 40% weight for duration performance (lower is better)
    ) as "Performance Score", -- calculates composite performance score
    RANK() OVER (ORDER BY 
        (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 60.0 / COUNT(*) + 
         GREATEST(0, 40 - AVG(duration_secs) * 40.0 / 600)) DESC
    ) as "Rank" -- ranks sources by performance score
FROM call_records -- from the main call_records table
WHERE calling_source_id IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with valid source IDs and duration
GROUP BY calling_source_id -- groups results by source ID
HAVING COUNT(*) >= 10 -- only includes sources with at least 10 calls for statistical significance
ORDER BY "Performance Score" DESC -- sorts by performance score in descending order
LIMIT 50; -- limits results to top 50 performing sources
-- Ranks source IDs by composite performance score for identifying best and worst performers

-- 44. Hourly vs Daily Performance (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Comparison of hourly performance patterns | Unit: Success Rate % | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Orientation: Vertical | Show value: Yes | Bar width: 0.9
-- 💡 BEST PRACTICE: Use different colors for different metrics, enable x-axis scrolling, show trend lines
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour of Day", -- extracts hour for hourly comparison
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 1) as "Success Rate %", -- calculates hourly success rate
    COUNT(*) as "Call Volume", -- counts calls per hour
    ROUND(AVG(duration_secs), 1) as "Avg Duration (sec)" -- calculates average duration per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with valid timestamps and duration
GROUP BY EXTRACT(HOUR FROM date_time) -- groups by hour of day
ORDER BY "Hour of Day"; -- sorts by hour chronologically
-- Compares performance metrics across different hours of the day to identify peak performance times

-- 45. Success vs Failure Correlation Analysis (Scatter plot)
-- 📊 OVERVIEW: Panel Type: Scatter plot | Description: Correlation between call duration and success rate | Unit: Duration vs Success | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: Auto | Point size: 4 | Show trend line: Yes | Alpha: 0.7
-- 💡 BEST PRACTICE: Use correlation colors, enable zoom, add regression line, show R-squared value
SELECT 
    AVG(duration_secs) as "Avg Duration (sec)", -- X-axis: average call duration per source
    (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*))::decimal as "Success Rate %", -- Y-axis: success rate percentage per source
    calling_source_id as "Source ID", -- identifies each point by source
    COUNT(*) as "Call Count" -- size metric for bubble sizing
FROM call_records -- from the main call_records table
WHERE calling_source_id IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with valid source IDs and duration
GROUP BY calling_source_id -- groups by source ID to create one point per source
HAVING COUNT(*) >= 5 -- only includes sources with at least 5 calls for meaningful correlation
ORDER BY "Call Count" DESC -- sorts by call count for consistent ordering
LIMIT 100; -- limits to top 100 sources for visualization clarity
-- Creates scatter plot to analyze correlation between call duration and success rates

-- 46. Technology Trend Comparison (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Trend comparison of different technologies over time | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Line width: 2 | Fill opacity: 0% | Stack series: No
-- 💡 BEST PRACTICE: Use distinct colors per technology, enable legend, add moving averages, stack if comparing totals
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals
    COUNT(*) FILTER (WHERE source_type = 'ISSI') as "ISSI Calls", -- counts ISSI technology calls per hour
    COUNT(*) FILTER (WHERE source_type = 'VOIP') as "VOIP Calls", -- counts VOIP technology calls per hour
    COUNT(*) FILTER (WHERE source_type IS NULL OR source_type NOT IN ('ISSI', 'VOIP')) as "Other Technology Calls" -- counts other technology calls per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND date_time >= NOW() - INTERVAL '7 day' -- only includes records from last 7 days
GROUP BY DATE_TRUNC('hour', date_time) -- groups by hour intervals
ORDER BY time; -- sorts chronologically by time
-- Compares usage trends of different technologies over time for technology adoption analysis
