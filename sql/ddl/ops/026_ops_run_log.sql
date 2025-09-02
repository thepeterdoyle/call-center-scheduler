-- ops.run_log
CREATE OR REPLACE TABLE `ops.run_log` (
  run_id STRING OPTIONS(description="Run identifier (e.g., run_YYYYMMDD_hhmmss)."),
  run_kind STRING OPTIONS(description="MORNING or AFTERNOON."),
  run_ts_et TIMESTAMP OPTIONS(description="Timestamp when planning was executed (ET)."),
  notes STRING OPTIONS(description="Freeform notes or planner version tag.")
)
OPTIONS(description="Audit log of planning runs.");
