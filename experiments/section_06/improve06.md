# Improve - Section 06: Sample Data Preparation

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 10/10 | None | None needed | None needed |

---

## Round 1

### Evaluation

Score: 10/10

#### 1. Data Coverage (2.0/2.0)

All 7 tables populated with sample data:
- USER: 7 records (all 6 roles + 1 suspended account)
- SPACE: 8 records (all 6 space types + all 5 statuses)
- FACILITY: 10 records (projectors, computers, whiteboards, video conferencing, microphones, livestreaming, air conditioning — including facilities for unavailable spaces)
- BOOKING_REQUEST: 8 records (all 7 booking statuses)
- BOOKING_APPROVAL: 6 records (5 Approved + 1 Rejected)
- USAGE_SESSION: 3 records (2 Completed + 1 Checked In)
- MAINTENANCE_RECORD: 4 records (all 4 statuses: Open, In Progress, Resolved, Closed)

#### 2. Referential Integrity (2.0/2.0)

- All FK references verified: every user_id, space_code, booking_id in child tables references an existing parent record.
- INSERT order follows FK dependency: USER, SPACE → FACILITY → BOOKING_REQUEST → BOOKING_APPROVAL → USAGE_SESSION → MAINTENANCE_RECORD.
- DELETE cleanup in reverse FK order.
- No orphaned or dangling references.

#### 3. Realism and Business Consistency (2.0/2.0)

- Users: Thai names, realistic university email format, appropriate departments (CS, Facility Management).
- Spaces: Realistic building names (Engineering Building A/B, Central Building, Library Building), sensible room numbers, appropriate capacities (12–500).
- Bookings: Realistic purposes (CS101 lectures, TA training workshops, department seminars, student club activities), reasonable participant counts, logical time slots.
- Maintenance: Real-world problems (faulty outlets, projector overheating, broken furniture, scratched whiteboard).
- Dates: Historical bookings in May–June 2025, future bookings in July 2025.

#### 4. Normal Operations Coverage (2.0/2.0)

- Multiple user roles making bookings (Student, Lecturer, TA, Department Administrator).
- Multiple spaces booked across different types.
- Facilities assigned to spaces including unavailable ones.
- Full booking lifecycle demonstrated: Pending → Approved → Checked In → Completed.
- Approval workflow: Facility Staff and Facility Manager both act as approvers.
- Usage sessions with check-in and check-out.
- Maintenance with assignment and resolution.

#### 5. Important Exceptional Cases Coverage (2.0/2.0)

- ✅ Pending booking (BK05) — no approval, no session
- ✅ Approved booking (BK04) — has approval, no session yet
- ✅ Rejected booking (BK06) — has meaningful rejection reason
- ✅ Cancelled booking (BK07) — no approval, no session
- ✅ No-Show booking (BK08) — has prior Approved approval record
- ✅ Checked In booking (BK03) — actual_end_time IS NULL, completed_by IS NULL
- ✅ Space Under Maintenance (SP05)
- ✅ Space Temporarily Closed (SP06)
- ✅ Space Retired (SP07)
- ✅ Space In Use (SP08)
- ✅ Unassigned maintenance (M03) — assigned_staff_user_id = NULL
- ✅ Suspended user account (U07) — no bookings (avoids confusion)
- ✅ Facilities on unavailable spaces (SP05 has 2 facilities)

Strengths

- Complete coverage of all status values across all tables
- Proper booking lifecycle consistency (every Completed/Checked In/No-Show booking has approval)
- Checked In session correctly has NULL end time and NULL completed_by
- Realistic, meaningful rejection reason (not placeholder text)
- Facilities included for unavailable spaces per common mistake #6
- All 4 maintenance statuses represented
- Idempotent with DELETE cleanup + IDENTITY reseed
- Self-documenting with inline comments explaining each row's purpose

Issues

- None identified

### Verification Checklist

* [x] All 7 booking statuses are represented: PASS - Pending(BK05), Approved(BK04), Rejected(BK06), Cancelled(BK07), Checked In(BK03), Completed(BK01,BK02), No-Show(BK08)
* [x] All 6 user roles are represented: PASS - Student(U01,U07), Lecturer(U02), Teaching Assistant(U03), Facility Staff(U04), Facility Manager(U05), Department Administrator(U06)
* [x] All 5 space statuses are represented: PASS - Available(SP01-SP04), In Use(SP08), Under Maintenance(SP05), Temporarily Closed(SP06), Retired(SP07)
* [x] BK_NoShow has a prior Approved BOOKING_APPROVAL: PASS - BK08 (No-Show) has approval_id=6 with decided_by=U05
* [x] All Completed bookings have a matching USAGE_SESSION: PASS - BK01→session_id=1, BK02→session_id=2 (both fully populated)
* [x] Checked In bookings have actual_end_time IS NULL: PASS - BK03→session_id=3 has actual_end_time=NULL, completed_by_user_id=NULL, final_condition=NULL
* [x] Rejected booking has a non-empty rejection_reason: PASS - BK06 has rejection_reason='The meeting room is reserved for faculty use on Thursday mornings. Student activities should use the Student Workspace instead.'
* [x] DELETE statements are in strict reverse FK order: PASS - USAGE_SESSION, BOOKING_APPROVAL, BOOKING_REQUEST, MAINTENANCE_RECORD, FACILITY, SPACE, USER
* [x] INSERT statements are in strict FK dependency order: PASS - USER, SPACE, FACILITY, BOOKING_REQUEST, BOOKING_APPROVAL, USAGE_SESSION, MAINTENANCE_RECORD

### Improvements

Agent Updates

- None needed — all evaluation rubric items and verification checklist items satisfied.

Skill Updates

- None needed.

---

## Overall Summary

Initial weaknesses

- None significant — this is Round 1.

Major improvements

- N/A (first round).

Final observations

- The sample data comprehensively covers all normal operations and exceptional cases. All 7 booking statuses, all 6 user roles, all 5 space statuses, and all 4 maintenance statuses are represented. Referential integrity is maintained throughout, and the booking lifecycle is fully consistent (No-Show and Completed bookings have approval records; Checked In sessions have NULL end times).

Final score: 10/10
