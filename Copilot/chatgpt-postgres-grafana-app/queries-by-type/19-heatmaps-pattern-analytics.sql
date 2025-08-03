-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 HEATMAPS & PATTERN ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 61. Call Volume Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Call volume intensity across days and hours | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use blue-to-red gradient, enable tooltips, set bucket bounds to auto, show color scale
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for X-axis (0-23)
    EXTRACT(DOW FROM date_time) as "Day of Week", -- extracts day of week for Y-axis (0=Sunday)
    COUNT(*) as "Call Volume" -- counts calls for each hour-day combination creating heat intensity
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY EXTRACT(HOUR FROM date_time), EXTRACT(DOW FROM date_time) -- groups by hour and day of week
ORDER BY "Day of Week", "Hour"; -- sorts by day of week then hour for proper heatmap ordering
-- Creates heatmap showing call volume patterns across the week for capacity planning

-- 62. Error Rate Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Error rate distribution across time periods | Unit: Error Percentage | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use green-to-red gradient (low to high error rates), enable tooltips, set appropriate color thresholds
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for X-axis
    EXTRACT(DOW FROM date_time) as "Day of Week", -- extracts day of week for Y-axis
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / GREATEST(COUNT(*), 1))::decimal, 1) as "Error Rate %" -- calculates error rate percentage for heat intensity
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY EXTRACT(HOUR FROM date_time), EXTRACT(DOW FROM date_time) -- groups by hour and day of week
HAVING COUNT(*) >= 5 -- only includes time periods with at least 5 calls for statistical significance
ORDER BY "Day of Week", "Hour"; -- sorts by day of week then hour
-- Shows error rate patterns across time to identify problematic periods

-- 63. Duration Pattern Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Average call duration patterns across time | Unit: Average Duration (seconds) | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 600 | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use yellow-to-red gradient for duration intensity, enable tooltips, normalize color scale
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for X-axis
    EXTRACT(DOW FROM date_time) as "Day of Week", -- extracts day of week for Y-axis
    ROUND(AVG(duration_secs), 1) as "Avg Duration (sec)" -- calculates average duration for heat intensity
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with valid timestamps and duration
GROUP BY EXTRACT(HOUR FROM date_time), EXTRACT(DOW FROM date_time) -- groups by hour and day of week
HAVING COUNT(*) >= 3 -- only includes time periods with at least 3 calls for reliable averages
ORDER BY "Day of Week", "Hour"; -- sorts by day of week then hour
-- Shows duration patterns to identify when calls typically run longer

