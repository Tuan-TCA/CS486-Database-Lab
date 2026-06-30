# Section 01: Business Requirement Analysis

## 1. Business Purpose

The School of Computer Science manages several shared physical spaces — including auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces — used for teaching, seminars, examinations, workshops, student projects, research activities, and academic events. Currently, all requests to use these spaces are handled manually: lecturers, teaching assistants, students, and staff contact the school office or facility staff by email, phone, or in person, and facility staff then check spreadsheets or shared calendars to determine room availability, requester eligibility, equipment needs, and maintenance status.

As the volume of classes, student projects, workshops, seminars, and academic events grows, this manual process has become increasingly difficult to manage and error-prone. Double-bookings occur when spreadsheets are not updated in time. Spaces under maintenance are accidentally assigned. Usage history is scattered across emails and disconnected files, making it hard to audit past activity or plan future allocations.

The Campus Space Management System is being built to replace this manual workflow with a relational database that enforces business constraints — such as preventing overlapping bookings and blocking reservations on unavailable spaces — directly at the data level. The system will centralize space booking, approval workflows, usage session tracking, maintenance management, and incident reporting into a single, consistent platform. By doing so, it ensures fair access to shared campus spaces, eliminates scheduling conflicts, prevents the use of unavailable or under-maintenance rooms, and preserves a complete historical record of all bookings and maintenance activities.

Every user of the system must have a university account, ensuring that only authorized members of the university community can request and manage campus spaces.

## 2. System Actors

The following actors interact with the Campus Space Management System:

- **Student** — Submits booking requests for student activities, project work, and group meetings.
- **Lecturer** — Submits booking requests for lectures, seminars, examinations, and workshops.
- **Teaching Assistant** — Submits booking requests on behalf of courses and assists in coordinating space usage.
- **Facility Staff** — Manages day-to-day space operations including booking approvals, check-ins, completions, and maintenance reporting.
- **Department Administrator** — Oversees departmental space usage and coordinates administrative events.
- **Facility Manager** — Has overall responsibility for space management policy, approval decisions, and maintenance oversight.

## 3. Entities and Attributes

### 3.1 USER

| Attribute | Description | Constraints |
|-----------|-------------|-------------|
| user_id | Unique identifier for the user | PK |
| full_name | Full name of the user | Required |
| email | University email address | Candidate key |
| phone | Phone number | |
| role | Role within the system | Required |
| department | Department the user belongs to | |
| account_status | Current status of the user's account | Required |

### 3.2 SPACE

| Attribute | Description | Constraints |
|-----------|-------------|-------------|
| space_code | Unique code identifying the space | PK |
| space_name | Name of the space | Required |
| space_type | Type of space | Required |
| building | Building where the space is located | Required |
| floor | Floor number | Required |
| room_number | Room number within the building and floor | Required |
| capacity | Maximum number of occupants | Required |
| current_status | Current availability status of the space | Required |
| usage_policy | Policy governing the use of the space | |

### 3.3 FACILITY

| Attribute | Description | Constraints |
|-----------|-------------|-------------|
| facility_id | Unique identifier for the facility item | PK |
| space_code | Reference to the space this facility belongs to | FK → SPACE |
| facility_name | Name of the facility item | Required |
| description | Additional details about the facility | |

### 3.4 BOOKING_REQUEST

| Attribute | Description | Constraints |
|-----------|-------------|-------------|
| booking_id | Unique identifier for the booking request | PK |
| user_id | Reference to the user who submitted the request | FK → USER |
| space_code | Reference to the requested space | FK → SPACE |
| requested_start_time | Desired start time for the booking | Required |
| requested_end_time | Desired end time for the booking | Required |
| purpose | Description of the purpose of the booking | Required |
| expected_participants | Expected number of participants | Required |
| booking_type | Type of booking | Required |
| status | Current status of the booking request | Required |

### 3.5 BOOKING_APPROVAL

