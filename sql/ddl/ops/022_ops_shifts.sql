-- ops.shifts
CREATE OR REPLACE TABLE `ops.shifts` (
  employee_id STRING OPTIONS(description="Employee unique identifier."),
  shift_start TIMESTAMP OPTIONS(description="Shift start timestamp (ET)."),
  shift_end   TIMESTAMP OPTIONS(description="Shift end timestamp (ET), exclusive.")
)
OPTIONS(description="Shift roster (ET) defining when employees are on duty and eligible for assignments.");
