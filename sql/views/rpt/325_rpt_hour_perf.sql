-- PURPOSE: Completion rate by ET hour to weight planning toward better hours.

CREATE OR REPLACE VIEW `rpt.hour_perf` AS
SELECT
  TIMESTAMP_TRUNC(assigned_for_hour_ts, HOUR, 'America/New_York') AS hour_et,
  FORMAT_DATETIME('%H:00', DATETIME(assigned_for_hour_ts,'America/New_York')) AS hour_label,
  COUNT(*) assigned,
  COUNTIF(c.outcome='completed') completed,
  SAFE_DIVIDE(COUNTIF(c.outcome='completed'), NULLIF(COUNT(*),0)) AS comp_rate
FROM `ops.assignments` a
LEFT JOIN `ops.call_attempts` c
  ON c.account_id=a.account_id AND c.assignment_seq=a.assignment_seq
GROUP BY hour_et, hour_label;
