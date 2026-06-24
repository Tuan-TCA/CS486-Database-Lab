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
-- SPACE
-- =====================================================

CREATE TABLE SPACE (

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
        REFERENCES SPACE(space_code)

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
        REFERENCES SPACE(space_code),

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
        REFERENCES SPACE(space_code),

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
using SQL DDL constraints alone because they
require comparisons across multiple rows,
multiple tables, or dynamic system states.

These rules would require SQL triggers
or application-level logic in a complete
production system.

1. Prevent overlapping approved bookings
   for the same space.

2. Prevent booking spaces whose
   current_status is:

   - under_maintenance
   - temporarily_closed
   - retired

3. Prevent booking spaces that have
   active maintenance records.

4. Ensure only Facility Staff
   or Facility Managers
   can approve bookings.

5. Ensure only approved bookings
   can create usage sessions.

6. Ensure a rejected booking
   contains a rejection reason.

7. Preserve historical booking
   and maintenance records.

*/