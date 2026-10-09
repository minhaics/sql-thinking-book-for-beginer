#!/usr/bin/env python3
"""
Check your SQL exercise answers against the expected results.

    python3 tools/verify.py E01            # check my-answers/E01.sql
    python3 tools/verify.py E01 M05 H02    # check several exercises
    python3 tools/verify.py --all          # check every exercise you have started
    python3 tools/verify.py --list         # list exercises and your progress
    python3 tools/verify.py --file x.sql --id M03   # check any file

The checker compares RESULTS, not how you wrote the query — many answers can be correct.
- Column names do not have to match; the number of columns, the values and the row count do.
- Row order is only checked when the exercise asks you to sort.
- Numbers are normalized (4.30 == 4.3).
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from sqlbook_lib import ANSWERS, LEVEL_BADGE, all_exercises, compare, read_expected, run_query  # noqa: E402

GREEN, RED, YELLOW, DIM, RESET = "\033[32m", "\033[31m", "\033[33m", "\033[2m", "\033[0m"
if not sys.stdout.isatty():
    GREEN = RED = YELLOW = DIM = RESET = ""


def strip_comments(sql: str) -> str:
    # drop comment-only lines so the answer templates (which contain the prompt as comments) still run
    return "\n".join(l for l in sql.splitlines() if not l.lstrip().startswith("--"))


def started(path: Path) -> bool:
    return path.exists() and bool(strip_comments(path.read_text(encoding="utf-8")).strip())


def check(ex, sql_path: Path) -> bool:
    title = f"{ex['id']} {LEVEL_BADGE[ex['level']]} — {ex['title']}"
    if not started(sql_path):
        print(f"{YELLOW}⏭  {title}: no answer yet ({sql_path}){RESET}")
        return False
    try:
        _, rows = run_query(strip_comments(sql_path.read_text(encoding="utf-8")))
    except RuntimeError as e:
        print(f"{RED}✗  {title}\n   SQL error: {e}{RESET}")
        return False
    _, expected = read_expected(ex["id"])
    ok, msgs = compare(expected, rows, ex["ordered"])
    if ok:
        print(f"{GREEN}✓  {title}{RESET}")
    else:
        print(f"{RED}✗  {title}{RESET}")
        for m in msgs:
            print(f"   {m}")
        if ex.get("hint"):
            print(f"{DIM}   Hint: {ex['hint']}{RESET}")
    return ok


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("ids", nargs="*", help="exercise ids, e.g. E01 M05 H02")
    ap.add_argument("--all", action="store_true", help="check every answer in my-answers/")
    ap.add_argument("--list", action="store_true", help="list the exercises")
    ap.add_argument("--file", help="check any SQL file (use with --id)")
    ap.add_argument("--id", help="exercise id for --file")
    args = ap.parse_args()

    exercises = {e["id"]: e for e in all_exercises()}

    if args.list:
        for e in exercises.values():
            mark = "✎" if started(ANSWERS / f"{e['id']}.sql") else " "
            print(f"{mark} {e['id']}  {LEVEL_BADGE[e['level']]:<10} Ch.{e['chapter']:>2}  {e['title']}")
        return 0

    if args.file:
        if not args.id or args.id.upper() not in exercises:
            ap.error("--file needs a valid --id")
        return 0 if check(exercises[args.id.upper()], Path(args.file)) else 1

    if args.all:
        ids = [i for i in exercises if started(ANSWERS / f"{i}.sql")]
        if not ids:
            print("You have not started any exercise in my-answers/ yet. Open a file, write SQL below the prompt, "
                  "and run this again.")
            return 2
    else:
        ids = [i.upper() for i in args.ids]
    if not ids:
        ap.print_help()
        return 2

    passed = 0
    for i in ids:
        if i not in exercises:
            print(f"{YELLOW}?  No exercise called {i}{RESET}")
            continue
        passed += check(exercises[i], ANSWERS / f"{i}.sql")
    if len(ids) > 1:
        print(f"\nPassed {passed}/{len(ids)}.")
    return 0 if passed == len(ids) else 1


if __name__ == "__main__":
    sys.exit(main())
