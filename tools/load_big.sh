#!/usr/bin/env bash
# Create the LARGE database "chonhata_big" for Part III (indexes, EXPLAIN, the planner).
#   bash tools/load_big.sh        # scale 20 ≈ 400,000 orders (a few minutes)
#   bash tools/load_big.sh 50     # ≈ 1,000,000 orders (needs ~2 GB disk)
set -euo pipefail
SCALE="${1:-20}"
DB="${2:-chonhata_big}"
LANG_DATA="${3:-en}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$HERE/db-big-seed.sql"

echo "▶ Generating data (scale=$SCALE, lang=$LANG_DATA) ..."
python3 "$HERE/tools/generate_seed.py" --scale "$SCALE" --lang "$LANG_DATA" -o "$OUT"

PSQL=(docker exec -i chonhata-db psql -U sqlbook -v ON_ERROR_STOP=1 -q)
echo "▶ Creating database $DB ..."
"${PSQL[@]}" -d chonhata -c "DROP DATABASE IF EXISTS $DB;" -c "CREATE DATABASE $DB;"
"${PSQL[@]}" -d "$DB" < "$HERE/db/01-schema.sql"
echo "▶ Loading data (this can take a few minutes) ..."
"${PSQL[@]}" -d "$DB" < "$OUT"
"${PSQL[@]}" -d "$DB" -c "ALTER DATABASE $DB SET search_path TO shop;" \
  -c "GRANT CONNECT ON DATABASE $DB TO learner;" -c "GRANT USAGE ON SCHEMA shop TO learner;" \
  -c "GRANT SELECT ON ALL TABLES IN SCHEMA shop TO learner;"
rm -f "$OUT"
"${PSQL[@]}" -d "$DB" -c "SELECT pg_size_pretty(pg_database_size('$DB')) AS size, (SELECT count(*) FROM shop.orders) AS orders;"
echo "✔ Done. Connect: docker exec -it chonhata-db psql -U sqlbook -d $DB"
