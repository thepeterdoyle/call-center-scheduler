-- ops.call_attempts
CREATE OR REPLACE TABLE `ops.call_attempts` (
  attempt_id STRING OPTIONS(description="Unique attempt identifier."),
  account_id STRING OPTIONS(description="Target account."),
  employee_id STRING OPTIONS(description="Agent who performed the attempt."),
  assigned_for_hour_ts TIMESTAMP OPTIONS(description="Planned ET hour bucket when the assignment was scheduled."),
  attempt_ts TIMESTAMP OPTIONS(description="Actual timestamp of the attempt (ET)."),
  outcome STRING OPTIONS(description="Outcome label, e.g., completed, no_answer, busy, reschedule."),
  run_id STRING OPTIONS(description="Planner run id associated with the assignment."),
  assignment_seq INT64 OPTIONS(description="Assignment sequence this attempt belongs to (join key with ops.assignments).")
)
OPTIONS(description="Attempt-level call outcomes linked to assignments.");
