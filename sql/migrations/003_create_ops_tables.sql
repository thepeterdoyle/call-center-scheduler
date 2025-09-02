-- MIGRATION 003: Operational tables
-- ops.employees
CREATE OR REPLACE TABLE `ops.employees` (
  employee_id STRING OPTIONS(description="Stable unique identifier for an employee."),
  display_name STRING OPTIONS(description="Human-readable agent name."),
  is_active BOOL OPTIONS(description="Whether this employee is currently active and eligible for shifts.")
)
OPTIONS(description="Employee master data for call agents.");

-- ops.employee_flags
CREATE OR REPLACE TABLE `ops.employee_flags` (
  employee_id STRING OPTIONS(description="Employee unique identifier."),
  flag_code   STRING OPTIONS(description="Eligibility/skill flag required by some accounts (string code).")
)
OPTIONS(description="Eligibility flags that qualify employees for specific account types/SLAs.");


-- ops.shifts
CREATE OR REPLACE TABLE `ops.shifts` (
  employee_id STRING OPTIONS(description="Employee unique identifier."),
  shift_start TIMESTAMP OPTIONS(description="Shift start timestamp (ET)."),
  shift_end   TIMESTAMP OPTIONS(description="Shift end timestamp (ET), exclusive.")
)
OPTIONS(description="Shift roster (ET) defining when employees are on duty and eligible for assignments.");

-- ops.accounts
CREATE OR REPLACE TABLE `ops.accounts` (
  account_id STRING OPTIONS(description="Unique account identifier to be called."),
  state_code STRING OPTIONS(description="USPS state code used to infer local time window."),
  created_at TIMESTAMP OPTIONS(description="Timestamp when the account entered the queue."),
  sla_priority INT64 OPTIONS(description="Optional numeric SLA priority; lower means higher priority."),
  required_flag STRING OPTIONS(description="Eligibility flag required to handle this account."),
  status STRING OPTIONS(description="Lifecycle: new|assigned|attempted|done|dead."),
  last_assigned_at TIMESTAMP OPTIONS(description="Timestamp of most recent assignment."),
  last_assigned_employee_id STRING OPTIONS(description="Most recent assignee for sticky logic."),
  assign_count INT64 OPTIONS(description="How many times this account has been assigned (cumulative).")
)
OPTIONS(description="Active account queue that still needs calls. Rows are removed/marked done when completed.");

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

-- ops.run_log
CREATE OR REPLACE TABLE `ops.run_log` (
  run_id STRING OPTIONS(description="Run identifier (e.g., run_YYYYMMDD_hhmmss)."),
  run_kind STRING OPTIONS(description="MORNING or AFTERNOON."),
  run_ts_et TIMESTAMP OPTIONS(description="Timestamp when planning was executed (ET)."),
  notes STRING OPTIONS(description="Freeform notes or planner version tag.")
)
OPTIONS(description="Audit log of planning runs.");

