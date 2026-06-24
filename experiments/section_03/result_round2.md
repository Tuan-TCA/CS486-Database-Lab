# Logical Database Design — Shared Campus Space Booking & Facility Management System

## 1. Relational Schema

```
USER (**user_id**, full_name, email, phone, role, department, account_status)

SPACE (**space_code**, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)

FACILITY (**facility_id**, *space_code*, facility_name, description)

BOOKING_REQUEST (**booking_id**, *user_id*, *space_code*, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)

BOOKING_APPROVAL (**approval_id**, *booking_id*, *decided_by_user_id*, decision_time, decision_note, rejection_reason)

USAGE_SESSION (**session_id**, *booking_id*, actual_start_time, actual_end_time, *checked_in_by_user_id*, *completed_by_user_id*, initial_condition, final_condition, usage_notes)

MAINTENANCE_RECORD (**maintenance_id**, *space_code*, *reporter_user_id*, *assigned_staff_user_id*, problem_description, start_time, completion_time, status, result_note)
```

## 2. Attribute Data Dictionary

### USER

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| user_id | INT | NOT NULL | Unique identifier for each user |
| full_name | VARCHAR(100) | NOT NULL | User's full name |
| email | VARCHAR(255) | NOT NULL | User's email address (candidate key) |
| phone | VARCHAR(20) | NULL | Contact phone number |
| role | VARCHAR(50) | NOT NULL | User's role (student, lecturer, TA, facility staff, admin, facility manager) |
| department | VARCHAR(100) | NULL | Academic or administrative department |
| account_status | VARCHAR(20) | NOT NULL | Account status: active, inactive, suspended |

### SPACE

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| space_code | VARCHAR(20) | NOT NULL | Unique code identifying the space |
| space_name | VARCHAR(100) | NOT NULL | Display name of the space |
| space_type | VARCHAR(50) | NOT NULL | Type of space (classroom, lab, meeting room, auditorium) |
| building | VARCHAR(100) | NOT NULL | Building where the space is located |
| floor | INT | NOT NULL | Floor number within the building |
| room_number | VARCHAR(20) | NOT NULL | Room number within the floor |
| capacity | INT | NOT NULL | Maximum occupancy |
| current_status | VARCHAR(30) | NOT NULL | Availability status: available, under_maintenance, temporarily_closed, retired |
| usage_policy | VARCHAR(255) | NULL | Rules or restrictions for using the space |

### FACILITY

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| facility_id | INT | NOT NULL | Unique identifier for the facility |
| space_code | VARCHAR(20) | NOT NULL | Foreign key referencing the containing space |
| facility_name | VARCHAR(100) | NOT NULL | Name of the facility (e.g., projector, whiteboard) |
| description | VARCHAR(255) | NULL | Optional description of the facility |

### BOOKING_REQUEST

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| booking_id | INT | NOT NULL | Unique identifier for the booking request |
| user_id | INT | NOT NULL | Foreign key referencing the requesting user |
| space_code | VARCHAR(20) | NOT NULL | Foreign key referencing the requested space |
| requested_start_time | TIMESTAMP | NOT NULL | Desired start time for the booking |
| requested_end_time | TIMESTAMP | NOT NULL | Desired end time for the booking (must be > start time) |
| purpose | VARCHAR(500) | NULL | Reason for the booking |
| expected_participants | INT | NULL | Expected number of attendees |
| booking_type | VARCHAR(50) | NOT NULL | Category of booking (e.g., lecture, meeting, event) |
| status | VARCHAR(20) | NOT NULL | Current status: pending, approved, rejected, checked_in, completed, cancelled |

### BOOKING_APPROVAL

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| approval_id | INT | NOT NULL | Unique identifier for the approval record |
| booking_id | INT | NOT NULL | Foreign key referencing the booking (UNIQUE, 1:0..1) |
| decided_by_user_id | INT | NOT NULL | Foreign key referencing the approving user |
| decision_time | TIMESTAMP | NOT NULL | When the decision was made |
| decision_note | VARCHAR(500) | NULL | Optional note accompanying the decision |
| rejection_reason | VARCHAR(500) | NULL | Reason for rejection (required when rejected) |

### USAGE_SESSION

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| session_id | INT | NOT NULL | Unique identifier for the usage session |
| booking_id | INT | NOT NULL | Foreign key referencing the booking (UNIQUE, 1:0..1) |
| actual_start_time | TIMESTAMP | NULL | Check-in time |
| actual_end_time | TIMESTAMP | NULL | Check-out time |
| checked_in_by_user_id | INT | NULL | Foreign key referencing the user who performed check-in |
| completed_by_user_id | INT | NULL | Foreign key referencing the user who performed check-out |
| initial_condition | VARCHAR(500) | NULL | Condition of the space at check-in |
| final_condition | VARCHAR(500) | NULL | Condition of the space at check-out |
| usage_notes | VARCHAR(1000) | NULL | Additional notes about the session |

