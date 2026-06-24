# Improve - Section 06: Sample Data Preparation

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 10/10 | None        | None          | None          |

---

## Round 1

### Evaluation

Score: 10/10

Strengths

- Sample data is extensive, varied, and strictly complies with the DDL constraints of `05-db-definition-G08.sql`.
- Covers all edge cases dictated by the business requirements, including all `USER.role`, `SPACE.current_status`, `BOOKING_REQUEST.status`, and `MAINTENANCE_RECORD.status` cases.
- Properly handles logical life-cycle dependencies (e.g., No-Show and Completed bookings have their requisite Approved records).
- Accurately adjusts for strict NOT NULL constraints in the actual DDL that conflicted with legacy guidance (such as ensuring an assignee is always mapped to maintenance records).

Issues

- None found. 

### Verification Checklist
* [x] All 7 booking statuses are represented: PASS - (pending, approved, rejected, cancelled, checked_in, completed, no_show all present)
* [x] All 6 user roles are represented: PASS - (student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager all present)
* [x] All 5 space statuses are represented: PASS - (available, in_use, under_maintenance, temporarily_closed, retired all present)
* [x] BK_NoShow has a prior Approved BOOKING_APPROVAL: PASS - (BK08 is 'no_show' and has AP08 indicating an 'Approved' state)
* [x] All Completed bookings have a matching USAGE_SESSION: PASS - (BK01 and BK02 are 'completed' and have US01 and US02)
* [x] Checked In bookings have actual_end_time IS NULL: PASS - (US03 for BK03 has NULL actual_end_time and NULL completed_by_user_id)
* [x] Rejected booking has a non-empty rejection_reason: PASS - (AP06 for BK06 has a realistic rejection_reason)
* [x] DELETE statements are in strict reverse FK order: PASS - (USAGE_SESSION -> BOOKING_APPROVAL -> BOOKING_REQUEST -> MAINTENANCE_RECORD -> FACILITY -> SPACES -> USERS)
* [x] INSERT statements are in strict FK dependency order: PASS - (USERS -> SPACES -> FACILITY -> BOOKING_REQUEST -> BOOKING_APPROVAL -> USAGE_SESSION -> MAINTENANCE_RECORD)

### Improvements

Agent Updates

- None

Skill Updates

- None

---

## Overall Summary

Initial weaknesses

- None

Major improvements

- None

Final observations

- Data generated passes all checks and respects SQL Server DDL constraints exactly.

Final score: 10/10
