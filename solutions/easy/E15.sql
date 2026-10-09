-- id: E15
-- title: Orders per month in 2025
-- chapter: 11
-- tags: EXTRACT, GROUP BY
-- ordered: true
-- prompt: Count the orders placed in each month of 2025. Return month (a number 1–12) and order_count, sorted by month.
SELECT EXTRACT(MONTH FROM order_date)::int AS month,
       COUNT(*) AS order_count
FROM orders
WHERE order_date >= '2025-01-01' AND order_date < '2026-01-01'
GROUP BY month
ORDER BY month;
