# 03-logical-design-G08.md

# Logical Database Design

## 1. Relational Schema

Below is the logical relational schema mapped directly from the ER Diagram.

- **Primary Keys (PK)** are marked in **bold**.
- _Foreign Keys (FK)_ are marked in _italics_.

- **USER** (**user_id**, full_name, email, phone_number, role, department, account_status)

- **SPACE** (**space_code**, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)

- **FACILITY** (**facility_id**, _space_code_, facility_name, description)

- **BOOKING_REQUEST** (**booking_id**, _user_id_, _space_code_, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)

- **BOOKING_APPROVAL** (**approval_id**, _booking_id_, _decided_by_user_id_, decision_time, decision_note, rejection_reason)

- **USAGE_SESSION** (**session_id**, _booking_id_, actual_start_time, actual_end_time, _checked_in_by_user_id_, _completed_by_user_id_, initial_condition, final_condition, usage_notes)

- **MAINTENANCE_RECORD** (**maintenance_id**, _space_code_, _reporter_user_id_, _assigned_staff_user_id_, problem_description, start_time, completion_time, status, result_note)

---

## 2. Logical Design Dictionary & Key Constraints

### 2.1 USER

| Attribute | Data Type | Constraint | Description |
|-----------|-----------|------------|-------------|
| **user_id** | VARCHAR | **Primary Key** | Unique identifier for the user's university account |
| full_name | VARCHAR | Not Null | User's full name |
| email | VARCHAR | Not Null, **Candidate Key** | User's email address (must be unique) |
| phone_number | VARCHAR | Nullable | User's contact number |
| role | VARCHAR | Not Null | User's role (e.g., Student, Lecturer) |
| department | VARCHAR | Nullable | Department the user belongs to |
| account_status | VARCHAR | Not Null | Current status of the account |

### 2.2 SPACE

| Attribute | Data Type | Constraint | Description |
|-----------|-----------|------------|-------------|
| **space_code** | VARCHAR | **Primary Key** | Unique system code for the physical space |
| space_name | VARCHAR | Not Null | Descriptive name of the space |
| space_type | VARCHAR | Not Null | Category (e.g., Classroom, Lab) |
| building | VARCHAR | Not Null | Building name or code |
| floor | INT | Not Null | Floor number |
| room_number | VARCHAR | Not Null | Room number (Unique within a building) |
| capacity | INT | Not Null | Maximum participants allowed |
| current_status | VARCHAR | Not Null | Current operational status |
| usage_policy | TEXT | Nullable | Specific rules for using the space |

**Composite Candidate Key:** (building, room_number)

**Composite Candidate Key:** (building, room_number)

### 2.3 FACILITY

| Attribute | Data Type | Constraint | Description |
|-----------|-----------|------------|-------------|
| **facility_id** | VARCHAR | **Primary Key** | Unique identifier for the facility |
| _space_code_ | VARCHAR | **Foreign Key** | References `SPACE(space_code)` |
| facility_name | VARCHAR | Not Null | Name of the equipment/feature |
| description | TEXT | Nullable | Details about the facility |

### 2.4 BOOKING_REQUEST

| Attribute | Data Type | Constraint | Description |
|-----------|-----------|------------|-------------|
| **booking_id** | VARCHAR | **Primary Key** | Unique identifier for the booking |
| _user_id_ | VARCHAR | **Foreign Key** | References `USER(user_id)` (Submitter) |
| _space_code_ | VARCHAR | **Foreign Key** | References `SPACE(space_code)` |
| requested_start_time | DATETIME | Not Null | Requested start date and time |
| requested_end_time | DATETIME | Not Null | Requested end date and time |
| purpose | TEXT | Not Null | Reason for booking |
| expected_participants | INT | Not Null | Estimated turnout |
| booking_type | VARCHAR | Not Null | Event type (e.g., Seminar, Examination) |
| status | VARCHAR | Not Null | Current state of the booking request |

### 2.5 BOOKING_APPROVAL

| Attribute | Data Type | Constraint | Description |
|-----------|-----------|------------|-------------|
| **approval_id** | VARCHAR | **Primary Key** | Unique identifier for the approval record |
| _booking_id_ | VARCHAR | **Foreign Key**, **Candidate Key** | References `BOOKING_REQUEST(booking_id)`. **UNIQUE** constraint enforces at most one approval per booking request |
| _decided_by_user_id_ | VARCHAR | **Foreign Key** | References `USER(user_id)` (Staff member) |
| decision_time | DATETIME | Not Null | When the decision was made |
| decision_note | TEXT | Nullable | Notes accompanying the decision |
| rejection_reason | TEXT | Nullable | Reason for rejection (if applicable) |

### 2.6 USAGE_SESSION

| Attribute | Data Type | Constraint | Description |
|-----------|-----------|------------|-------------|
| **session_id** | VARCHAR | **Primary Key** | Unique identifier for the actual session |
| _booking_id_ | VARCHAR | **Foreign Key**, **Candidate Key** | References `BOOKING_REQUEST(booking_id)`. **UNIQUE** constraint enforces at most one usage session per booking request |
| actual_start_time | DATETIME | Not Null | Check-in timestamp |
| actual_end_time | DATETIME | Nullable | Check-out timestamp |
| _checked_in_by_user_id_ | VARCHAR | **Foreign Key** | References `USER(user_id)` (Check-in staff) |
| _completed_by_user_id_ | VARCHAR | **Foreign Key** | References `USER(user_id)` (Check-out staff) |
| initial_condition | TEXT | Not Null | Space condition at start |
| final_condition | TEXT | Nullable | Space condition at end |
| usage_notes | TEXT | Nullable | Incidents or notes during the session |

### 2.7 MAINTENANCE_RECORD

| Attribute | Data Type | Constraint | Description |
|-----------|-----------|------------|-------------|
| **maintenance_id** | VARCHAR | **Primary Key** | Unique identifier for maintenance log |
| _space_code_ | VARCHAR | **Foreign Key** | References `SPACE(space_code)` |
| _reporter_user_id_ | VARCHAR | **Foreign Key** | References `USER(user_id)` (Reporter) |
| _assigned_staff_user_id_ | VARCHAR | **Foreign Key** | References `USER(user_id)` (Assigned staff) |
| problem_description | TEXT | Not Null | Details of the maintenance issue |
| start_time | DATETIME | Not Null | Maintenance start timestamp |
| completion_time | DATETIME | Nullable | Maintenance completion timestamp |
| status | VARCHAR | Not Null | Current state of maintenance |
| result_note | TEXT | Nullable | Resolution details |