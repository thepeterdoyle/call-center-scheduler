#!/usr/bin/env bash
set -euo pipefail
files=(
  "data/ref/us_state_timezones.csv"
  "sql/migrations/001_init_schemas.sql"
  "sql/migrations/002_create_ref_tables.sql"
  "sql/migrations/003_create_ops_tables.sql"
  "sql/migrations/004_create_udfs.sql"
  "sql/migrations/005_create_procedures.sql"
  "sql/migrations/006_create_views.sql"
  "sql/migrations/007_load_state_timezones.sql"
  "sql/migrations/008_seed_minimal_config.sql"
  "README.md"
  "docs/architecture.md"
)
missing=0
for f in "${files[@]}"; do
  if [[ ! -f "$f" ]]; then echo "MISSING: $f"; missing=$((missing+1)); fi
done
if (( missing > 0 )); then
  echo "❌ Validation failed ($missing missing)"; exit 1
else
  echo "✅ Structure OK"
fi
