-- id: H04
-- title: 90-day repeat purchase rate by cohort
-- chapter: 13
-- tags: cohort, retention, CTE, EXISTS
-- ordered: true
-- prompt: Ignore 'cancelled' orders. A customer's cohort is the month of their first order. For the cohorts of 2024,
--   compute: cohort ('YYYY-MM'), customer_count, repeat_customers (customers with at least one OTHER order placed
--   AFTER their first order and no more than 90 days after it), and repeat_rate_pct (rounded to 1 decimal).
--   Sort by cohort.
WITH valid_orders AS (
    SELECT customer_id, order_date
    FROM orders
    WHERE status <> 'cancelled'
), first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_at
    FROM valid_orders
    GROUP BY customer_id
), flagged AS (
    SELECT f.customer_id,
           TO_CHAR(f.first_at, 'YYYY-MM') AS cohort,
           EXISTS (
               SELECT 1 FROM valid_orders v
               WHERE v.customer_id = f.customer_id
                 AND v.order_date >  f.first_at
                 AND v.order_date <= f.first_at + INTERVAL '90 days'
           ) AS repeated
    FROM first_orders f
    WHERE f.first_at >= '2024-01-01' AND f.first_at < '2025-01-01'
)
SELECT cohort,
       COUNT(*) AS customer_count,
       COUNT(*) FILTER (WHERE repeated) AS repeat_customers,
       ROUND(COUNT(*) FILTER (WHERE repeated) * 100.0 / COUNT(*), 1) AS repeat_rate_pct
FROM flagged
GROUP BY cohort
ORDER BY cohort;
