-- Migration 007: create metrics view
CREATE OR REPLACE VIEW scheduler.call_metrics AS
SELECT agent_id, COUNT(*) AS total_calls
FROM scheduler.calls
GROUP BY agent_id;
