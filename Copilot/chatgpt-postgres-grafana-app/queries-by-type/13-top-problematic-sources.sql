-- ═══════════════════════════════════════════════════════════════════════
-- 🏆 TOP PROBLEMATIC SOURCES
-- ═══════════════════════════════════════════════════════════════════════

-- 21. Top Problematic Source IDs (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Sources with highest failure rates | Unit: Source ID | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: Enable with 20 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable sorting by failure rate, use red color for high failure rates, add click-through filters
SELECT 
    calling_source_id as "Source ID", -- displays the source identifier for tracking
    COUNT(*) as "Total Calls", -- counts total number of calls from this source
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls", -- counts failed calls excluding normal disconnections
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*)::decimal), 2) as "Failure Rate %" -- calculates failure rate percentage with 2 decimal precision
FROM call_records -- from the main call_records table
WHERE calling_source_id IS NOT NULL -- only includes records with valid source IDs
GROUP BY calling_source_id -- groups results by source ID
HAVING COUNT(*) > 10 -- only includes sources with more than 10 calls for statistical significance
ORDER BY "Failure Rate %" DESC -- sorts by failure rate in descending order to show most problematic first
LIMIT 20; -- limits results to top 20 problematic sources
-- Identifies sources with highest failure rates for targeted troubleshooting and maintenance

-- 22. Top Failed Source Types (Bar gauge)
-- 📊 OVERVIEW: Panel Type: Bar gauge | Description: Source types ranked by failure count | Unit: Failed Calls | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and auto-max | Orientation: Horizontal | Show value: Yes | Bar thickness: 0.8
-- 💡 BEST PRACTICE: Use gradient colors (green to red), enable data labels, set display mode to basic
SELECT 
    source_type as "Source Type", -- displays the technology type (ISSI, VOIP, etc.)
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls" -- counts failed calls excluding normal disconnections
FROM call_records -- from the main call_records table
WHERE source_type IS NOT NULL -- only includes records with valid source types
GROUP BY source_type -- groups results by source type
ORDER BY "Failed Calls" DESC; -- sorts by failed call count in descending order
-- Shows which technology types have the most failures for technology-specific troubleshooting

-- 23. Most Common Disconnection Causes (Pie chart)
-- 📊 OVERVIEW: Panel Type: Pie chart | Description: Distribution of disconnection causes | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use distinct colors, enable legends, show percentages, limit to top 10 causes
SELECT 
    disconnection_cause as "Disconnection Cause", -- displays the disconnection reason
    COUNT(*) as "Count" -- counts occurrences of each disconnection cause
FROM call_records -- from the main call_records table
WHERE disconnection_cause IS NOT NULL -- only includes records with valid disconnection causes
GROUP BY disconnection_cause -- groups results by disconnection cause
ORDER BY COUNT(*) DESC -- sorts by count in descending order
LIMIT 10; -- limits results to top 10 causes for clarity
-- Shows distribution of disconnection causes to identify most common failure types

-- 31. Source Performance Comparison (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Comparison of different sources by success metrics | Unit: Percentage | Decimals: 1
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Orientation: Vertical | Show value: Yes | Bar width: 0.8
-- 💡 BEST PRACTICE: Use contrasting colors for different metrics, enable legend, add value labels
SELECT 
    calling_source_id as "Source ID", -- displays the source identifier
    ROUND(AVG(duration_secs), 1) as "Avg Duration (sec)", -- calculates average duration with 1 decimal precision
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*)::decimal), 1) as "Success Rate %" -- calculates success rate percentage with 1 decimal precision
FROM call_records -- from the main call_records table
WHERE calling_source_id IS NOT NULL AND duration_secs IS NOT NULL -- only includes records with valid source IDs and duration
GROUP BY calling_source_id -- groups results by source ID
HAVING COUNT(*) > 20 -- only includes sources with more than 20 calls for statistical significance
ORDER BY "Success Rate %" DESC -- sorts by success rate in descending order
LIMIT 15; -- limits results to top 15 performing sources
-- Compares source performance by success rate and duration for performance ranking

-- 34. Failure Distribution by Time (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Failure distribution across days and hours | Unit: Hour | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use color scale from blue (low) to red (high), enable tooltips, set bucket bounds auto
SELECT 
    EXTRACT(HOUR FROM date_time) as "Hour", -- extracts hour from timestamp for X-axis
    EXTRACT(DOW FROM date_time) as "Day of Week", -- extracts day of week (0=Sunday) for Y-axis
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls" -- counts failed calls excluding normal disconnections
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY EXTRACT(HOUR FROM date_time), EXTRACT(DOW FROM date_time) -- groups by hour and day of week
ORDER BY "Day of Week", "Hour"; -- sorts by day of week then hour
-- Creates heatmap showing when failures occur most frequently by day and time

-- 36. Source Technology Distribution (Donut chart)
-- 📊 OVERVIEW: Panel Type: Pie chart (donut) | Description: Distribution of calls by source technology | Unit: Call Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use donut style, distinct colors, enable legend with percentages, show total in center
SELECT 
    source_type as "Technology Type", -- displays the technology type
    COUNT(*) as "Call Count" -- counts total calls for each technology type
FROM call_records -- from the main call_records table
WHERE source_type IS NOT NULL -- only includes records with valid source types
GROUP BY source_type -- groups results by source type
ORDER BY COUNT(*) DESC; -- sorts by call count in descending order
-- Shows distribution of calls across different technology types for infrastructure analysis
