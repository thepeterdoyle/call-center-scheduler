-- Migration 008: seed initial data
INSERT INTO scheduler.agents (agent_id, full_name)
VALUES (1, 'Alice'), (2, 'Bob');
