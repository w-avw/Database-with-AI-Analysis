-- ═════════════════════════════════════════════════════════════════════════════════════════════
-- 1. Call Traffic by Hour and Day of Week
-- 📊 Bar Chart
-- 📝 DESCRIPTION: Distribution of call volume across different hours and days for resource planning
-- 
-- 📈 BAR CHART SETTINGS:
-- • Show values on bars: True
-- • Min/Max Values: None as it valuates all
-- • Pagination: None
-- • Thresholds: 5 / 20 / Green-Yellow-Red
-- • Value mapping: None
-- 
-- 🎨 VISUAL CONFIGURATION:
-- • X-axis (Hour): Label "Hour of Day", Min: 0, Max: 23, Unit: Custom "h", Decimals: 0
-- • Y-axis (Call Count): Label "Number of Calls", Unit: Short, Decimals: 0, Scale: Linear
-- • Show grid: True on both axes
-- 
-- 📊 TOOLTIP CONFIGURATION:
-- • Mode: All series
-- • Sort order: Descending
-- • Header: Hour {{Hour}} - {{Day}}
-- ═════════════════════════════════════════════════════════════════════════════════════════════

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

-- ═════════════════════════════════════════════════════════════════════════════════════════════
-- 2. Failure Rate by Location and Hour (BAR CHART)
-- 📊 Bar Chart
-- 📝 DESCRIPTION: Shows failure percentage patterns across locations and time periods for quality monitoring
-- 
-- 📈 BAR CHART SETTINGS:
-- • Orientation: Vertical
-- • Bar width: 0.8 (80% of available space)
-- • Bar alignment: Center
-- • Show values on bars: True
-- • Stacking: None (individual bars for each location-hour combination)
-- • Group by: Location (creates grouped bars by location)
-- 
-- 🎨 VISUAL CONFIGURATION:
-- • X-axis (Location): Label "Location", Show all labels, Rotation: 45° (for readability)
-- • Y-axis (Failure Rate %): Label "Failure Rate (%)", Min: 0, Max: 100, Unit: Percent (%), Decimals: 1, Scale: Linear
-- • Show grid: True on both axes
-- • Grid color: Light gray (rgba(128,128,128,0.2))
-- 
-- 🏷️ LEGEND SETTINGS:
-- • Display mode: Table
-- • Placement: Right or Bottom
-- • Show legend: True (if grouping by hour, otherwise hide for single series)
-- • Values in legend: Max, Min, Mean
-- • Max items: 10 (to avoid overcrowding with many locations)
-- 
-- 🎨 COLOR SCHEME (by Location):
-- • Use palette: Classic or Spectrum
-- • Color mode: Palette (auto-assigns colors to each location)
-- • Alternative: Custom colors for specific locations if needed
-- 
-- 🚨 THRESHOLD SETTINGS (for visual alerts):
-- • 0-5%: Green zone - Excellent performance
-- • 5-15%: Yellow zone - Acceptable performance  
-- • 15-25%: Orange zone - Needs monitoring
-- • >25%: Red zone - Critical issues requiring immediate attention
-- 
-- 📊 TOOLTIP CONFIGURATION:
-- • Mode: All series
-- • Sort order: Descending (highest failure rates first)
-- • Header: "{{Location}}"
-- • Content: "Failure Rate: {{Failure Rate %}}%"
-- 
-- 🏷️ AXIS CONFIGURATION:
-- • X-axis label: "Location"
-- • Y-axis label: "Failure Rate (%)"
-- • Show axis labels: True
-- • X-axis label rotation: 45° (for long location names)
-- • Y-axis number format: Percentage with 1 decimal place
-- ═════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    SUBSTRING(source_location FROM 1 FOR 15) as "Location", -- X-axis: location (first 15 chars for readability)
    ROUND(
        (COUNT(CASE WHEN disconnection_cause NOT IN ('001 - User requested disconnection') THEN 1 END) * 100.0 / 
         NULLIF(COUNT(*), 0))::numeric, 
        1
    ) as "Failure Rate %" -- Y-axis: overall failure rate percentage by location (1 decimal place)
FROM call_records
WHERE source_location IS NOT NULL 
    AND date_time IS NOT NULL
    AND TRIM(source_location) != '' -- exclude empty locations
GROUP BY 
    SUBSTRING(source_location FROM 1 FOR 15) -- group only by location
HAVING COUNT(*) >= 20 -- only include locations with sufficient data (increased threshold for overall stats)
ORDER BY 
    "Failure Rate %" DESC; -- sort by highest failure rate first

