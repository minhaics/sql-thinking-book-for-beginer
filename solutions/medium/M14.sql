-- id: M14
-- title: In stock in Hanoi, not in HCMC
-- chapter: 9
-- tags: EXCEPT
-- ordered: false
-- prompt: Count the variants that are in stock (quantity > 0) at 'Hanoi Warehouse' but NOT in stock at
--   'HCMC Warehouse' (including variants HCMC does not carry at all).
SELECT COUNT(*) AS variant_count
FROM (
    SELECT i.variant_id FROM inventory i JOIN warehouses w USING (warehouse_id)
    WHERE w.name = 'Hanoi Warehouse' AND i.quantity > 0
    EXCEPT
    SELECT i.variant_id FROM inventory i JOIN warehouses w USING (warehouse_id)
    WHERE w.name = 'HCMC Warehouse' AND i.quantity > 0
) t;
