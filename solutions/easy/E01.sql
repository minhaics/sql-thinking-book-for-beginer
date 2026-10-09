-- id: E01
-- title: Provinces in the Central region
-- chapter: 3
-- tags: SELECT, WHERE, ORDER BY
-- ordered: true
-- prompt: List the name of every province in the 'Central' region, sorted by name.
-- hint: The provinces table has a region column.
SELECT name
FROM provinces
WHERE region = 'Central'
ORDER BY name;
