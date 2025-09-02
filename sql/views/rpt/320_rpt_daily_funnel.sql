-- PURPOSE: Daily assigned → attempted → completed funnel.

CREATE OR REPLACE VIEW `rpt.daily_funnel` AS
WITH a AS (
  SELECT DATE(assigned_for_hour_ts, 'America/New_York') d, COUNT(*) assigned
  FROM `ops.assignments` GROUP BY 1
),
att AS (
  SELECT DATE(attempt_ts, 'America/New_York') d, COUNT(*) attempted
  FROM `ops.call_attempts` GROUP BY 1
),
comp AS (
  SELECT DATE(attempt_ts, 'America/New_York') d, COUNT(*) completed
  FROM `ops.call_attempts` WHERE outcome = 'completed' GROUP BY 1
)
SELECT
  d,
  a.assigned,
  att.attempted,
  comp.completed,
  SAFE_DIVIDE(comp.completed, NULLIF(a.assigned,0)) AS comp_per_assigned,
  SAFE_DIVIDE(comp.completed, NULLIF(att.attempted,0)) AS comp_per_attempt
FROM (SELECT DISTINCT d FROM a UNION DISTINCT SELECT d FROM att UNION DISTINCT SELECT d FROM comp) days d
LEFT JOIN a   ON a.d = d.d
LEFT JOIN att ON att.d = d.d
LEFT JOIN comp ON comp.d = d.d
ORDER BY d;
