-- PURPOSE: Morning planning run (e.g., 07:55 ET). Set Scheduled Query TZ to America/New_York.

DECLARE run_ts_et TIMESTAMP DEFAULT TIMESTAMP_TRUNC(
  TIMESTAMP(CURRENT_DATETIME('America/New_York')), MINUTE, 'America/New_York');

DECLARE out_run_id STRING;

CALL `ops.run_call_assignment_v2`(
  run_ts_et,
  'MORNING',
  12,   -- horizon hours
  0,    -- rotation seed
  out_run_id
);

-- Optional CSV export to GCS (replace bucket)
-- EXPORT DATA OPTIONS(
--   uri='gs://YOUR_BUCKET/call-plans/dt_date={{DATE(CURRENT_DATETIME("America/New_York"))}}/morning_*.csv',
--   format='CSV', overwrite=true, header=true, field_delimiter=','
-- ) AS
-- SELECT * FROM `rpt.agent_schedule_daily`
-- ORDER BY employee_name, display_hour_et, row_in_hour;
