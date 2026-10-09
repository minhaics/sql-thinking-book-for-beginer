-- id: E13
-- title: Line items of order 246
-- chapter: 7
-- tags: JOIN, expressions
-- ordered: true
-- prompt: List the line items of order 246: sku, variant_name, quantity, unit_price and
--   line_total = quantity * unit_price. Sort by sku.
SELECT v.sku, v.variant_name, oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM order_items oi
JOIN product_variants v ON v.variant_id = oi.variant_id
WHERE oi.order_id = 246
ORDER BY v.sku;
