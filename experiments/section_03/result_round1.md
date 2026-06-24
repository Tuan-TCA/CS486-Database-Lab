# Logical Database Design — Shared Campus Space Booking & Facility Management System

## 1. Relational Schema

### USER

| Column | Type | Constraints |
|--------|------|-------------|
| **user_id** | INT | PRIMARY KEY |
| full_name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(255) | NOT NULL, UNIQUE |
| phone | VARCHAR(20) | |
| role | VARCHAR(50) | NOT NULL |
| department | VARCHAR(100) | |
| account_status | VARCHAR(20) | NOT NULL, CHECK (account_status IN ('active', 'inactive', 'suspended')) |

### SPACE

| Column | Type | Constraints |
|--------|------|-------------|
| **space_code** | VARCHAR(20) | PRIMARY KEY |
| space_name | VARCHAR(100) | NOT NULL |
| space_type | VARCHAR(50) | NOT NULL |
| building | VARCHAR(100) | NOT NULL |
| floor | INT | NOT NULL |
| room_number | VARCHAR(20) | NOT NULL |
| capacity | INT | NOT NULL, CHECK (capacity > 0) |
| current_status | VARCHAR(30) | NOT NULL, CHECK (current_status IN ('available', 'under_maintenance', 'temporarily_closed', 'retired')) |
| usage_policy | VARCHAR(255) | |

### FACILITY

| Column | Type | Constraints |
|--------|------|-------------|
| **facility_id** | INT | PRIMARY KEY |
| *space_code* | VARCHAR(20) | NOT NULL, FOREIGN KEY REFERENCES SPACE(space_code) |
| facility_name | VARCHAR(100) | NOT NULL |
| description | VARCHAR(255) | |

### BOOKING_REQUEST

| Column | Type | Constraints |
|--------|------|-------------|
| **booking_id** | INT | PRIMARY KEY |
| *user_id* | INT | NOT NULL, FOREIGN KEY REFERENCES USER(user_id) |
| *space_code* | VARCHAR(20) | NOT NULL, FOREIGN KEY REFERENCES SPACE(space_code) |
| requested_start_time | TIMESTAMP | NOT NULL |
| requested_end_time | TIMESTAMP | NOT NULL, CHECK (requested_end_time > requested_start_time) |
| purpose | VARCHAR(500) | |
| expected_participants | INT | CHECK (expected_participants > 0) |
| booking_type | VARCHAR(50) | NOT NULL |
| status | VARCHAR(20) | NOT NULL, CHECK (status IN ('pending', 'approved', 'rejected', 'checked_in', 'completed', 'cancelled')) |

### BOOKING_APPROVAL

| Column | Type | Constraints |
|--------|------|-------------|
| **approval_id** | INT | PRIMARY KEY |
| *booking_id* | INT | NOT NULL, UNIQUE, FOREIGN KEY REFERENCES BOOKING_REQUEST(booking_id) |
| *decided_by_user_id* | INT | NOT NULL, FOREIGN KEY REFERENCES USER(user_id) |
| decision_time | TIMESTAMP | NOT NULL |
| decision_note | VARCHAR(500) | |
| rejection_reason | VARCHAR(500) | |

### USAGE_SESSION

| Column | Type | Constraints |
|--------|------|-------------|
| **session_id** | INT | PRIMARY KEY |
| *booking_id* | INT | NOT NULL, UNIQUE, FOREIGN KEY REFERENCES BOOKING_REQUEST(booking_id) |
| actual_start_time | TIMESTAMP | |
| actual_end_time | TIMESTAMP | |
| *checked_in_by_user_id* | INT | FOREIGN KEY REFERENCES USER(user_id) |
| *completed_by_user_id* | INT | FOREIGN KEY REFERENCES USER(user_id) |
| initial_condition | VARCHAR(500) | |
| final_condition | VARCHAR(500) | |
| usage_notes | VARCHAR(1000) | |

### MAINTENANCE_RECORD

| Column | Type | Constraints |
|--------|------|-------------|
| **maintenance_id** | INT | PRIMARY KEY |
| *space_code* | VARCHAR(20) | NOT NULL, FOREIGN KEY REFERENCES SPACE(space_code) |
| *reporter_user_id* | INT | NOT NULL, FOREIGN KEY REFERENCES USER(user_id) |
| *assigned_staff_user_id* | INT | FOREIGN KEY REFERENCES USER(user_id) |
| problem_description | VARCHAR(1000) | NOT NULL |
| start_time | TIMESTAMP | NOT NULL |
| completion_time | TIMESTAMP | CHECK (completion_time IS NULL OR completion_time > start_time) |
| status | VARCHAR(20) | NOT NULL, CHECK (status IN ('reported', 'in_progress', 'resolved', 'closed')) |
| result_note | VARCHAR(1000) | |

