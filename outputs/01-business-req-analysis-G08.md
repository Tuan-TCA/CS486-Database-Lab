# 01-business-req-analysis-G08.md

# 1. Business Purpose

The database system manages the booking and usage of shared campus spaces (auditoriums, classrooms, laboratories, meeting rooms, workspaces) for the School of Computer Science. It replaces a manual spreadsheet/email process with a structured system that handles booking requests, approvals, check-in/check-out, maintenance tracking, and historical reporting. The system ensures fair allocation, prevents overlapping bookings, blocks unavailable spaces, and preserves complete usage history.

# 2. Actors

| Role                     | Description                                                                                                        |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| Student                  | Submits booking requests for student activities, projects, seminars; views own bookings                            |
| Lecturer                 | Submits booking requests for lectures, examinations, seminars; views own bookings                                  |
| Teaching Assistant       | Submits booking requests for workshops, tutorials; assists lecturers with bookings                                 |
| Facility Staff           | Checks room availability, approves/rejects bookings, performs check-in/check-out, reports and manages maintenance |
| Department Administrator | Views departmental booking history and supports administrative coordination                                        |
| Facility Manager         | Oversees space management, views all bookings/maintenance, manages space statuses and facilities                   |

# 3. Entities & Attributes

| Entity Name        | Description                                    | Identified Attributes                                                                                                                                                        |
| ------------------ | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User               | System users with university accounts          | user_id (PK), full_name, email, phone_number, role, department, account_status                                                                                               |
| Space              | Bookable physical spaces managed by the School | space_code (PK), space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy                                                               |
| Facility           | Equipment/features available in spaces         | facility_id (PK), space_code (FK), facility_name, description                                                                                                                |
| Booking_Request    | User requests to book a space                  | booking_id (PK), user_id (FK), space_code (FK), requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status                              |
| Booking_Approval   | Approval/rejection decisions on bookings       | approval_id (PK), booking_id (FK), decided_by_user_id (FK), decision_time, decision_note, rejection_reason                                                                  |
| Usage_Session      | Actual usage session (check-in/check-out)      | session_id (PK), booking_id (FK), actual_start_time, actual_end_time, checked_in_by_user_id (FK), completed_by_user_id (FK), initial_condition, final_condition, usage_notes |
| Maintenance_Record | Maintenance activities on spaces               | maintenance_id (PK), space_code (FK), reporter_user_id (FK), assigned_staff_user_id (FK), problem_description, start_time, completion_time, status, result_note             |

# 4. Relationships and Cardinalities

## Space contains Facility

Space ----- Facility

Relationship: contains

**Cardinality: 1:N**

A space may contain multiple facilities. Each facility belongs to one space.

---

## User submits Booking_Request

User ----- Booking_Request

Relationship: submits

**Cardinality: 1:N**

A user may submit many booking requests. Each booking request is submitted by one user.

---

## Space receives Booking_Request

Space ----- Booking_Request

Relationship: receives

**Cardinality: 1:N**

A space may receive many booking requests. Each booking request is associated with one space.

---

## Booking_Request has Booking_Approval

Booking_Request ----- Booking_Approval

Relationship: has

**Cardinality: 1:0..1**

A booking request may have zero or one approval record. Some booking requests may not require approval.

---

## User performs Booking_Approval

User ----- Booking_Approval

Relationship: performs

**Cardinality: 1:N**

Note: Only users with role = 'Facility Staff'
or 'Facility Manager' may perform approval actions.

A facility staff member may perform many approval actions. Each approval is performed by one facility staff member.

---

## Booking_Request creates Usage_Session

Booking_Request ----- Usage_Session

Relationship: creates

**Cardinality: 1:0..1**

A booking request may create zero or one usage session. Only approved bookings may result in actual usage sessions.

---

## User checks in Usage_Session

User ----- Usage_Session

Relationship: checks_in

**Cardinality: 1:N**

Note: Only users with role = 'Facility Staff' may check in usage sessions.

A facility staff member may check in many usage sessions. Each usage session is checked in by one facility staff member.

---

## User completes Usage_Session

User ----- Usage_Session

Relationship: completes

**Cardinality: 1:N**

Note: Only users with role = 'Facility Staff' may complete usage sessions.

A facility staff member may complete many usage sessions. Each usage session is completed by one facility staff member.

---

## Space has Maintenance_Record

Space ----- Maintenance_Record

Relationship: has

**Cardinality: 1:N**

A space may have multiple maintenance records. Each maintenance record belongs to one space.

---

## User reports Maintenance_Record

User ----- Maintenance_Record

Relationship: reports

**Cardinality: 1:N**

A user may report many maintenance issues. Each maintenance record is reported by one user.

---

## User assigned to Maintenance_Record

User ----- Maintenance_Record

Relationship: assigned

**Cardinality: 1:N**

Note: Only users with role = 'Facility Staff' may be assigned maintenance tasks.

A facility staff member may be assigned multiple maintenance tasks. Each maintenance record is assigned to one facility staff member.

---

# Business Rules

- Every user accessing the system must possess a valid university account.
- User's role may be student, lecturer, teaching assistant, facility staff, department administrator, or facility manager.
- A Space cannot have two approved Booking_Requests with overlapping time periods.
- A Space with current_status in {under_maintenance, temporarily_closed, retired} cannot be booked.
- A Booking_Request must have requested_end_time > requested_start_time.
- When a Booking_Request is approved/rejected, the system records: decided_by_user_id, decision_time, decision_note (and rejection_reason if rejected).
- When a Usage_Session is checked in, the system records: actual_start_time, checked_in_by_user_id, initial_condition.
- When a Usage_Session is completed, the system records: actual_end_time, completed_by_user_id, final_condition, usage_notes.
- A Space under maintenance (Maintenance_Record with active status) cannot be booked.
- Historical records of all bookings and maintenance activities must be preserved.