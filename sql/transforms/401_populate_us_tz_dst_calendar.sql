-- PURPOSE: Populate/refresh DST calendar table (2020–2035 default).
-- Schedule annually. Adjust years as needed.

DECLARE year_start INT64 DEFAULT 2020;
DECLARE year_end   INT64 DEFAULT 2035;

CREATE OR REPLACE TEMP TABLE _tzs AS
SELECT DISTINCT morning_tz_id AS tz_id FROM `ref.us_state_time_profile`
UNION DISTINCT
SELECT DISTINCT evening_tz_id FROM `ref.us_state_time_profile`;

CREATE OR REPLACE TEMP FUNCTION util_first_sunday(d DATE) AS (
  DATE_ADD(d, INTERVAL MOD(8 - EXTRACT(DAYOFWEEK FROM d), 7) DAY)
);

WITH years AS (
  SELECT y AS year FROM UNNEST(GENERATE_ARRAY(year_start, year_end)) AS y
),
bounds AS (
  SELECT
    year,
    DATETIME(DATE_ADD(util_first_sunday(DATE(year,3,1)), INTERVAL 7 DAY), TIME '02:00:00') AS dst_start_local_dt,
    DATETIME(util_first_sunday(DATE(year,11,1)), TIME '02:00:00') AS dst_end_local_dt
  FROM years
),
calc AS (
  SELECT
    t.tz_id, b.year,
    SAFE_CAST(
      TIMESTAMP_DIFF(
        TIMESTAMP(DATETIME(DATE(b.year,7,15), TIME '12:00:00'), t.tz_id),
        TIMESTAMP(DATETIME(DATE(b.year,1,15), TIME '12:00:00'), t.tz_id),
        MINUTE
      ) != 0 AS BOOL
    ) AS observes_dst,
    TIMESTAMP(DATETIME(b.dst_start_local_dt), t.tz_id) AS dst_start_local_ts,
    TIMESTAMP(DATETIME(b.dst_end_local_dt),   t.tz_id) AS dst_end_local_ts,
    TIMESTAMP_DIFF(
      TIMESTAMP(DATETIME(DATETIME(TIMESTAMP(DATETIME(DATE(b.year,1,15), TIME '12:00:00'),
              'America/New_York')), t.tz_id)),
      TIMESTAMP(DATETIME(DATE(b.year,1,15), TIME '12:00:00'), 'America/New_York'),
      MINUTE
    ) AS diff_minutes_vs_et_standard,
    TIMESTAMP_DIFF(
      TIMESTAMP(DATETIME(DATETIME(TIMESTAMP(DATETIME(DATE(b.year,7,15), TIME '12:00:00'),
              'America/New_York')), t.tz_id)),
      TIMESTAMP(DATETIME(DATE(b.year,7,15), TIME '12:00:00'), 'America/New_York'),
      MINUTE
    ) AS diff_minutes_vs_et_daylight
  FROM _tzs t CROSS JOIN bounds b
)
MERGE `ref.us_tz_dst_calendar` T
USING calc S
ON T.tz_id = S.tz_id AND T.year = S.year
WHEN MATCHED THEN UPDATE SET
  observes_dst                = S.observes_dst,
  dst_start_local_ts          = IF(S.observes_dst, S.dst_start_local_ts, NULL),
  dst_end_local_ts            = IF(S.observes_dst, S.dst_end_local_ts,   NULL),
  diff_minutes_vs_et_standard = S.diff_minutes_vs_et_standard,
  diff_minutes_vs_et_daylight = S.diff_minutes_vs_et_daylight
WHEN NOT MATCHED THEN INSERT ROW;