| Attribute | Description | Constraints |
|-----------|-------------|-------------|
| approval_id | Unique identifier for the approval record | PK |
| booking_id | Reference to the associated booking request | FK → BOOKING_REQUEST, unique |
| decided_by_user_id | Reference to the staff member who made the decision | FK → USER |
| decision_time | Timestamp when the decision was made | Required |
| decision_note | Notes accompanying the approval or rejection decision | |
| rejection_reason | Reason for rejection (required when booking is rejected) | Conditional |

### 3.6 USAGE_SESSION

| Attribute | Description | Constraints |
|-----------|-------------|-------------|
| session_id | Unique identifier for the usage session | PK |
| booking_id | Reference to the associated booking request | FK → BOOKING_REQUEST, unique |
| actual_start_time | Actual time the session began (recorded at check-in) | Required at check-in |
| actual_end_time | Actual time the session ended (recorded at completion) | Required at completion |
| checked_in_by_user_id | Reference to the staff member who performed check-in | FK → USER; Required at check-in |
| completed_by_user_id | Reference to the staff member who completed the session | FK → USER; Required at completion |
| initial_condition | Condition of the space at the start of the session | Required at check-in |
| final_condition | Condition of the space at the end of the session | Required at completion |
| usage_notes | Notes about the session usage | Required at completion |

### 3.7 MAINTENANCE_RECORD

| Attribute | Description | Constraints |
|-----------|-------------|-------------|
| maintenance_id | Unique identifier for the maintenance record | PK |
| space_code | Reference to the space requiring maintenance | FK → SPACE |
| reporter_user_id | Reference to the user who reported the issue | FK → USER |
| assigned_staff_user_id | Reference to the staff member assigned to resolve the issue | FK → USER |
| problem_description | Description of the maintenance problem | Required |
| start_time | Time when maintenance began | Required |
| completion_time | Time when maintenance was completed | |
| status | Current status of the maintenance record | Required |
| result_note | Notes about the outcome of the maintenance work | |

## 4. Domain Value Enumerations

The following enumerated domain values are defined by the project description. These values represent the complete set of valid options for their respective attributes.

### 4.1 User Roles

| # | Value |
|---|-------|
| 1 | Student |
| 2 | Lecturer |
| 3 | Teaching Assistant |
| 4 | Facility Staff |
| 5 | Department Administrator |
| 6 | Facility Manager |

### 4.2 Space Types

| # | Value |
|---|-------|
| 1 | Auditorium |
| 2 | Classroom |
| 3 | Computer Laboratory |
| 4 | Project Laboratory |
| 5 | Meeting Room |
| 6 | Student Workspace |

### 4.3 Space Statuses

| # | Value | Description |
|---|-------|-------------|
| 1 | Available | Space is open for booking and use |
| 2 | In Use | Space is currently occupied by an active session |
| 3 | Under Maintenance | Space is undergoing maintenance work and cannot be booked |
| 4 | Temporarily Closed | Space is closed for a temporary period and cannot be booked |
| 5 | Retired | Space is permanently decommissioned and cannot be booked |

### 4.4 Booking Types

| # | Value |
|---|-------|
| 1 | Lecture |
| 2 | Examination |
| 3 | Seminar |
| 4 | Workshop |
| 5 | Meeting |
| 6 | Student Activity |
| 7 | Administrative Event |

### 4.5 Booking Statuses

| # | Value | Description |
|---|-------|-------------|
| 1 | Pending | Booking request submitted, awaiting approval |
| 2 | Approved | Booking approved by authorized staff |
| 3 | Rejected | Booking denied; rejection_reason is preserved |
| 4 | Cancelled | Booking cancelled by the requester or staff |
| 5 | Checked In | Space usage has begun; check-in recorded |
| 6 | Completed | Space usage has ended; completion recorded |
| 7 | No-show | Approved booking where the requester did not check in |

### 4.6 Facility Examples

| # | Value |
|---|-------|
| 1 | Projector |
| 2 | Whiteboard |
| 3 | Microphone |
| 4 | Computer |
| 5 | Livestreaming Equipment |
| 6 | Air Conditioner |

### 4.7 Maintenance Problem Types

