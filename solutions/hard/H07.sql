-- id: H07
-- title: Payment reconciliation
-- chapter: 13
-- tags: reconciliation, multiple CTEs, CASE, GREATEST
-- ordered: true
-- prompt: Accounting suspects the system collected the wrong amounts. For each 'delivered' order the EXPECTED amount is
--     expected = GREATEST(subtotal - discount, 0) + shipping_fee
--   where discount = ROUND(subtotal * discount_value / 100, -3) for a 'percent' coupon, = discount_value for a 'fixed'
--   coupon, and 0 when no coupon was used. The COLLECTED amount is the sum of the order's payments with status
--   'success'. List the mismatching orders: order_id, expected, collected, difference (= collected - expected),
--   sorted by order_id.
-- hint: Aggregate order_items and payments in TWO separate CTEs before joining — joining them at once multiplies rows.
WITH merchandise AS (
    SELECT order_id, SUM(quantity * unit_price) AS subtotal
    FROM order_items
    GROUP BY order_id
), collected AS (
    SELECT order_id, SUM(amount) AS collected
    FROM payments
    WHERE status = 'success'
    GROUP BY order_id
), expected AS (
    SELECT o.order_id,
           GREATEST(m.subtotal - CASE c.discount_type
                                   WHEN 'percent' THEN ROUND(m.subtotal * c.discount_value / 100, -3)
                                   WHEN 'fixed'   THEN c.discount_value
                                   ELSE 0
                                 END, 0) + s.shipping_fee AS expected
    FROM orders o
    JOIN merchandise m ON m.order_id = o.order_id
    JOIN shipments s   ON s.order_id = o.order_id
    LEFT JOIN coupons c ON c.coupon_id = o.coupon_id
    WHERE o.status = 'delivered'
)
SELECT e.order_id, e.expected,
       COALESCE(k.collected, 0) AS collected,
       COALESCE(k.collected, 0) - e.expected AS difference
FROM expected e
LEFT JOIN collected k ON k.order_id = e.order_id
WHERE COALESCE(k.collected, 0) <> e.expected
ORDER BY e.order_id;
