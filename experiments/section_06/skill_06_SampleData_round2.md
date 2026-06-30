# Skill 06: Sample Data Preparation (Round 2 Snapshot)

*This snapshot reflects updates after the Round 1 evaluation, explicitly addressing date staleness and facility coverage.*

# Purpose
Insert realistic sample data to support testing of normal operations and important exceptional cases. Produces a single idempotent `.sql` file.

# Methodology
1. **Dependency Order:** Strict reverse `DELETE` order, forward `INSERT` order.
2. **Date Stability (NEW):** Use concrete dates in the most recent past month. Do not use dates from years ago, as it will break monthly reporting queries (like Query 5).
3. **Facility Coverage (NEW):** Even spaces that are 'Under Maintenance', 'Temporarily Closed', or 'Retired' must have `FACILITY` records. A closed room does not lose its physical assets.
4. **Idempotency:** Always begin with DELETE statements.
5. **Explicit values:** Provide explicit strings for rejection notes (e.g. 'Projector broken', not just 'Rejected').

# Verification Checklist
* [ ] All 7 booking statuses are represented: PASS/FAIL
* [ ] All 6 user roles are represented: PASS/FAIL
* [ ] All Completed bookings have a matching USAGE_SESSION: PASS/FAIL
* [ ] Checked In bookings have actual_end_time IS NULL: PASS/FAIL
* [ ] Rejected booking has a non-empty rejection_reason: PASS/FAIL
* [ ] DELETE statements are in strict reverse FK order: PASS/FAIL
