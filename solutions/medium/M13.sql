-- id: M13
-- title: Coupon users who also returned goods
-- chapter: 8
-- tags: EXISTS
-- ordered: false
-- prompt: Count the customers who satisfy BOTH conditions: they have placed an order using a coupon, AND they have
--   an order with status 'returned'. (The two conditions may be met by different orders.)
SELECT COUNT(*) AS customer_count
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.coupon_id IS NOT NULL)
  AND EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'returned');