-- ═══════════════════════════════════════════════════════════════════════

-- ═════════════════════════════════════════════════════════════════════════════════════════════
-- 3. Average Call Duration by Network Type and Hour (HEATMAP)
-- 📊 Heatmap
-- 📝 DESCRIPTION: Shows call quality patterns across network types and time periods to identify performance trends
-- 
-- 📈 HEATMAP SETTINGS:
-- • Calculate from data: YES - REQUIRED for duration calculations
-- • Calculation: Last (to get the calculated average from SQL)
-- • X-axis bucket: Hour (select the "Hour" field from dropdown)
-- • X-axis bucket size: 1 (integer - creates one bucket per hour)
-- • Y-axis bucket: Network Type (select the "Network Type" field from dropdown)  
-- • Y-axis bucket size: Auto (leave empty or use default for string fields)
-- • Value field: Avg Call Duration (select from dropdown)
-- • Bucket bound: Auto (automatic min/max detection)
-- 
-- 🔧 CORRECT GRAFANA CONFIGURATION STEPS:
-- 1. Panel type: Heatmap
-- 2. Data source: PostgreSQL
-- 3. In "Heatmap" tab:
--    - ✅ Enable "Calculate from data"  
--    - X-axis bucket field: Select "Hour" (not text like "0-23")
--    - X-axis bucket size: Enter 1 (the number 1, not text)
--    - Y-axis bucket field: Select "Network Type" 
--    - Y-axis bucket size: Leave empty (auto for strings)
--    - Value field: Select "Avg Call Duration"
-- 
-- 🎨 COLOR CONFIGURATION:
-- • Color mode: Spectrum
-- • Color scheme: Blue-Green-Yellow-Red (blue for short calls, red for long calls)
-- • Color scale: Linear
-- • Min value: 0 (set manually for consistent scaling)
-- • Max value: Auto (or set based on your typical max call duration)
-- • Show color scale legend: True
-- 
-- 📊 CELL SETTINGS:
-- • Cell display mode: Value (shows duration in seconds)
-- • Cell size: Auto (adjusts based on panel size)
-- • Cell padding: 2px
-- • Show cell border: True
-- • Text color: Auto (contrast-based for readability)
-- • Font size: 10px
-- 
-- 🚨 THRESHOLD SETTINGS (for duration analysis):
-- • 0-30s: Blue - Very short calls (potential connection issues)
-- • 30-120s: Green - Normal short calls
-- • 120-300s: Yellow - Medium duration calls
-- • 300-600s: Orange - Long calls
-- • >600s: Red - Very long calls (potential issues or specific use cases)
-- 
-- 🏷️ AXIS CONFIGURATION:
-- • X-axis label: "Hour of Day"
-- • Y-axis label: "Network Type"
-- • Show axis labels: True
-- • Label rotation: 0° for hours, auto for network types
-- 
-- 📏 TOOLTIP CONFIGURATION:
-- • Show tooltip: True
-- • Tooltip mode: Single
-- • Sort order: None
-- • Header format: "{Network Type} at {Hour}:00"
-- • Content format: "Avg Duration: {Avg Call Duration}s"
-- 
-- 📊 VALUE DISPLAY:
-- • Show values in cells: True
-- • Value decimal places: 1
-- • Value unit: Seconds (s)
-- • Value format: 123.4s
-- ═════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    EXTRACT(HOUR FROM date_time) as "Hour", -- X-axis: hour of day (0-23)
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END as "Network Type", -- Y-axis: categorized network types (SBS-XX, VOIP, OTHER)
    ROUND(AVG(duration_secs)::numeric, 1) as "Avg Call Duration" -- Value: average call duration in seconds (1 decimal)
FROM call_records
WHERE source_location IS NOT NULL 
    AND date_time IS NOT NULL 
    AND duration_secs IS NOT NULL
    AND duration_secs > 0 -- exclude zero duration calls (connection failures)
GROUP BY 
    EXTRACT(HOUR FROM date_time),
    CASE 
        WHEN source_location LIKE 'SBS%' THEN SUBSTRING(source_location FROM 1 FOR 6)
        WHEN source_location LIKE 'VOIP%' THEN 'VOIP'
        ELSE 'OTHER'
    END
HAVING COUNT(*) >= 5 -- only include hour-network combinations with sufficient data
ORDER BY 
    "Network Type",
    "Hour";

-- ═══════════════════════════════════════════════════════════════════════

