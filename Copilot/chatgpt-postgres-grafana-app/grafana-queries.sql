-- 🚀 UNIVERSAL DB - COMPLETE GRAFANA ANALYTICS QUERIES
-- 📊 Advanced insights from 24,842 call records - ALL POSSIBLE ANALYTICS
-- 🎯 Each query includes the recommended visualization type
-- 🔍 Focus: INTERFERENCE ANALYSIS, SYSTEM FAILURES & NETWORK DIAGNOSTICS

-- ═══════════════════════════════════════════════════════════════════════
-- 📈 BASIC OVERVIEW METRICS
-- ═══════════════════════════════════════════════════════════════════════

-- 1. Total Call Records (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Total number of call records in database | Unit: Short | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use big font, center alignment, add suffix "Records" in display name
SELECT COUNT(*) as value -- counts all rows and returns as 'value' column
FROM call_records; -- from the main call_records table
-- Gets all records from call_records table, counts them and returns total amount

-- 2. System Health Score (Gauge) - 0-100 based on success rate
-- 📊 OVERVIEW: Panel Type: Gauge | Description: System health percentage based on success rate | Unit: Percent (0-100) | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 70 / 90 / Red-Yellow-Green | Value mapping: None
-- 💡 BEST PRACTICE: Use "From thresholds" color scheme, enable needle display, set decimals to 1
SELECT 
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*))::numeric, 2) as value -- calculates success percentage and rounds to 2 decimals
FROM call_records; -- from the main call_records table
-- Calculates success rate by dividing successful calls (user disconnections) by total calls, multiplied by 100

-- 3. Critical Failures Count (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Count of critical system failures and errors | Unit: Short | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 5 / 20 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use red background when value > 0, add alert icon, enable sparkline for trend
SELECT COUNT(*) as value 
FROM call_records 
WHERE disconnection_cause IN ('034 - Error in SBS', '016 - Unknown TETRA identity', '019 - Call restoration of the other user failed'); -- Counts only calls that ended with specific critical error types

-- 4. Interference Events (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Speech and timer timeout interference events | Unit: Short | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 10 / 50 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Show trend direction, use orange color scheme, add description "Speech/Timer timeouts"
SELECT 
    COUNT(*) as value -- counts all records that match timeout criteria
FROM call_records -- from the main call_records table
WHERE disconnection_cause LIKE '%timeout%' -- filters for disconnection causes containing 'timeout'
    OR disconnection_cause LIKE '%timer%'; -- or disconnection causes containing 'timer'
-- Counts calls that ended due to timeout or timer-related issues (interference indicators)

-- 5. Network Load (Gauge) - Calls per hour average
-- 📊 OVERVIEW: Panel Type: Gauge | Description: Average network load in calls per hour | Unit: Calls/hour | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and Auto | Pagination: None | Thresholds: 100 / 200 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Set max based on your network capacity, use linear scale, show current value
SELECT 
    ROUND((COUNT(*) / NULLIF(EXTRACT(EPOCH FROM (MAX(date_time) - MIN(date_time))) / 3600, 0))::numeric, 2) as value -- calculates calls per hour and rounds to 2 decimals
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL; -- only includes records with valid timestamps
-- Calculates average calls per hour by dividing total calls by time span in hours

-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 SYSTEM FAILURE ANALYTICS - CAUSAS DE CAÍDAS
-- ═══════════════════════════════════════════════════════════════════════

-- 6. System Failures Over Time (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: System failures and errors over time by category | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use different colors per series, enable tooltip sort, set point size 5, stack series for better visualization
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for grouping
    COUNT(*) FILTER (WHERE disconnection_cause = '034 - Error in SBS') as "SBS Errors", -- counts SBS system errors per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '016 - Unknown TETRA identity') as "TETRA Identity Errors", -- counts TETRA identity errors per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '019 - Call restoration of the other user failed') as "Restoration Failures", -- counts call restoration failures per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '014 - SwMI requested disconnection') as "SwMI Disconnections" -- counts SwMI disconnections per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Groups calls by hour and counts different types of system failures for time series analysis

