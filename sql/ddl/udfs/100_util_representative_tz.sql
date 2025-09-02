-- PURPOSE: Return representative tz (morning westernmost / afternoon easternmost)
-- for a given state and run kind.

CREATE OR REPLACE FUNCTION `util.representative_tz`(state_code STRING, run_kind STRING)
RETURNS STRING AS ((
  SELECT AS VALUE
    CASE UPPER(run_kind)
      WHEN 'MORNING'   THEN morning_tz_id
      WHEN 'AFTERNOON' THEN evening_tz_id
      ELSE morning_tz_id
    END
  FROM `ref.us_state_time_profile`
  WHERE state_code = state_code
));
