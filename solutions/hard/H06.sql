-- id: H06
-- title: Customers who come back fastest
-- chapter: 10
-- tags: LAG, intervals
-- ordered: true
-- prompt: Ignore 'cancelled' orders. For customers with at least 5 orders, compute avg_days = the average number of days
--   between two consecutive orders (rounded to 1 decimal). Return the 10 customers with the smallest avg_days:
--   customer_id, order_count, avg_days; sort by avg_days ascending, then customer_id.
WITH gaps AS (
    SELECT customer_id, order_date,
           order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS gap
    FROM orders
    WHERE status <> 'cancelled'
)
SELECT customer_id,
       COUNT(*) AS order_count,
       ROUND((AVG(EXTRACT(EPOCH FROM gap)) / 86400)::numeric, 1) AS avg_days
FROM gaps
GROUP BY customer_id
HAVING COUNT(*) >= 5
ORDER BY avg_days, customer_id
LIMIT 10;
