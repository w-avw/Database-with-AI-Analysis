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
