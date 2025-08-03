-- ═══════════════════════════════════════════════════════════════════════
-- 📊 DISTRIBUTION ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 54. Call Duration Distribution (Histogram)
-- 📊 OVERVIEW: Panel Type: Histogram | Description: Distribution of call durations across the system | Unit: Duration (seconds) | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and 3600 | Bucket size: 60 seconds | Show bucket boundaries: Yes | Y-axis: Call count
-- 💡 BEST PRACTICE: Use appropriate bin sizes, enable tooltips, add statistical overlay (mean, median)
SELECT 
    FLOOR(duration_secs / 60) * 60 as "Duration Bucket (sec)", -- creates 60-second buckets for duration distribution
    COUNT(*) as "Call Count" -- counts calls in each duration bucket
FROM call_records -- from the main call_records table
WHERE duration_secs IS NOT NULL AND duration_secs >= 0 AND duration_secs <= 3600 -- only includes valid durations up to 1 hour
GROUP BY FLOOR(duration_secs / 60) -- groups by duration buckets
ORDER BY "Duration Bucket (sec)"; -- sorts by duration bucket in ascending order
-- Shows distribution of call durations to identify common patterns and outliers

-- 55. Error Code Distribution (Pie chart)
-- 📊 OVERVIEW: Panel Type: Pie chart | Description: Distribution of different error codes in the system | Unit: Error Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use distinct colors, show percentages, limit to top 10 categories, enable legend
SELECT 
    CASE 
        WHEN disconnection_cause = '001 - User requested disconnection' THEN 'Normal Termination'
        WHEN disconnection_cause LIKE '%timeout%' THEN 'Timeout Errors'
        WHEN disconnection_cause LIKE '%failure%' THEN 'System Failures'
        WHEN disconnection_cause LIKE '%network%' THEN 'Network Issues'
        WHEN disconnection_cause LIKE '%connection%' THEN 'Connection Problems'
        WHEN disconnection_cause LIKE '%busy%' THEN 'Busy/Unavailable'
        ELSE 'Other Errors'
    END as "Error Category", -- categorizes disconnection causes for distribution analysis
    COUNT(*) as "Count" -- counts occurrences of each error category
FROM call_records -- from the main call_records table
WHERE disconnection_cause IS NOT NULL -- only includes records with valid disconnection causes
GROUP BY 
    CASE 
        WHEN disconnection_cause = '001 - User requested disconnection' THEN 'Normal Termination'
        WHEN disconnection_cause LIKE '%timeout%' THEN 'Timeout Errors'
        WHEN disconnection_cause LIKE '%failure%' THEN 'System Failures'
        WHEN disconnection_cause LIKE '%network%' THEN 'Network Issues'
        WHEN disconnection_cause LIKE '%connection%' THEN 'Connection Problems'
        WHEN disconnection_cause LIKE '%busy%' THEN 'Busy/Unavailable'
        ELSE 'Other Errors'
    END -- groups by error categories
ORDER BY COUNT(*) DESC; -- sorts by count in descending order
-- Shows distribution of different error types for troubleshooting prioritization

