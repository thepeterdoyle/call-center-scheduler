-- PURPOSE: Adherence = completed / (scheduled_hours * target_cph).

CREATE OR REPLACE VIEW `rpt.employee_adherence` AS
WITH cfg AS (SELECT calls_per_agent_per_hour cph FROM `ref.system_config` ORDER BY config_date DESC LIMIT 1),
sched AS (
  SELECT
    DATE(shift_start, 'America/New_York') AS d,
    employee_id,
    SUM(TIMESTAMP_DIFF(LEAST(shift_end, TIMESTAMP_TRUNC(TIMESTAMP_ADD(shift_start, INTERVAL 1 DAY), DAY)),
                       shift_start, MINUTE))/60.0 AS scheduled_hours
  FROM `ops.shifts`
  GROUP BY 1,2
),
prod AS (
  SELECT
    DATE(attempt_ts, 'America/New_York') AS d,
    employee_id,
    COUNTIF(outcome='completed') AS completed
  FROM `ops.call_attempts`
  GROUP BY 1,2
)
SELECT
  s.d,
  e.display_name AS employee_name,
  s.employee_id,
  s.scheduled_hours,
  p.completed,
  (SELECT cph FROM cfg) AS target_cph,
  s.scheduled_hours * (SELECT cph FROM cfg) AS expected_calls,
  SAFE_DIVIDE(p.completed, NULLIF(s.scheduled_hours * (SELECT cph FROM cfg), 0)) AS adherence
FROM sched s
LEFT JOIN prod p USING (d, employee_id)
LEFT JOIN `ops.employees` e USING (employee_id)
ORDER BY s.d, employee_name;
