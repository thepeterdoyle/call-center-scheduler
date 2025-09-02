-- Migration 001: create agents table
CREATE TABLE IF NOT EXISTS scheduler.agents (
  agent_id INT64,
  full_name STRING
);