-- 7. Failure Rate by Location (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Failure rate percentage by location and hour | Unit: Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 20 / 80 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use percentage unit, enable data labels, set bucket size to 1 hour, sort Y-axis alphabetically
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    SUBSTRING(source_location FROM 1 FOR 10) as "Location",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as "Failure Rate %"
FROM call_records
WHERE source_location IS NOT NULL AND date_time IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    SUBSTRING(source_location FROM 1 FOR 10)
HAVING COUNT(*) > 5
ORDER BY 
    SUBSTRING(source_location FROM 1 FOR 10),
    EXTRACT(hour FROM date_time); -- Creates heatmap showing failure percentage by location and hour, excluding normal user disconnections

-- 8. Critical System Alerts (Alert list)
-- 📊 OVERVIEW: Panel Type: Alert list | Description: Critical system alerts from last 24 hours | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: 50 rows | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Enable unified alerting, set auto-refresh 30s, use alert severity mapping, show alert details
SELECT 
    source_location as "Location", -- shows the source location of the alert
    disconnection_cause as "Error Type", -- displays the type of error that occurred
    COUNT(*) as "Occurrence Count", -- counts how many times this error occurred at this location
    MAX(date_time) as "Last Occurrence" -- shows the most recent time this error happened
FROM call_records -- from the main call_records table
WHERE disconnection_cause IN ('034 - Error in SBS', '016 - Unknown TETRA identity', '019 - Call restoration of the other user failed') -- filters for only critical error types
    AND date_time >= NOW() - INTERVAL '24 hours' -- only includes records from the last 24 hours
GROUP BY source_location, disconnection_cause -- groups by location and error type combination
HAVING COUNT(*) > 3 -- only shows combinations with more than 3 occurrences
ORDER BY COUNT(*) DESC; -- sorts by frequency, showing most frequent errors first
-- Shows critical errors from last 24 hours grouped by location and error type, filtered for frequent occurrences

-- ═══════════════════════════════════════════════════════════════════════
-- 📡 INTERFERENCE DETECTION - ANÁLISIS DE INTERFERENCIAS
-- ═══════════════════════════════════════════════════════════════════════

-- 9. Interference Pattern Analysis (Time series)
-- 📊 OVERVIEW: Panel Type: Time series | Description: Interference patterns by timeout and reselection types | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use warm colors (red/orange/yellow), enable crosshair, show all values in tooltip, add trend lines
SELECT 
    DATE_TRUNC('hour', date_time) as time, -- truncates timestamp to hourly intervals for grouping
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts", -- counts speech timeout incidents per hour
    COUNT(*) FILTER (WHERE disconnection_cause = '013 - Expiry of timer') as "Timer Expiry", -- counts timer expiration incidents per hour
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections" -- counts cell reselection events per hour
FROM call_records -- from the main call_records table
WHERE date_time IS NOT NULL -- only includes records with valid timestamps
GROUP BY DATE_TRUNC('hour', date_time) -- groups results by hour intervals
ORDER BY time; -- sorts results chronologically by time
-- Tracks interference patterns over time by counting speech timeouts, timer expirations, and cell reselections per hour

-- 10. Cell Reselection Impact Analysis (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Impact of cell reselection on call failure rates | Unit: Count and Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use contrasting colors, enable data labels on bars, sort by failure rate, add percentage format
SELECT 
    cell_reselection as metric, -- groups by whether cell reselection occurred or not
    COUNT(*) as "Total Calls", -- counts total calls for each group
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls", -- counts failed calls excluding normal disconnections
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*))::numeric, 2) as "Failure Rate %" -- calculates failure percentage for each group
FROM call_records -- from the main call_records table
WHERE cell_reselection IS NOT NULL -- only includes records with valid cell reselection data
GROUP BY cell_reselection; -- groups results by cell reselection status
-- Compares failure rates between calls with and without cell reselection to analyze its impact on call success

-- 11. Location-Based Interference Hotspots (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Interference hotspots by location with timeout analysis | Unit: Count and Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: 15 rows | Thresholds: 20 / 80 / for Timeout Rate % | Value mapping: None
-- 💡 BEST PRACTICE: Use gradient colors for rate columns, enable row selection, add search box, set conditional formatting
SELECT 
    source_location as "Location", -- displays the source location of calls
    COUNT(*) as "Total Calls", -- counts total calls from each location
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts", -- counts speech timeout incidents per location
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections", -- counts cell reselection events per location
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*))::numeric, 2) as "Timeout Rate %" -- calculates timeout percentage for each location
FROM call_records -- from the main call_records table
WHERE source_location IS NOT NULL -- only includes records with valid location data
GROUP BY source_location -- groups results by location
HAVING COUNT(*) > 50 -- only includes locations with more than 50 calls for statistical relevance
ORDER BY "Timeout Rate %" DESC -- sorts by timeout rate, showing worst locations first
LIMIT 15; -- limits to top 15 problematic locations
-- Identifies locations with highest interference activity by analyzing timeout rates and cell reselections

-- 12. Network Quality Heatmap (Heatmap)
-- 📊 OVERVIEW: Panel Type: Heatmap | Description: Average call duration by hour and network type | Unit: Seconds | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 30 / 120 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use seconds unit, set bucket size to 1 hour, enable hover tooltip, normalize by row
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END as "Network Type",
    AVG(duration_secs)::numeric as "Avg Call Duration"
FROM call_records
WHERE source_location IS NOT NULL AND date_time IS NOT NULL AND duration_secs IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END
ORDER BY 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END,
    EXTRACT(hour FROM date_time); -- Creates heatmap showing average call duration by network type and hour to identify quality patterns

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 NETWORK CONTROLLER ANALYSIS - PUNTOS DE COMPARACIÓN
-- ═══════════════════════════════════════════════════════════════════════

-- 13. Controller Performance Comparison (Bar chart)
-- 📊 OVERVIEW: Panel Type: Bar chart | Description: Performance comparison across network controllers | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use contrasting colors per metric, enable data labels, sort by total calls, add legend
SELECT 
    network_controller as metric, -- groups by network controller identifier
    COUNT(*) as "Total Calls", -- counts total calls per controller
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Successful", -- counts successful calls per controller
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') as "Timeouts", -- counts timeout incidents per controller
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%') as "Errors" -- counts error incidents per controller
FROM call_records -- from the main call_records table
WHERE network_controller IS NOT NULL -- only includes records with valid controller data
GROUP BY network_controller -- groups results by controller
ORDER BY COUNT(*) DESC; -- sorts by total calls, showing busiest controllers first
-- Compares performance metrics across different network controllers to identify best and worst performers

