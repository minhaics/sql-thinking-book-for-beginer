#!/usr/bin/env python3
"""
FOR THE AUTHOR. From solutions/**/*.sql:
  1. run every solution → write expected/<ID>.csv (the answer key)
  2. self-check: each solution must match its expected file and must not be empty
  3. generate the workbooks exercises/{easy,medium,hard}.md (prompt + sample result, NO solutions)
  4. generate exercises/solutions.md (all solutions, for the appendix)
  5. create answer templates my-answers/<ID>.sql (if missing)

    python3 tools/build_workbook.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from sqlbook_lib import (ANSWERS, LEVEL_BADGE, LEVELS, ROOT, all_exercises, compare,  # noqa: E402
                         read_expected, run_query, write_expected)

PREVIEW_ROWS = 5


def md_table(header, rows):
    esc = lambda s: s.replace("|", "\\|")
    out = ["| " + " | ".join(header) + " |", "|" + "---|" * len(header)]
    out += ["| " + " | ".join(esc(c) if c != "" else "*NULL*" for c in r) + " |" for r in rows]
    return "\n".join(out)


def main():
    exercises = all_exercises()
    ids = [e["id"] for e in exercises]
    assert len(ids) == len(set(ids)), "Duplicate exercise ids!"
    problems = 0

    for e in exercises:
        header, rows = run_query(e["sql"])
        write_expected(e["id"], header, rows)
        _, again = read_expected(e["id"])
        ok, _ = compare(again, rows, e["ordered"])
        warn = "" if rows else "  ⚠ EMPTY RESULT"
        problems += (not ok) + (not rows)
        e["header"], e["rows"] = header, rows
        print(f"{e['id']}  {len(rows):>5} rows  {e['title']}{warn}")

    out_dir = ROOT / "exercises"
    out_dir.mkdir(exist_ok=True)
    ANSWERS.mkdir(exist_ok=True)

    for level, label in LEVELS.items():
        items = [e for e in exercises if e["level"] == level]
        md = [f"# {LEVEL_BADGE[level]} exercises\n",
              f"{len(items)} exercises. Write your answer in `my-answers/<ID>.sql`, then check it with "
              "`python3 tools/verify.py <ID>`.\n",
              "> Row order is only checked when the prompt asks you to sort. Column names do not have to match.\n"]
        for e in items:
            md.append(f"\n---\n\n## {e['id']} · {e['title']}\n")
            md.append(f"**Level:** {LEVEL_BADGE[level]} · **Chapter:** {e['chapter']} · **Topics:** {e['tags']}\n")
            md.append(e["prompt"].replace("\n", "  \n") + "\n")
            if e.get("hint"):
                md.append(f"<details><summary>💡 Hint</summary>\n\n{e['hint']}\n\n</details>\n")
            shown = e["rows"][:PREVIEW_ROWS]
            more = len(e["rows"]) - len(shown)
            md.append(f"**Expected result** ({len(e['rows'])} rows{', first ' + str(len(shown)) + ' shown' if more > 0 else ''}):\n")
            md.append(md_table(e["header"], shown) + "\n")
        (out_dir / f"{level}.md").write_text("\n".join(md), encoding="utf-8")

        for e in items:
            f = ANSWERS / f"{e['id']}.sql"
            if not f.exists():
                prompt = "\n".join("-- " + l for l in e["prompt"].splitlines())
                f.write_text(f"-- {e['id']} · {e['title']} ({label})\n{prompt}\n\n-- (write your query below)\n",
                             encoding="utf-8")

    sol = ["# Reference solutions\n", "> Solve the exercise and check it with `verify.py` before reading. "
           "Most exercises have more than one correct solution.\n"]
    for e in exercises:
        sol.append(f"\n## {e['id']} · {e['title']} ({LEVEL_BADGE[e['level']]})\n")
        sol.append(f"```sql\n{e['sql']}\n```\n")
    (out_dir / "solutions.md").write_text("\n".join(sol), encoding="utf-8")

    print(f"\n{len(exercises)} exercises · problems: {problems}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