## 2. Referential Integrity Summary

| Foreign Key | Parent Table | Child Table | Type |
|-------------|--------------|-------------|------|
| FACILITY.space_code | SPACE | FACILITY | Mandatory 1:N |
| BOOKING_REQUEST.user_id | USER | BOOKING_REQUEST | Mandatory 1:N |
| BOOKING_REQUEST.space_code | SPACE | BOOKING_REQUEST | Mandatory 1:N |
| BOOKING_APPROVAL.booking_id | BOOKING_REQUEST | BOOKING_APPROVAL | Mandatory 1:0..1 (UNIQUE) |
| BOOKING_APPROVAL.decided_by_user_id | USER | BOOKING_APPROVAL | Mandatory 1:N |
| USAGE_SESSION.booking_id | BOOKING_REQUEST | USAGE_SESSION | Mandatory 1:0..1 (UNIQUE) |
| USAGE_SESSION.checked_in_by_user_id | USER | USAGE_SESSION | Optional 1:N |
| USAGE_SESSION.completed_by_user_id | USER | USAGE_SESSION | Optional 1:N |
| MAINTENANCE_RECORD.space_code | SPACE | MAINTENANCE_RECORD | Mandatory 1:N |
| MAINTENANCE_RECORD.reporter_user_id | USER | MAINTENANCE_RECORD | Mandatory 1:N |
| MAINTENANCE_RECORD.assigned_staff_user_id | USER | MAINTENANCE_RECORD | Optional 1:N |

## 3. Candidate Keys

| Table | Candidate Key(s) | Chosen PK |
|-------|------------------|-----------|
| USER | user_id, email | user_id |
| SPACE | space_code | space_code |
| FACILITY | facility_id | facility_id |
| BOOKING_REQUEST | booking_id | booking_id |
| BOOKING_APPROVAL | approval_id, booking_id (UNIQUE) | approval_id |
| USAGE_SESSION | session_id, booking_id (UNIQUE) | session_id |
| MAINTENANCE_RECORD | maintenance_id | maintenance_id |

## 4. Business Rule Enforcement

| Rule | Enforcement Mechanism |
|------|----------------------|
| 1. Every user must have a university account. | Application-layer enforcement (referential integrity from external user directory); NOT NULL on email and UNIQUE constraint ensure no duplicate accounts. |
| 2. No overlapping approved bookings for a space. | Application-layer trigger or check; requires querying existing approved bookings for the same space with overlapping time ranges before inserting/updating a BOOKING_REQUEST to 'approved'. |
| 3. Unavailable spaces cannot be booked. | Application-layer check: before creating a BOOKING_REQUEST, validate that SPACE.current_status = 'available'. |
| 4. Active maintenance blocks booking. | Application-layer check: before creating a BOOKING_REQUEST, verify no active MAINTENANCE_RECORD (status IN ('reported', 'in_progress')) exists for the requested SPACE. |
| 5. End time > start time. | CHECK constraint on BOOKING_REQUEST: requested_end_time > requested_start_time. |
| 6. BOOKING_APPROVAL and USAGE_SESSION are optional. | UNIQUE + NOT NULL on foreign keys ensures at most one per BOOKING_REQUEST; FOREIGN KEY allows NULL on child side. |
| 7. Rejected bookings must retain rejection_reason. | NOT NULL constraint when status = 'rejected' (enforced at application layer or via CHECK). |
| 8. Check-in records captured. | USAGE_SESSION fields actual_start_time, checked_in_by_user_id, initial_condition recorded at check-in time. |
| 9. Completion records captured. | USAGE_SESSION fields actual_end_time, completed_by_user_id, final_condition, usage_notes recorded at completion time. |
| 10. No hard deletes. | All tables use status fields for logical deletion; no DELETE operations permitted at application layer. |

## 5. Summary of Constraints

| Constraint Type | Count | Examples |
|-----------------|-------|----------|
| PRIMARY KEY | 7 | One per table |
| FOREIGN KEY | 11 | As listed in referential integrity summary |
| UNIQUE | 3 | USER.email, BOOKING_APPROVAL.booking_id, USAGE_SESSION.booking_id |
| NOT NULL | 30+ | Applied to all mandatory columns |
| CHECK | 7 | Status value sets (5 tables), capacity > 0, end_time > start_time, expected_participants > 0, completion_time > start_time |
