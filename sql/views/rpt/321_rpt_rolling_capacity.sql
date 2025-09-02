-- PURPOSE: Rolling average of actual completions per day (7d/14d).

CREATE OR REPLACE VIEW `rpt.rolling_capacity` AS
WITH base AS (
  SELECT DATE(attempt_ts, 'America/New_York') d, COUNTIF(outcome='completed') completed
  FROM `ops.call_attempts` GROUP BY 1
)
SELECT
  d,
  completed,
  AVG(completed) OVER (ORDER BY d ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)  AS avg7_completed,
  AVG(completed) OVER (ORDER BY d ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS avg14_completed
FROM base
ORDER BY d;
