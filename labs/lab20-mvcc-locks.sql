-- LAB 20 · MVCC, isolation levels and locks — YOU NEED 2 TERMINAL WINDOWS (called [A] and [B])
-- In each window: docker exec -it chonhata-db psql -U sqlbook -d chonhata
-- Run the blocks in numbered order, in the window shown.

-- [A] 0. Setup
SET search_path TO shop;
CREATE TABLE IF NOT EXISTS stock_demo (sku TEXT PRIMARY KEY, qty INT NOT NULL);
TRUNCATE stock_demo; INSERT INTO stock_demo VALUES ('SKU-A', 10), ('SKU-B', 5);

-- ===================== PART 1: readers do not block writers =====================
-- [A] 1.
BEGIN;
UPDATE stock_demo SET qty = 9 WHERE sku = 'SKU-A';
SELECT xmin, xmax, ctid, * FROM stock_demo;
-- [B] 2.
SET search_path TO shop;
SELECT xmin, xmax, ctid, * FROM stock_demo;     -- 📝 does B see qty = 10 or 9? Does B hang?
-- [A] 3.
COMMIT;
-- [B] 4.
SELECT * FROM stock_demo;                        -- 📝 and now?

-- ===================== PART 2: READ COMMITTED vs REPEATABLE READ =====================
-- [B] 5.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT qty FROM stock_demo WHERE sku = 'SKU-B';
-- [A] 6.
UPDATE stock_demo SET qty = 4 WHERE sku = 'SKU-B';
-- [B] 7.
SELECT qty FROM stock_demo WHERE sku = 'SKU-B';  -- 📝 same transaction, two reads, two different answers?
COMMIT;
-- Repeat steps 5–7 with: BEGIN ISOLATION LEVEL REPEATABLE READ;   (A sets qty = 3)

-- ===================== PART 3: lost updates & SELECT ... FOR UPDATE =====================
-- Scenario: two customers buy SKU-A at once; each app reads the stock, then writes (stock - 1)
-- [A] 8.
BEGIN; SELECT qty FROM stock_demo WHERE sku = 'SKU-A' FOR UPDATE;
-- [B] 9.
BEGIN; SELECT qty FROM stock_demo WHERE sku = 'SKU-A' FOR UPDATE;   -- 📝 B hangs. Why?
-- [A] 10.
UPDATE stock_demo SET qty = qty - 1 WHERE sku = 'SKU-A'; COMMIT;
-- [B] 11.  (B continues and sees the NEW value)
UPDATE stock_demo SET qty = qty - 1 WHERE sku = 'SKU-A'; COMMIT;
SELECT * FROM stock_demo;                                           -- 📝 qty = 7?

-- Who holds the lock? (run in a third window while B is waiting at step 9)
-- SELECT pid, locktype, relation::regclass, mode, granted FROM pg_locks WHERE relation = 'shop.stock_demo'::regclass;

-- ===================== PART 4: deadlock =====================
-- [A] 12.  BEGIN; UPDATE stock_demo SET qty = qty WHERE sku = 'SKU-A';
-- [B] 13.  BEGIN; UPDATE stock_demo SET qty = qty WHERE sku = 'SKU-B';
-- [A] 14.  UPDATE stock_demo SET qty = qty WHERE sku = 'SKU-B';     -- waits
-- [B] 15.  UPDATE stock_demo SET qty = qty WHERE sku = 'SKU-A';     -- 📝 after ~1 second: "deadlock detected"
-- [A][B]   ROLLBACK;
-- 📝 Prevention: always lock rows in the SAME ORDER.

-- ===================== PART 5: MVCC garbage & VACUUM =====================
-- [A] 16.
SELECT n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE relname = 'stock_demo';
UPDATE stock_demo SET qty = qty;  UPDATE stock_demo SET qty = qty;  UPDATE stock_demo SET qty = qty;
SELECT n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE relname = 'stock_demo';
VACUUM (VERBOSE) stock_demo;
SELECT n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE relname = 'stock_demo';
DROP TABLE stock_demo;
