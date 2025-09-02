-- ops.employees
CREATE OR REPLACE TABLE `ops.employees` (
  employee_id STRING OPTIONS(description="Stable unique identifier for an employee."),
  display_name STRING OPTIONS(description="Human-readable agent name."),
  is_active BOOL OPTIONS(description="Whether this employee is currently active and eligible for shifts.")
)
OPTIONS(description="Employee master data for call agents.");
