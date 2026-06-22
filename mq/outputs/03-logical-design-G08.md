# Logical Database Design — G08

**Sources:** `project_description.md` and `req/business-requirement.md`

## Relational Schema

### Table: User

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | INT | PK, IDENTITY(1,1) | Unique user identifier |
| full_name | NVARCHAR(100) | NOT NULL | User's full name |
| email | NVARCHAR(255) | NOT NULL, UNIQUE | University email address |
| phone | NVARCHAR(20) | NULL | Phone number |
| role | NVARCHAR(30) | NOT NULL, CHECK IN (Student, Lecturer, TA, Facility Staff, Dept Administrator, Facility Manager) | User role |
| department | NVARCHAR(100) | NOT NULL | Department name |
| account_status | NVARCHAR(20) | NOT NULL, DEFAULT 'Active', CHECK IN (Active, Inactive, Suspended) | Account status |

### Table: Space

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| space_code | NVARCHAR(20) | PK | Unique space identifier |
| space_name | NVARCHAR(100) | NOT NULL | Descriptive name |
| space_type | NVARCHAR(30) | NOT NULL, CHECK IN (Auditorium, Classroom, Computer Lab, Project Lab, Meeting Room, Workspace) | Type of space |
| building | NVARCHAR(100) | NOT NULL | Building name |
| floor | INT | NOT NULL | Floor number |
| room_number | NVARCHAR(20) | NOT NULL | Room number |
| capacity | INT | NOT NULL, CHECK (capacity > 0) | Maximum occupancy |
| current_status | NVARCHAR(30) | NOT NULL, DEFAULT 'Available', CHECK IN (Available, In Use, Under Maintenance, Temporarily Closed, Retired) | Current operational status |
| usage_policy | NVARCHAR(MAX) | NULL | Usage policy text |

### Table: Facility

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| facility_id | INT | PK, IDENTITY(1,1) | Unique facility identifier |
| facility_name | NVARCHAR(100) | NOT NULL, UNIQUE | Facility name |
| description | NVARCHAR(MAX) | NULL | Description |

### Table: Space_Facility

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| space_code | NVARCHAR(20) | PK, FK → Space(space_code) | Reference to space |
| facility_id | INT | PK, FK → Facility(facility_id) | Reference to facility |
| quantity | INT | NOT NULL, DEFAULT 1, CHECK (quantity > 0) | Number of units |

PK = (space_code, facility_id)

### Table: Booking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| booking_id | INT | PK, IDENTITY(1,1) | Unique booking identifier |
| requester_id | INT | NOT NULL, FK → User(user_id) | User who submitted the booking |
| space_code | NVARCHAR(20) | NOT NULL, FK → Space(space_code) | Booked space |
| requested_start | DATETIME2 | NOT NULL | Requested start time |
| requested_end | DATETIME2 | NOT NULL, CHECK (requested_end > requested_start) | Requested end time |
| purpose | NVARCHAR(30) | NOT NULL, CHECK IN (Lecture, Examination, Seminar, Workshop, Meeting, Student Activity, Administrative Event) | Purpose of booking |
| expected_participants | INT | NOT NULL, CHECK (expected_participants > 0) | Expected number of participants |
| status | NVARCHAR(20) | NOT NULL, DEFAULT 'Pending', CHECK IN (Pending, Approved, Rejected, Cancelled, Checked In, Completed, No-Show) | Current booking status |
| booking_time | DATETIME2 | NOT NULL, DEFAULT GETDATE() | When the booking was submitted |
| actual_start_time | DATETIME2 | NULL | Actual check-in time |
| checkin_staff_id | INT | NULL, FK → User(user_id) | Staff who checked in the booking |
| initial_condition | NVARCHAR(MAX) | NULL | Condition at check-in |
| actual_end_time | DATETIME2 | NULL | Actual completion time |
| final_condition | NVARCHAR(MAX) | NULL | Condition at completion |
| usage_notes | NVARCHAR(MAX) | NULL | Notes from the session |

### Table: Booking_Approval

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| approval_id | INT | PK, IDENTITY(1,1) | Unique approval identifier |
| booking_id | INT | NOT NULL, UNIQUE, FK → Booking(booking_id) | Booking being decided |
| staff_id | INT | NOT NULL, FK → User(user_id) | Staff who made the decision |
| decision_time | DATETIME2 | NOT NULL, DEFAULT GETDATE() | When decision was made |
| decision | NVARCHAR(10) | NOT NULL, CHECK IN (Approved, Rejected) | Decision outcome |
| decision_note | NVARCHAR(MAX) | NULL | Optional note |
| rejection_reason | NVARCHAR(MAX) | NULL | Reason if rejected (required when decision = Rejected) |

### Table: Maintenance

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| maintenance_id | INT | PK, IDENTITY(1,1) | Unique maintenance identifier |
| space_code | NVARCHAR(20) | NOT NULL, FK → Space(space_code) | Affected space |
| reporter_id | INT | NOT NULL, FK → User(user_id) | Person who reported the issue |
| assigned_staff_id | INT | NULL, FK → User(user_id) | Staff assigned to fix the issue |
| problem_description | NVARCHAR(MAX)   | NOT NULL | Description of the problem |
| problem_type        | NVARCHAR(30)    | NULL, CHECK IN (Broken Projector, AC Failure, Damaged Furniture, Cleaning Issue, Network Problem) | Category of the problem |
| start_time          | DATETIME2       | NOT NULL, DEFAULT GETDATE() | When the problem was reported |
| completion_time | DATETIME2 | NULL | When the issue was resolved |
| status | NVARCHAR(20) | NOT NULL, DEFAULT 'Open', CHECK IN (Open, In Progress, Resolved, Closed) | Maintenance status |
| result_note | NVARCHAR(MAX) | NULL | Resolution notes |

## Candidate Keys

| Table | Candidate Keys | PK Choice |
|-------|---------------|-----------|
| User | user_id, email | user_id |
| Space | space_code | space_code |
| Facility | facility_id, facility_name | facility_id |
| Space_Facility | (space_code, facility_id) | (space_code, facility_id) |
| Booking | booking_id | booking_id |
| Booking_Approval | approval_id, booking_id | approval_id |
| Maintenance | maintenance_id | maintenance_id |

## FK Constraints Summary

| FK Column | Parent Table | Child Table | Notes |
|-----------|-------------|-------------|-------|
| requester_id | User | Booking | User who made the booking |
| space_code | Space | Booking | Space being booked |
| checkin_staff_id | User | Booking | Staff who performed check-in (nullable) |
| booking_id | Booking | Booking_Approval | Booking being decided |
| staff_id | User | Booking_Approval | Staff who made the decision |
| space_code | Space | Space_Facility | Space containing facility |
| facility_id | Facility | Space_Facility | Facility in the space |
| space_code | Space | Maintenance | Space under maintenance |
| reporter_id | User | Maintenance | Person who reported the problem |
| assigned_staff_id | User | Maintenance | Staff assigned to resolve (nullable) |

## Referential Integrity Rules

| Parent Delete | Child | Action |
|---------------|-------|--------|
| User | Booking | RESTRICT |
| User | Booking_Approval | RESTRICT |
| User | Maintenance (reporter) | RESTRICT |
| User | Maintenance (assigned) | SET NULL |
| Space | Booking | RESTRICT |
| Space | Space_Facility | CASCADE |
| Space | Maintenance | RESTRICT |
| Facility | Space_Facility | CASCADE |
| Booking | Booking_Approval | CASCADE |
