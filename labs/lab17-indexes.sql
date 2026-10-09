-- LAB 17 · Indexes: the table of contents of your data
-- Database: chonhata_big (run tools/load_big.sh first) · User: sqlbook
SET search_path TO shop;
\timing on

-- 0) Setup: drop the experiment indexes if you run this lab again
DROP INDEX IF EXISTS idx_orders_customer, idx_orders_date, idx_orders_customer_date,
                     idx_orders_status_date, idx_items_variant;
ANALYZE orders;

-- 1) No index → Seq Scan: read EVERY page
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE customer_id = 4242;
-- 📝 Write down: time ____ ms, shared hit/read ____ pages.

-- 2) Create a B-tree and measure again
CREATE INDEX idx_orders_customer ON orders(customer_id);
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE customer_id = 4242;
-- 📝 Which scan type is used now? How many times fewer pages were read?

-- 3) Size and depth of the B-tree
CREATE EXTENSION IF NOT EXISTS pageinspect;
SELECT pg_size_pretty(pg_relation_size('idx_orders_customer')) AS size;
SELECT level AS root_level FROM bt_metap('idx_orders_customer');
-- 📝 Hundreds of thousands of rows, yet the tree is only a few levels deep. Each level = one page read.

-- 4) Selectivity: an index is not always used
CREATE INDEX idx_orders_date ON orders(order_date);
ANALYZE orders;
EXPLAIN ANALYZE SELECT * FROM orders WHERE order_date >= '2025-12-30';   -- few rows
EXPLAIN ANALYZE SELECT * FROM orders WHERE order_date >= '2024-03-01';   -- almost the whole table
-- 📝 Why does the planner IGNORE the index for the second query?

-- 5) A function on the column "kills" the index
EXPLAIN ANALYZE SELECT * FROM orders WHERE order_date::date = '2025-11-11';
EXPLAIN ANALYZE SELECT * FROM orders WHERE order_date >= '2025-11-11' AND order_date < '2025-11-12';
-- 📝 Rewrite the condition as a range (sargable) so the index can be used.

-- 6) Multicolumn indexes: COLUMN ORDER matters (a phone book sorts by last name, then first name)
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 4242 AND order_date >= '2025-01-01';
EXPLAIN ANALYZE SELECT * FROM orders WHERE order_date >= '2025-12-30' AND customer_id > 0;
-- 📝 Which query does the (customer_id, order_date) index help? Why?

-- 7) Index-Only Scan: the index "contains" every column the query needs
VACUUM ANALYZE orders;
EXPLAIN (ANALYZE, BUFFERS) SELECT order_date FROM orders WHERE customer_id = 4242;
-- 📝 "Heap Fetches: 0" means the table itself was never opened.

-- 8) The price of indexes: slower writes
CREATE TABLE write_test AS SELECT * FROM orders WITH NO DATA;
INSERT INTO write_test SELECT * FROM orders;                    -- 📝 time without indexes: ____
TRUNCATE write_test;
CREATE INDEX ON write_test(customer_id); CREATE INDEX ON write_test(order_date); CREATE INDEX ON write_test(status, order_date);
INSERT INTO write_test SELECT * FROM orders;                    -- 📝 time with 3 indexes: ____
DROP TABLE write_test;
