-- id: H08
-- title: 7-day moving average in November 2025
-- chapter: 10
-- tags: WINDOW FRAME, ROWS BETWEEN, filtering too early
-- ordered: true
-- prompt: Compute daily merchandise revenue for orders that were not cancelled (status <> 'cancelled'), and its 7-day
--   moving average (the current day plus the 6 previous days, rounded to a whole number). SHOW only the days of
--   November 2025, but the average for Nov 1 must still use the last days of October.
--   Return day, revenue, avg_7d; sort by day.
-- hint: If you filter November in WHERE, the window cannot "see" October. Compute the window first, filter afterwards.
--   (Every day has orders, so ROWS 6 PRECEDING equals 7 calendar days here.)
WITH daily AS (
    SELECT o.order_date::date AS day, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY 1
), moving AS (
    SELECT day, revenue,
           ROUND(AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS avg_7d
    FROM daily
)
SELECT day, revenue, avg_7d
FROM moving
WHERE day >= '2025-11-01' AND day < '2025-12-01'
ORDER BY day;
