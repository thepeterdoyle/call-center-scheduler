-- Migration 005: create backlog table
CREATE TABLE IF NOT EXISTS scheduler.backlog (
  backlog_id INT64,
  created_at TIMESTAMP,
  call_id INT64
);
