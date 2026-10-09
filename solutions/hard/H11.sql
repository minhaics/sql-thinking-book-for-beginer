-- id: H11
-- title: Frequently bought together
-- chapter: 13
-- tags: self join, market basket
-- ordered: true
-- prompt: Find the 10 pairs of PRODUCTS (product_a < product_b) that appear together in the largest number of orders.
--   Return product_a, product_b, order_count; sort by order_count descending, then product_a, product_b.
-- hint: Self-join the "order–product" list on order_id, with a < b so each pair is counted once.
WITH order_products AS (
    SELECT DISTINCT oi.order_id, v.product_id
    FROM order_items oi
    JOIN product_variants v ON v.variant_id = oi.variant_id
)
SELECT a.product_id AS product_a, b.product_id AS product_b, COUNT(*) AS order_count
FROM order_products a
JOIN order_products b ON b.order_id = a.order_id AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
ORDER BY order_count DESC, product_a, product_b
LIMIT 10;