-- 64. Source Performance Correlation Matrix (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Performance correlation between different sources | Unit: Correlation Score | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: -1 and 1 | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use diverging color scale (red-white-blue), show correlation values, enable source filtering
WITH source_metrics AS (
    SELECT 
        calling_source_id,
        COUNT(*) as call_count, -- counts total calls per source
        AVG(duration_secs) as avg_duration, -- calculates average duration per source
        COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as success_rate -- calculates success rate per source
    FROM call_records 
    WHERE calling_source_id IS NOT NULL AND duration_secs IS NOT NULL
    GROUP BY calling_source_id
    HAVING COUNT(*) >= 10 -- only includes sources with sufficient data
),
source_pairs AS (
    SELECT 
        s1.calling_source_id as "Source A", -- first source for correlation analysis
        s2.calling_source_id as "Source B", -- second source for correlation analysis
        (s1.success_rate - AVG(s1.success_rate) OVER()) * (s2.success_rate - AVG(s2.success_rate) OVER()) / 
        (STDDEV(s1.success_rate) OVER() * STDDEV(s2.success_rate) OVER()) as "Correlation Score" -- calculates correlation coefficient
    FROM source_metrics s1
    CROSS JOIN source_metrics s2
    WHERE s1.calling_source_id <= s2.calling_source_id -- avoids duplicate pairs
)
SELECT 
    "Source A",
    "Source B", 
    ROUND("Correlation Score"::decimal, 2) as "Correlation" -- rounds correlation for display
FROM source_pairs
WHERE "Correlation Score" IS NOT NULL AND ABS("Correlation Score") > 0.1 -- only shows meaningful correlations
ORDER BY ABS("Correlation Score") DESC -- sorts by absolute correlation strength
LIMIT 100; -- limits results for visualization clarity
-- Creates correlation matrix showing performance relationships between sources

-- 65. Technology Usage Pattern Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Technology usage patterns across time | Unit: Technology Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use distinct color scales for each technology, enable legend, show relative intensities
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for X-axis
    source_type as "Technology Type", -- uses technology type for Y-axis instead of day
    COUNT(*) as "Usage Count" -- counts usage for each hour-technology combination
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND source_type IS NOT NULL -- only includes records with valid timestamps and technology
GROUP BY EXTRACT(HOUR FROM date_time), source_type -- groups by hour and technology type
ORDER BY source_type, "Hour"; -- sorts by technology type then hour
-- Shows when different technologies are most heavily used throughout the day

-- 66. Failure Pattern Analysis (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Failure patterns across sources and time | Unit: Failure Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use red intensity gradient, enable drill-down, filter out normal disconnections
SELECT 
    SUBSTRING(calling_source_id FROM 1 FOR 5) as "Source Prefix", -- groups sources by prefix for pattern analysis
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for time-based analysis
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failure Count" -- counts failures excluding normal disconnections
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND calling_source_id IS NOT NULL -- only includes records with valid timestamps and source IDs
    AND LENGTH(calling_source_id) >= 5 -- ensures source ID is long enough for prefix extraction
GROUP BY SUBSTRING(calling_source_id FROM 1 FOR 5), EXTRACT(HOUR FROM date_time) -- groups by source prefix and hour
HAVING COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) > 0 -- only shows combinations with failures
ORDER BY "Source Prefix", "Hour"; -- sorts by source prefix then hour
-- Identifies failure patterns across source groups and time periods

-- 67. Quality Score Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Service quality scores across time and sources | Unit: Quality Score | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use green-to-red gradient (high to low quality), enable tooltips with score breakdown
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour for X-axis
    CASE 
        WHEN source_type = 'ISSI' THEN 'ISSI'
        WHEN source_type = 'VOIP' THEN 'VOIP'
        ELSE 'Other'
    END as "Technology", -- groups technologies for Y-axis
    ROUND(
        (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 60.0 / COUNT(*) + -- 60% weight for success rate
         GREATEST(0, 40 - AVG(duration_secs) * 40.0 / 600))::decimal, 1 -- 40% weight for duration performance (shorter is better)
    ) as "Quality Score" -- calculates composite quality score (0-100)
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND source_type IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with complete data
GROUP BY EXTRACT(HOUR FROM date_time), 
    CASE 
        WHEN source_type = 'ISSI' THEN 'ISSI'
        WHEN source_type = 'VOIP' THEN 'VOIP'
        ELSE 'Other'
    END -- groups by hour and technology category
HAVING COUNT(*) >= 3 -- only includes combinations with at least 3 calls for reliable scores
ORDER BY "Technology", "Hour"; -- sorts by technology then hour
-- Shows service quality patterns across technologies and time periods

-- 68. Temporal Call Pattern Clustering (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Clusters of similar call patterns over time | Unit: Pattern Intensity | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use cluster colors, enable pattern identification, show clustering intensity
SELECT 
    FLOOR(EXTRACT(HOUR FROM date_time) / 4) * 4 as "Hour Block", -- creates 4-hour time blocks for pattern analysis
    CASE 
        WHEN COUNT(*) >= 100 THEN 'High Traffic'
        WHEN COUNT(*) >= 50 THEN 'Medium Traffic'
        WHEN COUNT(*) >= 20 THEN 'Low Traffic'
        ELSE 'Minimal Traffic'
    END as "Traffic Pattern", -- categorizes traffic levels into patterns
    COUNT(*) as "Pattern Intensity" -- measures intensity of each pattern
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY FLOOR(EXTRACT(HOUR FROM date_time) / 4), 
    CASE 
        WHEN COUNT(*) >= 100 THEN 'High Traffic'
        WHEN COUNT(*) >= 50 THEN 'Medium Traffic'
        WHEN COUNT(*) >= 20 THEN 'Low Traffic'
        ELSE 'Minimal Traffic'
    END -- groups by time block and traffic pattern
ORDER BY "Hour Block", "Traffic Pattern"; -- sorts by time block then pattern
-- Identifies temporal clustering patterns in call traffic for predictive analysis

-- 69. Multi-dimensional Performance Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Multi-dimensional performance analysis | Unit: Performance Index | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use performance gradient colors, enable multi-metric tooltips, normalize across dimensions
SELECT 
    EXTRACT(DOW FROM date_time) as "Day of Week", -- extracts day of week for one dimension
    CASE 
        WHEN EXTRACT(HOUR FROM date_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM date_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM date_time) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END as "Time Period", -- groups hours into time periods for another dimension
    ROUND(
        (COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 30.0 / COUNT(*) + -- 30% weight for success rate
         COUNT(*) * 20.0 / 1000 + -- 20% weight for volume (normalized to 1000 max)
         GREATEST(0, 30 - AVG(duration_secs) * 30.0 / 600) + -- 30% weight for duration performance
         GREATEST(0, 20 - COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 20.0 / COUNT(*)))::decimal, 1 -- 20% weight for timeout performance
    ) as "Performance Index" -- calculates multi-dimensional performance index (0-100)
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with complete data
GROUP BY EXTRACT(DOW FROM date_time), 
    CASE 
        WHEN EXTRACT(HOUR FROM date_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM date_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM date_time) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END -- groups by day of week and time period
HAVING COUNT(*) >= 5 -- only includes combinations with sufficient data
ORDER BY "Day of Week", "Time Period"; -- sorts by day of week then time period
-- Creates comprehensive performance heatmap across multiple time dimensions for strategic analysis