| # | Value |
|---|-------|
| 1 | Broken Projectors |
| 2 | Air-conditioning Failure |
| 3 | Damaged Furniture |
| 4 | Cleaning Issues |
| 5 | Network Problems |

## 5. Business Rules

Business rules are organized by domain category. All rules are sourced from the Agent.md non-negotiable business rules.

### 5.1 Booking Constraints

| Rule | Statement |
|------|-----------|
| 1 | A space cannot have two approved bookings with overlapping time periods. |
| 4 | `requested_end_time` must be greater than `requested_start_time`. |

### 5.2 Space Availability Constraints

| Rule | Statement |
|------|-----------|
| 2 | Spaces with `current_status` of under_maintenance, temporarily_closed, or retired cannot be booked. |
| 3 | Spaces with active maintenance records (i.e., MAINTENANCE_RECORD rows with a non-completed status) cannot be booked. |

> **Clarification — Rules 2 vs. 3:** These rules enforce space unavailability through two distinct mechanisms. Rule 2 is a **status-field check**: the system reads the `current_status` column on the SPACE entity and rejects bookings when the value is `Under Maintenance`, `Temporarily Closed`, or `Retired`. Rule 3 is a **record-existence check**: the system queries the MAINTENANCE_RECORD table for active (non-completed) rows linked to the space and rejects bookings if any exist. Both rules must be enforced independently — a space could have `current_status = Available` yet still have an active maintenance record, or conversely have `current_status = Under Maintenance` with no corresponding maintenance record yet created. Enforcing both ensures comprehensive protection.

### 5.3 Approval Rules

| Rule | Statement |
|------|-----------|
| 5 | BOOKING_APPROVAL is optional and at most one per BOOKING_REQUEST. |
| 7 | Rejected bookings must preserve `rejection_reason`. |

### 5.4 Usage Session Rules

| Rule | Statement |
|------|-----------|
| 6 | USAGE_SESSION is optional and at most one per BOOKING_REQUEST. |
| 8 | Check-in records must preserve: `actual_start_time`, `checked_in_by_user_id`, `initial_condition`. |
| 9 | Completion records must preserve: `actual_end_time`, `completed_by_user_id`, `final_condition`, `usage_notes`. |

### 5.5 Data Integrity Rules

| Rule | Statement |
|------|-----------|
| 10 | Historical data must be preserved. Do not use hard deletes. |
| 11 | Every user must have a university account. |

## 6. Role-Action Matrix

The following matrix summarizes which actors are authorized to perform key system actions, based on the actor descriptions in the project description.

| Action | Student | Lecturer | Teaching Assistant | Facility Staff | Dept. Administrator | Facility Manager |
|--------|:-------:|:--------:|:-----------------:|:--------------:|:-------------------:|:----------------:|
| Submit booking request | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Approve/Reject booking | | | | ✓ | | ✓ |
| Perform check-in | | | | ✓ | | ✓ |
| Record completion | | | | ✓ | | ✓ |
| Report maintenance issue | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Assign maintenance staff | | | | | | ✓ |
| Perform maintenance work | | | | ✓ | | |
| View staff reports | | | | ✓ | ✓ | ✓ |
| Manage space records | | | | ✓ | | ✓ |
| Cancel own booking | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

## 7. Staff View/Reporting Requirements

The project description explicitly states that staff should be able to view the following information. These are functional requirements that the system must support.

| # | View/Report | Description |
|---|-------------|-------------|
| 1 | **Booking History** | A complete historical record of all past bookings, including their statuses, associated spaces, requesters, and outcomes. Supports auditing and usage analysis. |
| 2 | **Upcoming Bookings** | A list of all future approved bookings that have not yet been checked in or completed. Enables staff to prepare spaces and anticipate demand. |
| 3 | **Spaces Under Maintenance** | A view of all spaces currently undergoing maintenance, including the associated maintenance records, assigned staff, and problem descriptions. Prevents accidental booking of unavailable spaces. |
| 4 | **No-show Bookings** | A list of approved bookings where the requester did not check in within the expected time. Supports policy enforcement and identification of habitual no-shows. |

