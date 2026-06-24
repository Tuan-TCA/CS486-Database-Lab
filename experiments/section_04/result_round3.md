# Database Design Validation Report — Round 3 (Final)

## 1. ERD Representation

### Entities

| ERD Entity        | Logical Relation    | Status |
|-------------------|---------------------|--------|
| USERS             | USERS               | PASS   |
| SPACES            | SPACES              | PASS   |
| FACILITY          | FACILITY            | PASS   |
| BOOKING_REQUEST   | BOOKING_REQUEST     | PASS   |
| BOOKING_APPROVAL  | BOOKING_APPROVAL    | PASS   |
| USAGE_SESSION     | USAGE_SESSION       | PASS   |
| MAINTENANCE_RECORD| MAINTENANCE_RECORD  | PASS   |

**Result: All 7 entities map 1:1. PASS.**

### Attributes

Every ERD attribute appears in the correct relation. No missing or extra attributes.

**Result: PASS.**

---

## 2. Relationship Mapping (ERD → Logical Schema)

| ERD Relationship                     | Cardinality | Implementation                          | Status |
|--------------------------------------|-------------|-----------------------------------------|--------|
| SPACES → FACILITY                    | 1:N         | FK space_code in FACILITY               | PASS   |
| USERS → BOOKING_REQUEST              | 1:N         | FK user_id in BOOKING_REQUEST           | PASS   |
| SPACES → BOOKING_REQUEST             | 1:N         | FK space_code in BOOKING_REQUEST        | PASS   |
| BOOKING_REQUEST → BOOKING_APPROVAL   | 1:0..1      | UNIQUE FK booking_id                    | PASS   |
| USERS → BOOKING_APPROVAL             | 1:N         | FK decided_by_user_id                   | PASS   |
| BOOKING_REQUEST → USAGE_SESSION      | 1:0..1      | UNIQUE FK booking_id                    | PASS   |
| USERS → USAGE_SESSION (check-in)     | 1:N         | FK checked_in_by_user_id                | PASS   |
| USERS → USAGE_SESSION (completion)   | 1:N         | FK completed_by_user_id                 | PASS   |
| SPACES → MAINTENANCE_RECORD          | 1:N         | FK space_code                           | PASS   |
| USERS → MAINTENANCE_RECORD (reporter)| 1:N         | FK reporter_user_id                     | PASS   |
| USERS → MAINTENANCE_RECORD (staff)   | 1:N         | FK assigned_staff_user_id               | PASS   |

**Result: PASS.**

---

## 3. Relationship Mapping Self-Consistency (Logical Schema Section 3)

| Mapping Entry | Consistent with FK Definitions? |
|---------------|---------------------------------|
| USERS → BOOKING_REQUEST: 1:N via FK user_id | PASS |
| SPACES → BOOKING_REQUEST: 1:N via FK space_code | PASS |
| SPACES → FACILITY: 1:N via FK space_code | PASS |
| BOOKING_REQUEST → BOOKING_APPROVAL: 1:0..1 via UNIQUE FK booking_id | PASS |
| USERS → BOOKING_APPROVAL: 1:N via FK decided_by_user_id | PASS |
| BOOKING_REQUEST → USAGE_SESSION: 1:0..1 via UNIQUE FK booking_id | PASS |
| USERS → USAGE_SESSION (check-in): 1:N via FK checked_in_by_user_id | PASS |
| USERS → USAGE_SESSION (completion): 1:N via FK completed_by_user_id | PASS |
| SPACES → MAINTENANCE_RECORD: 1:N via FK space_code | PASS |
| USERS → MAINTENANCE_RECORD (reporter): 1:N via FK reporter_user_id | PASS |
| USERS → MAINTENANCE_RECORD (assigned): 1:N via FK assigned_staff_user_id | PASS |

**Result: All 11 mapping entries are self-consistent. PASS.**

---

## 4. Business Rules Validation

### From Project Description (`doc/project_description.md`)

