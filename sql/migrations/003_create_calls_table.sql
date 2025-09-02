-- Migration 003: create calls table
CREATE TABLE IF NOT EXISTS scheduler.calls (
  call_id INT64,
  received_at TIMESTAMP,
  agent_id INT64
);