-- 56. Daily Call Volume Distribution (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Distribution of call volumes across days of the week | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Orientation: Vertical | Show value: Yes | Bar width: 0.8
-- 💡 BEST PRACTICE: Use consistent colors, add day labels, enable value display on bars
SELECT 
    CASE EXTRACT(DOW FROM date_time)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as "Day of Week", -- converts day of week number to readable names
    COUNT(*) as "Total Calls", -- counts total calls for each day
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Successful Calls", -- counts successful calls for each day
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls" -- counts failed calls for each day
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY EXTRACT(DOW FROM date_time) -- groups by day of week
ORDER BY EXTRACT(DOW FROM date_time); -- sorts by day of week chronologically
-- Shows call volume distribution across days of the week for capacity planning

-- 57. Hourly Traffic Distribution (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Traffic distribution across hours and days | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use color gradient from blue (low) to red (high), enable tooltips, set appropriate bucket bounds
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for X-axis
    CASE EXTRACT(DOW FROM date_time)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as "Day", -- converts day of week for Y-axis
    COUNT(*) as "Call Count" -- counts calls for each hour-day combination
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY EXTRACT(HOUR FROM date_time), EXTRACT(DOW FROM date_time) -- groups by hour and day of week
ORDER BY EXTRACT(DOW FROM date_time), EXTRACT(HOUR FROM date_time); -- sorts by day then hour
-- Creates heatmap showing traffic patterns across time for resource allocation

-- 58. Source Type Performance Distribution (Box plot / Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Statistical distribution of performance by source type | Unit: Statistical Metrics | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Disable | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Show quartiles, mean, and outliers, use statistical formatting
SELECT 
    source_type as "Technology Type", -- displays the technology type
    COUNT(*) as "Sample Size", -- shows number of calls for statistical significance
    ROUND(MIN(duration_secs), 2) as "Min Duration (sec)", -- shows minimum duration
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY duration_secs), 2) as "Q1 Duration (sec)", -- calculates first quartile
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_secs), 2) as "Median Duration (sec)", -- calculates median duration
    ROUND(AVG(duration_secs), 2) as "Mean Duration (sec)", -- calculates average duration
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY duration_secs), 2) as "Q3 Duration (sec)", -- calculates third quartile
    ROUND(MAX(duration_secs), 2) as "Max Duration (sec)", -- shows maximum duration
    ROUND(STDDEV(duration_secs), 2) as "Std Dev (sec)" -- calculates standard deviation
FROM call_records -- from the main call_records table
WHERE source_type IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with valid source types and duration
GROUP BY source_type -- groups by technology type
HAVING COUNT(*) >= 10 -- only includes types with sufficient sample size
ORDER BY "Mean Duration (sec)" DESC; -- sorts by average duration
-- Provides statistical distribution analysis of performance metrics by technology type

-- 59. Geographic Call Distribution (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Distribution of calls by source location/region | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Enable with 20 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable sorting, use percentage display, add geographic filtering if available
SELECT 
    SUBSTRING(calling_source_id FROM 1 FOR 3) as "Source Region", -- extracts first 3 characters as region identifier
    COUNT(*) as "Total Calls", -- counts total calls from each region
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER())::decimal, 2) as "Percentage %", -- calculates percentage of total calls
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Successful Calls", -- counts successful calls per region
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls", -- counts failed calls per region
    ROUND(AVG(duration_secs), 2) as "Avg Duration (sec)" -- calculates average duration per region
FROM call_records -- from the main call_records table
WHERE calling_source_id IS NOT NULL AND LENGTH(calling_source_id) >= 3 -- only includes records with valid source IDs of sufficient length
GROUP BY SUBSTRING(calling_source_id FROM 1 FOR 3) -- groups by extracted region identifier
HAVING COUNT(*) >= 5 -- only includes regions with at least 5 calls
ORDER BY "Total Calls" DESC -- sorts by total call count
LIMIT 50; -- limits to top 50 regions
-- Shows distribution of calls across different source regions for geographic analysis

-- 60. Peak Usage Pattern Distribution (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Distribution of peak usage patterns throughout the day | Unit: Peak Intensity | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Orientation: Vertical | Show value: Yes | Bar width: 0.7
-- 💡 BEST PRACTICE: Use gradient colors to show intensity, enable peak identification, add trend analysis
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for peak analysis
    COUNT(*) as "Call Volume", -- counts calls per hour
    ROUND((COUNT(*) * 100.0 / MAX(COUNT(*)) OVER())::decimal, 1) as "Peak Intensity %", -- calculates percentage of maximum hourly volume
    CASE 
        WHEN COUNT(*) >= MAX(COUNT(*)) OVER() * 0.8 THEN 'Peak Hours'
        WHEN COUNT(*) >= MAX(COUNT(*)) OVER() * 0.5 THEN 'High Usage'
        WHEN COUNT(*) >= MAX(COUNT(*)) OVER() * 0.3 THEN 'Medium Usage'
        ELSE 'Low Usage'
    END as "Usage Category" -- categorizes hours by usage level
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY EXTRACT(HOUR FROM date_time) -- groups by hour of day
ORDER BY EXTRACT(HOUR FROM date_time); -- sorts by hour chronologically
-- Analyzes peak usage patterns and categorizes hours by traffic intensity levels
