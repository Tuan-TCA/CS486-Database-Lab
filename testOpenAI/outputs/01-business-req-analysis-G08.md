# Business Requirement Analysis — Campus Space Management System

**Group:** G08  
**DBMS:** Microsoft SQL Server  
**Date:** 2026-06-08

---

## 1. Business Purpose

The School of Computer Science needs a database system to manage shared physical spaces (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces). The system replaces the current manual process (email, phone, spreadsheets, shared calendars) to provide fair and efficient space management. Key goals include preventing overlapping bookings, blocking use of unavailable spaces, and preserving usage history.

---

## 2. Actors

| Actor | Description |
|---|---|
| Student | Submits booking requests for student activities and projects |
| Lecturer | Submits booking requests for lectures, exams, seminars, workshops |
| Teaching Assistant | Submits booking requests on behalf of lecturers or for tutorials |
| Facility Staff | Checks in bookings, completes sessions, reports maintenance, can approve/reject requests |
| Department Administrator | Oversees bookings, may approve or reject requests |
| Facility Manager | Manages spaces, maintenance, approvals, and overall utilization |

---

## 3. Entities and Attributes

### 3.1 User
Stores all system users regardless of role.

| Attribute | Type | Description |
|---|---|---|
| UserID | INT | Primary key, unique identifier |
| FullName | NVARCHAR(100) | Full name of the user |
| Email | NVARCHAR(255) | Email address, unique |
| PhoneNumber | NVARCHAR(20) | Contact phone number |
| Role | NVARCHAR(30) | Student, Lecturer, TeachingAssistant, FacilityStaff, DepartmentAdministrator, FacilityManager |
| Department | NVARCHAR(100) | Department affiliation |
| AccountStatus | NVARCHAR(20) | Active, Inactive, Suspended |

### 3.2 Space
Represents a physical room that can be booked.

| Attribute | Type | Description |
|---|---|---|
| SpaceCode | NVARCHAR(20) | Primary key, unique code (e.g., "CS-AUD-101") |
| SpaceName | NVARCHAR(100) | Descriptive name |
| SpaceType | NVARCHAR(30) | Auditorium, Classroom, ComputerLaboratory, ProjectLaboratory, MeetingRoom, StudentWorkspace |
| Building | NVARCHAR(100) | Building name |
| Floor | INT | Floor number |
| RoomNumber | NVARCHAR(20) | Room identifier within the building |
| Capacity | INT | Maximum number of occupants |
| CurrentStatus | NVARCHAR(20) | Available, InUse, UnderMaintenance, TemporarilyClosed, Retired |
| UsagePolicy | NVARCHAR(MAX) | Free-text policy for usage rules |

### 3.3 Facility
Represents equipment or amenities available in spaces.

| Attribute | Type | Description |
|---|---|---|
| FacilityID | INT | Primary key, unique identifier |
| FacilityName | NVARCHAR(50) | Name (e.g., Projector, Whiteboard, Microphone, Computer, LivestreamingEquipment, AirConditioner) |
| Description | NVARCHAR(255) | Optional details |

### 3.4 SpaceFacility
Associates facilities with spaces (M:N relationship).

| Attribute | Type | Description |
|---|---|---|
| SpaceCode | NVARCHAR(20) | Foreign key to Space |
| FacilityID | INT | Foreign key to Facility |
| Quantity | INT | Number of units of this facility in the space |

### 3.5 BookingRequest
Captures requests submitted by users to reserve a space.

| Attribute | Type | Description |
|---|---|---|
| BookingID | INT | Primary key, unique identifier |
| RequesterID | INT | Foreign key to User |
| SpaceCode | NVARCHAR(20) | Foreign key to Space |
| RequestedStartTime | DATETIME2 | Desired start time |
| RequestedEndTime | DATETIME2 | Desired end time |
| Purpose | NVARCHAR(30) | Lecture, Examination, Seminar, Workshop, Meeting, StudentActivity, AdministrativeEvent |
| ExpectedParticipantCount | INT | Number of expected attendees |
| Status | NVARCHAR(20) | Pending, Approved, Rejected, Cancelled, CheckedIn, Completed, NoShow |
| SubmittedAt | DATETIME2 | Timestamp of submission |

### 3.6 BookingApproval
Records approval or rejection decisions for booking requests.

| Attribute | Type | Description |
|---|---|---|
| BookingID | INT | Primary key and foreign key to BookingRequest |
| DecisionMakerID | INT | Foreign key to User (staff who decided) |
| DecisionTime | DATETIME2 | When the decision was made |
| DecisionNote | NVARCHAR(MAX) | Note accompanying the decision |
| RejectionReason | NVARCHAR(MAX) | Required only if status is Rejected |

### 3.7 CheckIn
Records the actual start of a booking session.

