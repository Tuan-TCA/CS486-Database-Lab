# Database Design Validation Report — Round 2

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

## 3. Relationship Mapping Self-Consistency (Logical Schema Section 3)

| Mapping Entry | FK Implemented? | Consistent? |
|---------------|-----------------|-------------|
| USERS → BOOKING_REQUEST: 1:N via FK user_id | FK user_id in BOOKING_REQUEST | PASS |
| SPACES → BOOKING_REQUEST: 1:N via FK space_code | FK space_code in BOOKING_REQUEST | PASS |
| SPACES → FACILITY: 1:N via FK space_code | FK space_code in FACILITY | PASS |
| BOOKING_REQUEST → BOOKING_APPROVAL: 1:0..1 via UNIQUE FK booking_id | UNIQUE FK booking_id | PASS |
| USERS → BOOKING_APPROVAL: 1:N via FK decided_by_user_id | FK decided_by_user_id | PASS |
| BOOKING_REQUEST → USAGE_SESSION: 1:0..1 via UNIQUE FK booking_id | UNIQUE FK booking_id | PASS |
| USERS → USAGE_SESSION (check-in): 1:N via FK checked_in_by_user_id | FK checked_in_by_user_id | PASS |
| USERS → USAGE_SESSION (completion): 1:N via FK completed_by_user_id | FK completed_by_user_id | PASS |
| SPACES → MAINTENANCE_RECORD: 1:N via FK space_code | FK space_code | PASS |
| USERS → MAINTENANCE_RECORD (reporter): 1:N via FK reporter_user_id | FK reporter_user_id | PASS |
| USERS → MAINTENANCE_RECORD (assigned): 1:N via FK assigned_staff_user_id | FK assigned_staff_user_id | PASS |

**Result: All mapping entries are self-consistent with FK definitions. PASS.**

---

## 4. Business Rules Validation

### From 01-business-req-analysis-G08.md

| # | Business Rule | Status | Owner |
|---|---------------|--------|-------|
| 1 | Every user must have a university account | Documented Gap | [04] |
| 2 | Role must be one of the defined set | Gap — no CHECK defined | [05] |
| 3 | No overlapping approved bookings for same space | Documented Gap ✓ | — |
| 4 | Space with status under_maintenance/temporarily_closed/retired cannot be booked | Documented Gap ✓ | — |
| 5 | requested_end_time > requested_start_time | Gap — no CHECK defined | [05] |
| 6 | Approval records: decided_by_user_id, decision_time, decision_note, rejection_reason | PASS | — |
| 7 | Check-in records: actual_start_time, checked_in_by_user_id, initial_condition | PASS | — |
| 8 | Completion records: actual_end_time, completed_by_user_id, final_condition, usage_notes | PASS | — |
| 9 | Space with active maintenance cannot be booked | Gap — not documented | [04] |
| 10 | Historical records preserved | PASS | — |

### From AGENT.md Section 5 (Non-Negotiable Rules)

| # | Business Rule | Status | Owner |
|---|---------------|--------|-------|
| 1 | No overlapping approved bookings | Documented Gap ✓ | — |
| 2 | Blocked-status spaces cannot be booked | Documented Gap ✓ | — |
| 3 | Active maintenance record blocks booking | Gap — not documented | [04] |
| 4 | requested_end_time > requested_start_time | Gap — no CHECK defined | [05] |
| 5 | BOOKING_APPROVAL and USAGE_SESSION are 0..1 each | PASS | — |
| 6 | Rejected bookings retain rejection_reason | PASS | — |
| 7 | Check-in fields present | PASS | — |
| 8 | Completion fields present | PASS | — |
| 9 | No hard deletes | PASS | — |
| 10 | University account requirement | Documented Gap | [04] |
| 11 | Department optional | Implicitly supported | — |
| 12 | Facility belongs to exactly one space | PASS | — |
| 13 | Booking status vs usage status separation | Not documented | [04] |
| 14 | ID generation standards defined | Gap — not defined | [04] |
| 15 | (building, room_number) unique | PASS | — |

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

