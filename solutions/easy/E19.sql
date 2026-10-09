-- id: E19
-- title: Top 5 provinces by customers
-- chapter: 7
-- tags: JOIN, GROUP BY, LIMIT
-- ordered: true
-- prompt: Using each customer's DEFAULT address, find the 5 provinces with the most customers.
--   Return province_name and customer_count; sort by customer_count descending, then province_name.
SELECT p.name AS province_name, COUNT(*) AS customer_count
FROM addresses a
JOIN provinces p ON p.province_id = a.province_id
WHERE a.is_default
GROUP BY p.name
ORDER BY customer_count DESC, province_name
LIMIT 5;
