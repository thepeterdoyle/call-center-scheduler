-- ops.assignments
CREATE OR REPLACE TABLE `ops.assignments` (
  run_id STRING OPTIONS(description="Planner run identifier that produced this assignment."),
  assigned_for_hour_ts TIMESTAMP OPTIONS(description="ET hour bucket for which the call is scheduled."),
  employee_id STRING OPTIONS(description="Assignee employee identifier."),
  account_id  STRING OPTIONS(description="Account identifier."),
  is_old_backlog BOOL OPTIONS(description="TRUE if account created before today (ET)."),
  state_code STRING OPTIONS(description="State used for local time window check."),
  assignment_seq INT64 OPTIONS(description="Sequence number of assignment for this account (1..N)."),
  assignment_reason STRING OPTIONS(description="Reason code: STICKY|NEW|RELEASED_EMPLOYEE_OFF|REBALANCE."),
  prior_employee_id STRING OPTIONS(description="Previous assignee (for sticky/release audit)."),
  carried_from_date DATE OPTIONS(description="If sticky across days, original date of carryover (ET).")
)
OPTIONS(description="Immutable assignment history; one row per assignment instance for an account.");
