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
