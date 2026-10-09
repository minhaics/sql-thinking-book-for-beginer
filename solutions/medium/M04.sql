-- id: M04
-- title: Shops with many active products
-- chapter: 6
-- tags: HAVING
-- ordered: true
-- prompt: Find the shops that have at least 12 active products (is_active). Return shop_name and product_count,
--   sorted by product_count descending, then shop_name.
-- hint: WHERE filters rows BEFORE grouping; HAVING filters groups AFTER grouping.
SELECT s.shop_name, COUNT(*) AS product_count
FROM sellers s
JOIN products p ON p.seller_id = s.seller_id
WHERE p.is_active
GROUP BY s.seller_id, s.shop_name
HAVING COUNT(*) >= 12
ORDER BY product_count DESC, s.shop_name;
