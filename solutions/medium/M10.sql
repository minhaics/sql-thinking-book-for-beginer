-- id: M10
-- title: Order value buckets
-- chapter: 11
-- tags: CASE, GROUP BY
-- ordered: false
-- prompt: Put every order into a bucket by its subtotal (sum of quantity * unit_price):
--   'Under 200k' (< 200,000), '200k-500k' (< 500,000), '500k-2M' (< 2,000,000), '2M and up' (everything else).
--   Return bucket and order_count.
WITH t AS (
    SELECT order_id, SUM(quantity * unit_price) AS subtotal
    FROM order_items
    GROUP BY order_id
)
SELECT CASE
         WHEN subtotal < 200000  THEN 'Under 200k'
         WHEN subtotal < 500000  THEN '200k-500k'
         WHEN subtotal < 2000000 THEN '500k-2M'
         ELSE '2M and up'
       END AS bucket,
       COUNT(*) AS order_count
FROM t
GROUP BY bucket;
