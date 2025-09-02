-- ref.us_state_timezones
CREATE OR REPLACE TABLE `ref.us_state_timezones` (
  state_code STRING OPTIONS(description="USPS two-letter state code, e.g., FL, AZ."),
  tz_id      STRING OPTIONS(description="IANA time zone ID, e.g., America/New_York, America/Phoenix.")
)
OPTIONS(description="Raw mapping of US states to one or more IANA time zones. Source for representative tz selection.");
