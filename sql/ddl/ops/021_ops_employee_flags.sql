-- ops.employee_flags
CREATE OR REPLACE TABLE `ops.employee_flags` (
  employee_id STRING OPTIONS(description="Employee unique identifier."),
  flag_code   STRING OPTIONS(description="Eligibility/skill flag required by some accounts (string code).")
)
OPTIONS(description="Eligibility flags that qualify employees for specific account types/SLAs.");
