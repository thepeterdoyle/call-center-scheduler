
-- Clear (optional)
-- DELETE FROM `ops.shifts` WHERE TRUE;

DECLARE days_ahead INT64 DEFAULT 14;

WITH cal AS (
  -- Next N days, ET
  SELECT DATE_ADD(CURRENT_DATE('America/New_York'), INTERVAL off DAY) AS d
  FROM UNNEST(GENERATE_ARRAY(0, days_ahead-1)) AS off
  -- Monday=2 ... Saturday=7   (1=Sunday)
  WHERE EXTRACT(DAYOFWEEK FROM DATE_ADD(CURRENT_DATE('America/New_York'), INTERVAL off DAY)) BETWEEN 2 AND 7
),
patterns AS (
  -- Candidate start/end (ET hours). We’ll pick per-employee/day by hash for variety.
  SELECT 1 AS pid, TIME  '08:00:00' AS start_t, TIME '16:00:00' AS end_t UNION ALL  -- 8–4
  SELECT 2, TIME  '09:00:00', TIME '17:00:00' UNION ALL                                -- 9–5
  SELECT 3, TIME  '10:00:00', TIME '18:00:00' UNION ALL                                -- 10–6
  SELECT 4, TIME  '12:00:00', TIME '20:00:00' UNION ALL                                -- 12–8
  SELECT 5, TIME  '13:00:00', TIME '21:00:00'                                          -- 1–9
),
emp AS (
  SELECT employee_id FROM `ops.employees` WHERE is_active
),
grid AS (
  SELECT e.employee_id, c.d,
         -- deterministic “random” pick of a pattern
         1 + ABS(MOD(FARM_FINGERPRINT(CONCAT(e.employee_id, CAST(c.d AS STRING))), 5)) AS pid
  FROM emp e CROSS JOIN cal c
),
chosen AS (
  SELECT g.employee_id, g.d, p.start_t, p.end_t
  FROM grid g
  JOIN patterns p USING (pid)
),
shifts AS (
  -- Build 1 shift per day. To ensure **both** morning and afternoon coverage across the week,
  -- we bias mid/late starts on Thu–Sat via a simple rule.
  SELECT
    employee_id,
    TIMESTAMP(DATETIME(d,
      IF(EXTRACT(DAYOFWEEK FROM d) IN (5,6,7) /*Thu-Sat*/, GREATEST(start_t, TIME '12:00:00'), start_t)
    ), 'America/New_York') AS shift_start,
    TIMESTAMP(DATETIME(d,
      IF(EXTRACT(DAYOFWEEK FROM d) IN (5,6,7) /*Thu-Sat*/, GREATEST(end_t,   TIME '20:00:00'), end_t)
    ), 'America/New_York') AS shift_end
  FROM chosen
)
INSERT INTO `ops.shifts` (employee_id, shift_start, shift_end)
SELECT employee_id, shift_start, shift_end
FROM shifts
ORDER BY employee_id, shift_start;
