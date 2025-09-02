-- ref.cooldown_config
CREATE OR REPLACE TABLE `ref.cooldown_config` (
  outcome STRING OPTIONS(description="Last call outcome category (e.g., no_answer, busy, left_voicemail, reschedule)."),
  cooldown_hours INT64 OPTIONS(description="Number of hours to wait before the account becomes eligible again.")
)
OPTIONS(description="Outcome-based cooldown policy to prevent rapid, low-yield retries.");
