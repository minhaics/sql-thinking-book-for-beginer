-- LAB 15 · The journey of a query
-- Database: chonhata · User: sqlbook
SET search_path TO shop;

-- 1) A SYNTAX error is caught by the PARSER — no data is touched at all
SELEC * FROM orders;
-- 📝 What does the error say? Why is it instant even though the table has 20,000 rows?

-- 2) A SEMANTIC error is caught by the ANALYZER — the syntax is fine, but the column does not exist
SELECT total_amount FROM orders;
-- 📝 Which stage has to "look things up" in the system catalog to know which columns orders has?

-- 3) The system catalog: the database describes itself... using tables
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'shop' AND table_name = 'orders'
ORDER BY ordinal_position;

-- 4) The PLANNER: see the plan without running the query
EXPLAIN
SELECT o.order_id, c.full_name
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date >= '2025-12-01';
-- 📝 Read it from the inside out (the most indented line runs first). How many nodes are there? What are they called?

-- 5) The EXECUTOR: actually run it and measure
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, c.full_name
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date >= '2025-12-01';
-- 📝 Compare the estimated "rows=" with "actual ... rows=". How far off is the estimate?
-- 📝 "shared hit" means the data page was already in memory.

-- 6) LOGICAL order is not WRITTEN order: a SELECT alias cannot be used in WHERE
SELECT order_id, EXTRACT(YEAR FROM order_date) AS yr
FROM orders
WHERE yr = 2025;            -- error! WHERE is processed BEFORE SELECT
-- ...but it can be used in ORDER BY (processed AFTER SELECT)
SELECT order_id, EXTRACT(YEAR FROM order_date) AS yr
FROM orders
ORDER BY yr DESC, order_id
LIMIT 3;
