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
