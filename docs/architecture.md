# Architecture

- **ref.***: Config & reference (time windows, state tz, DST calendar, cooldowns, old/new split bounds, what-if params, holidays).
- **ops.***: Operational facts (employees, flags, shifts, accounts, assignments, attempts, run log).
- **util.***: UDFs (representative_tz, optional is_et_daylight).
- **rpt.***: Reporting views (agent schedule, funnels, backlog, projections, adherence, age).

**Planner**: `ops.run_call_assignment_v2` builds hour buckets in ET, selects callable states using `DATETIME(hour_et, representative_tz)` (DST aware), computes capacity & dynamic quotas, honors sticky carryover, respects cooldowns, weights by hour performance, and assigns (sticky → same employee; else round-robin by flag).
