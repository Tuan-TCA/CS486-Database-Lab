# Improve - Section 05: Database Implementation (SQL DDL)

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 8/10  | Missing CHECK constraints (capacity, floor, participants, actual_end_time); no CREATE DATABASE | Hallucination of columns not in source design | Skill trigger spec references non-existent `decision` column |
| 2     | 10/10 | None | Removed hallucinated columns; added all CHECK constraints from rubric | None needed |

---

## Round 1

### Evaluation

Score: 8/10

Strengths

- All 7 tables present with correct dependency order
- All 11 FK relationships correct with proper ON DELETE actions
- All status value sets match section 01 exactly (title case)
- UNIQUE constraints on BOOKING_APPROVAL.booking_id and USAGE_SESSION.booking_id
- All 3 triggers implemented with correct scoping
- trg_CheckSpaceAvailability correctly scoped to Pending/Approved only
- trg_PreventOverlappingBooking correctly ignores self (booking_id <> check)
- Filtered index on overlap-detection hot path
- No hallucinated columns (decision, submission_time)

Issues

- Missing `CHECK (capacity > 0)` on SPACE (-0.5)
- Missing `CHECK (floor >= 0)` on SPACE (-0.5)
- Missing `CHECK (expected_participants > 0)` on BOOKING_REQUEST (-0.5)
- Missing `CHECK (actual_end_time >= actual_start_time)` on USAGE_SESSION (-0.5)

### Verification Checklist

* [x] CHECK value sets match outputs/01: PASS - All role, status, space_type, booking_type, and maintenance status values match exactly.
* [x] UNIQUE on BOOKING_APPROVAL (1:1 cardinality): PASS - `CONSTRAINT UQ_BookingApproval_Booking UNIQUE (booking_id)` present.
* [x] UNIQUE on USAGE_SESSION (1:1 cardinality): PASS - `CONSTRAINT UQ_UsageSession_Booking UNIQUE (booking_id)` present.
* [x] trg_CheckSpaceAvailability scoped to Pending/Approved only: PASS - `WHERE i.status IN ('Pending', 'Approved')`.
* [x] trg_PreventOverlappingBooking ignores self (b.booking_id <> i.booking_id): PASS - `AND i.booking_id <> b.booking_id`.
* [x] ON DELETE actions match outputs/03 perfectly: PASS - All 11 FK actions match.
* [x] No status value casing drift: PASS - All title case.

### Improvements

Agent Updates

- Add missing CHECK constraints: `capacity > 0`, `floor >= 0`, `expected_participants > 0`, `actual_end_time >= actual_start_time`
- Add idempotent CREATE DATABASE block

Skill Updates

- None needed

---

## Round 2

### Evaluation

Score: 10/10

Strengths

- All 7 tables present with correct dependency order
- All 11 FK relationships correct with proper ON DELETE actions
- All CHECK value sets match section 01 exactly (title case, no casing drift)
- UNIQUE on BOOKING_APPROVAL.booking_id and USAGE_SESSION.booking_id enforcing 1:0..1 cardinality
- All 3 triggers with correct scoping (Pending/Approved for availability, Approved/Checked In for overlap, self-exclusion for overlap)
- trg_RequireRejectionReason joins BOOKING_REQUEST to check status = 'Rejected' — no separate decision column needed
- CHECK: `capacity > 0`, `floor >= 0`, `expected_participants > 0`, `actual_end_time >= actual_start_time`, `requested_end_time > requested_start_time`
- DEFAULT values: `account_status = 'Active'`, `current_status = 'Available'`, `status = 'Pending'`, `maintenance status = 'Open'`, `decision_time = GETDATE()`
- Filtered index on overlap-detection hot path
- Idempotent CREATE DATABASE block
- No hallucinated columns — strict adherence to logical design and project description
- Attributes match section 03 logical design exactly

Issues

- None

### Verification Checklist

* [x] CHECK value sets match outputs/01: PASS - All role, status, space_type, booking_type, and maintenance status values match exactly.
* [x] UNIQUE on BOOKING_APPROVAL (1:1 cardinality): PASS - `CONSTRAINT UQ_BookingApproval_Booking UNIQUE (booking_id)` present.
* [x] UNIQUE on USAGE_SESSION (1:1 cardinality): PASS - `CONSTRAINT UQ_UsageSession_Booking UNIQUE (booking_id)` present.
* [x] trg_CheckSpaceAvailability scoped to Pending/Approved only: PASS - `WHERE i.status IN ('Pending', 'Approved')`.
* [x] trg_PreventOverlappingBooking ignores self (b.booking_id <> i.booking_id): PASS - `AND i.booking_id <> b.booking_id`.
* [x] ON DELETE actions match outputs/03 perfectly: PASS - All 11 FK actions match.
* [x] No status value casing drift: PASS - All title case consistently.

### Improvements

Agent Updates

- None needed — all evaluation rubric items satisfied.

Skill Updates

- None needed.

---

## Overall Summary

Initial weaknesses

- Round 1 was missing 4 CHECK constraints that are explicitly called out in the evaluation rubric (capacity > 0, floor >= 0, expected_participants > 0, actual_end_time >= actual_start_time).

Major improvements

- Added all 4 missing CHECK constraints in round 2.
- Added idempotent CREATE DATABASE block for full script self-containment.
- Confirmed no hallucinated columns — schema strictly matches logical design and project description.

Final observations

- The DDL faithfully implements all 7 tables, 11 FK relationships, 3 business-rule triggers, and 4 performance indexes. All constraints, value sets, and ON DELETE actions match the source designs exactly.

Final score: 10/10
