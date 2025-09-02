# Call Center Scheduler (BigQuery)

End-to-end, DST-aware, state-timezone scheduling + backlog burn analytics for national call centers.

## Highlights
- Twice-daily planning (morning/evening) with **state-level local time** windows.
- Sticky reassignment, skill/flag eligibility, fair round-robin.
- **Dynamic old/new split**, **cooldowns**, **hour weighting** by completion rate.
- Assignment history, completion audit, backlog ETA & what-if (+5 calls/agent/day).
- Agent schedule report (hour labels) + manager KPIs (Looker/Tableau-ready).

## How to deploy
1. Run `sql/ddl/000_create_datasets.sql`.
2. Run all `sql/ddl/ref/*.sql` then `sql/ddl/ops/*.sql`.
3. Load `ref.us_state_timezones`.
4. Run `sql/transforms/400_build_us_state_time_profile.sql`.
5. Run `sql/transforms/401_populate_us_tz_dst_calendar.sql`.
6. Seed config: `sql/deploy/500_seed_minimal_config.sql`.
7. Create UDFs (`sql/udfs/*.sql`), Procedure (`sql/procedures/200_ops_run_call_assignment_v2.sql`).
8. Create views (`sql/views/**/*.sql`).
9. Schedule runs (`sql/deploy/510_*.sql`, `511_*.sql`).

## Testing
- Manually call the procedure with a fixed ET timestamp.
- Check `rpt.agent_schedule_daily` output.
- Validate capacity per hour and cooldown filtering.

## BI
- Point Looker/Tableau at `rpt.*` views for dashboards.
