"""Shared helpers for verify.py and build_workbook.py (standard library only)."""
import csv
import io
import os
import re
import shlex
import shutil
import subprocess
from collections import Counter
from decimal import Decimal, InvalidOperation
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent          # the companion/ folder
SOLUTIONS = ROOT / "solutions"
EXPECTED = ROOT / "expected"
ANSWERS = ROOT / "my-answers"
LEVELS = {"easy": "Easy", "medium": "Medium", "hard": "Hard"}
LEVEL_BADGE = {"easy": "Easy", "medium": "Medium", "hard": "Hard"}


# --------------------------------------------------------------------- exercise metadata
def parse_exercise(path: Path) -> dict:
    """Read the '-- key: value' header at the top of a solution file."""
    meta, sql_lines, key = {}, [], None
    in_header = True
    for line in path.read_text(encoding="utf-8").splitlines():
        if in_header and line.startswith("--"):
            m = re.match(r"^--\s([a-z]+):\s?(.*)$", line)
            if m:
                key = m.group(1)
                meta[key] = m.group(2).strip()
            elif key and line.startswith("--   "):
                meta[key] += "\n" + line[5:].rstrip()
            continue
        in_header = False
        sql_lines.append(line)
    meta["level"] = path.parent.name
    meta["ordered"] = meta.get("ordered", "false").lower() == "true"
    meta["sql"] = "\n".join(sql_lines).strip()
    meta["path"] = path
    return meta


def all_exercises() -> list:
    items = []
    for level in LEVELS:
        items += [parse_exercise(p) for p in sorted((SOLUTIONS / level).glob("*.sql"))]
    return items


# --------------------------------------------------------------------- running SQL
def psql_command() -> list:
    """
    SQLBOOK_PSQL overrides the command, for example:
        export SQLBOOK_PSQL="psql -h localhost -p 5433 -U learner -d chonhata"
    Default: run psql inside the book's Docker container.
    """
    custom = os.environ.get("SQLBOOK_PSQL")
    if custom:
        return shlex.split(custom)
    if not shutil.which("docker"):
        raise SystemExit("docker not found. Install Docker or set SQLBOOK_PSQL (see README).")
    return ["docker", "exec", "-i", "-e", "PGPASSWORD=learner", "chonhata-db",
            "psql", "-h", "127.0.0.1", "-U", "learner", "-d", "chonhata"]


def run_query(sql: str):
    """Run one SELECT inside a READ-ONLY transaction. Returns (header, rows) or raises RuntimeError."""
    sql = sql.strip().rstrip(";")
    if not sql:
        raise RuntimeError("The answer file is empty.")
    script = f"SET search_path TO shop;\nBEGIN READ ONLY;\n{sql}\n;\nROLLBACK;\n"
    env = dict(os.environ, PGOPTIONS="-c statement_timeout=15000", PGCLIENTENCODING="UTF8")
    cmd = psql_command() + ["-X", "-q", "--csv", "-v", "ON_ERROR_STOP=1"]
    proc = subprocess.run(cmd, input=script, capture_output=True, text=True, encoding="utf-8", env=env)
    if proc.returncode != 0:
        msg = proc.stderr.strip() or proc.stdout.strip()
        raise RuntimeError(msg.replace("psql:<stdin>:", "line "))
    rows = list(csv.reader(io.StringIO(proc.stdout)))
    if not rows:
        raise RuntimeError("The query returned no result set (did you forget SELECT?).")
    return rows[0], rows[1:]


# --------------------------------------------------------------------- comparing
def norm(v: str) -> str:
    """Normalize so that 4.30 == 4.3 and 12.0 == 12; strings are left untouched."""
    try:
        d = Decimal(v)
        if not d.is_finite():
            return v
        d = d.quantize(Decimal("0.01")) if d != d.to_integral_value() else d.to_integral_value()
        return format(d.normalize(), "f")
    except (InvalidOperation, ValueError):
        return v


def normalize(rows):
    return [tuple(norm(c) for c in r) for r in rows]


def compare(expected_rows, actual_rows, ordered: bool):
    """Return (passed?, list of messages)."""
    exp, act = normalize(expected_rows), normalize(actual_rows)
    msgs = []
    if exp and act and len(exp[0]) != len(act[0]):
        return False, [f"Column count: expected {len(exp[0])}, you returned {len(act[0])}."]
    if len(exp) != len(act):
        msgs.append(f"Row count: expected {len(exp)}, you returned {len(act)}.")
    if ordered:
        if exp == act:
            return True, []
        if Counter(exp) == Counter(act):
            return False, ["Right rows, WRONG ORDER. Check your ORDER BY."]
        for i, (e, a) in enumerate(zip(exp, act), start=1):
            if e != a:
                msgs.append(f"Row {i} differs:\n      expected: {e}\n      yours   : {a}")
                break
        return False, msgs
    ce, ca = Counter(exp), Counter(act)
    if ce == ca:
        return True, []
    missing = list((ce - ca).elements())[:3]
    extra = list((ca - ce).elements())[:3]
    if missing:
        msgs.append("Missing (e.g.): " + "; ".join(map(str, missing)))
    if extra:
        msgs.append("Unexpected (e.g.): " + "; ".join(map(str, extra)))
    return False, msgs


def read_expected(ex_id: str):
    with open(EXPECTED / f"{ex_id}.csv", encoding="utf-8", newline="") as f:
        rows = list(csv.reader(f))
    return rows[0], rows[1:]


def write_expected(ex_id: str, header, rows):
    EXPECTED.mkdir(exist_ok=True)
    with open(EXPECTED / f"{ex_id}.csv", "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
