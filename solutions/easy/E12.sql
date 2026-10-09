-- id: E12
-- title: Products and their categories
-- chapter: 7
-- tags: INNER JOIN
-- ordered: true
-- prompt: For the 20 products with the smallest product_id, show product_id, the product name (product_name)
--   and the category name (category_name).
-- hint: Both tables have a column called name — give each one an alias.
SELECT p.product_id,
       p.name AS product_name,
       c.name AS category_name
FROM products p
JOIN categories c ON c.category_id = p.category_id
ORDER BY p.product_id
LIMIT 20;
