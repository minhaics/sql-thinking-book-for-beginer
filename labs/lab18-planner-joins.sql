-- LAB 18 · What is the planner thinking? Statistics and join algorithms
-- Database: chonhata_big · User: sqlbook
SET search_path TO shop;

-- 1) The statistics the planner relies on
SELECT attname, n_distinct, null_frac, most_common_vals, most_common_freqs
FROM pg_stats
WHERE schemaname = 'shop' AND tablename = 'orders' AND attname IN ('status', 'customer_id', 'coupon_id');
-- 📝 How many rows does the planner expect for WHERE status = 'returned'? Check with EXPLAIN.
EXPLAIN SELECT * FROM orders WHERE status = 'returned';
SELECT count(*) FROM orders WHERE status = 'returned';

-- 2) WRONG estimates when columns are correlated (the planner assumes independence)
EXPLAIN ANALYZE SELECT * FROM shipments WHERE delivered_at IS NULL AND shipped_at >= '2025-12-25';
-- 📝 Compare estimated rows with actual rows.

-- 3) Three join algorithms
-- 3a. Nested Loop: good when the outer side is small and the inner side has an index
EXPLAIN ANALYZE
SELECT * FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_id < 50;

-- 3b. Hash Join: good when both sides are large and the condition is equality
EXPLAIN ANALYZE
SELECT c.full_name, count(*) FROM orders o JOIN customers c ON c.customer_id = o.customer_id GROUP BY c.full_name;

-- 3c. Force the planner to pick other algorithms, to compare (FOR LEARNING ONLY — never in production)
SET enable_hashjoin = off;
EXPLAIN ANALYZE
SELECT c.full_name, count(*) FROM orders o JOIN customers c ON c.customer_id = o.customer_id GROUP BY c.full_name;
SET enable_mergejoin = off;
EXPLAIN ANALYZE
SELECT c.full_name, count(*) FROM orders o JOIN customers c ON c.customer_id = o.customer_id GROUP BY c.full_name;
RESET enable_hashjoin; RESET enable_mergejoin;
-- 📝 Timing table: Hash ____ · Merge ____ · Nested Loop ____

-- 4) work_mem affects Sort and Hash
SET work_mem = '1MB';
EXPLAIN ANALYZE SELECT * FROM order_items ORDER BY unit_price;     -- look for "external merge  Disk:"
SET work_mem = '256MB';
EXPLAIN ANALYZE SELECT * FROM order_items ORDER BY unit_price;     -- look for "quicksort  Memory:"
RESET work_mem;
