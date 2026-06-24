-- ============================================================
-- DATABASE CREATION (idempotent: drop and recreate)
-- ============================================================
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- Drop triggers if they exist
IF OBJECT_ID('trg_PreventOverlappingBooking', 'TR') IS NOT NULL DROP TRIGGER trg_PreventOverlappingBooking;
GO
IF OBJECT_ID('trg_CheckSpaceAvailability', 'TR') IS NOT NULL DROP TRIGGER trg_CheckSpaceAvailability;
GO
IF OBJECT_ID('trg_RequireRejectionReason', 'TR') IS NOT NULL DROP TRIGGER trg_RequireRejectionReason;
GO

-- Drop tables in reverse dependency order
IF OBJECT_ID('MAINTENANCE_RECORD', 'U') IS NOT NULL DROP TABLE MAINTENANCE_RECORD;
IF OBJECT_ID('USAGE_SESSION', 'U') IS NOT NULL DROP TABLE USAGE_SESSION;
IF OBJECT_ID('BOOKING_APPROVAL', 'U') IS NOT NULL DROP TABLE BOOKING_APPROVAL;
IF OBJECT_ID('BOOKING_REQUEST', 'U') IS NOT NULL DROP TABLE BOOKING_REQUEST;
IF OBJECT_ID('FACILITY', 'U') IS NOT NULL DROP TABLE FACILITY;
IF OBJECT_ID('SPACE', 'U') IS NOT NULL DROP TABLE SPACE;
IF OBJECT_ID('USER', 'U') IS NOT NULL DROP TABLE [USER];
GO

-- ============================================================
-- TABLE: USER
-- Stores system users with university accounts.
-- ============================================================
CREATE TABLE [USER] (
    user_id VARCHAR(20) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    role VARCHAR(50) NOT NULL,
    department VARCHAR(100),
    account_status VARCHAR(30) DEFAULT 'Active' NOT NULL,
    
    CONSTRAINT PK_User PRIMARY KEY (user_id),
    CONSTRAINT UQ_User_Email UNIQUE (email),
    CONSTRAINT CHK_User_Role CHECK (role IN ('Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager')),
    CONSTRAINT CHK_User_Status CHECK (account_status IN ('Active', 'Inactive', 'Suspended'))
);
GO

-- ============================================================
-- TABLE: SPACE
-- Stores bookable physical spaces managed by the School.
-- ============================================================
CREATE TABLE SPACE (
    space_code VARCHAR(20) NOT NULL,
    space_name VARCHAR(100) NOT NULL,
    space_type VARCHAR(50) NOT NULL,
    building VARCHAR(50) NOT NULL,
    floor INT,
    room_number VARCHAR(20) NOT NULL,
    capacity INT NOT NULL,
    current_status VARCHAR(30) DEFAULT 'Available' NOT NULL,
    usage_policy VARCHAR(MAX),
    
    CONSTRAINT PK_Space PRIMARY KEY (space_code),
    CONSTRAINT UQ_Space_Building_Room UNIQUE (building, room_number),
    CONSTRAINT CHK_Space_Capacity CHECK (capacity > 0),
    CONSTRAINT CHK_Space_Type CHECK (space_type IN ('Auditorium', 'Classroom', 'Computer Lab', 'Project Lab', 'Meeting Room', 'Student Workspace')),
    CONSTRAINT CHK_Space_Status CHECK (current_status IN ('Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired'))
);
GO

-- ============================================================
-- TABLE: FACILITY
-- Stores equipment/features available in spaces.
-- ============================================================
CREATE TABLE FACILITY (
    facility_id VARCHAR(20) NOT NULL,
    space_code VARCHAR(20) NOT NULL,
    facility_name VARCHAR(100) NOT NULL,
    description VARCHAR(MAX),
    
    CONSTRAINT PK_Facility PRIMARY KEY (facility_id),
    CONSTRAINT FK_Facility_Space FOREIGN KEY (space_code) REFERENCES SPACE(space_code) ON DELETE CASCADE
);
GO

-- ============================================================
-- TABLE: BOOKING_REQUEST
-- Stores user requests to book a space.
-- ============================================================
CREATE TABLE BOOKING_REQUEST (
    booking_id VARCHAR(20) NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    space_code VARCHAR(20) NOT NULL,
    requested_start_time DATETIME NOT NULL,
    requested_end_time DATETIME NOT NULL,
    purpose VARCHAR(MAX),
    expected_participants INT NOT NULL,
    booking_type VARCHAR(50) NOT NULL,
    status VARCHAR(30) DEFAULT 'Pending' NOT NULL,
    
    CONSTRAINT PK_BookingRequest PRIMARY KEY (booking_id),
    CONSTRAINT FK_BookingRequest_User FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_BookingRequest_Space FOREIGN KEY (space_code) REFERENCES SPACE(space_code) ON DELETE NO ACTION,
    CONSTRAINT CHK_BookingRequest_Time CHECK (requested_end_time > requested_start_time),
    CONSTRAINT CHK_BookingRequest_Participants CHECK (expected_participants > 0),
    CONSTRAINT CHK_BookingRequest_Type CHECK (booking_type IN ('Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event')),
    CONSTRAINT CHK_BookingRequest_Status CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-Show'))
);
GO

