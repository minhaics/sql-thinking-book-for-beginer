-- id: M06
-- title: The 10 largest orders
-- chapter: 6
-- tags: GROUP BY, ORDER BY, LIMIT
-- ordered: true
-- prompt: Compute each order's merchandise subtotal (sum of quantity * unit_price) and return the 10 orders with
--   the largest subtotal. Return order_id and subtotal, sorted by subtotal descending, then order_id.
SELECT order_id, SUM(quantity * unit_price) AS subtotal
FROM order_items
GROUP BY order_id
ORDER BY subtotal DESC, order_id
LIMIT 10;
