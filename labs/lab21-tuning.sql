-- LAB 21 · Real-world tuning: four slow queries from the Cho Nha Ta team
-- Database: chonhata_big · User: sqlbook
-- For EACH case: (1) EXPLAIN (ANALYZE, BUFFERS) → (2) find the most expensive node
--                → (3) form a hypothesis → (4) fix it (index / rewrite) → (5) measure again, record the numbers
SET search_path TO shop;
DROP INDEX IF EXISTS idx_orders_customer, idx_orders_date, idx_orders_customer_date, idx_items_variant, idx_orders_status_date;
ANALYZE;

-- CASE 1: the customer's "Order history" page takes seconds to load
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, status FROM orders
WHERE customer_id = 777 ORDER BY order_date DESC LIMIT 20;
-- 📝 Hypothesis: ______   Fix: ______   Before: ___ms  After: ___ms

-- CASE 2: the "how many units of this product sold" report — a foreign key without an index
EXPLAIN (ANALYZE, BUFFERS)
SELECT sum(oi.quantity) FROM order_items oi WHERE oi.variant_id = 15;
-- 📝 Remember: PostgreSQL does NOT automatically index foreign keys.

-- CASE 3: operations dashboard — recent 'pending'/'paid' orders
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE status IN ('pending', 'paid') AND order_date >= '2025-12-01';
-- 📝 Try: an index on (status, order_date)? or a partial index WHERE status IN ('pending','paid')? Compare their sizes.

-- CASE 4: case-insensitive customer lookup by email
EXPLAIN ANALYZE SELECT * FROM customers WHERE lower(email) = 'tung.huynh2@gmail.com';
-- 📝 Does a plain index on email help? Try an expression index: CREATE INDEX ON customers (lower(email));

-- Wrap-up: the indexes you created and their sizes
SELECT indexrelid::regclass AS index, pg_size_pretty(pg_relation_size(indexrelid)) AS size, idx_scan AS times_used
FROM pg_stat_user_indexes WHERE schemaname = 'shop' ORDER BY pg_relation_size(indexrelid) DESC;
