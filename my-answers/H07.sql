-- H07 · Payment reconciliation (Hard)
-- Accounting suspects the system collected the wrong amounts. For each 'delivered' order the EXPECTED amount is
--   expected = GREATEST(subtotal - discount, 0) + shipping_fee
-- where discount = ROUND(subtotal * discount_value / 100, -3) for a 'percent' coupon, = discount_value for a 'fixed'
-- coupon, and 0 when no coupon was used. The COLLECTED amount is the sum of the order's payments with status
-- 'success'. List the mismatching orders: order_id, expected, collected, difference (= collected - expected),
-- sorted by order_id.

-- (write your query below)