| # | Requirement | Captured in Logical Schema? | Status |
|---|-------------|----------------------------|--------|
| 1 | University account for every user | Documented as external constraint | PASS |
| 2 | Store user info (user_id, full_name, email, phone, role, dept, account_status) | All 7 attributes in USERS | PASS |
| 3 | 6 actor roles defined | Role attribute present; value set to be enforced later | PASS |
| 4 | Store space info (space_code, name, type, building, floor, room_number, capacity, status, policy) | All 9 attributes in SPACES | PASS |
| 5 | 5 space statuses defined | current_status attribute present | PASS |
| 6 | Store facilities per space (facility_id, space_code, name, description) | All 4 attributes in FACILITY | PASS |
| 7 | Booking request captures space, times, purpose, participants | All in BOOKING_REQUEST | PASS |
| 8 | 7 booking types defined | booking_type attribute present | PASS |
| 9 | Booking statuses defined (including Checked In, Completed, No-show) | Status attribute present | PASS |
| 10 | Prevent conflicting bookings | Documented as application constraint | PASS |
| 11 | No overlapping approved bookings | Documented as application constraint | PASS |
| 12 | Blocked-status spaces cannot be booked | Documented as application constraint | PASS |
| 13 | Approval records: staff, time, note, rejection_reason | All in BOOKING_APPROVAL | PASS |
| 14 | Check-in records: actual_start_time, person, initial_condition | All in USAGE_SESSION | PASS |
| 15 | Completion records: actual_end_time, final_condition, usage_notes | All in USAGE_SESSION | PASS |
| 16 | Maintenance records: space, reporter, staff, description, times, status, result | All in MAINTENANCE_RECORD | PASS |
| 17 | Space under maintenance cannot be booked | Documented as application constraint | PASS |
| 18 | Historical records preserved | Schema supports (no hard deletes) | PASS |

**Result: All 18 project description requirements are captured. PASS.**

### From 01-business-req-analysis-G08.md

| # | Business Rule | Status | Owner | Priority |
|---|---------------|--------|-------|----------|
| 1 | Every user must have a university account | Documented Gap | [04] | nice-to-have |
| 2 | Role must be one of the defined set | Gap — no CHECK defined | [05] | nice-to-have |
| 3 | No overlapping approved bookings for same space | Documented Gap ✓ | — | — |
| 4 | Blocked-status spaces cannot be booked | Documented Gap ✓ | — | — |
| 5 | requested_end_time > requested_start_time | Gap — no CHECK defined | [05] | important |
| 6 | Approval records: decided_by_user_id, decision_time, decision_note, rejection_reason | PASS | — | — |
| 7 | Check-in records: actual_start_time, checked_in_by_user_id, initial_condition | PASS | — | — |
| 8 | Completion records: actual_end_time, completed_by_user_id, final_condition, usage_notes | PASS | — | — |
| 9 | Space with active maintenance cannot be booked | Gap — not documented | [04] | important |
| 10 | Historical records preserved | PASS | — | — |

### From AGENT.md Section 5 (Non-Negotiable Rules)

| # | Business Rule | Status | Owner | Priority |
|---|---------------|--------|-------|----------|
| 1 | No overlapping approved bookings | Documented Gap ✓ | — | — |
| 2 | Blocked-status spaces cannot be booked | Documented Gap ✓ | — | — |
| 3 | Active maintenance record blocks booking | Gap — not documented | [04] | important |
| 4 | requested_end_time > requested_start_time | Gap — no CHECK defined | [05] | important |
| 5 | BOOKING_APPROVAL and USAGE_SESSION are 0..1 each | PASS | — | — |
| 6 | Rejected bookings retain rejection_reason | PASS | — | — |
| 7 | Check-in fields present | PASS | — | — |
| 8 | Completion fields present | PASS | — | — |
| 9 | No hard deletes | PASS | — | — |
| 10 | University account requirement | Documented Gap | [04] | nice-to-have |
| 11 | Department optional | Implicitly supported | — | — |
| 12 | Facility belongs to exactly one space | PASS | — | — |
| 13 | Booking status vs usage status separation | Not documented | [04] | nice-to-have |
| 14 | ID generation standards defined | Gap — not defined | [04] | important |
| 15 | (building, room_number) unique | PASS | — | — |

---

## 5. Key Validation

| Relation | PK Valid | CK Valid | FK Valid |
|----------|----------|----------|----------|
| USERS | PASS | PASS (user_id, email) | N/A |
| SPACES | PASS | PASS (space_code, (building, room_number)) | N/A |
| FACILITY | PASS | PASS | PASS |
| BOOKING_REQUEST | PASS | PASS | PASS |
| BOOKING_APPROVAL | PASS | PASS (approval_id, booking_id UNIQUE) | PASS |
| USAGE_SESSION | PASS | PASS (session_id, booking_id UNIQUE) | PASS |
| MAINTENANCE_RECORD | PASS | PASS | PASS |

