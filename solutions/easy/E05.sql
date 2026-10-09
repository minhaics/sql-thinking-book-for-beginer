-- id: E05
-- title: Unbranded products
-- chapter: 4
-- tags: NULL
-- ordered: true
-- prompt: List product_id and name of products that have no brand, sorted by product_id.
SELECT product_id, name
FROM products
WHERE brand IS NULL
ORDER BY product_id;
