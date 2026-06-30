# Skill 06: Sample Data Preparation (Round 3 Snapshot)

*This snapshot reflects updates after the Round 2 evaluation. It matches the final, fully evolved state of `skill_06_SampleData.md`.*

# Purpose
Insert realistic sample data to support testing of normal operations and important exceptional cases. Produces a single idempotent `.sql` file.

# Methodology
1. **Strict Dependency:** Reverse `DELETE`, forward `INSERT`.
2. **Lifecycle Validity (CRITICAL):**
   - A `No-Show` booking can ONLY occur if there is a corresponding `BOOKING_APPROVAL` with an 'Approved' decision.
   - A `Completed` booking MUST have an approval record AND a complete `USAGE_SESSION`.
3. **Account Status Logic:** If a suspended user is booking a space, explicitly document that it tests application-layer enforcement (the DB layer allows it).
4. **Concrete Dates:** Use recent past month dates to support Query 5.
5. **Facility Coverage:** Include facilities for closed/retired spaces.

# Verification Checklist
* [ ] All 7 booking statuses are represented: PASS/FAIL
* [ ] All 6 user roles are represented: PASS/FAIL
* [ ] All 5 space statuses are represented: PASS/FAIL
* [ ] BK_NoShow has a prior Approved BOOKING_APPROVAL: PASS/FAIL
* [ ] All Completed bookings have a matching USAGE_SESSION: PASS/FAIL
* [ ] Checked In bookings have actual_end_time IS NULL: PASS/FAIL
* [ ] Rejected booking has a non-empty rejection_reason: PASS/FAIL
* [ ] DELETE statements are in strict reverse FK order: PASS/FAIL
* [ ] INSERT statements are in strict FK dependency order: PASS/FAIL
