# Improve - Section 06: Sample Data Preparation

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 10/10 | None        | Careful trigger-aware data design | None |

---

## Round 1

### Evaluation

Score: 10/10

Strengths

- All 7 booking statuses covered: Pending, Approved, Rejected, Cancelled, Checked In, Completed, No-Show.
- All 6 user roles represented with at least one user per role, plus a Suspended account edge case (user 7).
- All 6 space types covered: Classroom, Computer Lab, Meeting Room, Auditorium, Project Lab, Student Workspace.
- All 5 space statuses represented: Available, In Use, Under Maintenance, Temporarily Closed, Retired.
- All 4 maintenance statuses covered: Open, In Progress, Resolved, Closed.
- No-Show booking (BK08) has a prior Approved BOOKING_APPROVAL record (approval_id=6) — lifecycle is valid.
- Completed bookings (BK01, BK02) both have BOOKING_APPROVAL and USAGE_SESSION records — full lifecycle chain.
- Checked In booking (BK03) has actual_end_time=NULL, completed_by_user_id=NULL, final_condition=NULL — correctly models in-progress state.
- Rejected booking (BK06) has a meaningful, multi-sentence rejection_reason explaining the policy violation.
- Maintenance record M03 has assigned_staff_user_id=NULL — covers the unassigned edge case.
- Facilities included for unavailable spaces SP05 and SP06 (Common Mistake #6 avoided).
- Completed booking dates (May 2026) fall in the previous calendar month relative to current date (June 2026) — Query 5 will return rows (Common Mistake #4 avoided).
- No bookings placed by the suspended user (Common Mistake #7 avoided).
- All bookings target Available/In Use spaces only — avoids trigger conflicts with trg_CheckSpaceAvailability.
- No overlapping time slots for active bookings on the same space — avoids trigger conflicts with trg_PreventOverlappingBooking.
- DELETE statements in strict reverse FK order; INSERT statements in strict FK dependency order.
- All status values use exact title-case strings matching the DDL CHECK constraints — no casing drift.
- Concrete date values used throughout (no GETDATE()) for stable test results.
- All NOT NULL columns have explicit values — no reliance on DEFAULTs in sample data.

Issues

- None identified.

### Verification Checklist
* [x] All 7 booking statuses are represented: PASS - Pending(BK05), Approved(BK04), Rejected(BK06), Cancelled(BK07), Checked In(BK03), Completed(BK01, BK02), No-Show(BK08).
* [x] All 6 user roles are represented: PASS - Student(U01, U07), Lecturer(U02), Teaching Assistant(U03), Facility Staff(U04), Facility Manager(U05), Department Administrator(U06).
* [x] All 5 space statuses are represented: PASS - Available(SP01, SP02, SP03), In Use(SP04), Under Maintenance(SP05), Temporarily Closed(SP06), Retired(SP07).
* [x] BK_NoShow has a prior Approved BOOKING_APPROVAL: PASS - BK08 (No-Show) has approval_id=6 with decided_by_user_id=4 and rejection_reason=NULL (approved, not rejected).
* [x] All Completed bookings have a matching USAGE_SESSION: PASS - BK01→session_id=1 (full check-in/out), BK02→session_id=2 (full check-in/out).
* [x] Checked In bookings have actual_end_time IS NULL: PASS - BK03→session_id=3 has actual_end_time=NULL, completed_by_user_id=NULL, final_condition=NULL.
* [x] Rejected booking has a non-empty rejection_reason: PASS - BK06 rejection_reason explains auditorium usage policy restriction in detail.
* [x] DELETE statements are in strict reverse FK order: PASS - USAGE_SESSION → BOOKING_APPROVAL → BOOKING_REQUEST → MAINTENANCE_RECORD → FACILITY → SPACE → USER.
* [x] INSERT statements are in strict FK dependency order: PASS - USER → SPACE → FACILITY → BOOKING_REQUEST → BOOKING_APPROVAL → USAGE_SESSION → MAINTENANCE_RECORD.

### Improvements

Agent Updates

- Verification behavior: Explicitly traced each INSERT through the active triggers to confirm no trigger conflicts would occur at runtime.
- Requirement traceability: Used the coverage matrix from the skill spec to map every row to a specific test scenario.

Skill Updates

- None required.

---

## Overall Summary

Initial weaknesses

- None — Round 1 achieved 10/10.

Major improvements

- N/A — no iterations needed.

Final observations

- The sample data comprehensively covers all entity values, lifecycle states, and exceptional scenarios mandated by the business rules.
- Trigger-aware data design ensures the script runs cleanly against the active DDL from Section 05 without any rollbacks.
- Date placement in May 2026 for historical records ensures Query 5 (monthly utilization) returns meaningful results.

Final score: 10/10
