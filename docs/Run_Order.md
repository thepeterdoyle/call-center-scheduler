
# Query List — run in this order

### Dataset Creation [sql/ddl]
1. **`000_create_datasets.sql`**
   Creates the base datasets (`ref`, `ops`, `rpt`) that all subsequent objects live in.

---

### Reference (config/lookup) tables [sql/ddl/ref]


2. **`010_ref_call_window_config.sql`**
   Defines allowed call windows (e.g., earliest and latest call times).
3. **`011_ref_system_config.sql`**
   Stores system-level parameters and feature toggles for the scheduler.
4. **`012_ref_us_state_timezones.sql`**
   Maps U.S. states to their representative time zones.
5. **`013_ref_us_state_time_profile.sql`**
   Defines per-state calling profiles (morning vs evening window preferences).
6. **`014_ref_us_tz_dst_calendar.sql`**
   Calendar of daylight savings time offsets by state and date.
7. **`015_ref_cooldown_config.sql`**
   Configures retry cooldowns (how long to wait before re-calling an account).
8. **`016_ref_split_tuning.sql`**
   Defines the old-vs-new account call split (e.g., 4 old vs 3 new per hour).
9. **`017_ref_us_state_holidays.sql`**
   Lists state-specific holidays to avoid calling on.
10. **`018_ref_what_if_params.sql`**
    Holds scenario parameters for backlog/throughput what-if analysis.

---

### Operational (fact) tables [sql/ddl/ops]

11. **`020_ops_employees.sql`**
    Stores call center employee records (who they are, active status).
12. **`021_ops_employee_flags.sql`**
    Tracks employee eligibility flags (premium, SLA, Spanish, etc.).
13. **`022_ops_shifts.sql`**
    Holds employee work schedules (shift start/end times by day).
14. **`023_ops_accounts.sql`**
    The master backlog of accounts that need to be called.
15. **`024_ops_assignments.sql`**
    Assignments table mapping accounts → employees → hours.
16. **`025_ops_call_attempts.sql`**
    Tracks every call attempt (who called, when, and result).
17. **`026_ops_run_log.sql`**
    Logs each run of the assignment procedure (when, how many calls assigned).

### Insert Data into Operational tables [sql/seeds]

- **`seed_ops_employees.sql`**
   populates table ops.employees 
- **`seed_ops_shifts.sql`**
   populates table ops.shifts 
- **`seed_ops_accounts.sql'**
   populates table ops.accounts

---

### UDFs (helpers) [sql/ddl/udfs]

18. **`100_util_representative_tz.sql`**
    Function that picks a representative time zone for a state (east vs west).
19. **`101_util_is_et_daylight.sql`**
    Function that checks if Eastern Time is in daylight savings on a date.

---

### Stored procedure (orchestration) [sql/procedures]

20. **`200_ops_run_call_assignment_v2.sql`**
    Core procedure: looks at accounts, employees, configs, and time zones to generate daily call assignments and log the run.

---

### Views (reporting) [sql/views]

21. **`300_ref_us_state_offset_vs_et_today.sql`**
    Shows today’s offset between each state’s time zone and Eastern Time.

### Views (reporting) [sql/views/rpt]
23. **`310_rpt_agent_schedule_daily.sql`**
    Daily per-agent schedule report (who’s assigned what).
24. **`311_rpt_agent_schedule_pending_today.sql`**
    Shows each agent’s pending (not yet completed) calls for today.
25. **`320_rpt_daily_funnel.sql`**
    Funnel report: assignments → attempts → completions.
26. **`321_rpt_rolling_capacity.sql`**
    Rolling view of staffing capacity vs calls assigned.
27. **`322_rpt_backlog_today.sql`**
    Snapshot of today’s remaining backlog.
28. **`323_rpt_backlog_composition.sql`**
    Breaks down backlog by state, priority, and account type.
29. **`324_rpt_account_last_outcome.sql`**
    Shows the last call outcome for each account.
30. **`325_rpt_hour_perf.sql`**
    Hourly performance metrics across employees and shifts.
31. **`326_rpt_backlog_projection.sql`**
    Projects how long until backlog is cleared at current pace.
32. **`327_rpt_employee_daily.sql`**
    Daily employee performance summary.
33. **`328_rpt_employee_adherence.sql`**
    Measures adherence (calls made vs calls scheduled).
34. **`329_rpt_backlog_age_hist.sql`**
    Histogram of backlog account ages (how long accounts have waited).

---

### Transforms / population jobs [sql/transforms]

34. **`400_build_us_state_time_profile.sql`**
    Builds the derived state-time profiles from configs and DST rules.
35. **`401_populate_us_tz_dst_calendar.sql`**
    Populates the daylight savings calendar with correct offsets.

---

### Deploy / scheduled helpers [sql/deploy]

36. **`500_seed_minimal_config.sql`**
    Inserts baseline config so the system can run out of the box.
37. **`510_scheduled_morning_run.sql`**
    Defines a scheduled job for morning assignments.
38. **`511_scheduled_afternoon_run.sql`**
    Defines a scheduled job for afternoon assignments.
39. **`520_optional_per_agent_exports.sql`**
    Optional export job: produces per-agent call files/reports.


