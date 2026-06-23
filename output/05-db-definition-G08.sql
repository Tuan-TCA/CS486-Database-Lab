-- =====================================================
-- 05-db-definition-G08.sql
-- Campus Space Management System
-- Database Implementation (SQL Server)
-- =====================================================
USE master;

IF DB_ID('campus_space_management') IS NOT NULL
BEGIN
    ALTER DATABASE campus_space_management
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE campus_space_management;
END

CREATE DATABASE campus_space_management;

USE campus_space_management;


-- =====================================================
-- USERS
-- =====================================================

CREATE TABLE USERS (

    user_id VARCHAR(20),

    full_name VARCHAR(100) NOT NULL,

    email VARCHAR(100) NOT NULL,

    phone_number VARCHAR(20),

    role VARCHAR(50) NOT NULL,

    department VARCHAR(100),

    account_status VARCHAR(30)
        NOT NULL
        DEFAULT 'active',

    PRIMARY KEY (user_id),

    UNIQUE (email),

    CHECK (
        role IN (
            'student',
            'lecturer',
            'teaching_assistant',
            'facility_staff',
            'department_administrator',
            'facility_manager'
        )
    ),

    CHECK (
        account_status IN (
            'active',
            'inactive',
            'suspended'
        )
    )
);



-- =====================================================
-- SPACES
-- =====================================================

CREATE TABLE SPACES (

    space_code VARCHAR(20),

    space_name VARCHAR(100) NOT NULL,

    space_type VARCHAR(50) NOT NULL,

    building VARCHAR(50) NOT NULL,

    floor INT NOT NULL,

    room_number VARCHAR(20) NOT NULL,

    capacity INT NOT NULL,

    current_status VARCHAR(30)
        NOT NULL
        DEFAULT 'available',

    usage_policy VARCHAR(MAX),

    PRIMARY KEY (space_code),

    UNIQUE (building, room_number),

    CHECK (capacity > 0),

    CHECK (
        current_status IN (
            'available',
            'in_use',
            'under_maintenance',
            'temporarily_closed',
            'retired'
        )
    )
);



-- =====================================================
-- FACILITY
-- =====================================================

CREATE TABLE FACILITY (

    facility_id VARCHAR(20),

    space_code VARCHAR(20) NOT NULL,

    facility_name VARCHAR(100) NOT NULL,

    description VARCHAR(MAX),

    PRIMARY KEY (facility_id),

    FOREIGN KEY (space_code)
        REFERENCES SPACES(space_code)

);



-- =====================================================
-- BOOKING_REQUEST
-- =====================================================

CREATE TABLE BOOKING_REQUEST (

    booking_id VARCHAR(20),

    user_id VARCHAR(20) NOT NULL,

    space_code VARCHAR(20) NOT NULL,

    requested_start_time DATETIME NOT NULL,

    requested_end_time DATETIME NOT NULL,

    purpose VARCHAR(MAX) NOT NULL,

    expected_participants INT NOT NULL,

    booking_type VARCHAR(50) NOT NULL,

    status VARCHAR(30)
        NOT NULL
        DEFAULT 'pending',

    PRIMARY KEY (booking_id),

    FOREIGN KEY (user_id)
        REFERENCES USERS(user_id),

    FOREIGN KEY (space_code)
        REFERENCES SPACES(space_code),

    CHECK (
        requested_end_time > requested_start_time
    ),

    CHECK (
        expected_participants > 0
    ),

    CHECK (
        booking_type IN (
            'lecture',
            'examination',
            'seminar',
            'workshop',
            'meeting',
            'student_activity',
            'administrative_event'
        )
    ),

    CHECK (
        status IN (
            'pending',
            'approved',
            'rejected',
            'cancelled',
            'checked_in',
            'completed',
            'no_show'
        )
    )


);



-- =====================================================
-- BOOKING_APPROVAL
-- =====================================================

CREATE TABLE BOOKING_APPROVAL (

    approval_id VARCHAR(20),

    booking_id VARCHAR(20) NOT NULL,

    decided_by_user_id VARCHAR(20) NOT NULL,

    decision_time DATETIME NOT NULL,

    decision_note VARCHAR(MAX),

    rejection_reason VARCHAR(MAX),

    PRIMARY KEY (approval_id),

    UNIQUE (booking_id),

    FOREIGN KEY (booking_id)
        REFERENCES BOOKING_REQUEST(booking_id),

    FOREIGN KEY (decided_by_user_id)
        REFERENCES USERS(user_id)

);



-- =====================================================
-- USAGE_SESSION
-- =====================================================

