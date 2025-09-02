-- PURPOSE: Old vs New split for dynamic quota tuning.

CREATE OR REPLACE VIEW `rpt.backlog_composition` AS
WITH cutoff AS (
  SELECT TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'America/New_York') AS new_cutoff
)
SELECT
  COUNTIF(a.created_at < (SELECT new_cutoff FROM cutoff)) AS backlog_old,
  COUNTIF(a.created_at >= (SELECT new_cutoff FROM cutoff)) AS backlog_new
FROM `ops.accounts` a
WHERE a.status IN ('new','assigned','attempted');