| Constraint Area | Observation | Status | Owner |
|-----------------|-------------|--------|-------|
| NOT NULL on PKs | All PKs are NOT NULL by definition | PASS | — |
| NOT NULL on mandatory FKs | Most mandatory FKs listed as NOT NULL | PASS | — |
| NOT NULL on completed_by_user_id | Not listed — correct (nullable until completion) | PASS | — |
| NOT NULL on actual_start_time | Not specified — should be NOT NULL | Minor Gap | [04] |
| NOT NULL on initial_condition | Not specified — should be NOT NULL | Minor Gap | [04] |
| CHECK on status values | Not defined (implementation concern) | Acceptable | [05] |
| CHECK on requested_end_time > requested_start_time | Not defined | Gap | [05] |
| DEFAULT values | Not proposed (implementation concern) | Acceptable | [05] |
| ID generation standards | Not defined | Gap | [04] |

---

## 7. Normalization Check (3NF)

### USERS
- PK: user_id. Non-key attrs: full_name, email, phone_number, role, department, account_status.
- No transitive dependencies. email is a CK, not a dependency on a non-key attribute.
- **3NF: PASS**

### SPACES
- PK: space_code. Non-key attrs: space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy.
- FK: none. No transitive dependencies.
- **3NF: PASS**

### FACILITY
- PK: facility_id. Non-key attrs: space_code (FK), facility_name, description.
- No transitive dependencies.
- **3NF: PASS**

### BOOKING_REQUEST
- PK: booking_id. Non-key attrs: user_id (FK), space_code (FK), requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status.
- No transitive dependencies.
- **3NF: PASS**

### BOOKING_APPROVAL
- PK: approval_id. Non-key attrs: booking_id (FK, UNIQUE CK), decided_by_user_id (FK), decision_time, decision_note, rejection_reason.
- booking_id is a CK, so functional dependencies via booking_id are acceptable.
- **3NF: PASS**

### USAGE_SESSION
- PK: session_id. Non-key attrs: booking_id (FK, UNIQUE CK), actual_start_time, actual_end_time, checked_in_by_user_id (FK), completed_by_user_id (FK), initial_condition, final_condition, usage_notes.
- booking_id is a CK. No transitive dependencies among non-key attrs.
- **3NF: PASS**

### MAINTENANCE_RECORD
- PK: maintenance_id. Non-key attrs: space_code (FK), reporter_user_id (FK), assigned_staff_user_id (FK), problem_description, start_time, completion_time, status, result_note.
- No transitive dependencies.
- **3NF: PASS**

**Result: All 7 relations satisfy 3NF. PASS.**

---

## 8. Gap Summary (Deduplicated, with Ownership)

| # | Gap Description | Severity | Owner | Recommendation |
|---|-----------------|----------|-------|----------------|
| 1 | Role value set not documented as CHECK constraint | Low | [05] | Add CHECK in DDL |
| 2 | requested_end_time > requested_start_time not enforced | Medium | [05] | Add CHECK in DDL |
| 3 | Active maintenance blocks booking not in Additional Business Constraints | Medium | [04] | Add to logical schema documentation |
| 4 | ID generation standards not defined (AGENT.md rule 14) | Medium | [04] | Define ID format in logical schema |
| 5 | actual_start_time and initial_condition should be NOT NULL | Low | [04] | Add NOT NULL to logical schema |
| 6 | Booking vs usage status separation not documented | Low | [04] | Add note to logical schema |
| 7 | DEFAULT values not proposed | Low | [05] | Add DEFAULT in DDL |

---

## 9. Overall Verdict

The logical database design correctly represents the ERD, all relationships are faithfully implemented, and the schema is fully normalized to 3NF.

**7 gaps identified** (down from 7 — deduplication removed 0 duplicates in this round since the original had duplicates that were already merged for round 2).

- **4 gaps** owned by [04]: documentation items to fix in the logical schema.
- **3 gaps** owned by [05]: implementation items to address in DDL.

**Recommendation:** Resolve [04] gaps in the logical schema before proceeding to DDL implementation.
