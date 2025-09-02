-- ref.split_tuning
CREATE OR REPLACE TABLE `ref.split_tuning` (
  min_old_share FLOAT64 OPTIONS(description="Minimum fraction of hourly capacity reserved for OLD backlog (0–1)."),
  max_old_share FLOAT64 OPTIONS(description="Maximum fraction of hourly capacity reserved for OLD backlog (0–1).")
)
OPTIONS(description="Bounds for dynamic split between OLD vs NEW backlog during hourly planning.");
