-- PURPOSE: Agent-facing schedule with hour labels and attempt/completion flags.
-- One row = one assignment. Rows within an hour labeled by ET hour.

DECLARE report_date DATE DEFAULT DATE(CURRENT_TIMESTAMP(), 'America/New_York');

CREATE OR REPLACE VIEW `rpt.agent_schedule_daily` AS
WITH day_assignments AS (
  SELECT
    a.run_id,
    a.employee_id,
    e.display_name AS employee_name,
    a.account_id,
    a.state_code,
    a.is_old_backlog,
    a.assignment_reason,
    a.assignment_seq,
    TIMESTAMP_TRUNC(a.assigned_for_hour_ts, HOUR, 'America/New_York') AS display_hour_et
  FROM `ops.assignments` a
  JOIN `ops.employees` e USING (employee_id)
  WHERE DATE(a.assigned_for_hour_ts, 'America/New_York') = report_date
),
acct AS (
  SELECT account_id, sla_priority, created_at FROM `ops.accounts`
),
attempts AS (
  SELECT
    account_id, assignment_seq,
    BOOL_OR(TRUE) AS attempted_flag,
    BOOL_OR(outcome = 'completed') AS completed_flag,
    ARRAY_AGG(STRUCT(attempt_ts, outcome) ORDER BY attempt_ts DESC LIMIT 1)[OFFSET(0)].attempt_ts AS last_attempt_ts,
    ARRAY_AGG(STRUCT(attempt_ts, outcome) ORDER BY attempt_ts DESC LIMIT 1)[OFFSET(0)].outcome AS last_outcome
  FROM `ops.call_attempts`
  GROUP BY account_id, assignment_seq
),
with_row AS (
  SELECT
    d.*, ac.sla_priority, ac.created_at,
    COALESCE(at.attempted_flag, FALSE) AS attempted_flag,
    COALESCE(at.completed_flag, FALSE) AS completed_flag,
    at.last_attempt_ts, at.last_outcome,
    ROW_NUMBER() OVER (
      PARTITION BY d.employee_id, d.display_hour_et
      ORDER BY d.is_old_backlog DESC, COALESCE(ac.sla_priority,999), ac.created_at, d.account_id
    ) AS row_in_hour
  FROM day_assignments d
  LEFT JOIN acct ac USING (account_id)
  LEFT JOIN attempts at
    ON at.account_id = d.account_id
   AND at.assignment_seq = d.assignment_seq
)
SELECT
  employee_name, employee_id,
  display_hour_et,
  FORMAT_DATETIME('%I:%M %p', DATETIME(display_hour_et, 'America/New_York')) AS display_hour_str,
  account_id, state_code, is_old_backlog, assignment_reason, assignment_seq,
  row_in_hour, sla_priority, created_at,
  attempted_flag, completed_flag, last_attempt_ts, last_outcome
FROM with_row
ORDER BY employee_name, display_hour_et, row_in_hour;
