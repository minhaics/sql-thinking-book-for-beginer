-- id: M17
-- title: The row-multiplication trap
-- chapter: 7
-- tags: fan-out, COUNT DISTINCT
-- ordered: true
-- prompt: For 'delivered' orders, compute per shop: order_count (number of DISTINCT orders containing that shop's
--   products) and units (total quantity sold). Return the 10 shops with the most units.
--   Columns: shop_name, order_count, units; sort by units descending, then shop_name.
-- hint: An order with 3 line items from the same shop is counted 3 times by COUNT(*).
SELECT s.shop_name,
       COUNT(DISTINCT o.order_id) AS order_count,
       SUM(oi.quantity) AS units
FROM orders o
JOIN order_items oi     ON oi.order_id  = o.order_id
JOIN product_variants v ON v.variant_id = oi.variant_id
JOIN products p         ON p.product_id = v.product_id
JOIN sellers s          ON s.seller_id  = p.seller_id
WHERE o.status = 'delivered'
GROUP BY s.seller_id, s.shop_name
ORDER BY units DESC, s.shop_name
LIMIT 10;
