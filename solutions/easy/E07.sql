-- id: E07
-- title: Orders by status
-- chapter: 6
-- tags: GROUP BY, COUNT
-- ordered: true
-- prompt: Count orders per status. Return status and order_count, sorted by order_count descending.
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;
