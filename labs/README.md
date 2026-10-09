# Part III labs — looking inside PostgreSQL

These labs are NOT auto-graded: run each block, observe, and write down what you see at the `-- 📝` markers.
Use the full-access account `sqlbook` (you need it to install extensions and read raw data pages).

```bash
docker exec -it chonhata-db psql -U sqlbook -d chonhata        # labs 15, 16, 19, 20
bash tools/load_big.sh                                          # once, before labs 17, 18, 21
docker exec -it chonhata-db psql -U sqlbook -d chonhata_big    # labs 17, 18, 21
```

Inside psql you can run a whole file with `\i path/to/lab.sql` — but you will learn more by **pasting one block at a time**.
Tips: `\x auto` wraps wide results; `\timing on` shows how long each statement takes.

| Lab | Chapter | Topic | Database |
|---|---|---|---|
| lab15-query-journey.sql | 15 | Parser → planner → executor, your first EXPLAIN | chonhata |
| lab16-pages-and-tuples.sql | 16 | 8KB pages, the heap, ctid, pageinspect, TOAST | chonhata |
| lab17-indexes.sql | 17 | B-trees, Seq Scan vs Index Scan, multicolumn and covering indexes | chonhata_big |
| lab18-planner-joins.sql | 18 | Statistics, row estimates, Nested Loop / Hash / Merge Join | chonhata_big |
| lab19-transactions-wal.sql | 19 | ACID, the write-ahead log, LSNs | chonhata |
| lab20-mvcc-locks.sql | 20 | MVCC xmin/xmax, isolation levels, locks, deadlocks (two terminal windows) | chonhata |
| lab21-tuning.sql | 21 | Fixing four real slow queries on this dataset | chonhata_big |
