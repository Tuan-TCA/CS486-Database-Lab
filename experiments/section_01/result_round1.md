# Business Requirement Analysis — Shared Campus Space Booking & Facility Management System

## 1. Project Overview

| Item | Detail |
|------|--------|
| Project | Shared Campus Space Booking & Facility Management System |
| Client | School of Computer Science |
| Group | G08 |
| Assignment | Database Design Project — Phase 1 |

The system replaces a manual spreadsheet/email process with a relational database that enforces no double-booking and no booking of unavailable spaces at the data level.

## 2. Stakeholders

| Stakeholder | Role | Key Concerns |
|-------------|------|--------------|
| Students | End-users booking spaces | Easy booking, availability visibility |
| Faculty/Staff | End-users booking spaces | Schedule classes, meetings |
| Facility Managers | Approve bookings, manage spaces | Utilization tracking, conflict prevention |
| Maintenance Staff | Report/receive work orders | Track repairs, update space status |
| System Administrators | Oversee system integrity | Data consistency, audit trail |

## 3. Business Objectives

1. **Eliminate double-booking** — Prevent two approved bookings from overlapping in time for the same space.
2. **Prevent booking of unavailable spaces** — Block bookings when a space is under maintenance, temporarily closed, or retired.
3. **Provide full audit trail** — Preserve all historical data; no hard deletes.
4. **Streamline approval workflow** — Support booking requests with optional approval and usage tracking.
5. **Track facility usage and maintenance** — Record check-in/check-out details and maintenance history.

## 4. Scope

**In scope:**
- Booking, approval, check-in/check-out, and cancellation of campus spaces
- Maintenance request and work-order tracking
- Role-based user management (students, faculty, facility managers, maintenance staff)

**Out of scope (Phase 1):**
- Payment/fee processing
- Recurring booking patterns
- Real-time calendar integration with external systems
- Automated notifications

## 5. Functional Requirements

### FR1 — User Management
- Users are identified by a unique user_id.
- Each user has a full_name, email (candidate key), phone, role, department, and account_status.
- Only active users may create bookings or approve requests.

### FR2 — Space Management
- Spaces are identified by a unique space_code.
- Each space has a space_name, space_type, building, floor, room_number, capacity, current_status, and usage_policy.
- A space's current_status determines bookability: available spaces may be booked; spaces with status under_maintenance, temporarily_closed, or retired may not.

### FR3 — Facility Inventory
- A space may contain zero or more facilities (e.g., projector, whiteboard, air conditioning).
- Each facility is identified by facility_id and linked to a space via space_code.

### FR4 — Booking Requests
- A user may submit a booking request for a specific space and time window.
- `requested_end_time` must be strictly greater than `requested_start_time`.
- Overlapping approved bookings for the same space are prohibited.
- A space with active maintenance records cannot be booked.
- Requests progress through a status workflow: pending → approved/rejected → checked_in → completed/cancelled.

### FR5 — Booking Approval
- Each booking request may optionally have zero or one approval record.
- An approved booking is confirmed; a rejected booking must include a rejection_reason.
- Approval decisions are recorded with the decision-maker, time, and optional note.

### FR6 — Usage Sessions
- Each approved booking may optionally have zero or one usage session.
- Check-in records: actual_start_time, checked_in_by_user_id, initial_condition.
- Completion records: actual_end_time, completed_by_user_id, final_condition, usage_notes.

### FR7 — Maintenance Management
- Maintenance records track problems reported for a space.
- Records include reporter, assigned staff, problem description, start/completion times, status, and result note.
- An active (unresolved) maintenance record prevents new bookings for that space.

### FR8 — History Preservation
- No hard deletes. All entities retain history via status fields (account_status, current_status, booking status, maintenance status).

## 6. Entity Definitions

| Entity | Description | Primary Key |
|--------|-------------|-------------|
| **USER** | Individuals who interact with the system (students, faculty, staff, admins) | user_id |
| **SPACE** | Physical rooms or areas available for booking | space_code |
| **FACILITY** | Equipment or amenities within a space | facility_id |
| **BOOKING_REQUEST** | A request by a user to reserve a space for a time period | booking_id |
| **BOOKING_APPROVAL** | Approval or rejection decision linked to a booking request | approval_id |
| **USAGE_SESSION** | Check-in and check-out record for an approved booking | session_id |
| **MAINTENANCE_RECORD** | Problem report and work order for a space | maintenance_id |

## 7. Business Rules

1. A space cannot have two **approved** bookings with overlapping time periods.
2. A space with `current_status` in `{under_maintenance, temporarily_closed, retired}` cannot be booked.
3. A space with an **active** maintenance record cannot be booked.
4. `requested_end_time` must be strictly greater than `requested_start_time`.
5. `BOOKING_APPROVAL` and `USAGE_SESSION` are each optional (zero-or-one) per `BOOKING_REQUEST`.
6. Rejected bookings must retain a `rejection_reason`.
7. Check-in records: actual_start_time, checked_in_by_user_id, initial_condition.
8. Completion records: actual_end_time, completed_by_user_id, final_condition, usage_notes.
9. No hard deletes — all history is preserved via status fields.

## 8. Key Relationships

- A **USER** may create many **BOOKING_REQUEST**s. A **BOOKING_REQUEST** belongs to exactly one **USER**.
- A **SPACE** may have many **BOOKING_REQUEST**s. A **BOOKING_REQUEST** is for exactly one **SPACE**.
- A **SPACE** may have many **FACILITY** items. A **FACILITY** belongs to exactly one **SPACE**.
- A **BOOKING_REQUEST** may have zero or one **BOOKING_APPROVAL**. A **BOOKING_APPROVAL** belongs to exactly one **BOOKING_REQUEST**.
- A **BOOKING_REQUEST** may have zero or one **USAGE_SESSION**. A **USAGE_SESSION** belongs to exactly one **BOOKING_REQUEST**.
- A **SPACE** may have many **MAINTENANCE_RECORD**s. A **MAINTENANCE_RECORD** belongs to exactly one **SPACE**.
- A **USER** may approve many requests (via **BOOKING_APPROVAL.decided_by_user_id**).
- A **USER** may check in/out many usage sessions (via **USAGE_SESSION** FK fields).
- A **USER** may report or be assigned many maintenance records.

## 9. Status Value Sets

| Entity | Field | Allowed Values |
|--------|-------|----------------|
| USER | account_status | active, inactive, suspended |
| SPACE | current_status | available, under_maintenance, temporarily_closed, retired |
| BOOKING_REQUEST | status | pending, approved, rejected, checked_in, completed, cancelled |
| MAINTENANCE_RECORD | status | reported, in_progress, resolved, closed |

## 10. Assumptions

- A booking request must be approved before a usage session can be created.
- Only one approval or rejection exists per booking request.
- A usage session is created at check-in time, not at booking time.
- Maintenance records are considered "active" when status is `reported` or `in_progress`.
- The system does not enforce minimum booking duration or advance notice requirements.
- Users are pre-registered by an administrator; self-registration is out of scope.
- Building, floor, and room_number are descriptive attributes; they do not imply a location hierarchy enforced by the schema.

## 11. Glossary

| Term | Definition |
|------|------------|
| Booking | A reservation of a space for a specific time period |
| Check-in | Recording the start of a usage session |
| Check-out | Recording the completion of a usage session |
| Double-booking | Two approved bookings with overlapping time for the same space |
| Space | A physical room or area (classroom, lab, meeting room, auditorium) |
| Facility | Equipment or amenity within a space |
