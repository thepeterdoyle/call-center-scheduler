-- ref.system_config
CREATE OR REPLACE TABLE `ref.system_config` (
  config_date DATE OPTIONS(description="Date this config row applies. Newest row wins."),
  calls_per_agent_per_hour INT64 OPTIONS(description="Target assignment rate per agent per hour (integer)."),
  morning_run_hour_et TIME OPTIONS(description="Default morning planning start time (ET)."),
  afternoon_run_hour_et TIME OPTIONS(description="Default afternoon planning start time (ET).")
)
OPTIONS(description="Global knobs for planning runs: calls/hour per agent and default AM/PM run hours (ET).");
