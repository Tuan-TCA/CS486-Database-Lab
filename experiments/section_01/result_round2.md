# Business Requirement Analysis — Shared Campus Space Booking & Facility Management System

## 1. Business Purpose

The School of Computer Science currently manages campus space bookings—classrooms, labs, meeting rooms, and auditoriums—through a manual spreadsheet-and-email process. This approach causes frequent double-bookings, lacks visibility into space availability, and provides no audit trail for approvals or usage. A centralized database system is needed to enforce no double-booking and no booking of unavailable spaces at the data level, streamline the approval workflow, preserve all historical records, and support facility maintenance tracking. The system ensures that every booking is validated against space status, active maintenance, and time overlap constraints before it is confirmed.

## 2. System Actors

- Student
- Lecturer
- Teaching Assistant
- Facility Staff
- Department Administrator
- Facility Manager

## 3. Entities and Attributes

### USER

| Attribute | Type | Notes |
|-----------|------|-------|
| **user_id** | PK | Unique identifier |
| full_name | | |
| email | | Candidate key |
| phone | | |
| role | | |
| department | | |
| account_status | | |

### SPACE

| Attribute | Type | Notes |
|-----------|------|-------|
| **space_code** | PK | Unique identifier |
| space_name | | |
| space_type | | |
| building | | |
| floor | | |
| room_number | | |
| capacity | | |
| current_status | | |
| usage_policy | | |

### FACILITY

| Attribute | Type | Notes |
|-----------|------|-------|
| **facility_id** | PK | Unique identifier |
| *space_code* | FK | References SPACE |
| facility_name | | |
| description | | |

### BOOKING_REQUEST

| Attribute | Type | Notes |
|-----------|------|-------|
| **booking_id** | PK | Unique identifier |
| *user_id* | FK | References USER |
| *space_code* | FK | References SPACE |
| requested_start_time | | |
| requested_end_time | | |
| purpose | | |
| expected_participants | | |
| booking_type | | |
| status | | |

### BOOKING_APPROVAL

| Attribute | Type | Notes |
|-----------|------|-------|
| **approval_id** | PK | Unique identifier |
| *booking_id* | FK (unique) | References BOOKING_REQUEST |
| *decided_by_user_id* | FK | References USER |
| decision_time | | |
| decision_note | | |
| rejection_reason | | |

### USAGE_SESSION

| Attribute | Type | Notes |
|-----------|------|-------|
| **session_id** | PK | Unique identifier |
| *booking_id* | FK (unique) | References BOOKING_REQUEST |
| actual_start_time | | |
| actual_end_time | | |
| *checked_in_by_user_id* | FK | References USER |
| *completed_by_user_id* | FK | References USER |
| initial_condition | | |
| final_condition | | |
| usage_notes | | |

### MAINTENANCE_RECORD

| Attribute | Type | Notes |
|-----------|------|-------|
| **maintenance_id** | PK | Unique identifier |
| *space_code* | FK | References SPACE |
| *reporter_user_id* | FK | References USER |
| *assigned_staff_user_id* | FK | References USER |
| problem_description | | |
| start_time | | |
| completion_time | | |
| status | | |
| result_note | | |

## 4. Business Rules

1. Every user must have a university account.
2. A space cannot have two approved bookings with overlapping time periods.
3. A space with `current_status` in `{under_maintenance, temporarily_closed, retired}` cannot be booked.
4. A space with an active maintenance record cannot be booked.
5. `requested_end_time` must be strictly greater than `requested_start_time`.
6. `BOOKING_APPROVAL` and `USAGE_SESSION` are each optional (zero-or-one) per `BOOKING_REQUEST`.
7. Rejected bookings must retain a `rejection_reason`.
8. Check-in records: actual_start_time, checked_in_by_user_id, initial_condition.
9. Completion records: actual_end_time, completed_by_user_id, final_condition, usage_notes.
10. No hard deletes — all history is preserved via status fields.