-- ============================================================
-- TABLE: BOOKING_APPROVAL
-- Stores approval/rejection decisions on bookings.
-- ============================================================
CREATE TABLE BOOKING_APPROVAL (
    approval_id VARCHAR(20) NOT NULL,
    booking_id VARCHAR(20) NOT NULL,
    decided_by_user_id VARCHAR(20) NOT NULL,
    decision_time DATETIME DEFAULT GETDATE() NOT NULL,
    decision_note VARCHAR(MAX),
    rejection_reason VARCHAR(MAX),
    
    CONSTRAINT PK_BookingApproval PRIMARY KEY (approval_id),
    CONSTRAINT UQ_BookingApproval_Booking UNIQUE (booking_id),
    CONSTRAINT FK_BookingApproval_Booking FOREIGN KEY (booking_id) REFERENCES BOOKING_REQUEST(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_BookingApproval_User FOREIGN KEY (decided_by_user_id) REFERENCES [USER](user_id) ON DELETE NO ACTION
);
GO

-- ============================================================
-- TABLE: USAGE_SESSION
-- Stores actual usage session (check-in/check-out) details.
-- ============================================================
CREATE TABLE USAGE_SESSION (
    session_id VARCHAR(20) NOT NULL,
    booking_id VARCHAR(20) NOT NULL,
    actual_start_time DATETIME NOT NULL,
    actual_end_time DATETIME,
    checked_in_by_user_id VARCHAR(20) NOT NULL,
    completed_by_user_id VARCHAR(20),
    initial_condition VARCHAR(MAX),
    final_condition VARCHAR(MAX),
    usage_notes VARCHAR(MAX),
    
    CONSTRAINT PK_UsageSession PRIMARY KEY (session_id),
    CONSTRAINT UQ_UsageSession_Booking UNIQUE (booking_id),
    CONSTRAINT FK_UsageSession_Booking FOREIGN KEY (booking_id) REFERENCES BOOKING_REQUEST(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_UsageSession_CheckInUser FOREIGN KEY (checked_in_by_user_id) REFERENCES [USER](user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_UsageSession_CompleteUser FOREIGN KEY (completed_by_user_id) REFERENCES [USER](user_id) ON DELETE NO ACTION,
    CONSTRAINT CHK_UsageSession_Time CHECK (actual_end_time IS NULL OR actual_end_time >= actual_start_time)
);
GO

-- ============================================================
-- TABLE: MAINTENANCE_RECORD
-- Stores maintenance activities on spaces.
-- ============================================================
CREATE TABLE MAINTENANCE_RECORD (
    maintenance_id VARCHAR(20) NOT NULL,
    space_code VARCHAR(20) NOT NULL,
    reporter_user_id VARCHAR(20) NOT NULL,
    assigned_staff_user_id VARCHAR(20),
    problem_description VARCHAR(MAX) NOT NULL,
    start_time DATETIME NOT NULL,
    completion_time DATETIME,
    status VARCHAR(30) DEFAULT 'Open' NOT NULL,
    result_note VARCHAR(MAX),
    
    CONSTRAINT PK_MaintenanceRecord PRIMARY KEY (maintenance_id),
    CONSTRAINT FK_MaintenanceRecord_Space FOREIGN KEY (space_code) REFERENCES SPACE(space_code) ON DELETE NO ACTION,
    CONSTRAINT FK_MaintenanceRecord_Reporter FOREIGN KEY (reporter_user_id) REFERENCES [USER](user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_MaintenanceRecord_Assigned FOREIGN KEY (assigned_staff_user_id) REFERENCES [USER](user_id) ON DELETE SET NULL,
    CONSTRAINT CHK_MaintenanceRecord_Status CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed'))
);
GO

-- ============================================================
-- INDEXES
-- ============================================================

CREATE NONCLUSTERED INDEX IX_BookingRequest_Space_Time 
ON BOOKING_REQUEST(space_code, requested_start_time, requested_end_time)
WHERE status IN ('Approved', 'Checked In');
GO

CREATE NONCLUSTERED INDEX IX_BookingRequest_User ON BOOKING_REQUEST(user_id);
GO
CREATE NONCLUSTERED INDEX IX_BookingApproval_Decider ON BOOKING_APPROVAL(decided_by_user_id);
GO
CREATE NONCLUSTERED INDEX IX_Maintenance_Space ON MAINTENANCE_RECORD(space_code);
GO

-- ============================================================
-- TRIGGERS
-- ============================================================

CREATE TRIGGER trg_PreventOverlappingBooking
ON BOOKING_REQUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BOOKING_REQUEST b ON i.space_code = b.space_code
        WHERE i.status IN ('Approved', 'Checked In')
          AND b.status IN ('Approved', 'Checked In', 'Completed')
          AND b.booking_id <> i.booking_id
          AND i.requested_start_time < b.requested_end_time
          AND i.requested_end_time > b.requested_start_time
    )
    BEGIN
        RAISERROR ('Overlapping booking detected.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

CREATE TRIGGER trg_CheckSpaceAvailability
ON BOOKING_REQUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SPACE s ON i.space_code = s.space_code
        WHERE i.status IN ('Pending', 'Approved')
          AND s.current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
    )
    BEGIN
        RAISERROR ('Cannot book a space that is under maintenance, temporarily closed, or retired.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

CREATE TRIGGER trg_RequireRejectionReason
ON BOOKING_APPROVAL
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BOOKING_REQUEST br ON i.booking_id = br.booking_id
        WHERE br.status = 'Rejected'
          AND (i.rejection_reason IS NULL OR LTRIM(RTRIM(i.rejection_reason)) = '')
    )
    BEGIN
        RAISERROR ('A rejection reason is required when rejecting a booking.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO
