# Skill 07: Query Design (Round 3 Snapshot)

*This snapshot reflects updates after the Round 2 evaluation, adding Checklist Integrity and LEFT JOIN mandates.*

# Purpose
Design and execute 24 meaningful SQL queries for the Campus Space Booking system.

# Methodology
1. **Checklist Integrity Rule:** Fixing one bug must not silently delete another required checklist pattern (e.g. dropping `TOP X` while fixing a `LEFT JOIN`).
2. **Zero-State Entities:** Use `LEFT JOIN` instead of `INNER JOIN` when counting things (like bookings per user) so users with 0 bookings aren't dropped.
3. **T-SQL Compliance:** Use `TOP X WITH TIES` and `NULLIF`.
4. **Temporal Anchoring:** Require the use of explicit `DECLARE @ReportDate` or data-anchored timestamps when querying static sample sets to ensure reproducibility.

# Checklist
- [ ] Exactly 24 SQL queries are provided.
- [ ] Each query includes Business Question, Target User(s), Explanation, and SQL.
- [ ] `TOP X WITH TIES` is present.
- [ ] `LEFT JOIN` used for aggregations requiring zero-states.
- [ ] `@ReportDate` static anchors utilized.
