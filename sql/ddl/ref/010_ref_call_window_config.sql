-- ref.call_window_config
CREATE OR REPLACE TABLE `ref.call_window_config` (
  effective_date DATE OPTIONS(description="Date the configuration becomes effective (ET). Newest row wins."),
  local_start_time TIME OPTIONS(description="Earliest local time (HH:MM:SS) calls are allowed in the customer’s local time zone."),
  local_end_time   TIME OPTIONS(description="Latest local time (HH:MM:SS) calls are allowed in the customer’s local time zone.")
)
OPTIONS(description="Business-hours configuration for local calling windows. Used to determine if a state’s local time is callable.");