Additionally, the project description states that the system should keep **historical records of bookings and maintenance activities**, ensuring that completed, cancelled, and expired records are retained for auditing purposes.

## 8. Workflow/Lifecycle Descriptions

### 8.1 Booking Lifecycle

The booking process follows a defined state transition path from submission to final outcome:

```
Submit Request
     │
     ▼
  PENDING ──────────────────────┐
     │                          │
     ▼                          ▼
  APPROVED                  REJECTED
     │                     (rejection_reason
     │                      preserved)
     ├──────────┐
     │          │
     ▼          ▼
 CHECKED IN   NO-SHOW
     │       (requester did
     │        not check in)
     ▼
 COMPLETED
(final_condition,
 usage_notes recorded)
```

**State Transitions:**

1. **Submit → Pending:** A user submits a booking request. The system validates that no time conflict exists and the space is available. The booking enters `Pending` status.
2. **Pending → Approved:** Authorized staff (Facility Staff or Facility Manager) reviews and approves the request. A BOOKING_APPROVAL record is created with the decision details.
3. **Pending → Rejected:** Authorized staff rejects the request. A BOOKING_APPROVAL record is created with the `rejection_reason` preserved (Rule 7).
4. **Pending → Cancelled:** The requester or staff cancels the booking before a decision is made.
5. **Approved → Checked In:** At the scheduled time, staff performs check-in. A USAGE_SESSION record is created with `actual_start_time`, `checked_in_by_user_id`, and `initial_condition` (Rule 8).
6. **Approved → No-show:** The approved booking time passes without a check-in. The booking is marked as `No-show`.
7. **Approved → Cancelled:** The requester or staff cancels the booking after approval but before check-in.
8. **Checked In → Completed:** The session ends. Staff records `actual_end_time`, `completed_by_user_id`, `final_condition`, and `usage_notes` in the USAGE_SESSION (Rule 9).

### 8.2 Maintenance Lifecycle

The maintenance process tracks an issue from initial report through resolution:

```
Report Issue
     │
     ▼
  REPORTED
     │
     ▼
  ASSIGNED
  (staff member
   assigned)
     │
     ▼
 IN PROGRESS
  (start_time
   recorded)
     │
     ▼
 COMPLETED
 (completion_time,
  result_note recorded)
```

**State Transitions:**

1. **Report → Reported:** Any user reports a maintenance problem for a space. A MAINTENANCE_RECORD is created with the `reporter_user_id`, `space_code`, and `problem_description`.
2. **Reported → Assigned:** A Facility Manager assigns a staff member to the issue. The `assigned_staff_user_id` is recorded.
3. **Assigned → In Progress:** The assigned staff begins work. The `start_time` is recorded. While active, this record may block new bookings for the space (Rule 3).
4. **In Progress → Completed:** The maintenance work is finished. The `completion_time` and `result_note` are recorded. The space may return to `Available` status.

## 9. Assumptions

The following assumptions are inferred from the project description. They are not explicitly stated but are necessary for a consistent system design.

| # | Assumption | Rationale |
|---|-----------|-----------|
| 1 | Each user belongs to exactly one department. | The `department` attribute is a single field on USER, not a many-to-many relationship. |
| 2 | Each user has exactly one role. | The `role` attribute is a single field on USER. The project description does not mention users holding multiple roles simultaneously. |
| 3 | Booking times are specified with date and time (datetime), not date-only. | The project description refers to "Requested Start Time" and "Requested End Time" implying datetime precision, and overlap checks require time-level granularity. |
| 4 | A facility item belongs to exactly one space. | The FACILITY entity has a single `space_code` FK. Shared equipment across spaces is not modeled. |
| 5 | Only authorized staff (Facility Staff, Facility Manager) can approve or reject bookings. | The project description states "facility staff" check availability and make decisions. Department Administrators oversee usage but are not described as approvers. |
| 6 | Check-in and completion are performed by staff, not by the booking requester. | The USAGE_SESSION attributes `checked_in_by_user_id` and `completed_by_user_id` are FK → USER referencing staff members, and the project description describes these as facility staff actions. |
| 7 | A booking request is for a single contiguous time block in a single space. | Each BOOKING_REQUEST has one `space_code`, one `requested_start_time`, and one `requested_end_time`. Multi-space or multi-slot bookings are not supported. |
| 8 | The "No-show" status is determined after the scheduled start time has passed without a check-in. | The project description mentions "No-show Bookings" as a staff view but does not specify the exact trigger mechanism. |
| 9 | Maintenance problems are described as free-text with common categories, not a strict enumeration. | The `problem_description` attribute is a text field. The listed problem types (Broken Projectors, Air-conditioning Failure, etc.) are common examples, not a closed set. |
| 10 | "Account Status" tracks whether a user's account is active or inactive, supporting soft-delete of users. | Combined with Rule 10 (no hard deletes), inactive accounts are preserved for historical reference. |