-- 14. ISSI vs VOIP Interference Comparison (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Technology comparison between ISSI and VOIP for interference analysis | Unit: Mixed | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 30 / 60 / for Failure Rate % | Value mapping: None
-- 💡 BEST PRACTICE: Use conditional formatting for failure rate, enable sorting, add percentage bars, highlight differences
SELECT 
    source_type as "Technology", -- displays the technology type (ISSI or VOIP)
    COUNT(*) as "Total Calls", -- counts total calls per technology
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts", -- counts speech timeout incidents per technology
    COUNT(*) FILTER (WHERE disconnection_cause = '013 - Expiry of timer') as "Timer Expiry", -- counts timer expiration incidents per technology
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections", -- counts cell reselection events per technology
    ROUND(AVG(duration_secs), 2) as "Avg Duration", -- calculates average call duration per technology
    ROUND(COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*), 2) as "Failure Rate %" -- calculates failure percentage per technology
FROM call_records -- from the main call_records table
GROUP BY source_type; -- groups results by technology type
-- Compares interference and performance metrics between ISSI and VOIP technologies to identify technology-specific issues

-- 15. Fleet Interference Analysis (Bar gauge)
-- 📊 OVERVIEW: Panel Type: Bar gauge | Description: Interference rate percentage by fleet | Unit: Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 20 / 40 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use percentage format, enable value labels, sort descending, use gradient colors
SELECT 
    source_fleet as metric, -- groups by fleet identifier
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%' OR cell_reselection = 'Yes') * 100.0 / NULLIF(COUNT(*), 0) as value -- calculates interference percentage (timeouts + reselections)
FROM call_records -- from the main call_records table
WHERE source_fleet IS NOT NULL -- only includes records with valid fleet data
    AND source_fleet != '' -- and non-empty fleet values
GROUP BY source_fleet -- groups results by fleet
HAVING COUNT(*) > 20 -- only includes fleets with more than 20 calls for statistical relevance
ORDER BY value DESC; -- sorts by interference rate, showing worst fleets first
-- Identifies fleets with highest interference rates by analyzing timeout and reselection patterns

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

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 STATE ANALYSIS & TRENDS
-- ═══════════════════════════════════════════════════════════════════════

-- 19. System State Timeline (State timeline)
-- 📊 OVERVIEW: Panel Type: State timeline | Description: System status over time based on failure rates | Unit: Status Code | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: 0 and 2 | Pagination: None | Thresholds: None | Value mapping: NORMAL=0, WARNING=1, CRITICAL=2
-- 💡 BEST PRACTICE: Use traffic light colors (Green/Yellow/Red), enable region selection, show state duration labels
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    CASE 
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 20 THEN 'CRITICAL'
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 10 THEN 'WARNING'
        ELSE 'NORMAL'
    END as "System Status"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- 20. Network Capacity Trend (Trend)
-- 📊 CONFIGURATION: Panel Type: Time series | Format: Time series | X-axis: Sequence (not time) | Display: Line
-- 🎯 SETTINGS: Line width: 2 | Point size: 5 | Show points: Auto | Connect nulls: Yes | Gradient fill: 20%
-- 💡 BEST PRACTICE: Use for capacity planning, add moving average, enable annotations for capacity changes
SELECT 
    ROW_NUMBER() OVER (ORDER BY DATE_TRUNC('hour', date_time)) as x,
    COUNT(*) as y
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY x;

-- ═══════════════════════════════════════════════════════════════════════
-- 🏆 TOP PROBLEMATIC SOURCES & DESTINATIONS
-- ═══════════════════════════════════════════════════════════════════════

-- 21. Most Problematic Sources (Table)
-- 📊 OVERVIEW: Panel Type: Table | Description: Sources with highest failure rates and cell reselections | Unit: Count and Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: 20 rows | Thresholds: 20 / 80 / for Failure Rate % | Value mapping: None
SELECT 
    source as "Source",
    source_fleet as "Fleet",
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as "Failed Calls",
    ROUND((COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*))::numeric, 2) as "Failure Rate %",
    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as "Cell Reselections"
FROM call_records 
WHERE source IS NOT NULL
GROUP BY source, source_fleet
HAVING COUNT(*) > 10
ORDER BY "Failure Rate %" DESC
LIMIT 20; -- Identifies sources with highest failure rates, sorted by problem frequency for troubleshooting priority

-- 22. Error Distribution by Time (Pie chart)
-- 📊 OVERVIEW: Panel Type: Pie chart | Description: Distribution of errors by time of day periods | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use distinct colors, enable hover interactions, set minimum slice percentage to reduce clutter
SELECT 
    CASE 
        WHEN EXTRACT(hour FROM date_time) BETWEEN 6 AND 12 THEN 'Morning (6-12)'
        WHEN EXTRACT(hour FROM date_time) BETWEEN 12 AND 18 THEN 'Afternoon (12-18)'
        WHEN EXTRACT(hour FROM date_time) BETWEEN 18 AND 24 THEN 'Evening (18-24)'
        ELSE 'Night (0-6)'
    END as metric,
    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) as value
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY 
    CASE 
        WHEN EXTRACT(hour FROM date_time) BETWEEN 6 AND 12 THEN 'Morning (6-12)'
        WHEN EXTRACT(hour FROM date_time) BETWEEN 12 AND 18 THEN 'Afternoon (12-18)'
        WHEN EXTRACT(hour FROM date_time) BETWEEN 18 AND 24 THEN 'Evening (18-24)'
        ELSE 'Night (0-6)'
    END;

