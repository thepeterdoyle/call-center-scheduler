-- PURPOSE: Per-employee daily funnel and completion rate.

CREATE OR REPLACE VIEW `rpt.employee_daily` AS
WITH base AS (
  SELECT
    DATE(a.assigned_for_hour_ts, 'America/New_York') AS work_date,
    a.employee_id,
    COUNT(*) AS assigned_cnt,
    COUNTIF(ca.outcome IS NOT NULL) AS attempted_cnt,
    COUNTIF(ca.outcome = 'completed') AS completed_cnt
  FROM `ops.assignments` a
  LEFT JOIN `ops.call_attempts` ca
    ON ca.account_id = a.account_id
   AND ca.assignment_seq = a.assignment_seq
  GROUP BY 1,2
)
SELECT
  b.work_date,
  e.display_name AS employee_name,
  b.employee_id,
  assigned_cnt,
  attempted_cnt,
  completed_cnt,
  SAFE_DIVIDE(completed_cnt, NULLIF(assigned_cnt,0)) AS completion_rate
FROM base b
LEFT JOIN `ops.employees` e USING (employee_id)
ORDER BY b.work_date, employee_name;
