-- LAB 19 · Transactions and the WAL: why a power cut does not lose your data
-- Database: chonhata · User: sqlbook
SET search_path TO shop;

-- 1) Atomicity: all or nothing
CREATE TABLE IF NOT EXISTS wallets (owner TEXT PRIMARY KEY, balance NUMERIC NOT NULL CHECK (balance >= 0));
TRUNCATE wallets;
INSERT INTO wallets VALUES ('An', 500000), ('Binh', 100000);

BEGIN;
UPDATE wallets SET balance = balance + 700000 WHERE owner = 'Binh';
UPDATE wallets SET balance = balance - 700000 WHERE owner = 'An';     -- violates CHECK → error
COMMIT;                                                              -- actually becomes a ROLLBACK
SELECT * FROM wallets;
-- 📝 Did Binh receive the 700,000? Why not?

-- 2) The WAL: every change is written to the LOG before it is written to the table
SELECT pg_current_wal_lsn() AS lsn_before \gset
UPDATE wallets SET balance = balance + 1 WHERE owner = 'An';
SELECT pg_current_wal_lsn() AS lsn_after,
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'lsn_before')) AS wal_written;

-- 3) How much WAL does a bulk UPDATE produce?
SELECT pg_current_wal_lsn() AS lsn_before \gset
BEGIN;
UPDATE orders SET status = status;
ROLLBACK;
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'lsn_before')) AS wal_for_20000_rows;
-- 📝 Even after ROLLBACK the WAL was written. Why is that harmless?

-- 4) The WAL files
SELECT name, pg_size_pretty(size) FROM pg_ls_waldir() ORDER BY modification DESC LIMIT 3;

-- 5) Savepoints: roll back part of a transaction
BEGIN;
UPDATE wallets SET balance = 0 WHERE owner = 'An';
SAVEPOINT before_delete;
DELETE FROM wallets;
ROLLBACK TO before_delete;
SELECT * FROM wallets;          -- 📝 how many rows are left? what is An's balance?
ROLLBACK;

DROP TABLE wallets;
