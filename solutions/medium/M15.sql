-- id: M15
-- title: September birthdays who bought in 2025
-- chapter: 11
-- tags: EXTRACT, EXISTS
-- ordered: true
-- prompt: List customer_id, full_name and birth_date of customers born in September who placed at least one order
--   in 2025. Sort by customer_id.
-- hint: If you JOIN orders directly, a customer with many orders appears many times.
SELECT c.customer_id, c.full_name, c.birth_date
FROM customers c
WHERE EXTRACT(MONTH FROM c.birth_date) = 9
  AND EXISTS (
      SELECT 1 FROM orders o
      WHERE o.customer_id = c.customer_id
        AND o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
  )
ORDER BY c.customer_id;
