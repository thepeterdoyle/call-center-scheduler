-- PURPOSE: Human-readable offset vs ET for each state's representative tz “right now”.

CREATE OR REPLACE VIEW `ref.us_state_offset_vs_et_today` AS
WITH now_et AS (SELECT CURRENT_TIMESTAMP() AS t),
states AS (SELECT state_code, morning_tz_id, evening_tz_id FROM `ref.us_state_time_profile`)
SELECT
  state_code, 'MORNING' AS run_kind, morning_tz_id AS tz_id,
  TIMESTAMP_DIFF(
    TIMESTAMP(DATETIME(DATETIME((SELECT t FROM now_et), 'America/New_York'), morning_tz_id)),
    (SELECT t FROM now_et), MINUTE
  ) AS diff_minutes_vs_et_now
FROM states
UNION ALL
SELECT
  state_code, 'AFTERNOON', evening_tz_id,
  TIMESTAMP_DIFF(
    TIMESTAMP(DATETIME(DATETIME((SELECT t FROM now_et), 'America/New_York'), evening_tz_id)),
    (SELECT t FROM now_et), MINUTE
  )
FROM states;
