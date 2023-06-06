-- ============================================================
-- Meridian Trade & Logistics — Data Quality Checks
-- Analyst: Nurbol Sultanov
-- Date: 2023-06-06
-- ============================================================

-- 1. Row counts
SELECT 'shipments' AS table_name, COUNT(*) AS rows FROM shipments
UNION ALL
SELECT 'ports', COUNT(*) FROM ports;

-- 2. Date range
SELECT 
    MIN(booking_date) AS earliest,
    MAX(booking_date) AS latest,
    COUNT(DISTINCT year) AS years_covered
FROM shipments;

-- 3. Null checks
SELECT 
    COUNT(*) AS total,
    SUM(CASE WHEN shipment_id IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN origin_port IS NULL THEN 1 ELSE 0 END) AS null_origin,
    SUM(CASE WHEN destination_port IS NULL THEN 1 ELSE 0 END) AS null_dest,
    SUM(CASE WHEN actual_arrival IS NULL THEN 1 ELSE 0 END) AS null_arrival,
    SUM(CASE WHEN cost_usd <= 0 THEN 1 ELSE 0 END) AS bad_cost
FROM shipments;

-- 4. Delay overview
SELECT 
    year,
    quarter,
    COUNT(*) AS shipments,
    SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) AS delayed,
    ROUND(AVG(CASE WHEN is_delayed THEN total_delay_days END), 1) AS avg_delay_days,
    ROUND(SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100, 1) AS delay_pct
FROM shipments
GROUP BY year, quarter
ORDER BY year, quarter;

-- 5. Delay causes
SELECT 
    delay_cause,
    COUNT(*) AS occurrences,
    ROUND(AVG(total_delay_days), 1) AS avg_delay
FROM shipments
WHERE is_delayed = TRUE AND delay_cause != ''
GROUP BY delay_cause
ORDER BY occurrences DESC;

-- 6. Top routes by volume
SELECT 
    origin_port || ' → ' || destination_port AS route,
    COUNT(*) AS shipments,
    ROUND(AVG(total_delay_days), 1) AS avg_delay,
    ROUND(SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100, 1) AS delay_pct
FROM shipments
GROUP BY origin_port, destination_port
ORDER BY shipments DESC
LIMIT 15;