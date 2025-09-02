-- PURPOSE: Last observed outcome timestamp per account (for cooldowns/QA).

CREATE OR REPLACE VIEW `rpt.account_last_outcome` AS
SELECT
  account_id,
  ARRAY_AGG(STRUCT(outcome, attempt_ts) ORDER BY attempt_ts DESC LIMIT 1)[OFFSET(0)] AS last_
FROM `ops.call_attempts`
GROUP BY account_id;