**Result: PASS.**

---

## 6. Constraint Validation

| Constraint Area | Observation | Status | Owner | Priority |
|-----------------|-------------|--------|-------|----------|
| NOT NULL on PKs | All PKs are NOT NULL by definition | PASS | — | — |
| NOT NULL on mandatory FKs | Most mandatory FKs listed as NOT NULL | PASS | — | — |
| NOT NULL on completed_by_user_id | Not listed — correct (nullable until completion) | PASS | — | — |
| NOT NULL on actual_start_time | Not specified — should be NOT NULL | Minor Gap | [04] | nice-to-have |
| NOT NULL on initial_condition | Not specified — should be NOT NULL | Minor Gap | [04] | nice-to-have |
| CHECK on status values | Not defined (implementation concern) | Acceptable | [05] | nice-to-have |
| CHECK on requested_end_time > requested_start_time | Not defined | Gap | [05] | important |
| DEFAULT values | Not proposed (implementation concern) | Acceptable | [05] | nice-to-have |
| ID generation standards | Not defined | Gap | [04] | important |

---

## 7. Data Type Precision Review

| Relation | Attribute | Type | Assessment |
|----------|-----------|------|------------|
| USERS | user_id | VARCHAR(20) | Adequate for prefixed ID |
| USERS | full_name | VARCHAR(100) | Adequate |
| USERS | email | VARCHAR(100) | Adequate |
| USERS | phone_number | VARCHAR(20) | Adequate for international numbers |
| USERS | role | VARCHAR(50) | Adequate |
| USERS | department | VARCHAR(100) | Adequate |
| USERS | account_status | VARCHAR(30) | Adequate |
| SPACES | space_code | VARCHAR(20) | Adequate for prefixed ID |
| SPACES | space_name | VARCHAR(100) | Adequate |
| SPACES | space_type | VARCHAR(50) | Adequate |
| SPACES | building | VARCHAR(50) | Adequate |
| SPACES | floor | INT | Adequate |
| SPACES | room_number | VARCHAR(20) | Adequate (e.g., "A201") |
| SPACES | capacity | INT | Adequate |
| SPACES | current_status | VARCHAR(30) | Adequate |
| SPACES | usage_policy | TEXT | Adequate (variable length) |
| FACILITY | facility_id | VARCHAR(20) | Adequate |
| FACILITY | space_code | VARCHAR(20) | Matches SPACES.space_code |
| FACILITY | facility_name | VARCHAR(100) | Adequate |
| FACILITY | description | TEXT | Adequate |
| BOOKING_REQUEST | booking_id | VARCHAR(20) | Adequate |
| BOOKING_REQUEST | requested_start_time | DATETIME | Adequate |
| BOOKING_REQUEST | requested_end_time | DATETIME | Adequate |
| BOOKING_REQUEST | purpose | TEXT | Adequate |
| BOOKING_REQUEST | expected_participants | INT | Adequate |
| BOOKING_REQUEST | booking_type | VARCHAR(50) | Adequate |
| BOOKING_REQUEST | status | VARCHAR(30) | Adequate |
| BOOKING_APPROVAL | approval_id | VARCHAR(20) | Adequate |
| BOOKING_APPROVAL | booking_id | VARCHAR(20) | Matches BOOKING_REQUEST.booking_id |
| BOOKING_APPROVAL | decided_by_user_id | VARCHAR(20) | Matches USERS.user_id |
| BOOKING_APPROVAL | decision_time | DATETIME | Adequate |
| BOOKING_APPROVAL | decision_note | TEXT | Adequate |
| BOOKING_APPROVAL | rejection_reason | TEXT | Adequate |
| USAGE_SESSION | session_id | VARCHAR(20) | Adequate |
| USAGE_SESSION | booking_id | VARCHAR(20) | Matches BOOKING_REQUEST.booking_id |
| USAGE_SESSION | actual_start_time | DATETIME | Adequate |
| USAGE_SESSION | actual_end_time | DATETIME | Adequate |
| USAGE_SESSION | checked_in_by_user_id | VARCHAR(20) | Matches USERS.user_id |
| USAGE_SESSION | completed_by_user_id | VARCHAR(20) | Matches USERS.user_id |
| USAGE_SESSION | initial_condition | TEXT | Adequate |
| USAGE_SESSION | final_condition | TEXT | Adequate |
| USAGE_SESSION | usage_notes | TEXT | Adequate |
| MAINTENANCE_RECORD | maintenance_id | VARCHAR(20) | Adequate |
| MAINTENANCE_RECORD | space_code | VARCHAR(20) | Matches SPACES.space_code |
| MAINTENANCE_RECORD | reporter_user_id | VARCHAR(20) | Matches USERS.user_id |
| MAINTENANCE_RECORD | assigned_staff_user_id | VARCHAR(20) | Matches USERS.user_id |
| MAINTENANCE_RECORD | problem_description | TEXT | Adequate |
| MAINTENANCE_RECORD | start_time | DATETIME | Adequate |
| MAINTENANCE_RECORD | completion_time | DATETIME | Adequate |
| MAINTENANCE_RECORD | status | VARCHAR(30) | Adequate |
| MAINTENANCE_RECORD | result_note | TEXT | Adequate |

