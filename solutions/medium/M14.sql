-- id: M14
-- title: In stock in New York, not in Dallas
-- chapter: 9
-- tags: EXCEPT
-- ordered: false
-- prompt: Count the variants that are in stock (quantity > 0) at 'New York Warehouse' but NOT in stock at
--   'Dallas Warehouse' (including variants Dallas does not carry at all).
SELECT COUNT(*) AS variant_count
FROM (
    SELECT i.variant_id FROM inventory i JOIN warehouses w USING (warehouse_id)
    WHERE w.name = 'New York Warehouse' AND i.quantity > 0
    EXCEPT
    SELECT i.variant_id FROM inventory i JOIN warehouses w USING (warehouse_id)
    WHERE w.name = 'Dallas Warehouse' AND i.quantity > 0
) t;
