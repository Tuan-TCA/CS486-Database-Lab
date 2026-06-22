# Business Requirement Analysis — G08

**Sources:** `project_description.md` (Project: Campus Space Management System) and `req/business-requirement.md`

## 1. Business Purpose

The School of Computer Science needs a database system to manage the booking, approval, usage, maintenance, incident reporting, and facility utilization of shared physical spaces (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces). The system replaces the current manual process (email, phone, spreadsheets, shared calendars) and aims to prevent overlapping bookings, prevent booking of unavailable spaces, and preserve usage history.

## 2. Actors / User Roles

| Role | Description |
|------|-------------|
| Student | Can book spaces for activities; requires active university account |
| Lecturer | Can book spaces for teaching, seminars, examinations |
| Teaching Assistant (TA) | Can book spaces for tutorials, assessments, lab sessions |
| Facility Staff | Can approve/reject bookings, check in/complete bookings, manage maintenance |
| Facility Manager | Can approve/reject bookings, oversee maintenance, manage space data, view reports |
| Department Administrator | Can book spaces for administrative events and view usage data |

## 3. Core Entities

| Entity | Description |
|--------|-------------|
| User | Anyone with a university account who interacts with the system |
| Space | A physical bookable room or area on campus |
| Facility | An item of equipment present in a space (projector, whiteboard, microphone, etc.) |
| Space_Facility | Many-to-many link between Space and Facility with quantity tracking |
| Booking | A request to use a space for a specific time period and purpose |
| Booking_Approval | The decision (approve/reject) made by a staff member on a booking |
| Maintenance | A record of a problem reported for a space and its resolution |

## 4. Attributes per Entity

### User
- `user_id` — unique identifier
- `full_name` — user's full name
- `email` — university email address
- `phone` — phone number
- `role` — one of: Student, Lecturer, TA, Facility Staff, Dept Administrator, Facility Manager
- `department` — department name
- `account_status` — Active, Inactive, or Suspended

### Space
- `space_code` — unique space identifier
- `space_name` — descriptive name
- `space_type` — Auditorium, Classroom, Computer Lab, Project Lab, Meeting Room, or Workspace
- `building` — building name
- `floor` — floor number
- `room_number` — room number
- `capacity` — maximum occupancy
- `current_status` — Available, In Use, Under Maintenance, Temporarily Closed, or Retired
- `usage_policy` — policy text

### Facility
- `facility_id` — unique identifier
- `facility_name` — e.g., Projector, Whiteboard, Microphone, Computer, Livestreaming Equipment, Air Conditioner
- `description` — further details

### Space_Facility
- `space_code` — reference to Space
- `facility_id` — reference to Facility
- `quantity` — number of units of this facility in the space

### Booking
- `booking_id` — unique identifier
- `requester_id` — user who submitted the booking
- `space_code` — space being booked
- `requested_start` — requested start datetime
- `requested_end` — requested end datetime
- `purpose` — Lecture, Examination, Seminar, Workshop, Meeting, Student Activity, or Administrative Event
- `expected_participants` — number of expected participants
- `status` — Pending, Approved, Rejected, Cancelled, Checked In, Completed, or No-Show
- `booking_time` — timestamp of submission
- `actual_start_time` — actual check-in time
- `checkin_staff_id` — staff who performed check-in
- `initial_condition` — condition of space at check-in
- `actual_end_time` — actual completion time
- `final_condition` — condition of space at completion
- `usage_notes` — notes from the session

### Booking_Approval
- `approval_id` — unique identifier
- `booking_id` — booking being decided
- `staff_id` — staff member who made the decision
- `decision_time` — when the decision was made
- `decision` — Approved or Rejected
- `decision_note` — optional note
- `rejection_reason` — required when decision is Rejected

### Maintenance
- `maintenance_id` — unique identifier
- `space_code` — affected space
- `reporter_id` — person who reported the problem
- `assigned_staff_id` — staff assigned to resolve it
- `problem_description` — description of the issue
- `start_time` — when the problem was reported
- `completion_time` — when resolved
- `status` — Open, In Progress, Resolved, or Closed
- `result_note` — resolution notes

## 5. Key Relationships and Cardinalities

| Relationship | Cardinality | Notes |
|-------------|-------------|-------|
| User → Booking (submits) | 1:N | A user may submit many bookings |
| Space → Booking (is booked in) | 1:N | A space may have many bookings over time |
| User → Booking_Approval (decides) | 1:N | A staff member may handle many approvals |
| Booking → Booking_Approval | 1:1 | Each booking has zero or one approval record |
| Space → Facility | M:N | Via Space_Facility |
| Space → Maintenance | 1:N | A space may have many maintenance records |
| User → Maintenance (reporter) | 1:N | A user may report many issues |
| User → Maintenance (assigned) | 1:N | A staff member may be assigned to many issues |

## 6. Business Rules

1. A user must have a valid active university account to submit a booking.
2. A space can only be booked if its status is Available or In Use.
3. Two approved bookings for the same space must not have overlapping time periods.
4. A booking must be approved or rejected by a facility staff member or manager before it can proceed to check-in.
5. If a booking is rejected, a rejection reason must be stored.
6. A space under maintenance, temporarily closed, or retired cannot be booked.
7. Check-in records actual start time, staff member, and initial condition of the space.
8. Check-out/completion records actual end time, final condition, and usage notes.
9. Historical records of bookings and maintenance must be preserved (no physical deletion).
10. Facility staff or manager performs check-in and checkout.

## 7. Status Lifecycle

```
Pending → Approved → Checked In → Completed
       ↘ Rejected
       ↘ Cancelled
                       ↘ No-Show (if approved but never checked in)
```

## 8. Assumptions

- Overlapping booking prevention is enforced at the application level (or via a trigger) since SQL Server does not support exclusion constraints declaratively.
- A booking transitions from Approved → Checked In → Completed. No-Show is set after a defined grace period.
- Each booking has at most one approval record. If a booking is rejected and re-submitted, a new booking ID is created.
- `quantity` in Space_Facility defaults to 1.

## 9. Open Questions / Unresolved Items

- Should the system support recurring bookings (e.g., weekly lectures for a full semester)?
- Should there be a maximum booking duration or advance-booking window per space type?
- Should automated notifications be part of the system?
- Should there be separate access control rules (e.g., students cannot book certain spaces)?
- Is there a concept of booking fees or deposits?
- Should cancelled bookings be physically deleted or just marked as Cancelled?
