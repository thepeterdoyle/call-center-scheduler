-- PURPOSE: Current backlog size (open accounts needing calls).

CREATE OR REPLACE VIEW `rpt.backlog_today` AS
SELECT
  CURRENT_DATE('America/New_York') AS asof_date,
  COUNTIF(status IN ('new','assigned','attempted')) AS backlog_open
FROM `ops.accounts`;
