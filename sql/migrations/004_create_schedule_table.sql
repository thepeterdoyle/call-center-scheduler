-- Migration 004: create schedule table
CREATE TABLE IF NOT EXISTS scheduler.schedule (
  schedule_id INT64,
  agent_id INT64,
  scheduled_at TIMESTAMP
);
