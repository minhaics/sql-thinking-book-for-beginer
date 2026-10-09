-- id: M01
-- title: Revenue by category
-- chapter: 7
-- tags: multi-table JOIN, SUM, GROUP BY
-- ordered: true
-- prompt: Compute merchandise revenue (sum of quantity * unit_price) per product category, counting only orders
--   whose status is 'delivered'. Return category_name and revenue, sorted by revenue descending.
-- hint: The path is orders → order_items → product_variants → products → categories.
SELECT c.name AS category_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi     ON oi.order_id   = o.order_id
JOIN product_variants v ON v.variant_id  = oi.variant_id
JOIN products p         ON p.product_id  = v.product_id
JOIN categories c       ON c.category_id = p.category_id
WHERE o.status = 'delivered'
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;
