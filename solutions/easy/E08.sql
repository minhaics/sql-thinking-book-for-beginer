-- id: E08
-- title: Total stock per warehouse
-- chapter: 6
-- tags: GROUP BY, SUM
-- ordered: true
-- prompt: For each warehouse, compute the total quantity in stock. Return warehouse_id and total_stock,
--   sorted by warehouse_id.
SELECT warehouse_id, SUM(quantity) AS total_stock
FROM inventory
GROUP BY warehouse_id
ORDER BY warehouse_id;
