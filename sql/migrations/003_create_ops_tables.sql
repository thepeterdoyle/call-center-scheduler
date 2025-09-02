-- MIGRATION 003: Operational tables
CREATE OR REPLACE TABLE `ops.employees` (
  employee_id STRING NOT NULL,
  display_name STRING NOT NULL,
  is_active BOOL NOT NULL
);
CREATE OR REPLACE TABLE `ops.employee_flags` (
  employee_id STRING NOT NULL,
  flag_code STRING NOT NULL
);
CREATE OR REPLACE TABLE `ops.shifts` (
  employee_id STRING NOT NULL,
  shift_start TIMESTAMP NOT NULL,
  shift_end   TIMESTAMP NOT NULL
);
CREATE OR REPLACE TABLE `ops.accounts` (
  account_id STRING NOT NULL,
  state_code STRING NOT NULL,
  created_at TIMESTAMP NOT NULL,
  sla_priority INT64,
  required_flag STRING,
  status STRING NOT NULL,
  last_assigned_at TIMESTAMP,
  last_assigned_employee_id STRING,
  assign_count INT64 DEFAULT 0
);
CREATE OR REPLACE TABLE `ops.assignments` (
  run_id STRING NOT NULL,
  assigned_for_hour_ts TIMESTAMP NOT NULL,
  employee_id STRING NOT NULL,
  account_id STRING NOT NULL,
  is_old_backlog BOOL NOT NULL,
  state_code STRING NOT NULL,
  assignment_seq INT64 NOT NULL,
  assignment_reason STRING,
  prior_employee_id STRING,
  carried_from_date DATE
);
CREATE OR REPLACE TABLE `ops.call_attempts` (
  attempt_id STRING NOT NULL,
  account_id STRING NOT NULL,
  employee_id STRING NOT NULL,
  assigned_for_hour_ts TIMESTAMP NOT NULL,
  attempt_ts TIMESTAMP NOT NULL,
  outcome STRING,
  run_id STRING NOT NULL,
  assignment_seq INT64 NOT NULL
);
CREATE OR REPLACE TABLE `ops.run_log` (
  run_id STRING NOT NULL,
  run_kind STRING NOT NULL,
  run_ts_et TIMESTAMP NOT NULL,
  notes STRING
);
