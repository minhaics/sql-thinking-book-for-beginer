-- id: M02
-- title: Customers who never ordered
-- chapter: 7
-- tags: LEFT JOIN, anti-join
-- ordered: false
-- prompt: How many customers have never placed a single order (cancelled orders count as orders)?
-- hint: LEFT JOIN, then keep the rows where the right-hand side is NULL — or use NOT EXISTS.
SELECT COUNT(*) AS customer_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