CREATE TABLE USAGE_SESSION (

    session_id VARCHAR(20),

    booking_id VARCHAR(20) NOT NULL,

    actual_start_time DATETIME NOT NULL,

    actual_end_time DATETIME,

    checked_in_by_user_id VARCHAR(20) NOT NULL,

    completed_by_user_id VARCHAR(20),

    initial_condition VARCHAR(MAX),

    final_condition VARCHAR(MAX),

    usage_notes VARCHAR(MAX),

    PRIMARY KEY (session_id),

    UNIQUE (booking_id),

    FOREIGN KEY (booking_id)
        REFERENCES BOOKING_REQUEST(booking_id),

    FOREIGN KEY (checked_in_by_user_id)
        REFERENCES USERS(user_id),

    FOREIGN KEY (completed_by_user_id)
        REFERENCES USERS(user_id),

    CHECK (
        actual_end_time IS NULL
        OR actual_end_time >= actual_start_time
    )
);



-- =====================================================
-- MAINTENANCE_RECORD
-- =====================================================

CREATE TABLE MAINTENANCE_RECORD (

    maintenance_id VARCHAR(20),

    space_code VARCHAR(20) NOT NULL,

    reporter_user_id VARCHAR(20) NOT NULL,

    assigned_staff_user_id VARCHAR(20) NOT NULL,

    problem_description VARCHAR(MAX) NOT NULL,

    start_time DATETIME NOT NULL,

    completion_time DATETIME,

    status VARCHAR(30)
        NOT NULL
        DEFAULT 'pending',

    result_note VARCHAR(MAX),

    PRIMARY KEY (maintenance_id),

    FOREIGN KEY (space_code)
        REFERENCES SPACES(space_code),

    FOREIGN KEY (reporter_user_id)
        REFERENCES USERS(user_id),

    FOREIGN KEY (assigned_staff_user_id)
        REFERENCES USERS(user_id),

    CHECK (
        status IN (
            'pending',
            'in_progress',
            'completed',
            'cancelled'
        )
    ),

    CHECK (
        completion_time IS NULL
        OR completion_time >= start_time
    )
);



-- =====================================================
-- BUSINESS RULES OUTSIDE DDL SCOPE
-- =====================================================


/*

The following business rules cannot be enforced
using standard SQL DDL constraints alone.

They require comparisons across multiple rows,
multiple tables, dynamic system states,
or application-level policies.

These rules would require SQL triggers,
stored procedures, or application logic
in a complete production system.

--------------------------------------------------

1. Prevent overlapping approved bookings
   for the same space.

Reason:

The system must compare a new booking's
requested_start_time and requested_end_time
against ALL existing approved bookings
for the same space.

CHECK constraints only validate values
within the current row and cannot compare
against other rows in the BOOKING_REQUEST table.

--------------------------------------------------

2. Prevent booking spaces whose
   current_status is:

   - under_maintenance
   - temporarily_closed
   - retired

Reason:

This rule requires checking the current
status stored in another table (SPACES)
before allowing insertion or approval
of a booking request.

Standard CHECK constraints cannot
reference values from another table.

--------------------------------------------------

3. Prevent booking spaces that have
   active maintenance records.

Reason:

The system must search the
MAINTENANCE_RECORD table to determine
whether an active maintenance task exists
for the requested space.

This requires cross-table lookups and
possibly checking multiple rows.

Standard DDL cannot perform such checks.

--------------------------------------------------

4. Ensure only Facility Staff
   or Facility Managers
   can approve bookings.

Reason:

The system must verify the role
of decided_by_user_id by looking up
the USERS table.

This is a cross-table validation.

Standard DDL cannot restrict a foreign key
based on another column's value.

--------------------------------------------------

5. Ensure only approved bookings
   can create usage sessions.

Reason:

The system must verify that the
associated BOOKING_REQUEST has:

status = 'approved'

before allowing insertion into
USAGE_SESSION.

This requires checking another table.

Standard DDL cannot enforce this rule.

--------------------------------------------------

6. Ensure a rejected booking
   contains a rejection reason.

Reason:

With the current design, booking status
is stored in BOOKING_REQUEST, while
rejection_reason is stored in
BOOKING_APPROVAL.

This is a cross-table business rule.

Standard CHECK constraints cannot
reference columns from another table.

This rule would require triggers
or application logic.

--------------------------------------------------

7. Preserve historical booking
   and maintenance records.

Reason:

This is a data retention policy,
not a database constraint.

The system must prevent accidental
deletion or overwriting of historical data.

This is usually implemented using:

- application rules
- soft delete mechanisms
- access control policies
- audit logging

It cannot be enforced by standard DDL alone.

*/