### MAINTENANCE_RECORD

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| maintenance_id | INT | NOT NULL | Unique identifier for the maintenance record |
| space_code | VARCHAR(20) | NOT NULL | Foreign key referencing the affected space |
| reporter_user_id | INT | NOT NULL | Foreign key referencing the user who reported the issue |
| assigned_staff_user_id | INT | NULL | Foreign key referencing the assigned maintenance staff |
| problem_description | VARCHAR(1000) | NOT NULL | Description of the problem |
| start_time | TIMESTAMP | NOT NULL | When the problem was reported or work began |
| completion_time | TIMESTAMP | NULL | When the work was completed |
| status | VARCHAR(20) | NOT NULL | Status: reported, in_progress, resolved, closed |
| result_note | VARCHAR(1000) | NULL | Notes on the resolution |

## 3. Keys Analysis

### Primary Keys

| Table | Primary Key |
|-------|-------------|
| USER | user_id |
| SPACE | space_code |
| FACILITY | facility_id |
| BOOKING_REQUEST | booking_id |
| BOOKING_APPROVAL | approval_id |
| USAGE_SESSION | session_id |
| MAINTENANCE_RECORD | maintenance_id |

### Candidate Keys

| Table | Candidate Key(s) | Rationale |
|-------|------------------|-----------|
| USER | user_id, email | Email is a natural unique identifier for each user |
| SPACE | space_code, (building, room_number) | A building and room number combination uniquely identifies a physical room |
| FACILITY | facility_id | No natural alternative key |
| BOOKING_REQUEST | booking_id | Surrogate key; no natural alternative |
| BOOKING_APPROVAL | approval_id, booking_id (UNIQUE FK) | Each booking has at most one approval |
| USAGE_SESSION | session_id, booking_id (UNIQUE FK) | Each booking has at most one usage session |
| MAINTENANCE_RECORD | maintenance_id | No natural alternative key |

## 4. Referential Integrity (Foreign Keys)

| Child Table | Foreign Key | Parent Table | Parent Primary Key |
|-------------|-------------|--------------|--------------------|
| FACILITY | space_code | SPACE | space_code |
| BOOKING_REQUEST | user_id | USER | user_id |
| BOOKING_REQUEST | space_code | SPACE | space_code |
| BOOKING_APPROVAL | booking_id | BOOKING_REQUEST | booking_id |
| BOOKING_APPROVAL | decided_by_user_id | USER | user_id |
| USAGE_SESSION | booking_id | BOOKING_REQUEST | booking_id |
| USAGE_SESSION | checked_in_by_user_id | USER | user_id |
| USAGE_SESSION | completed_by_user_id | USER | user_id |
| MAINTENANCE_RECORD | space_code | SPACE | space_code |
| MAINTENANCE_RECORD | reporter_user_id | USER | user_id |
| MAINTENANCE_RECORD | assigned_staff_user_id | USER | user_id |

## 5. Business Rule Enforcement

1. **Every user must have a university account.** — Schema: `NOT NULL` and `UNIQUE` on `USER.email`. Application layer validates against external user directory.

2. **No overlapping approved bookings for a space.** — Application layer: before approving a booking request, query existing approved bookings for the same space with overlapping time ranges.

3. **Unavailable spaces cannot be booked.** — Application layer: validate that `SPACE.current_status = 'available'` before creating a booking request.

4. **Active maintenance blocks booking.** — Application layer: verify no active `MAINTENANCE_RECORD` (status `reported` or `in_progress`) exists for the requested space before creating a booking request.

5. **End time > start time.** — Schema: `CHECK (requested_end_time > requested_start_time)` on `BOOKING_REQUEST`.

6. **BOOKING_APPROVAL and USAGE_SESSION are optional (zero-or-one).** — Schema: `FOREIGN KEY` with `UNIQUE` constraint on the FK column ensures at most one per booking.

7. **Rejected bookings must retain a rejection_reason.** — Application layer: enforce that `rejection_reason IS NOT NULL` when `BOOKING_APPROVAL` corresponds to a rejected booking.

8. **Check-in records captured.** — Schema: relevant columns (`actual_start_time`, `checked_in_by_user_id`, `initial_condition`) exist as nullable fields in `USAGE_SESSION`.

9. **Completion records captured.** — Schema: relevant columns (`actual_end_time`, `completed_by_user_id`, `final_condition`, `usage_notes`) exist as nullable fields in `USAGE_SESSION`.

10. **No hard deletes.** — Application layer: all data retention is managed via status fields; `DELETE` operations are prohibited.
