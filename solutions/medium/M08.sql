-- id: M08
-- title: Running revenue in 2025
-- chapter: 10
-- tags: WINDOW, SUM OVER
-- ordered: true
-- prompt: For 'delivered' orders placed in 2025, compute merchandise revenue per month (month: 1–12) and the
--   year-to-date running total (running_total). Return month, revenue, running_total, sorted by month.
-- hint: Aggregate per month first (in a CTE), then use SUM(...) OVER (ORDER BY month).
WITH monthly AS (
    SELECT EXTRACT(MONTH FROM o.order_date)::int AS month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
      AND o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
    GROUP BY month
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;
