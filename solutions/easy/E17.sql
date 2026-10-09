-- id: E17
-- title: Where are the official stores?
-- chapter: 7
-- tags: JOIN, boolean
-- ordered: true
-- prompt: List shop_name and the province name (province_name) of every official store (is_official).
--   Sort by shop_name.
SELECT s.shop_name, p.name AS province_name
FROM sellers s
JOIN provinces p ON p.province_id = s.province_id
WHERE s.is_official
ORDER BY s.shop_name;
