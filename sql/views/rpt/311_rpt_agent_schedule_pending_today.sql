-- PURPOSE: Which assignments today are still not completed.

CREATE OR REPLACE VIEW `rpt.agent_schedule_pending_today` AS
SELECT *
FROM `rpt.agent_schedule_daily`
WHERE completed_flag = FALSE
ORDER BY employee_name, display_hour_et, row_in_hour;
