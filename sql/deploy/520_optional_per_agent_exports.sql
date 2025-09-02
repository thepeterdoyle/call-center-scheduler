-- PURPOSE: Optional per-agent CSV exports after a run (dynamic EXECUTE IMMEDIATE).
-- Replace gs://YOUR_BUCKET.

DECLARE report_date DATE DEFAULT DATE(CURRENT_TIMESTAMP(), 'America/New_York');

CREATE TEMP TABLE _agents AS
SELECT DISTINCT employee_id, ANY_VALUE(employee_name) AS employee_name
FROM `rpt.agent_schedule_daily`
WHERE DATE(display_hour_et, 'America/New_York') = report_date;

DECLARE done BOOL DEFAULT FALSE;
DECLARE emp_id STRING;
DECLARE emp_name STRING;

DECLARE cur CURSOR FOR
  SELECT employee_id, employee_name FROM _agents ORDER BY employee_name;

OPEN cur;
LOOP
  FETCH cur INTO emp_id, emp_name;
  SET done = emp_id IS NULL;
  IF done THEN LEAVE; END IF;

  EXECUTE IMMEDIATE '''
    EXPORT DATA OPTIONS(
      uri = "gs://YOUR_BUCKET/call-plans/dt_date=''' || CAST(report_date AS STRING) || '''/agent_''' || emp_id || '''_*.csv",
      format = "CSV", overwrite = true, header = true
    ) AS
    SELECT *
    FROM `rpt.agent_schedule_daily`
    WHERE employee_id = "''' || emp_id || '''"
    ORDER BY display_hour_et, row_in_hour
  ''';
END LOOP;
CLOSE cur;
