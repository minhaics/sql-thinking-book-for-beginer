-- id: H02
-- title: Revenue rolled up to top-level categories
-- chapter: 12
-- tags: RECURSIVE CTE, trees, LEFT JOIN
-- ordered: true
-- prompt: Categories form a tree (parent_id). Products are attached only to leaf categories. Roll merchandise revenue
--   ('delivered' orders) up to every TOP-LEVEL category (parent_id IS NULL), including top-level categories with no
--   revenue (show 0). Return top_category and revenue, sorted by revenue descending, then top_category.
-- hint: Use WITH RECURSIVE to map every category to its top-level ancestor (root_id).
WITH RECURSIVE roots AS (
    SELECT category_id, category_id AS root_id
    FROM categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT c.category_id, r.root_id
    FROM categories c
    JOIN roots r ON c.parent_id = r.category_id
), leaf_revenue AS (
    SELECT p.category_id, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi     ON oi.order_id  = o.order_id
    JOIN product_variants v ON v.variant_id = oi.variant_id
    JOIN products p         ON p.product_id = v.product_id
    WHERE o.status = 'delivered'
    GROUP BY p.category_id
)
SELECT top.name AS top_category,
       COALESCE(SUM(lr.revenue), 0) AS revenue
FROM categories top
JOIN roots r ON r.root_id = top.category_id
LEFT JOIN leaf_revenue lr ON lr.category_id = r.category_id
WHERE top.parent_id IS NULL
GROUP BY top.category_id, top.name
ORDER BY revenue DESC, top_category;