-- ═══════════════════════════════════════════════════════════════════════
-- 📈 ADVANCED SYSTEM DIAGNOSTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 23. Service Degradation Indicators (Table)
-- 📊 CONFIGURATION: Panel Type: Table | Format: Table | Sort: Timeout Rate % desc
-- 🎯 SETTINGS: Cell display: Gradient gauge | Color scheme: Red-Yellow-Green | Decimals: 2
SELECT 
    service_type as "Service Type",
    COUNT(*) as "Total Calls",
    ROUND(AVG(duration_secs), 2) as "Avg Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts",
    COUNT(*) FILTER (WHERE disconnection_cause = '013 - Expiry of timer') as "Timer Expiry",
    ROUND(COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*), 2) as "Timeout Rate %"
FROM call_records 
WHERE service_type IS NOT NULL
GROUP BY service_type
ORDER BY "Timeout Rate %" DESC;

-- 24. Location Performance Status History (Status history)
-- 📊 CONFIGURATION: Panel Type: Status history | Format: Time series | Value: 0-3 scale
-- 🎯 SETTINGS: Row height: 30px | Value mappings: 0=Green, 1=Yellow, 2=Orange, 3=Red
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    source_location as metric,
    CASE 
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 25 THEN 3
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 15 THEN 2
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 5 THEN 1
        ELSE 0
    END as value
FROM call_records 
WHERE date_time IS NOT NULL AND source_location IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time), source_location
HAVING COUNT(*) > 5
ORDER BY time, source_location;

-- 25. Critical Error Frequency Analysis (Bar chart)
-- 📊 CONFIGURATION: Panel Type: Bar chart | Format: Table | Orientation: Horizontal
-- 🎯 SETTINGS: Sort: Descending | Color: Single | Show values: On bars | X-axis: Categories
SELECT 
    disconnection_cause as metric,
    COUNT(*) as value
FROM call_records 
WHERE disconnection_cause NOT IN ('001 - User requested disconnection')
    AND disconnection_cause IS NOT NULL
GROUP BY disconnection_cause 
ORDER BY COUNT(*) DESC 
LIMIT 10;

-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 REAL-TIME MONITORING QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 26. Current Hour System Health (Gauge)
-- 📊 CONFIGURATION: Panel Type: Gauge | Format: Table | Min: 0 | Max: 100 | Unit: Percent
-- 🎯 SETTINGS: Thresholds: Red<50, Yellow 50-80, Green>80 | Show threshold markers: Yes
SELECT 
    COALESCE(COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0), 0) as value
FROM call_records 
WHERE date_time >= DATE_TRUNC('hour', NOW() - INTERVAL '1 hour');

-- 27. Active Interference Events (Stat)
-- 📊 CONFIGURATION: Panel Type: Stat | Format: Table | Color mode: Background
-- 🎯 SETTINGS: Thresholds: Green<5, Yellow 5-15, Red>15 | Show sparkline: Yes
SELECT COUNT(*) as value
FROM call_records 
WHERE (disconnection_cause LIKE '%timeout%' OR cell_reselection = 'Yes')
    AND date_time >= NOW() - INTERVAL '1 hour';

-- 28. Network Load Distribution (Pie chart)
-- 📊 CONFIGURATION: Panel Type: Pie chart | Format: Table | Legend: List
-- 🎯 SETTINGS: Display: Donut | Unit: Short | Show percentage: Yes | Tooltip: Both
SELECT 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN 'SBS Network'
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP Network'
        ELSE 'Other'
    END as metric,
    COUNT(*) as value
FROM call_records 
WHERE source_location IS NOT NULL
GROUP BY 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN 'SBS Network'
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP Network'
        ELSE 'Other'
    END;

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 COMPARATIVE ANALYSIS
-- ═══════════════════════════════════════════════════════════════════════

-- 29. Technology Performance Comparison (Bar chart)
-- 📊 CONFIGURATION: Panel Type: Bar chart | Format: Table | Display: Stacked bars
-- 🎯 SETTINGS: Stack series: Yes | Orientation: Vertical | Legend: Bottom | Color: By series
SELECT 
    source_type as metric,
    COUNT(*) as "Total",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Success",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%') as "Errors",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') as "Timeouts"
FROM call_records 
GROUP BY source_type;

-- 30. Hourly System Performance Heatmap (Heatmap)
-- 📊 CONFIGURATION: Panel Type: Heatmap | Format: Table | Color scale: Linear
-- 🎯 SETTINGS: X-axis: Hour | Y-axis: Day | Color: Green-Yellow-Red | Min: 0 | Max: 100
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    CASE EXTRACT(dow FROM date_time)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday' 
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as "Day",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0) as "Success Rate %"
FROM call_records
WHERE date_time IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    EXTRACT(dow FROM date_time)
ORDER BY 
    EXTRACT(dow FROM date_time),
    EXTRACT(hour FROM date_time);

-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 ADVANCED ALERT QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 31. System Degradation Alerts (Alert list)
-- 📊 CONFIGURATION: Panel Type: Alert list | Format: Table | State filter: All
-- 🎯 SETTINGS: Group by: Alert name | Sort: Alphabetical | Show annotations: Yes
SELECT 
    CONCAT(source_fleet, ' - ', source_location) as "Alert Source",
    COUNT(*) as "Incident Count",
    STRING_AGG(DISTINCT disconnection_cause, ', ') as "Error Types",
    MAX(date_time) as "Last Occurrence"
FROM call_records 
WHERE disconnection_cause NOT IN ('001 - User requested disconnection')
    AND date_time >= NOW() - INTERVAL '6 hours'
    AND source_fleet IS NOT NULL
