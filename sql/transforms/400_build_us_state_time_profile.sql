-- PURPOSE: Derive representative tz per state using offsets in both winter/summer.
-- Run after loading ref.us_state_timezones.

CREATE OR REPLACE TABLE `ref.us_state_time_profile` AS
WITH z AS (
  SELECT DISTINCT state_code, tz_id FROM `ref.us_state_timezones`
),
off AS (
  SELECT
    z.state_code,
    z.tz_id,
    TIMESTAMP_DIFF(
      TIMESTAMP(DATETIME(DATE(2025,1,15), TIME '12:00:00'), z.tz_id),
      TIMESTAMP(DATETIME(DATE(2025,1,15), TIME '12:00:00')),
      MINUTE
    ) AS off_jan_min,
    TIMESTAMP_DIFF(
      TIMESTAMP(DATETIME(DATE(2025,7,15), TIME '12:00:00'), z.tz_id),
      TIMESTAMP(DATETIME(DATE(2025,7,15), TIME '12:00:00')),
      MINUTE
    ) AS off_jul_min
  FROM z
),
agg AS (
  SELECT state_code, ARRAY_AGG(STRUCT(tz_id, off_jan_min, off_jul_min)) AS rows
  FROM off GROUP BY state_code
)
SELECT
  state_code,
  (SELECT tz_id FROM UNNEST(rows)
   ORDER BY LEAST(off_jan_min, off_jul_min) ASC, tz_id LIMIT 1) AS morning_tz_id,
  (SELECT tz_id FROM UNNEST(rows)
   ORDER BY GREATEST(off_jan_min, off_jul_min) DESC, tz_id LIMIT 1) AS evening_tz_id
FROM agg;
