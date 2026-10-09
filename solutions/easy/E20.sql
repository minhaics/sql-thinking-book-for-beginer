-- id: E20
-- title: Provinces with a warehouse or a shop
-- chapter: 9
-- tags: UNION
-- ordered: false
-- prompt: List (without duplicates) the province_id of every province that has a warehouse OR at least one shop.
SELECT province_id FROM warehouses
UNION
SELECT province_id FROM sellers;