GROUP BY source_fleet, source_location
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;

-- 32. Interference Detection Summary (Text)
-- 📊 CONFIGURATION: Panel Type: Text | Format: Text | Content: Markdown
-- 🎯 SETTINGS: Mode: Markdown | Text align: Left | Font size: Default | Background: Transparent
SELECT 
    CONCAT(
        '## System Status Report

',
        '**Total Calls:** ', COUNT(*), '

',
        '**Success Rate:** ', ROUND(COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*), 2), '%

',
        '**Critical Errors:** ', COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%'), '

',
        '**Interference Events:** ', COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%'), '

',
        '**Network Health:** ', 
        CASE 
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 90 THEN '🟢 EXCELLENT'
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 80 THEN '🟡 GOOD'
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 70 THEN '🟠 WARNING'
            ELSE '🔴 CRITICAL'
        END
    ) as status_report
FROM call_records 
WHERE date_time >= NOW() - INTERVAL '24 hours';

-- ═══════════════════════════════════════════════════════════════════════
-- 📈 ADVANCED SYSTEM DIAGNOSTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 23. Service Degradation Indicators (Table)
SELECT 
    service_type as "Service Type",
    COUNT(*) as "Total Calls",
    ROUND(AVG(duration_secs), 2) as "Avg Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '033 - Speech inactivity timeout') as "Speech Timeouts",
    COUNT(*) FILTER (WHERE disconnection_cause = '013 - Expiry of timer') as "Timer Expiry",
    ROUND(COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*), 2) as "Timeout Rate %"
FROM call_records 
WHERE service_type IS NOT NULL
GROUP BY service_type
ORDER BY "Timeout Rate %" DESC;

-- 24. Location Performance Status History (Status history)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    source_location as metric,
    CASE 
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 25 THEN 3
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 15 THEN 2
        WHEN COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('001 - User requested disconnection')) * 100.0 / COUNT(*) > 5 THEN 1
        ELSE 0
    END as value
FROM call_records 
WHERE date_time IS NOT NULL AND source_location IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time), source_location
HAVING COUNT(*) > 5
ORDER BY time, source_location;

-- 25. Critical Error Frequency Analysis (Bar chart)
SELECT 
    disconnection_cause as metric,
    COUNT(*) as value
FROM call_records 
WHERE disconnection_cause NOT IN ('001 - User requested disconnection')
    AND disconnection_cause IS NOT NULL
GROUP BY disconnection_cause 
ORDER BY COUNT(*) DESC 
LIMIT 10;

-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 REAL-TIME MONITORING QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 26. Current Hour System Health (Gauge)
-- 📊 OVERVIEW: Panel Type: Gauge | Description: Real-time system health for current hour | Unit: Percent | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: 0 and 100 | Pagination: None | Thresholds: 50 / 80 / Red-Yellow-Green | Value mapping: None
-- 💡 BEST PRACTICE: Use for real-time monitoring, set auto-refresh to 30s, enable threshold notifications
SELECT 
    COALESCE((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 0) as value
FROM call_records 
WHERE date_time >= DATE_TRUNC('hour', NOW() - INTERVAL '1 hour'); -- Calculates success rate for the current hour to monitor real-time system health

-- 27. Active Interference Events (Stat)
-- 📊 OVERVIEW: Panel Type: Stat | Description: Active interference events in last hour | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: 5 / 15 / Green-Yellow-Red | Value mapping: None
-- 💡 BEST PRACTICE: Use for alerting, enable trend indication, set warning color when increasing
SELECT COUNT(*) as value
FROM call_records 
WHERE (disconnection_cause LIKE '%timeout%' OR cell_reselection = 'Yes')
    AND date_time >= NOW() - INTERVAL '1 hour'; -- Counts recent interference events (timeouts and cell reselections) in the last hour for immediate alerting

-- 28. Network Load Distribution (Pie chart)
-- 📊 OVERVIEW: Panel Type: Pie chart | Description: Distribution of network load by technology type | Unit: Count | Decimals: 0
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: None
-- 💡 BEST PRACTICE: Use distinct colors, enable hover interactions, set minimum slice percentage to reduce clutter
SELECT 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN 'SBS Network'
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP Network'
        ELSE 'Other'
    END as metric,
    COUNT(*) as value
FROM call_records 
WHERE source_location IS NOT NULL
GROUP BY 
    CASE 
        WHEN source_location LIKE 'SBS%' THEN 'SBS Network'
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP Network'
        ELSE 'Other'
    END; -- Categorizes calls by network technology type to show distribution of load across different network types

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 COMPARATIVE ANALYSIS
-- ═══════════════════════════════════════════════════════════════════════

-- 29. Technology Performance Comparison (Bar chart)
SELECT 
    source_type as metric,
    COUNT(*) as "Total",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Success",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%') as "Errors",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') as "Timeouts"
FROM call_records 
GROUP BY source_type;

-- 30. Hourly System Performance Heatmap (Heatmap)
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    CASE EXTRACT(dow FROM date_time)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday' 
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as "Day",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0) as "Success Rate %"
FROM call_records
WHERE date_time IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    EXTRACT(dow FROM date_time)
ORDER BY 
    EXTRACT(dow FROM date_time),
    EXTRACT(hour FROM date_time);

