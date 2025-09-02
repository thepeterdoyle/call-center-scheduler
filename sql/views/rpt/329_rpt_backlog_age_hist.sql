-- PURPOSE: Backlog age distribution to spot staleness.

CREATE OR REPLACE VIEW `rpt.backlog_age_hist` AS
SELECT
  CASE
    WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), created_at, DAY) < 1  THEN '0-1d'
    WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), created_at, DAY) < 3  THEN '1-3d'
    WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), created_at, DAY) < 7  THEN '3-7d'
    WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), created_at, DAY) < 14 THEN '7-14d'
    ELSE '14d+'
  END AS age_bucket,
  COUNT(*) AS cnt
FROM `ops.accounts`
WHERE status IN ('new','assigned','attempted')
GROUP BY age_bucket
ORDER BY
  CASE age_bucket WHEN '0-1d' THEN 1 WHEN '1-3d' THEN 2 WHEN '3-7d' THEN 3
                  WHEN '7-14d' THEN 4 ELSE 5 END;
