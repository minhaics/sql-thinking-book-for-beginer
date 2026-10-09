-- id: H10
-- title: Customers loyal to a product
-- chapter: 8
-- tags: COUNT DISTINCT, JOIN, HAVING
-- ordered: true
-- prompt: Ignore 'cancelled' orders. Find the (customer, product) pairs where the customer bought that product in at
--   least 6 DIFFERENT orders (different variants of the same product count as the same product).
--   Return customer_id, product_id, order_count; sort by order_count descending, then customer_id, product_id.
SELECT o.customer_id, v.product_id, COUNT(DISTINCT o.order_id) AS order_count
FROM orders o
JOIN order_items oi     ON oi.order_id  = o.order_id
JOIN product_variants v ON v.variant_id = oi.variant_id
WHERE o.status <> 'cancelled'
GROUP BY o.customer_id, v.product_id
HAVING COUNT(DISTINCT o.order_id) >= 6
ORDER BY order_count DESC, o.customer_id, v.product_id;
