-- id: H01
-- title: Best-selling product in every category
-- chapter: 10
-- tags: top-N per group, RANK
-- ordered: false
-- prompt: For each product category, find the product with the highest total quantity sold in 'delivered' orders.
--   If several products tie for first place, list all of them. Return category_name, product_name, units.
-- hint: MAX() cannot bring along "the name that goes with it". Rank inside each group: RANK() OVER (PARTITION BY ...).
WITH sales AS (
    SELECT p.category_id, p.product_id, p.name, SUM(oi.quantity) AS units
    FROM orders o
    JOIN order_items oi     ON oi.order_id  = o.order_id
    JOIN product_variants v ON v.variant_id = oi.variant_id
    JOIN products p         ON p.product_id = v.product_id
    WHERE o.status = 'delivered'
    GROUP BY p.category_id, p.product_id, p.name
), ranked AS (
    SELECT *, RANK() OVER (PARTITION BY category_id ORDER BY units DESC) AS rnk
    FROM sales
)
SELECT c.name AS category_name, r.name AS product_name, r.units
FROM ranked r
JOIN categories c ON c.category_id = r.category_id
WHERE r.rnk = 1;
