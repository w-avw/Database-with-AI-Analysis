-- ═══════════════════════════════════════════════════════════════════════
-- 📊 NECESSARY QUERIES FOR GRAFANA DASHBOARDS
-- ═══════════════════════════════════════════════════════════════════════

-- 1. Call Traffic by Hour and Day of Week
-- ═════════════════════════════════════════════════════════════════════════════════════════════
-- 📊 Bar Chart
-- 📝 DESCRIPTION: Distribution of call volume across different hours and days for resource planning
-- ═════════════════════════════════════════════════════════════════════════════════════════════
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