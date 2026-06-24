# Database Design Validation Report — Round 1

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

Every attribute from each ERD entity appears in its corresponding relation. No missing or extra attributes detected.

**Result: PASS.**

---

## 2. Relationship Mapping

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

**Result: All relationships correctly implemented. PASS.**

---

## 3. Business Rules Validation

### From 01-business-req-analysis-G08.md

| # | Business Rule | Enforceable at Schema? | Status |
|---|---------------|------------------------|--------|
| 1 | Every user must have a university account | No (external) | Documented Gap |
| 2 | Role must be one of the defined set | Yes (CHECK) | Gap — not defined in logical schema |
| 3 | No overlapping approved bookings for same space | No (application logic) | Documented Gap ✓ |
| 4 | Space with status under_maintenance/temporarily_closed/retired cannot be booked | No (application logic) | Documented Gap ✓ |
| 5 | requested_end_time > requested_start_time | Yes (CHECK) | Gap — not defined in logical schema |
| 6 | Approval records decided_by_user_id, decision_time, decision_note, rejection_reason | Schema structure supports | PASS |
| 7 | Check-in records actual_start_time, checked_in_by_user_id, initial_condition | Schema structure supports | PASS |
| 8 | Completion records actual_end_time, completed_by_user_id, final_condition, usage_notes | Schema structure supports | PASS |
| 9 | Space with active maintenance cannot be booked | No (application logic) | Gap — not documented in Additional Business Constraints |
| 10 | Historical records preserved | Schema supports (no hard deletes) | PASS |

### From AGENT.md Section 5 (Non-Negotiable Rules)

| # | Business Rule | Status |
|---|---------------|--------|
| 1 | No overlapping approved bookings | Documented Gap ✓ |
| 2 | Blocked-status spaces cannot be booked | Documented Gap ✓ |
| 3 | Active maintenance record blocks booking | Gap — not documented |
| 4 | requested_end_time > requested_start_time | Gap — no CHECK defined |
| 5 | BOOKING_APPROVAL and USAGE_SESSION are 0..1 each | PASS (UNIQUE FK) |
| 6 | Rejected bookings retain rejection_reason | PASS |
| 7 | Check-in fields present | PASS |
| 8 | Completion fields present | PASS |
| 9 | No hard deletes | PASS |
| 10 | University account requirement | Documented Gap |
| 11 | Department optional | Implicitly supported (nullable not enforced) |
| 12 | Facility belongs to exactly one space | PASS (NOT NULL FK) |
| 13 | Booking status vs usage status separation | Not enforced in schema — documentation gap |
| 14 | ID generation standards defined | Gap — logical schema does not define ID formats |
| 15 | (building, room_number) unique | PASS (candidate key) |

---

## 4. Key Validation

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

## 5. Constraint Validation

| Constraint Area | Observation | Status |
|-----------------|-------------|--------|
| NOT NULL on PKs | All PKs are NOT NULL by definition | PASS |
| NOT NULL on mandatory FKs | Most mandatory FKs are listed as NOT NULL | PASS |
| NOT NULL on completed_by_user_id | Not listed as NOT NULL — correct (nullable until completion) | PASS |
| NOT NULL on actual_start_time | Not specified — should be NOT NULL (recorded at check-in) | Minor Gap |
| NOT NULL on initial_condition | Not specified — should be NOT NULL | Minor Gap |
| CHECK on status values | Not defined in logical schema (appropriate for implementation phase) | Acceptable Gap |
| CHECK on requested_end_time > requested_start_time | Not defined | Gap |
| DEFAULT values | Not proposed | Acceptable Gap |
| ID generation standards | Not defined | Gap |

---

## 6. Summary

### PASS Count: 32

### FAIL / Gap Count: 7

| # | Gap Description | Severity |
|---|-----------------|----------|
| 1 | Role value set not defined as CHECK constraint | Low |
| 2 | requested_end_time > requested_start_time not enforced | Medium |
| 3 | Space with active maintenance blocks booking not documented in Additional Business Constraints | Medium |
| 4 | ID generation standards not defined (AGENT.md rule 14) | Medium |
| 5 | actual_start_time and initial_condition should be NOT NULL | Low |
| 6 | Booking vs usage status separation not documented | Low |
| 7 | Rule 3 from AGENT.md (active maintenance blocks booking) not in Additional Business Constraints | Medium |

### Overall Verdict

The logical database design correctly represents the ERD. All entities, attributes, relationships, and keys are faithfully mapped. The schema supports all required business operations.

However, 7 gaps were identified. The most important are:
1. The "active maintenance blocks booking" rule is not documented in the logical schema's constraints section.
2. ID generation standards (rule 14) are not addressed.
3. `requested_end_time > requested_start_time` should be documented even if enforced at implementation.

**Recommendation:** Address documented gaps before DDL implementation (section 05).
