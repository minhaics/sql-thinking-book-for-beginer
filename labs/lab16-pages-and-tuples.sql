-- LAB 16 · Where does the data actually live? Pages, the heap, tuples
-- Database: chonhata · User: sqlbook (superuser — needed for pageinspect)
SET search_path TO shop;
CREATE EXTENSION IF NOT EXISTS pageinspect;

-- 1) Every table is one (or a few) files on disk
SELECT pg_relation_filepath('orders')            AS file,
       pg_size_pretty(pg_relation_size('orders')) AS size,
       pg_relation_size('orders') / current_setting('block_size')::int AS pages,
       current_setting('block_size')              AS page_size;
-- 📝 20,000 orders fit in how many 8KB pages? How many rows per page on average?

-- 2) ctid = (page number, slot in the page): the "street address" of a row
SELECT ctid, order_id, status FROM orders ORDER BY order_id LIMIT 5;
SELECT ctid, order_id FROM orders WHERE ctid = '(10,3)';

-- 3) Dissect page 0: header + line pointers + tuples
SELECT * FROM page_header(get_raw_page('orders', 0));
SELECT lp, lp_off, lp_len, t_xmin, t_xmax, t_ctid
FROM heap_page_items(get_raw_page('orders', 0))
LIMIT 5;
-- 📝 lp_off goes DOWN: tuples are stacked from the END of the page upwards; line pointers grow from the START.

-- 4) UPDATE does not change a row in place — it writes a new version (try it inside a transaction, then undo)
BEGIN;
SELECT ctid, xmin, xmax, status FROM orders WHERE order_id = 1;
UPDATE orders SET status = status WHERE order_id = 1;
SELECT ctid, xmin, xmax, status FROM orders WHERE order_id = 1;
ROLLBACK;
-- 📝 The ctid changed after the UPDATE. Why? (Hint: Chapter 20 — MVCC)

-- 5) The real size of a row
SELECT pg_column_size(o.*) AS bytes_per_row FROM orders o LIMIT 1;
SELECT pg_column_size(r.*) AS bytes, length(r.comment) AS chars FROM reviews r WHERE comment IS NOT NULL LIMIT 3;

-- 6) TOAST: large values are sliced out and stored separately
SELECT reltoastrelid::regclass AS toast_table FROM pg_class WHERE relname = 'reviews';

-- 7) Table + indexes + TOAST
SELECT relname,
       pg_size_pretty(pg_table_size(oid))   AS table_size,
       pg_size_pretty(pg_indexes_size(oid)) AS index_size
FROM pg_class
WHERE relnamespace = 'shop'::regnamespace AND relkind = 'r'
ORDER BY pg_total_relation_size(oid) DESC;