-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 ADVANCED ALERT QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 31. System Degradation Alerts (Alert list)
SELECT 
    CONCAT(source_fleet, ' - ', source_location) as "Alert Source",
    COUNT(*) as "Incident Count",
    STRING_AGG(DISTINCT disconnection_cause, ', ') as "Error Types",
    MAX(date_time) as "Last Occurrence"
FROM call_records 
WHERE disconnection_cause NOT IN ('001 - User requested disconnection')
    AND date_time >= NOW() - INTERVAL '6 hours'
    AND source_fleet IS NOT NULL
GROUP BY source_fleet, source_location
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;

-- 32. Interference Detection Summary (Text)
-- 📊 OVERVIEW: Panel Type: Text | Description: System status report with key metrics in markdown format | Unit: Text | Decimals: 2
-- 🎯 SETTINGS: Min/Max Values: None as it valuates all | Pagination: None | Thresholds: None | Value mapping: Health status icons
-- 💡 BEST PRACTICE: Use markdown formatting, include health indicators, update in real-time
SELECT 
    CONCAT(
        '## System Status Report\n\n',
        '**Total Calls:** ', COUNT(*), '\n\n',
        '**Success Rate:** ', ROUND(COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*), 2), '%\n\n',
        '**Critical Errors:** ', COUNT(*) FILTER (WHERE disconnection_cause LIKE '%Error%'), '\n\n',
        '**Interference Events:** ', COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%'), '\n\n',
        '**Network Health:** ', 
        CASE 
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 90 THEN '🟢 EXCELLENT'
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 80 THEN '🟡 GOOD'
            WHEN COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) > 70 THEN '🟠 WARNING'
            ELSE '🔴 CRITICAL'
        END
    ) as status_report
FROM call_records 
WHERE date_time >= NOW() - INTERVAL '24 hours'; -- Generates formatted text report with key system metrics and health status indicators for the last 24 hours

-- ═══════════════════════════════════════════════════════════════════════
-- 🕐 TIME SERIES ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 6. Calls Over Time by Hour (Time series)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE source_type = 'ISSI') as "ISSI Calls",
    COUNT(*) FILTER (WHERE source_type = 'VOIP') as "VOIP Calls"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- 7. Average Duration Over Time (Time series)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    AVG(duration_secs) as "Average Duration",
    MAX(duration_secs) as "Max Duration",
    MIN(duration_secs) as "Min Duration"
FROM call_records 
WHERE date_time IS NOT NULL AND duration_secs IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- 8. Call Success Rate Over Time (Time series)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') * 100.0 / COUNT(*) as "Timeout Rate %",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%failure%') * 100.0 / COUNT(*) as "Failure Rate %"
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY time;

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 DISTRIBUTION ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 9. Source Type Distribution (Pie chart)
SELECT 
    source_type as metric, 
    COUNT(*) as value 
FROM call_records 
GROUP BY source_type 
ORDER BY COUNT(*) DESC;

-- 10. Call Duration Distribution (Histogram)
SELECT duration_secs 
FROM call_records 
WHERE duration_secs IS NOT NULL AND duration_secs > 0;

-- 11. Priority Distribution (Pie chart)
SELECT 
    priority::text as metric, 
    COUNT(*) as value 
FROM call_records 
WHERE priority IS NOT NULL 
GROUP BY priority 
ORDER BY priority;

-- 12. Duration Categories (Pie chart)
SELECT 
    CASE 
        WHEN duration_secs <= 5 THEN 'Very Short (≤5s)'
        WHEN duration_secs <= 15 THEN 'Short (6-15s)'
        WHEN duration_secs <= 60 THEN 'Medium (16-60s)'
        WHEN duration_secs <= 180 THEN 'Long (61-180s)'
        ELSE 'Very Long (>180s)'
    END as metric,
    COUNT(*) as value
FROM call_records 
WHERE duration_secs IS NOT NULL
GROUP BY 
    CASE 
        WHEN duration_secs <= 5 THEN 'Very Short (≤5s)'
        WHEN duration_secs <= 15 THEN 'Short (6-15s)'
        WHEN duration_secs <= 60 THEN 'Medium (16-60s)'
        WHEN duration_secs <= 180 THEN 'Long (61-180s)'
        ELSE 'Very Long (>180s)'
    END
ORDER BY 
    CASE 
        WHEN duration_secs <= 5 THEN 1
        WHEN duration_secs <= 15 THEN 2
        WHEN duration_secs <= 60 THEN 3
        WHEN duration_secs <= 180 THEN 4
        ELSE 5
    END;

-- ═══════════════════════════════════════════════════════════════════════
-- 🏢 FLEET & OPERATIONAL ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 13. Top Source Fleets Performance (Table)
SELECT 
    source_fleet as "Fleet", 
    COUNT(*) as "Total Calls",
    AVG(duration_secs) as "Avg Duration",
    MAX(duration_secs) as "Max Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %",
    COUNT(DISTINCT source) as "Unique Sources"
FROM call_records 
WHERE source_fleet IS NOT NULL AND source_fleet != '' 
GROUP BY source_fleet 
ORDER BY COUNT(*) DESC 
LIMIT 15;

-- 14. Fleet Activity Heatmap (Heatmap)
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    source_fleet as "Fleet",
    COUNT(*) as "Call Count"
FROM call_records
WHERE source_fleet IS NOT NULL AND date_time IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    source_fleet
ORDER BY 
    source_fleet,
    EXTRACT(hour FROM date_time);

-- 15. Destination Fleet Analysis (Bar chart)
SELECT 
    destination_fleet as metric,
    COUNT(*) as value
