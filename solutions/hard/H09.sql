-- id: H09
-- title: Region × quarter pivot table
-- chapter: 11
-- tags: pivot, FILTER
-- ordered: true
-- prompt: For orders placed in 2025, build a table of order counts: one row per quarter (quarter: 1–4) and the columns
--   north, central, south holding the number of orders shipped to each region. Sort by quarter.
SELECT EXTRACT(QUARTER FROM o.order_date)::int AS quarter,
       COUNT(*) FILTER (WHERE p.region = 'North')   AS north,
       COUNT(*) FILTER (WHERE p.region = 'Central') AS central,
       COUNT(*) FILTER (WHERE p.region = 'South')   AS south
FROM orders o
JOIN addresses a ON a.address_id = o.address_id
JOIN provinces p ON p.province_id = a.province_id
WHERE o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
GROUP BY quarter
ORDER BY quarter;
