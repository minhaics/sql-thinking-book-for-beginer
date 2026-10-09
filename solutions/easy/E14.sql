-- id: E14
-- title: Customers by gender
-- chapter: 6
-- tags: GROUP BY, COALESCE, NULL
-- ordered: false
-- prompt: Count customers by gender. The gender column should show 'M', 'F', or 'Unknown' (when gender is NULL);
--   the count column is customer_count.
-- hint: GROUP BY puts all NULLs into the same group.
SELECT COALESCE(gender, 'Unknown') AS gender,
       COUNT(*) AS customer_count
FROM customers
GROUP BY COALESCE(gender, 'Unknown');
