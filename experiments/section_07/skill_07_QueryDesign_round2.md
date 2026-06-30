# Skill 07: Query Design (Round 2 Snapshot)

*This snapshot reflects updates after the Round 1 evaluation, adding T-SQL strictness and division-by-zero handling.*

# Purpose
Design and execute 24 meaningful SQL queries for the Campus Space Booking system.

# Methodology
1. **Query Requirements:** Generate 24 queries across 8 categories.
2. **T-SQL Compliance:** MUST use T-SQL. Do not use PostgreSQL/MySQL `LIMIT`. Use `TOP X WITH TIES`.
3. **Division-by-Zero:** MUST use `NULLIF(denominator, 0)` for any division operations.

# Checklist
- [ ] Exactly 24 SQL queries are provided.
- [ ] Each query includes Business Question, Target User(s), Explanation, and SQL.
- [ ] No `LIMIT` syntax used.
- [ ] `SPACE.current_status` used (not `status`).
- [ ] `NULLIF` used for division.
