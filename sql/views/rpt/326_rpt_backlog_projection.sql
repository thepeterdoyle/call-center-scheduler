-- PURPOSE: Baseline vs What-If backlog ETA (e.g., +5 calls/agent/day).

CREATE OR REPLACE VIEW `rpt.backlog_projection` AS
WITH backlog AS (SELECT backlog_open FROM `rpt.backlog_today`),
perf AS (
  SELECT ANY_VALUE(avg7_completed) AS base_completed_per_day
  FROM `rpt.rolling_capacity`
  QUALIFY ROW_NUMBER() OVER (ORDER BY d DESC)=1
),
agents AS (
  SELECT COUNT(DISTINCT employee_id) AS active_agents_7d
  FROM `ops.call_attempts`
  WHERE attempt_ts >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
),
p AS (
  SELECT
    COALESCE((
      SELECT extra_calls_per_agent_per_day
      FROM `ref.what_if_params`
      WHERE asof_date = CURRENT_DATE('America/New_York')
      ORDER BY asof_date DESC LIMIT 1
    ), 0) AS extra_per_agent
)
SELECT
  (SELECT backlog_open FROM backlog) AS backlog_open,
  (SELECT base_completed_per_day FROM perf) AS baseline_daily_completed,
  (SELECT base_completed_per_day FROM perf) + ((SELECT active_agents_7d FROM agents) * (SELECT extra_per_agent FROM p)) AS whatif_daily_completed,
  SAFE_DIVIDE((SELECT backlog_open FROM backlog), NULLIF((SELECT base_completed_per_day FROM perf),0)) AS eta_days_baseline,
  SAFE_DIVIDE((SELECT backlog_open FROM backlog), NULLIF((SELECT base_completed_per_day FROM perf) + ((SELECT active_agents_7d FROM agents) * (SELECT extra_per_agent FROM p)),0)) AS eta_days_with_extra,
  SAFE_DIVIDE((SELECT backlog_open FROM backlog), NULLIF((SELECT base_completed_per_day FROM perf),0))
  - SAFE_DIVIDE((SELECT backlog_open FROM backlog), NULLIF((SELECT base_completed_per_day FROM perf) + ((SELECT active_agents_7d FROM agents) * (SELECT extra_per_agent FROM p)),0)) AS days_saved
;
