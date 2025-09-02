-- ref.what_if_params
CREATE OR REPLACE TABLE `ref.what_if_params` (
  asof_date DATE OPTIONS(description="Date for which the what-if parameter applies (ET)."),
  extra_calls_per_agent_per_day INT64 OPTIONS(description="Hypothetical additional completed calls per active agent per day.")
)
OPTIONS(description="Scenario parameters for backlog ETA what-ifs (e.g., +5 calls/agent/day).");
