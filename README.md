# Companion resources for *SQL Thinking for Beginners*

Everything you need to practise: the **MetroMart** database (PostgreSQL 16), **50 auto-graded exercises**, reference solutions, and **7 labs** that explore how the database works inside.

```
companion/
├── docker-compose.yml     ← start the database with one command
├── db/                    ← 17-table schema + data + read-only account
├── exercises/             ← WORKBOOKS: prompts + expected results (easy.md, medium.md, hard.md)
├── my-answers/            ← YOU WORK HERE (one file per exercise, prompt already inside)
├── tools/verify.py        ← the checker
├── solutions/             ← reference solutions (don't peek before trying!)
├── expected/              ← answer key (CSV) used by the checker
├── labs/                  ← Part III labs (indexes, the planner, MVCC…)
└── tools/                 ← data generator, big-database loader
```

---

## 1. Setup (10 minutes, once)

**You need:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) and Python 3.9+ (preinstalled on most macOS/Linux machines; on Windows install it from python.org or use WSL 2).

```bash
git clone https://github.com/minhaics/sql-thinking-book-for-beginer.git
cd sql-thinking-book-for-beginer
docker compose up -d          # first run: downloads PostgreSQL and loads ~100,000 rows (~30 seconds)
```

Check it:

```bash
docker exec -it chonhata-db psql -U learner -d chonhata -c "SELECT COUNT(*) FROM customers;"
#  count
# -------
#   3000
```

### Connecting with a graphical tool (DBeaver, pgAdmin, DataGrip, VS Code…)

| Setting | Value |
|---|---|
| Host | `localhost` |
| Port | **`5433`** |
| Database | `chonhata` |
| User / Password | `learner` / `learner` — **read-only**, use it for the exercises |
| User / Password | `sqlbook` / `sqlbook` — full access, for Chapter 14 and the labs |

> The tables live in the `shop` schema. As `learner` you can simply write `FROM orders`.

---

## 2. Exercises

**50 exercises** in three levels, inspired by HackerRank and LeetCode SQL:

| Level | IDs | Count | What to expect |
|---|---|---|---|
| 🟢 Easy | E01–E20 | 20 | One concept, at most two tables |
| 🟡 Medium | M01–M18 | 18 | Several tables, one trap (NULLs, duplicated rows, integer division…) |
| 🔴 Hard | H01–H12 | 12 | Multi-step problems, window functions, recursion, classic interview questions |

### Workflow

1. Read the prompt in `exercises/easy.md` (or `medium.md`, `hard.md`).
2. Open `my-answers/E01.sql` — the prompt is already there as comments. Write your query **below** it.
3. Check it:

```bash
python3 tools/verify.py E01
```

```text
✓  E01 Easy — Provinces in the Central region
```

When something is wrong, the checker tells you what:

```text
✗  E07 Easy — Orders by status
   Right rows, WRONG ORDER. Check your ORDER BY.

✗  M07 Medium — The NOT IN and NULL trap
   Missing (e.g.): ('2547',)
   Unexpected (e.g.): ('0',)
   Hint: x NOT IN (1, 2, NULL) is never TRUE. Use NOT EXISTS instead.
```

### Other commands

```bash
python3 tools/verify.py --list              # list exercises; ✎ marks the ones you started
python3 tools/verify.py E01 E02 M05         # check several at once
python3 tools/verify.py --all               # check everything you have started
python3 tools/verify.py --file draft.sql --id H03   # check any file
```

### How the checker works

- It runs your query **inside a read-only transaction** (you cannot damage the data), with a 15-second limit.
- It compares **results**, not wording — every correct solution passes.
- Column names do **not** need to match; the **number of columns, the values and the row count** do.
- Row order is only checked when the prompt asks you to sort.
- Numbers are normalized: `4.30` equals `4.3`.

---

## 3. Part III labs

See [`labs/README.md`](labs/README.md). Some labs need the large database:

```bash
bash tools/load_big.sh        # creates chonhata_big (~400,000 orders, a few minutes)
bash tools/load_big.sh 50     # ~1,000,000 orders
```

---

## 4. Troubleshooting

| Symptom | Fix |
|---|---|
| `port is already allocated` | Change `"5433:5432"` in `docker-compose.yml` to `"5434:5432"` |
| `relation "customers" does not exist` | You are connected to the wrong database (it must be `chonhata`), or your user has no `search_path` → use `shop.customers` |
| `verify.py`: docker not found | Install Docker, or point the checker at your own PostgreSQL: `export SQLBOOK_PSQL="psql -h localhost -p 5433 -U learner -d chonhata"` |
| I want a fresh copy of the data | `docker compose down -v && docker compose up -d` |
| Windows: `python3` is not recognized | Use `python` or `py`, or run inside WSL 2 |

---

## 5. For the curious

- The data is generated **deterministically** by `tools/generate_seed.py --seed 2024`: everyone has exactly the same data, so every number printed in the book is reproducible.
- The company, shops, brands, carriers and people in the data are **fictional**.
- `tools/build_workbook.py` (author tool) re-runs every solution and regenerates `expected/`, `exercises/` and `my-answers/`.
- License: the code and data in this folder are released under the MIT License.