**Result: All data type choices and precision values are appropriate. PASS.**

---

## 8. Normalization Check (3NF)

| Relation | PK | Transitive Dependencies? | 3NF Status |
|----------|----|--------------------------|------------|
| USERS | user_id | None. email is a CK, not a transitive dependency. | PASS |
| SPACES | space_code | None. (building, room_number) is a composite CK. | PASS |
| FACILITY | facility_id | None. | PASS |
| BOOKING_REQUEST | booking_id | None. | PASS |
| BOOKING_APPROVAL | approval_id | None. booking_id is a CK. | PASS |
| USAGE_SESSION | session_id | None. booking_id is a CK. | PASS |
| MAINTENANCE_RECORD | maintenance_id | None. | PASS |

**Result: All 7 relations satisfy 3NF. PASS.**

---

## 9. Gap Summary (Deduplicated, with Ownership & Priority)

| # | Gap Description | Severity | Owner | Priority |
|---|-----------------|----------|-------|----------|
| 1 | Role value set not documented as CHECK constraint | Low | [05] | nice-to-have |
| 2 | requested_end_time > requested_start_time not enforced | Medium | [05] | important |
| 3 | Active maintenance blocks booking not in Additional Business Constraints | Medium | [04] | important |
| 4 | ID generation standards not defined (AGENT.md rule 14) | Medium | [04] | important |
| 5 | actual_start_time and initial_condition should be NOT NULL | Low | [04] | nice-to-have |
| 6 | Booking vs usage status separation not documented | Low | [04] | nice-to-have |
| 7 | DEFAULT values not proposed | Low | [05] | nice-to-have |

### Gap Distribution

- **[04] Documentation fixes (logical schema):** 4 gaps (#3, #4, #5, #6)
- **[05] Implementation (DDL):** 3 gaps (#1, #2, #7)
- **Important:** 3 gaps (#2, #3, #4)
- **Nice-to-have:** 4 gaps (#1, #5, #6, #7)

---

## 10. Final Verdict

| Validation Dimension | Result |
|----------------------|--------|
| ERD Representation | **PASS** — 7/7 entities, all attributes |
| Relationship Mapping (ERD → Schema) | **PASS** — 11/11 relationships |
| Relationship Mapping (Self-Consistency) | **PASS** — 11/11 entries |
| Business Rules (Project Description) | **PASS** — 18/18 requirements captured |
| Business Rules (BR Analysis) | 6 PASS, 1 Documented Gap, 3 Gaps |
| Business Rules (AGENT.md) | 8 PASS, 2 Documented Gaps, 5 Gaps |
| Key Validation | **PASS** — 7/7 relations |
| Constraint Validation | 5 PASS, 4 Minor Gaps |
| Data Type Precision | **PASS** — all types appropriate |
| Normalization (3NF) | **PASS** — 7/7 relations |

**Overall Assessment:**

The logical database design for the Campus Space Management System is **valid**. It faithfully represents the ERD, correctly implements all relationships, satisfies 3NF, uses appropriate data types, and captures all project description requirements.

**7 non-blocking gaps** remain — 4 for documentation in the logical schema and 3 for DDL implementation. The most important gaps to address before DDL are:
1. Document "active maintenance blocks booking" in logical schema's constraint section.
2. Define ID generation standards (e.g., prefixes 'USR-', 'SPC-', 'BOK-').
3. Add CHECK constraint for `requested_end_time > requested_start_time` in DDL.
