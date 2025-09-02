# AGENTS.md

## Project
Call Center Scheduler (BigQuery): DST-aware, state-timezone scheduling and backlog analytics.

## Tech & Conventions
- Warehouse: Google BigQuery (standard SQL)
- Structure: migration-style under `sql/migrations` (001..008)
- Seeds/fixtures in `data/`
- Docs in `docs/`
- Use descriptive commit messages; PRs must include a summary of created/changed files.

## Target Tree
- data/ref/us_state_timezones.csv
- sql/migrations/001_init_schemas.sql
- sql/migrations/002_create_ref_tables.sql
- sql/migrations/003_create_ops_tables.sql
- sql/migrations/004_create_udfs.sql
- sql/migrations/005_create_procedures.sql
- sql/migrations/006_create_views.sql
- sql/migrations/007_load_state_timezones.sql
- sql/migrations/008_seed_minimal_config.sql
- README.md
- docs/architecture.md

## Guardrails
- Do NOT overwrite existing files without preserving custom edits; append or update sections in-place.
- Keep BigQuery **standard SQL** (no legacy SQL).
- Include top-of-file comments explaining purpose & run order.
- For large files, keep logical section headers and inline comments.

## Validation
- Run `scripts/validate_tree.sh` to verify required files exist.
- Check for “CREATE OR REPLACE …” in SQL files.
- Ensure no tabs; use 2 spaces.
- Open a PR from a feature branch and summarize changes.

## Tasks Codex Should Perform
1) Create folders and files per Target Tree if missing; otherwise, update headers & comments.
2) Add the CSV content we provide.
3) Populate SQL files with the content we provide (DDL, UDFs, proc, views).
4) Create `scripts/validate_tree.sh` with simple checks.
5) Commit on a new branch and open a PR titled “Scaffold: BigQuery scheduler (migrations + seeds + docs)”.

