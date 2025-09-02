-- PURPOSE: Afternoon rebalance (e.g., 12:55 ET).

DECLARE run_ts_et TIMESTAMP DEFAULT TIMESTAMP_TRUNC(
  TIMESTAMP(CURRENT_DATETIME('America/New_York')), MINUTE, 'America/New_York');

DECLARE out_run_id STRING;

CALL `ops.run_call_assignment_v2`(
  run_ts_et,
  'AFTERNOON',
  10,   -- horizon hours to close of day
  1,    -- different rotation seed
  out_run_id
);

-- Optional export like morning (different path/name).
