-- id: E02
-- title: The 10 most expensive variants
-- chapter: 3
-- tags: ORDER BY, LIMIT
-- ordered: true
-- prompt: Return sku, variant_name and price of the 10 product variants with the highest price.
--   Break ties by sku (ascending).
-- hint: With ORDER BY on several columns, the second column only matters when the first one ties.
SELECT sku, variant_name, price
FROM product_variants
ORDER BY price DESC, sku
LIMIT 10;
