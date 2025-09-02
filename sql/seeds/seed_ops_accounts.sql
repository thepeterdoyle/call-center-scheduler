
-- Reseed (optional)
-- DELETE FROM `ops.accounts` WHERE TRUE;

DECLARE total_accounts INT64 DEFAULT 20000;
DECLARE days_back INT64 DEFAULT 10;

WITH states AS (
  SELECT * FROM UNNEST([
    'AL','AK','AZ','AR','CA','CO','CT','DC','DE','FL','GA','HI','IA','ID','IL','IN','KS','KY','LA','MA',
    'MD','ME','MI','MN','MO','MS','MT','NC','ND','NE','NH','NJ','NM','NV','NY','OH','OK','OR','PA','RI',
    'SC','SD','TN','TX','UT','VA','VT','WA','WI','WV','WY'
  ]) AS state_code
),
id_seq AS (
  SELECT GENERATE_ARRAY(1, total_accounts) AS ids
),
base AS (
  SELECT
    FORMAT('ACC%06d', id) AS account_id,
    (SELECT state_code FROM states OFFSET(ABS(MOD(id * 131 + 17, 51)))) AS state_code,

    -- spread created_at over last N days (skew newer via simple mod)
    TIMESTAMP_SUB(TIMESTAMP(CURRENT_DATETIME('America/New_York')),
                  INTERVAL CAST(ABS(MOD(id * 37, days_back)) AS INT64) DAY) AS created_at,

    -- weighted SLA: more 2s, some 1s, some 3s
    CASE WHEN MOD(id, 10) IN (0,1) THEN 1
         WHEN MOD(id, 10) IN (2,3,4,5,6) THEN 2
         ELSE 3 END AS sla_priority,

    -- required_flag with HIGH % unflagged (~80% NULL), deterministic by fingerprint
    -- 0–79   → NULL (unflagged)
    -- 80–87  → 'premium'     (~8%)
    -- 88–93  → 'sla_special' (~6%)
    -- 94–99  → 'spanish'     (~6%)
    CASE
      WHEN MOD(ABS(FARM_FINGERPRINT(FORMAT('ACC%06d', id))), 100) < 80 THEN NULL
      WHEN MOD(ABS(FARM_FINGERPRINT(FORMAT('ACC%06d', id))), 100) < 88 THEN 'premium'
      WHEN MOD(ABS(FARM_FINGERPRINT(FORMAT('ACC%06d', id))), 100) < 94 THEN 'sla_special'
      ELSE 'spanish'
    END AS required_flag,

    -- status mix: ~70% new, 20% assigned, 10% attempted
    CASE
      WHEN MOD(id, 10) IN (0,1) THEN 'attempted'
      WHEN MOD(id, 10) IN (2,3) THEN 'assigned'
      ELSE 'new'
    END AS status
  FROM id_seq, UNNEST(ids) AS id
)
INSERT INTO `ops.accounts` (account_id, state_code, created_at, sla_priority, required_flag, status)
SELECT account_id, state_code, created_at, sla_priority, required_flag, status
FROM base;
