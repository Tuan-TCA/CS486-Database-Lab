# Section 03: Logical Schema Design

## 1. Table Definitions

### 1.1 USER
| Column | Data Type | PK/FK | UK | Nullability | Constraints |
|--------|-----------|-------|----|-------------|-------------|
| user_id | INT | PK | | NOT NULL | |
| full_name | VARCHAR(100) | | | NOT NULL | |
| email | VARCHAR(100) | | UK | NOT NULL | |
| phone | VARCHAR(20) | | | NULL | |
| role | VARCHAR(50) | | | NOT NULL | CHECK (role IN ('Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager')) |
| department | VARCHAR(100) | | | NULL | |
| account_status | VARCHAR(20) | | | NOT NULL | CHECK (account_status IN ('active', 'inactive', 'suspended')) |

### 1.2 SPACE
| Column | Data Type | PK/FK | UK | Nullability | Constraints |
|--------|-----------|-------|----|-------------|-------------|
| space_code | VARCHAR(20) | PK | | NOT NULL | |
| space_name | VARCHAR(100) | | | NOT NULL | |
| space_type | VARCHAR(50) | | | NOT NULL | CHECK (space_type IN ('Auditorium', 'Classroom', 'Computer Laboratory', 'Project Laboratory', 'Meeting Room', 'Student Workspace')) |
| building | VARCHAR(50) | | | NOT NULL | |
| floor | INT | | | NOT NULL | |
| room_number | VARCHAR(20) | | | NOT NULL | |
| capacity | INT | | | NOT NULL | CHECK (capacity > 0) |
| current_status | VARCHAR(20) | | | NOT NULL | CHECK (current_status IN ('Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired')) |
| usage_policy | VARCHAR(1000) | | | NULL | |

### 1.3 FACILITY
| Column | Data Type | PK/FK | UK | Nullability | Constraints |
|--------|-----------|-------|----|-------------|-------------|
| facility_id | INT | PK | | NOT NULL | |
| space_code | VARCHAR(20) | FK | | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| facility_name | VARCHAR(100) | | | NOT NULL | |
| description | VARCHAR(1000) | | | NULL | |

### 1.4 BOOKING_REQUEST
| Column | Data Type | PK/FK | UK | Nullability | Constraints |
|--------|-----------|-------|----|-------------|-------------|
| booking_id | INT | PK | | NOT NULL | |
| user_id | INT | FK | | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| space_code | VARCHAR(20) | FK | | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| requested_start_time | TIMESTAMP | | | NOT NULL | |
| requested_end_time | TIMESTAMP | | | NOT NULL | |
| purpose | VARCHAR(500) | | | NOT NULL | |
| expected_participants | INT | | | NOT NULL | CHECK (expected_participants > 0) |
| booking_type | VARCHAR(50) | | | NOT NULL | CHECK (booking_type IN ('Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event')) |
| status | VARCHAR(20) | | | NOT NULL | CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-show')) |

### 1.5 BOOKING_APPROVAL
| Column | Data Type | PK/FK | UK | Nullability | Constraints |
|--------|-----------|-------|----|-------------|-------------|
| approval_id | INT | PK | | NOT NULL | |
| booking_id | INT | FK | UK | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| decided_by_user_id | INT | FK | | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| decision_time | TIMESTAMP | | | NOT NULL | |
| decision_note | VARCHAR(1000) | | | NULL | |
| rejection_reason | VARCHAR(1000) | | | NULL | |

### 1.6 USAGE_SESSION
| Column | Data Type | PK/FK | UK | Nullability | Constraints |
|--------|-----------|-------|----|-------------|-------------|
| session_id | INT | PK | | NOT NULL | |
| booking_id | INT | FK | UK | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| actual_start_time | TIMESTAMP | | | NULL | |
| actual_end_time | TIMESTAMP | | | NULL | |
| checked_in_by_user_id | INT | FK | | NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| completed_by_user_id | INT | FK | | NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| initial_condition | VARCHAR(500) | | | NULL | |
| final_condition | VARCHAR(500) | | | NULL | |
| usage_notes | VARCHAR(1000) | | | NULL | |

### 1.7 MAINTENANCE_RECORD
| Column | Data Type | PK/FK | UK | Nullability | Constraints |
|--------|-----------|-------|----|-------------|-------------|
| maintenance_id | INT | PK | | NOT NULL | |
| space_code | VARCHAR(20) | FK | | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| reporter_user_id | INT | FK | | NOT NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| assigned_staff_user_id | INT | FK | | NULL | ON DELETE RESTRICT, ON UPDATE CASCADE |
| problem_description | VARCHAR(1000) | | | NOT NULL | |
| start_time | TIMESTAMP | | | NOT NULL | |
| completion_time | TIMESTAMP | | | NULL | |
| status | VARCHAR(20) | | | NOT NULL | CHECK (status IN ('Reported', 'In Progress', 'Completed')) |
| result_note | VARCHAR(1000) | | | NULL | |

## 2. Table-Level Constraints & Logic

The following business rules apply across rows or require cross-column validation that extends beyond basic data types:

| Rule Source | Constraint Description | Implementation Mechanism |
|-------------|------------------------|--------------------------|
| Rule 4 | `requested_end_time` must be greater than `requested_start_time` | **CHECK Constraint:** `CHECK (requested_end_time > requested_start_time)` applied to `BOOKING_REQUEST` table. |
| Rule 8 | `actual_end_time` must be greater than `actual_start_time` (Inferred) | **CHECK Constraint:** `CHECK (actual_end_time >= actual_start_time)` applied to `USAGE_SESSION` table. |
| Rule 1 | A space cannot have two approved bookings with overlapping time periods. | **Trigger / App Logic:** Requires a `BEFORE INSERT/UPDATE` trigger on `BOOKING_REQUEST` checking for time overlaps where status = 'Approved' and space_code matches. |
| Rule 2 | Spaces with status 'Under Maintenance', 'Temporarily Closed', or 'Retired' cannot be booked. | **Trigger / App Logic:** Requires validation against the `SPACE` table's `current_status` during booking creation. |
| Rule 3 | Spaces with active maintenance records cannot be booked. | **Trigger / App Logic:** Requires querying `MAINTENANCE_RECORD` where status != 'Completed' during booking creation. |

## 3. Assumptions

- **Data Types:** Since `Agent.md` does not specify data types, standard SQL types (`INT` for IDs, `VARCHAR` for strings, `TIMESTAMP` for dates) were inferred based on typical enterprise patterns. Text fields like `purpose` or `decision_note` were given generous bounds (e.g., `VARCHAR(500)` or `VARCHAR(1000)`).
- **Referential Integrity:** Rule 10 demands "No hard deletes." Therefore, all Foreign Keys explicitly use `ON DELETE RESTRICT` (or `NO ACTION`) to prevent cascading deletions. `ON UPDATE CASCADE` is assumed standard practice to allow ID regeneration if ever required.
- **Nullability Logic:** Fields such as `completed_by_user_id` and `actual_end_time` in `USAGE_SESSION` are `NULL`able because a session begins before it is completed. Similarly, `assigned_staff_user_id` is `NULL`able because a maintenance record is initially reported before it is assigned.
