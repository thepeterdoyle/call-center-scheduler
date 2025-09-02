-- MIGRATION 002: Reference/config tables
-- ref.call_window_config
CREATE OR REPLACE TABLE `ref.call_window_config` (
  effective_date DATE OPTIONS(description="Date the configuration becomes effective (ET). Newest row wins."),
  local_start_time TIME OPTIONS(description="Earliest local time (HH:MM:SS) calls are allowed in the customer’s local time zone."),
  local_end_time   TIME OPTIONS(description="Latest local time (HH:MM:SS) calls are allowed in the customer’s local time zone.")
)
OPTIONS(description="Business-hours configuration for local calling windows. Used to determine if a state’s local time is callable.");

-- ref.system_config
CREATE OR REPLACE TABLE `ref.system_config` (
  config_date DATE OPTIONS(description="Date this config row applies. Newest row wins."),
  calls_per_agent_per_hour INT64 OPTIONS(description="Target assignment rate per agent per hour (integer)."),
  morning_run_hour_et TIME OPTIONS(description="Default morning planning start time (ET)."),
  afternoon_run_hour_et TIME OPTIONS(description="Default afternoon planning start time (ET).")
)
OPTIONS(description="Global knobs for planning runs: calls/hour per agent and default AM/PM run hours (ET).");

-- ref.us_state_timezones
CREATE OR REPLACE TABLE `ref.us_state_timezones` (
  state_code STRING OPTIONS(description="USPS two-letter state code, e.g., FL, AZ."),
  tz_id      STRING OPTIONS(description="IANA time zone ID, e.g., America/New_York, America/Phoenix.")
)
OPTIONS(description="Raw mapping of US states to one or more IANA time zones. Source for representative tz selection.");

-- ref.us_state_time_profile
CREATE OR REPLACE TABLE `ref.us_state_time_profile` (
  state_code    STRING OPTIONS(description="USPS two-letter state code."),
  morning_tz_id STRING OPTIONS(description="Representative tz for morning runs (westernmost across split-TZ states)."),
  evening_tz_id STRING OPTIONS(description="Representative tz for afternoon runs (easternmost across split-TZ states).")
)
OPTIONS(description="Derived representative time zones per state. Morning=westernmost; afternoon=easternmost. Used for state-level local time checks.");

-- ref.us_tz_dst_calendar
CREATE OR REPLACE TABLE `ref.us_tz_dst_calendar` (
  tz_id STRING OPTIONS(description="IANA time zone identifier."),
  year INT64 OPTIONS(description="Gregorian year for DST computation."),
  observes_dst BOOL OPTIONS(description="Whether the zone observes DST in this year."),
  dst_start_local_ts TIMESTAMP OPTIONS(description="Local timestamp of DST start (if observes)."),
  dst_end_local_ts   TIMESTAMP OPTIONS(description="Local timestamp of DST end (if observes)."),
  diff_minutes_vs_et_standard INT64 OPTIONS(description="Offset difference (minutes) vs Eastern Time during winter (ET standard time)."),
  diff_minutes_vs_et_daylight INT64 OPTIONS(description="Offset difference (minutes) vs Eastern Time during summer (ET daylight time).")
)
OPTIONS(description="Audit calendar of DST boundaries and offsets vs Eastern Time per IANA tz/year. For QA/visibility; planner uses IANA tz directly.");

-- ref.cooldown_config
CREATE OR REPLACE TABLE `ref.cooldown_config` (
  outcome STRING OPTIONS(description="Last call outcome category (e.g., no_answer, busy, left_voicemail, reschedule)."),
  cooldown_hours INT64 OPTIONS(description="Number of hours to wait before the account becomes eligible again.")
)
OPTIONS(description="Outcome-based cooldown policy to prevent rapid, low-yield retries.");

-- ref.split_tuning
CREATE OR REPLACE TABLE `ref.split_tuning` (
  min_old_share FLOAT64 OPTIONS(description="Minimum fraction of hourly capacity reserved for OLD backlog (0–1)."),
  max_old_share FLOAT64 OPTIONS(description="Maximum fraction of hourly capacity reserved for OLD backlog (0–1).")
)
OPTIONS(description="Bounds for dynamic split between OLD vs NEW backlog during hourly planning.");

-- ref.us_state_holidays (optional)
CREATE OR REPLACE TABLE `ref.us_state_holidays` (
  state_code  STRING OPTIONS(description="USPS state code."),
  holiday_date DATE OPTIONS(description="Holiday/quiet date in the state calendar.")
)
OPTIONS(description="Optional quiet-day list by state to suppress calling on low-yield or restricted dates.");

-- ref.what_if_params
CREATE OR REPLACE TABLE `ref.what_if_params` (
  asof_date DATE OPTIONS(description="Date for which the what-if parameter applies (ET)."),
  extra_calls_per_agent_per_day INT64 OPTIONS(description="Hypothetical additional completed calls per active agent per day.")
)
OPTIONS(description="Scenario parameters for backlog ETA what-ifs (e.g., +5 calls/agent/day).");

