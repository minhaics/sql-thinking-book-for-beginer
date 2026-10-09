-- id: M09
-- title: Month-over-month order growth
-- chapter: 10
-- tags: LAG, WINDOW
-- ordered: true
-- prompt: For every month in the data, show month (as 'YYYY-MM'), order_count, and growth_pct =
--   (order_count - previous month's order_count) * 100 / previous month's order_count, rounded to 1 decimal.
--   The first month has a NULL growth. Sort by month.
WITH m AS (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS month, COUNT(*) AS order_count
    FROM orders
    GROUP BY month
)
SELECT month, order_count,
       ROUND((order_count - LAG(order_count) OVER w) * 100.0 / LAG(order_count) OVER w, 1) AS growth_pct
FROM m
WINDOW w AS (ORDER BY month)
ORDER BY month;
