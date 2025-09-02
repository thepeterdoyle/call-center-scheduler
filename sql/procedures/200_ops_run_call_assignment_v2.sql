-- PURPOSE: Plan call assignments by hour (ET), DST/time-zone aware per state.
-- Features:
--  - Callable states by local business hours (morning/evening TZ rule).
--  - Sticky reassignments if prior employee is on-shift.
--  - Dynamic old/new split (adaptive to backlog composition).
--  - Cooldown filter by last outcome.
--  - Hour weighting by historical completion rate.
--  - Fair round-robin across eligible agents (per flag) for released work.
-- Inputs:
--   run_ts_et TIMESTAMP (ET), run_kind STRING ('MORNING'|'AFTERNOON'),
--   hours_ahead INT64 (planning horizon), rotation_seed INT64 (RR offset).
-- Output:
--   Inserts into ops.assignments; updates ops.accounts status & counters.

CREATE OR REPLACE PROCEDURE `ops.run_call_assignment_v2`(
  run_ts_et TIMESTAMP,
  run_kind STRING,
  hours_ahead INT64,
  rotation_seed INT64,
  out_run_id OUT STRING
)
BEGIN
  DECLARE run_id STRING DEFAULT CONCAT('run_', FORMAT_TIMESTAMP('%Y%m%d_%H%M%S', run_ts_et, 'America/New_York'));
  SET out_run_id = run_id;

  -- Log run
  INSERT INTO `ops.run_log`(run_id, run_kind, run_ts_et, notes)
  VALUES (run_id, run_kind, run_ts_et, 'v2 planner');

  -- Hour buckets from run TS to +N hours (normalized to top-of-hour ET)
  CREATE TEMP TABLE hours AS
  SELECT TIMESTAMP_TRUNC(TIMESTAMP_ADD(run_ts_et, INTERVAL h HOUR), HOUR, 'America/New_York') AS hour_et
  FROM UNNEST(GENERATE_ARRAY(0, hours_ahead)) AS h;

  -- Call window (1 row)
  CREATE TEMP TABLE win AS
  SELECT local_start_time, local_end_time
  FROM `ref.call_window_config`
  ORDER BY effective_date DESC LIMIT 1;

  -- Callable states per hour (DST-aware via representative tz)
  CREATE TEMP TABLE callable AS
  WITH states AS (SELECT DISTINCT state_code FROM `ref.us_state_time_profile`),
  expanded AS (
    SELECT
      h.hour_et,
      s.state_code,
      `util.representative_tz`(s.state_code, run_kind) AS tz_id,
      DATETIME(h.hour_et, `util.representative_tz`(s.state_code, run_kind)) AS local_dt
    FROM hours h CROSS JOIN states s
  )
  SELECT e.hour_et, e.state_code
  FROM expanded e, win w
  WHERE TIME(e.local_dt) >= w.local_start_time
    AND TIME(e.local_dt) <  w.local_end_time
    AND NOT EXISTS (  -- optional holiday block
      SELECT 1 FROM `ref.us_state_holidays` h
      WHERE h.state_code = e.state_code
        AND h.holiday_date = DATE(e.local_dt)
    );

  -- On-shift employees per hour
  CREATE TEMP TABLE on_shift AS
  SELECT h.hour_et, s.employee_id
  FROM hours h
  JOIN `ops.shifts` s
    ON h.hour_et >= s.shift_start AND h.hour_et < s.shift_end
  JOIN `ops.employees` e USING (employee_id)
  WHERE e.is_active;

  -- Eligible employees by flag per hour
  CREATE TEMP TABLE elig_by_flag AS
  SELECT
    o.hour_et, f.flag_code,
    ARRAY_AGG(o.employee_id ORDER BY o.employee_id) AS elig_agents
  FROM on_shift o
  JOIN `ops.employee_flags` f USING (employee_id)
  GROUP BY o.hour_et, f.flag_code;

  -- Capacity per hour
  CREATE TEMP TABLE cfg AS
  SELECT calls_per_agent_per_hour AS cph
  FROM `ref.system_config`
  ORDER BY config_date DESC LIMIT 1;

  CREATE TEMP TABLE capacity AS
  SELECT
    h.hour_et,
    (SELECT cph FROM cfg) AS cph,
    COUNT(DISTINCT o.employee_id) AS agents,
    COUNT(DISTINCT o.employee_id) * (SELECT cph FROM cfg) AS total_capacity_h
  FROM hours h LEFT JOIN on_shift o USING (hour_et)
  GROUP BY h.hour_et;

  -- Dynamic old/new split based on backlog composition and bounds
  CREATE TEMP TABLE backlog_comp AS
  SELECT backlog_old, backlog_new FROM `rpt.backlog_composition`;

  CREATE TEMP TABLE split AS
  SELECT
    (SELECT min_old_share FROM `ref.split_tuning` LIMIT 1) AS min_old,
    (SELECT max_old_share FROM `ref.split_tuning` LIMIT 1) AS max_old,
    CAST(backlog_old AS FLOAT64) / NULLIF(CAST(backlog_old + backlog_new AS FLOAT64),0) AS pressure
  FROM backlog_comp;

  CREATE TEMP TABLE quotas AS
  SELECT
    c.hour_et,
    c.total_capacity_h,
    CAST(CEIL(
      LEAST((SELECT max_old FROM split),
            GREATEST((SELECT min_old FROM split), COALESCE((SELECT pressure FROM split), 0.5))
      ) * c.total_capacity_h
    ) AS INT64) AS old_quota_h,
    c.total_capacity_h -
    CAST(CEIL(
      LEAST((SELECT max_old FROM split),
            GREATEST((SELECT min_old FROM split), COALESCE((SELECT pressure FROM split), 0.5))
      ) * c.total_capacity_h
    ) AS INT64) AS new_quota_h
  FROM capacity c;

  -- Candidate accounts filtered by callable states
  CREATE TEMP TABLE cand AS
  SELECT
    c.hour_et, a.account_id, a.state_code, a.required_flag, a.created_at, a.sla_priority,
    a.last_assigned_employee_id, a.last_assigned_at, a.status
  FROM callable c
  JOIN `ops.accounts` a USING (state_code)
  WHERE a.status IN ('new','assigned','attempted');

  -- New/Old cutoff (example: created before today ET = OLD)
  CREATE TEMP TABLE marks AS
  SELECT TIMESTAMP_TRUNC(run_ts_et, DAY, 'America/New_York') AS new_cutoff;

  -- Cooldown exclusion by last outcome
  CREATE TEMP TABLE cooldown_excluded AS
  WITH lasto AS (
    SELECT account_id,
           ARRAY_AGG(STRUCT(outcome, attempt_ts) ORDER BY attempt_ts DESC LIMIT 1)[OFFSET(0)].outcome AS last_outcome,
           ARRAY_AGG(STRUCT(outcome, attempt_ts) ORDER BY attempt_ts DESC LIMIT 1)[OFFSET(0)].attempt_ts AS last_attempt_ts
    FROM `ops.call_attempts`
    GROUP BY account_id
  ),
  cd AS (SELECT outcome, cooldown_hours FROM `ref.cooldown_config`)
  SELECT ca.*
  FROM cand ca
  LEFT JOIN lasto lo USING (account_id)
  LEFT JOIN cd ON cd.outcome = lo.last_outcome
  WHERE lo.last_outcome IS NULL
     OR lo.last_attempt_ts <= TIMESTAMP_SUB(ca.hour_et, INTERVAL COALESCE(cd.cooldown_hours, 0) HOUR);

  -- Sticky vs released
  CREATE TEMP TABLE sticky AS
  SELECT ca.*, TRUE AS is_sticky
  FROM cooldown_excluded ca
  JOIN on_shift os
    ON os.hour_et = ca.hour_et AND os.employee_id = ca.last_assigned_employee_id;

  CREATE TEMP TABLE released AS
  SELECT ca.*, FALSE AS is_sticky
  FROM cooldown_excluded ca
  LEFT JOIN sticky s
    ON s.hour_et = ca.hour_et AND s.account_id = ca.account_id
  WHERE s.account_id IS NULL;

  -- Hour weighting by historical completion rate
  CREATE TEMP TABLE hour_weight AS
  SELECT hour_et, COALESCE(comp_rate, 0.0) AS score
  FROM `rpt.hour_perf`;

  -- Rank Old/New within (hour, flag, sticky), prioritize better hours
  CREATE TEMP TABLE ranked AS
  SELECT
    x.hour_et, x.account_id, x.state_code, x.required_flag, x.created_at, x.sla_priority,
    x.last_assigned_employee_id, x.last_assigned_at, x.is_sticky,
    CASE WHEN x.created_at < (SELECT new_cutoff FROM marks) THEN TRUE ELSE FALSE END AS is_old,
    ROW_NUMBER() OVER (
      PARTITION BY x.hour_et, x.required_flag, x.is_sticky,
                   CASE WHEN x.created_at < (SELECT new_cutoff FROM marks) THEN 'OLD' ELSE 'NEW' END
      ORDER BY
        (SELECT score FROM hour_weight WHERE hour_et = x.hour_et) DESC, -- better hours first
        COALESCE(x.sla_priority, 999),
        x.created_at,
        x.account_id
    ) AS rn
  FROM (SELECT * FROM sticky UNION ALL SELECT * FROM released) x;

  -- Take quotas in order: STICKY-OLD, STICKY-NEW, RELEASED-OLD, RELEASED-NEW
  CREATE TEMP TABLE picked AS
  WITH want AS (
    SELECT r.*, q.old_quota_h, q.new_quota_h
    FROM ranked r JOIN quotas q USING (hour_et)
  ),
  s_old AS (SELECT * FROM want WHERE is_sticky AND is_old  AND rn <= old_quota_h),
  s_new AS (SELECT * FROM want WHERE is_sticky AND NOT is_old AND rn <= new_quota_h),
  rel_old AS (
    SELECT w.*
    FROM want w
    JOIN (SELECT hour_et, old_quota_h - COUNT(*) AS rem FROM s_old GROUP BY hour_et, old_quota_h) rem USING (hour_et)
    WHERE NOT w.is_sticky AND w.is_old AND w.rn <= GREATEST(rem,0)
  ),
  rel_new AS (
    SELECT w.*
    FROM want w
    JOIN (SELECT hour_et, new_quota_h - COUNT(*) AS rem FROM s_new GROUP BY hour_et, new_quota_h) rem USING (hour_et)
    WHERE NOT w.is_sticky AND NOT w.is_old AND w.rn <= GREATEST(rem,0)
  )
  SELECT * FROM s_old
  UNION ALL SELECT * FROM s_new
  UNION ALL SELECT * FROM rel_old
  UNION ALL SELECT * FROM rel_new;

  -- Build assignment targets: sticky -> prior employee, else round-robin
  CREATE TEMP TABLE assigned AS
  WITH pool AS (
    SELECT
      p.*,
      ROW_NUMBER() OVER (
        PARTITION BY p.hour_et, p.required_flag, p.is_sticky
        ORDER BY p.is_old DESC, COALESCE(p.sla_priority,999), p.created_at, p.account_id
      ) - 1 AS slot
    FROM picked p
  ),
  rr AS (
    SELECT pool.*, e.elig_agents, ARRAY_LENGTH(e.elig_agents) AS k
    FROM pool
    JOIN elig_by_flag e
      ON e.hour_et = pool.hour_et AND e.flag_code = pool.required_flag
  )
  SELECT
    run_id AS run_id,
    pool.hour_et AS assigned_for_hour_ts,
    IF(pool.is_sticky,
       pool.last_assigned_employee_id,
       rr.elig_agents[OFFSET(MOD(pool.slot + rotation_seed, rr.k))]
    ) AS employee_id,
    pool.account_id,
    pool.is_old AS is_old_backlog,
    pool.state_code,
    CASE
      WHEN pool.is_sticky THEN 'STICKY'
      WHEN pool.last_assigned_employee_id IS NULL THEN 'NEW'
      ELSE 'RELEASED_EMPLOYEE_OFF'
    END AS assignment_reason,
    pool.last_assigned_employee_id AS prior_employee_id,
    IF(pool.is_sticky AND DATE(pool.last_assigned_at, 'America/New_York') < DATE(pool.hour_et, 'America/New_York'),
       DATE(pool.last_assigned_at, 'America/New_York'),
       NULL) AS carried_from_date
  FROM pool JOIN rr USING (hour_et, account_id, required_flag, is_sticky);

  -- Numbering per account (assignment_seq) and write history
  CREATE TEMP TABLE numbered AS
  SELECT a.*,
         1 + COALESCE((SELECT MAX(assignment_seq) FROM `ops.assignments` WHERE account_id = a.account_id),0) AS assignment_seq
  FROM assigned a;

  INSERT INTO `ops.assignments`
  SELECT run_id, assigned_for_hour_ts, employee_id, account_id, is_old_backlog, state_code,
         assignment_seq, assignment_reason, prior_employee_id, carried_from_date
  FROM numbered;

  -- Update active accounts (sticky count, last assigned, status)
  UPDATE `ops.accounts` acc
  SET acc.last_assigned_employee_id = n.employee_id,
      acc.last_assigned_at = run_ts_et,
      acc.assign_count = COALESCE(acc.assign_count,0) + 1,
      acc.status = 'assigned'
  FROM numbered n
  WHERE acc.account_id = n.account_id;

END;
