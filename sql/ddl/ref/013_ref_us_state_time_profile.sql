-- ref.us_state_time_profile
CREATE OR REPLACE TABLE `ref.us_state_time_profile` (
  state_code    STRING OPTIONS(description="USPS two-letter state code."),
  morning_tz_id STRING OPTIONS(description="Representative tz for morning runs (westernmost across split-TZ states)."),
  evening_tz_id STRING OPTIONS(description="Representative tz for afternoon runs (easternmost across split-TZ states).")
)
OPTIONS(description="Derived representative time zones per state. Morning=westernmost; afternoon=easternmost. Used for state-level local time checks.");
