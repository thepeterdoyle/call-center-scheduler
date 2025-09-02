-- MIGRATION 008: Seed defaults
INSERT INTO `ref.call_window_config`(effective_date, local_start_time, local_end_time)
VALUES (CURRENT_DATE(), TIME '08:00:00', TIME '17:00:00');
INSERT INTO `ref.system_config`(config_date, calls_per_agent_per_hour, morning_run_hour_et, afternoon_run_hour_et)
VALUES (CURRENT_DATE(), 7, TIME '08:00:00', TIME '13:00:00');
INSERT OR REPLACE INTO `ref.cooldown_config` VALUES
  ('no_answer', 24), ('busy', 4), ('left_voicemail', 48), ('reschedule', 72);
INSERT INTO `ref.split_tuning`(min_old_share, max_old_share) VALUES (0.30, 0.80);
