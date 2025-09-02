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
