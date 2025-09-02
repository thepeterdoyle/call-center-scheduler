-- Migration 006: create assignments table
CREATE TABLE IF NOT EXISTS scheduler.assignments (
  assignment_id INT64,
  call_id INT64,
  agent_id INT64,
  assigned_at TIMESTAMP
);