FROM call_records 
WHERE destination_fleet IS NOT NULL AND destination_fleet != ''
GROUP BY destination_fleet 
ORDER BY COUNT(*) DESC 
LIMIT 15;

-- ═══════════════════════════════════════════════════════════════════════
-- 🔒 SECURITY & QUALITY ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 16. Security Features Usage (Pie chart)
SELECT 
    CASE 
        WHEN ai_security = 'Yes' AND e2ee_security = 'Yes' THEN 'AI + E2EE'
        WHEN ai_security = 'Yes' THEN 'AI Only'
        WHEN e2ee_security = 'Yes' THEN 'E2EE Only'
        ELSE 'No Security'
    END as metric,
    COUNT(*) as value
FROM call_records 
GROUP BY 
    CASE 
        WHEN ai_security = 'Yes' AND e2ee_security = 'Yes' THEN 'AI + E2EE'
        WHEN ai_security = 'Yes' THEN 'AI Only'
        WHEN e2ee_security = 'Yes' THEN 'E2EE Only'
        ELSE 'No Security'
    END
ORDER BY COUNT(*) DESC;

-- 17. Voice Recording Usage (Gauge)
SELECT 
    COUNT(*) FILTER (WHERE voice_recording = 'Yes') * 100.0 / COUNT(*) as value
FROM call_records;

-- 18. Call Forwarding Analysis (Bar gauge)
SELECT 
    call_forwarding as metric,
    COUNT(*) as value
FROM call_records 
WHERE call_forwarding IS NOT NULL
GROUP BY call_forwarding;

-- ═══════════════════════════════════════════════════════════════════════
-- ❌ FAILURE & DISCONNECTION ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 19. Top Disconnection Causes (Bar chart)
SELECT 
    disconnection_cause as metric, 
    COUNT(*) as value 
FROM call_records 
WHERE disconnection_cause IS NOT NULL 
GROUP BY disconnection_cause 
ORDER BY COUNT(*) DESC 
LIMIT 10;

-- 20. Failure Analysis by Source Type (Bar chart)
SELECT 
    source_type as metric,
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%') as "Timeouts",
    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%failure%') as "Failures",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as "Normal"
FROM call_records 
GROUP BY source_type;

-- 21. Disconnection Cause Timeline (State timeline)
SELECT 
    DATE_TRUNC('hour', date_time) as time,
    disconnection_cause as metric,
    COUNT(*) as value
FROM call_records 
WHERE date_time IS NOT NULL AND disconnection_cause IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time), disconnection_cause
ORDER BY time;

-- ═══════════════════════════════════════════════════════════════════════
-- 🌍 LOCATION & NETWORK ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 22. Network Controller Performance (Table)
SELECT 
    network_controller as "Controller", 
    COUNT(*) as "Total Calls",
    source_type as "Source Type",
    AVG(duration_secs) as "Avg Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %"
FROM call_records 
WHERE network_controller IS NOT NULL 
GROUP BY network_controller, source_type 
ORDER BY COUNT(*) DESC;

-- 23. Source Location Activity (Bar chart)
SELECT 
    source_location as metric,
    COUNT(*) as value
FROM call_records 
WHERE source_location IS NOT NULL AND source_location != ''
GROUP BY source_location 
ORDER BY COUNT(*) DESC 
LIMIT 20;

-- 24. Cell Reselection Impact (Pie chart)
SELECT 
    cell_reselection as metric,
    COUNT(*) as value
FROM call_records 
WHERE cell_reselection IS NOT NULL
GROUP BY cell_reselection;

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 SERVICE TYPE & COMMUNICATION ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 25. Service Types Analysis (Table)
SELECT 
    service_type as "Service Type", 
    COUNT(*) as "Calls", 
    AVG(duration_secs) as "Avg Duration",
    MAX(duration_secs) as "Max Duration",
    MIN(duration_secs) as "Min Duration",
    STDDEV(duration_secs) as "Duration StdDev"
FROM call_records 
WHERE service_type IS NOT NULL 
GROUP BY service_type 
ORDER BY COUNT(*) DESC;

-- 26. Service Type Info Distribution (Bar chart)
SELECT 
    service_type_info as metric,
    COUNT(*) as value
FROM call_records 
WHERE service_type_info IS NOT NULL AND service_type_info != ''
GROUP BY service_type_info 
ORDER BY COUNT(*) DESC 
LIMIT 15;

-- ═══════════════════════════════════════════════════════════════════════
-- ⏱️ QUEUE & PERFORMANCE ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════════════
-- 🔥 HEATMAPS & PATTERN ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 30. Hourly Activity Heatmap (Heatmap)
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    CASE EXTRACT(dow FROM date_time)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday' 
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as "Day",
    COUNT(*) as "Call Count"
FROM call_records
WHERE date_time IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    EXTRACT(dow FROM date_time)
ORDER BY 
    EXTRACT(dow FROM date_time),
    EXTRACT(hour FROM date_time);

-- 31. Duration Heatmap by Hour and Priority (Heatmap)
SELECT
    EXTRACT(hour FROM date_time) as "Hour",
    priority::text as "Priority",
    AVG(duration_secs) as "Avg Duration"
FROM call_records
WHERE date_time IS NOT NULL AND priority IS NOT NULL AND duration_secs IS NOT NULL
GROUP BY 
    EXTRACT(hour FROM date_time),
    priority
ORDER BY 
    priority,
    EXTRACT(hour FROM date_time);

