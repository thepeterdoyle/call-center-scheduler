-- Migration 002: create shifts table
CREATE TABLE IF NOT EXISTS scheduler.shifts (
  shift_id INT64,
  agent_id INT64,
  shift_date DATE
);