| Attribute | Type | Description |
|---|---|---|
| BookingID | INT | Primary key and foreign key to BookingRequest |
| ActualStartTime | DATETIME2 | Actual time the session started |
| CheckedInByStaffID | INT | Foreign key to User (staff who performed check-in) |
| InitialCondition | NVARCHAR(MAX) | Condition of the space at check-in |

### 3.8 Completion
Records the actual end of a booking session.

| Attribute | Type | Description |
|---|---|---|
| BookingID | INT | Primary key and foreign key to BookingRequest |
| ActualEndTime | DATETIME2 | Actual time the session ended |
| FinalCondition | NVARCHAR(MAX) | Condition of the space after use |
| UsageNotes | NVARCHAR(MAX) | Free-text notes about the session |

### 3.9 MaintenanceRecord
Tracks maintenance activities for spaces.

| Attribute | Type | Description |
|---|---|---|
| MaintenanceID | INT | Primary key, unique identifier |
| SpaceCode | NVARCHAR(20) | Foreign key to Space |
| ReporterID | INT | Foreign key to User (who reported the issue) |
| AssignedStaffID | INT | Foreign key to User (staff assigned to fix) |
| ProblemDescription | NVARCHAR(MAX) | Description of the problem |
| StartTime | DATETIME2 | When maintenance started |
| CompletionTime | DATETIME2 | Nullable — when maintenance was completed |
| Status | NVARCHAR(20) | e.g., Reported, InProgress, Completed, Cancelled |
| ResultNote | NVARCHAR(MAX) | Outcome notes |

---

## 4. Relationships

| Relationship | Entity 1 | Entity 2 | Cardinality | Participation |
|---|---|---|---|---|
| Submits | User | BookingRequest | 1 : N | Total on BookingRequest |
| Books | Space | BookingRequest | 1 : N | Total on BookingRequest |
| Contains | Space | Facility | M : N | Total on SpaceFacility |
| Decides | BookingRequest | BookingApproval | 1 : 1 | Partial on BookingApproval |
| MakesDecision | User | BookingApproval | 1 : N | Total on BookingApproval |
| ChecksIn | BookingRequest | CheckIn | 1 : 1 | Partial on CheckIn |
| PerformsCheckIn | User | CheckIn | 1 : N | Partial on CheckIn |
| Completes | BookingRequest | Completion | 1 : 1 | Partial on Completion |
| Has | Space | MaintenanceRecord | 1 : N | Total on MaintenanceRecord |
| Reports | User | MaintenanceRecord | 1 : N | Partial on MaintenanceRecord |
| AssignedTo | User | MaintenanceRecord | 1 : N | Partial on MaintenanceRecord |

---

## 5. Business Rules

1. **No overlapping approved bookings** — The same space cannot have two approved bookings with overlapping time ranges.
2. **Unavailable spaces cannot be booked** — A space with status `Under Maintenance`, `Temporarily Closed`, or `Retired` cannot be selected in a new booking request.
3. **Approval required** — All booking requests require approval from Facility Staff or Facility Manager before they become effective.
4. **Check-in requires approval** — A booking cannot be checked in unless its status is `Approved`.
5. **Completion requires check-in** — A booking cannot be completed unless it has been checked in.
6. **Rejection reason** — If a booking is rejected, a rejection reason must be stored.
7. **Maintenance blocks booking** — A space with an active (non-completed) maintenance record cannot be booked.
8. **History preservation** — Completed bookings and maintenance records are kept indefinitely for historical reporting.

---

## 6. Assumptions

1. A booking request is automatically assigned status `Pending` upon submission.
2. The `DecisionTime` in BookingApproval defaults to the current timestamp if not provided.
3. Only Facility Staff and Facility Manager roles can approve/reject bookings.
4. Only Facility Staff can perform check-in and completion.
5. A booking can be checked in within a grace period (e.g., 30 minutes) after the requested start time; otherwise, it may be marked `NoShow`.
6. A `Cancelled` booking is cancelled by the requester before approval or after approval but before check-in.
7. `SubmittedAt` for BookingRequest defaults to `GETDATE()`.
8. Quantity defaults to 1 in SpaceFacility if not specified.

---

## 7. Open Questions

1. Should there be a separate cancellation reason field, or is the DecisionNote sufficient?
2. Should notification triggers be part of the database (triggers) or handled at the application layer?
3. Can a booking be modified after submission (e.g., time change) or must a new request be submitted?
4. Should there be a recurring booking capability (e.g., weekly lecture series)?
5. Should the system enforce a minimum or maximum booking duration?
6. Should there be a maximum number of active bookings per user?
7. Should check-in and completion require the same staff member or can they differ?
8. Is there a concept of booking fees or penalties for no-shows?
