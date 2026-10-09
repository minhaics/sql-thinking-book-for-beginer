-- id: M03
-- title: Products that never sold
-- chapter: 8
-- tags: NOT EXISTS, subquery
-- ordered: true
-- prompt: List product_id and name of products that never appear in any order (none of their variants is in
--   order_items). Sort by product_id.
SELECT p.product_id, p.name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM product_variants v
    JOIN order_items oi ON oi.variant_id = v.variant_id
    WHERE v.product_id = p.product_id
)
ORDER BY p.product_id;
