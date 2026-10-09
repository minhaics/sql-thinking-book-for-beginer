-- id: M18
-- title: How much do loyal customers spend per order?
-- chapter: 8
-- tags: CTE, two-level aggregation
-- ordered: true
-- prompt: Consider only 'delivered' orders. For customers with at least 30 such orders, compute order_count and
--   avg_order_value = the average subtotal PER ORDER (rounded to a whole number). Return customer_id, full_name,
--   order_count, avg_order_value; sort by avg_order_value descending, then customer_id.
-- hint: AVG(quantity * unit_price) averages LINE ITEMS, not ORDERS. Aggregate per order first.
WITH order_totals AS (
    SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS subtotal
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id, o.customer_id
)
SELECT c.customer_id, c.full_name,
       COUNT(*) AS order_count,
       ROUND(AVG(t.subtotal)) AS avg_order_value
FROM order_totals t
JOIN customers c ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(*) >= 30
ORDER BY avg_order_value DESC, c.customer_id;
