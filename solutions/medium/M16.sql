-- id: M16
-- title: Peak order days
-- chapter: 6
-- tags: HAVING, casting to date
-- ordered: true
-- prompt: Which days of 2025 had more than 100 orders? Return day (a date) and order_count, sorted by day.
--   What pattern do you notice?
SELECT order_date::date AS day, COUNT(*) AS order_count
FROM orders
WHERE order_date >= '2025-01-01' AND order_date < '2026-01-01'
GROUP BY day
HAVING COUNT(*) > 100
ORDER BY day;
