-- PURPOSE: Return TRUE if timestamp falls within ET daylight saving period.

CREATE OR REPLACE FUNCTION `util.is_et_daylight`(ts TIMESTAMP)
RETURNS BOOL AS ((
  WITH y AS (SELECT EXTRACT(YEAR FROM DATETIME(ts, 'America/New_York')) AS yr),
  b AS (
    SELECT
      TIMESTAMP(DATETIME(
        DATE_ADD(
          DATE(yr,3,1),
          INTERVAL MOD(8 - EXTRACT(DAYOFWEEK FROM DATE(yr,3,1)), 7) + 7 DAY
        ),
        TIME '02:00:00'
      ), 'America/New_York') AS start_et,
      TIMESTAMP(DATETIME(
        DATE_ADD(
          DATE(yr,11,1),
          INTERVAL MOD(8 - EXTRACT(DAYOFWEEK FROM DATE(yr,11,1)), 7) DAY
        ),
        TIME '02:00:00'
      ), 'America/New_York') AS end_et
  )
  SELECT (ts >= start_et AND ts < end_et) FROM b
));