-- ═══════════════════════════════════════════════════════════════════════
-- 🏆 TOP PERFORMERS & OUTLIERS
-- ═══════════════════════════════════════════════════════════════════════

-- 32. Longest Calls (Table)
SELECT 
    source as "Source", 
    destination as "Destination", 
    duration_secs as "Duration (sec)", 
    disconnection_cause as "End Reason",
    service_type as "Service",
    source_fleet as "Fleet"
FROM call_records 
WHERE duration_secs > 60 
ORDER BY duration_secs DESC 
LIMIT 25;

-- 33. Most Active Sources (Table)
SELECT 
    source as "Source",
    COUNT(*) as "Total Calls",
    source_fleet as "Fleet",
    AVG(duration_secs) as "Avg Duration",
    MAX(duration_secs) as "Max Duration"
FROM call_records 
WHERE source IS NOT NULL
GROUP BY source, source_fleet
ORDER BY COUNT(*) DESC 
LIMIT 20;

-- 34. Most Called Destinations (Table)
SELECT 
    destination as "Destination",
    COUNT(*) as "Incoming Calls",
    destination_fleet as "Fleet",
    AVG(duration_secs) as "Avg Duration"
FROM call_records 
WHERE destination IS NOT NULL
GROUP BY destination, destination_fleet
ORDER BY COUNT(*) DESC 
LIMIT 20;

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 ADVANCED COMPARATIVE ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 35. ISSI vs VOIP Performance Comparison (Table)
SELECT 
    source_type as "Type",
    COUNT(*) as "Total Calls",
    AVG(duration_secs) as "Avg Duration", 
    MAX(duration_secs) as "Max Duration",
    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / COUNT(*) as "Success Rate %",
    AVG(time_in_queue_secs) as "Avg Queue Time",
    COUNT(*) FILTER (WHERE voice_recording = 'Yes') * 100.0 / COUNT(*) as "Recording Rate %"
FROM call_records 
GROUP BY source_type;

-- 36. UTC Offset Analysis (Bar chart)
SELECT 
    utc_offset_minutes::text as metric,
    COUNT(*) as value
FROM call_records 
WHERE utc_offset_minutes IS NOT NULL
GROUP BY utc_offset_minutes 
ORDER BY COUNT(*) DESC;

-- ═══════════════════════════════════════════════════════════════════════
-- 💡 OPERATIONAL INSIGHTS & EFFICIENCY
-- ═══════════════════════════════════════════════════════════════════════

-- 37. Efficiency Metrics by Fleet (Gauge)
SELECT 
    source_fleet as metric,
    AVG(duration_secs) / NULLIF(AVG(time_in_queue_secs + duration_secs), 0) * 100 as value
FROM call_records 
WHERE source_fleet IS NOT NULL 
    AND time_in_queue_secs IS NOT NULL 
    AND duration_secs IS NOT NULL
GROUP BY source_fleet
ORDER BY value DESC;

-- 38. Call Pattern Trends (Trend)
SELECT 
    ROW_NUMBER() OVER (ORDER BY DATE_TRUNC('hour', date_time)) as x,
    COUNT(*) as y
FROM call_records 
WHERE date_time IS NOT NULL
GROUP BY DATE_TRUNC('hour', date_time)
ORDER BY x;

-- 39. Priority vs Duration Relationship (XY Chart)
SELECT 
    priority as x,
    duration_secs as y
FROM call_records 
WHERE priority IS NOT NULL AND duration_secs IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- 🎪 ADVANCED STATISTICAL ANALYTICS
-- ═══════════════════════════════════════════════════════════════════════

-- 40. Duration Statistics by Source Type (Table)
SELECT 
    source_type as "Source Type",
    COUNT(*) as "Count",
    AVG(duration_secs) as "Mean",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_secs) as "Median",
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_secs) as "95th Percentile",
    STDDEV(duration_secs) as "Std Deviation",
    MIN(duration_secs) as "Min",
    MAX(duration_secs) as "Max"
FROM call_records 
WHERE duration_secs IS NOT NULL
GROUP BY source_type;

-- 41. Call Volume Percentiles (Bar gauge)
SELECT 
    'P50' as metric, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hourly_calls) as value
FROM (
    SELECT COUNT(*) as hourly_calls 
    FROM call_records 
    WHERE date_time IS NOT NULL 
    GROUP BY DATE_TRUNC('hour', date_time)
) t
UNION ALL
SELECT 
    'P95' as metric, PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY hourly_calls) as value
FROM (
    SELECT COUNT(*) as hourly_calls 
    FROM call_records 
    WHERE date_time IS NOT NULL 
    GROUP BY DATE_TRUNC('hour', date_time)
) t;

-- ═══════════════════════════════════════════════════════════════════════
-- 🚨 ALERT-WORTHY QUERIES
-- ═══════════════════════════════════════════════════════════════════════

-- 42. High Failure Rate Sources (Alert list)
SELECT 
    source as "Source",
    COUNT(*) as "Total Calls",
    COUNT(*) FILTER (WHERE disconnection_cause NOT LIKE '%User requested%') * 100.0 / COUNT(*) as "Failure Rate %"
FROM call_records 
WHERE source IS NOT NULL
GROUP BY source
HAVING COUNT(*) > 10 AND COUNT(*) FILTER (WHERE disconnection_cause NOT LIKE '%User requested%') * 100.0 / COUNT(*) > 20
ORDER BY "Failure Rate %" DESC;