## 10. Scope Boundaries

### In-Scope

The following capabilities are within the scope of this system:

- **Space booking management** — submitting, approving, rejecting, and cancelling booking requests for shared campus spaces.
- **Conflict detection** — preventing overlapping approved bookings for the same space.
- **Space status enforcement** — blocking bookings for spaces that are under maintenance, temporarily closed, or retired.
- **Approval workflow** — recording staff decisions (approve/reject) with decision notes and rejection reasons.
- **Usage session tracking** — recording check-in and completion details including actual times, space conditions, and staff involved.
- **Maintenance management** — reporting, assigning, tracking, and completing maintenance issues for spaces.
- **Facility inventory** — tracking which facility items (projectors, whiteboards, etc.) are installed in each space.
- **Staff reporting** — providing views for booking history, upcoming bookings, spaces under maintenance, and no-show bookings.
- **Historical data preservation** — retaining all booking and maintenance records for auditing (no hard deletes).
- **User management** — storing user profiles with roles, departments, and account status.

### Out-of-Scope

The following are explicitly outside the scope of this system:

- **Billing and payment processing** — no financial transactions or fee calculations for space usage.
- **Notification and alerting** — no email, SMS, or push notifications to users about booking status changes or reminders.
- **External calendar integration** — no synchronization with Google Calendar, Outlook, or other external calendar systems.
- **Recurring/repeating bookings** — each booking is a single instance; no support for recurring weekly or daily patterns.
- **Authentication and authorization enforcement** — the system stores user roles but does not implement login, password management, or session-based access control.
- **Room scheduling optimization** — no AI/algorithmic recommendations for optimal space allocation.
- **Equipment checkout/lending** — facility items are tracked as installed in spaces, not as lendable assets.
- **Multi-campus management** — the system serves the School of Computer Science; cross-school or cross-campus coordination is not modeled.
- **Mobile application** — no dedicated mobile interface; the scope is limited to the database system.
- **Waitlisting** — no queue management for fully booked spaces.

---

## Verification Checklist

| # | Check | Status |
|---|-------|--------|
| 1 | Dedicated "Business Purpose" heading with narrative explanation? | ✅ PASS |
| 2 | Actors exactly as listed: Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, Facility Manager? | ✅ PASS |
| 3 | Zero hallucinated roles? | ✅ PASS |
| 4 | "Every user must have a university account" listed in Business Rules? | ✅ PASS (Rule 11, Section 5.5) |
| 5 | Entity names and attributes match Agent.md? | ✅ PASS |
| 6 | All domain value enumerations listed (Space Types, Space Statuses, Booking Types, Booking Statuses, Facility Examples, Maintenance Problem Types)? | ✅ PASS (Section 4) |
| 7 | Staff view/reporting requirements captured? | ✅ PASS (Section 7) |
| 8 | Booking and maintenance lifecycle workflows described? | ✅ PASS (Section 8) |
| 9 | Assumptions documented? | ✅ PASS (Section 9) |
| 10 | Scope boundaries defined? | ✅ PASS (Section 10) |
| 11 | Business rules categorized (not flat-listed)? | ✅ PASS (Section 5) |
