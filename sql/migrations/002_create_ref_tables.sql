-- MIGRATION 002: Reference/config tables
CREATE OR REPLACE TABLE `ref.call_window_config` (
  effective_date DATE NOT NULL,
  local_start_time TIME NOT NULL,
  local_end_time TIME NOT NULL
);
CREATE OR REPLACE TABLE `ref.system_config` (
  config_date DATE NOT NULL,
  calls_per_agent_per_hour INT64 NOT NULL,
  morning_run_hour_et TIME NOT NULL,
  afternoon_run_hour_et TIME NOT NULL
);
CREATE OR REPLACE TABLE `ref.us_state_timezones` (
  state_code STRING NOT NULL,
  tz_id STRING NOT NULL
);
CREATE OR REPLACE TABLE `ref.us_state_time_profile` (
  state_code STRING NOT NULL,
  morning_tz_id STRING NOT NULL,
  evening_tz_id STRING NOT NULL
);
CREATE OR REPLACE TABLE `ref.us_tz_dst_calendar` (
  tz_id STRING,
  year INT64,
  observes_dst BOOL,
  dst_start_local_ts TIMESTAMP,
  dst_end_local_ts TIMESTAMP,
  diff_minutes_vs_et_standard INT64,
  diff_minutes_vs_et_daylight INT64
);
CREATE OR REPLACE TABLE `ref.cooldown_config` (
  outcome STRING,
  cooldown_hours INT64 NOT NULL
);
CREATE OR REPLACE TABLE `ref.split_tuning` (
  min_old_share FLOAT64 NOT NULL,
  max_old_share FLOAT64 NOT NULL
);
CREATE OR REPLACE TABLE `ref.us_state_holidays` (
  state_code STRING,
  holiday_date DATE
);
CREATE OR REPLACE TABLE `ref.what_if_params` (
  asof_date DATE,
  extra_calls_per_agent_per_day INT64
);
