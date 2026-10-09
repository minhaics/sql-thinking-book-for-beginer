-- id: M11
-- title: Cancellation rate by region
-- chapter: 11
-- tags: JOIN, FILTER / CASE, ratios
-- ordered: false
-- prompt: By the region of the shipping address, compute total_orders, cancelled_orders (status = 'cancelled') and
--   cancel_rate_pct = cancelled_orders * 100 / total_orders, rounded to 2 decimals.
-- hint: COUNT(*) FILTER (WHERE ...) or SUM(CASE WHEN ... THEN 1 ELSE 0 END). Watch out for integer division!
SELECT p.region,
       COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE o.status = 'cancelled') AS cancelled_orders,
       ROUND(COUNT(*) FILTER (WHERE o.status = 'cancelled') * 100.0 / COUNT(*), 2) AS cancel_rate_pct
FROM orders o
JOIN addresses a ON a.address_id = o.address_id
JOIN provinces p ON p.province_id = a.province_id
GROUP BY p.region;
