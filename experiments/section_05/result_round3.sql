-- ============================================================
-- DATABASE CREATION (idempotent: drop and recreate)
-- ============================================================
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
-- ============================================================
CREATE TABLE [USER] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager')),
    department VARCHAR(100) NULL,
    account_status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (account_status IN ('Active', 'Inactive', 'Suspended'))
);
GO

-- ============================================================
-- TABLE: SPACE
-- ============================================================
CREATE TABLE SPACE (
    space_code VARCHAR(20) PRIMARY KEY,
    space_name VARCHAR(100) NOT NULL,
    space_type VARCHAR(50) NOT NULL CHECK (space_type IN ('Auditorium', 'Classroom', 'Computer Laboratory', 'Project Laboratory', 'Meeting Room', 'Student Workspace')),
    building VARCHAR(50) NOT NULL,
    floor INT NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    current_status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (current_status IN ('Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired')),
    usage_policy VARCHAR(1000) NULL
);
GO

-- ============================================================
-- TABLE: FACILITY
-- ============================================================
CREATE TABLE FACILITY (
    facility_id INT IDENTITY(1,1) PRIMARY KEY,
    space_code VARCHAR(20) NOT NULL,
    facility_name VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NULL,
    CONSTRAINT FK_Facility_Space FOREIGN KEY (space_code) REFERENCES SPACE(space_code) ON DELETE CASCADE
);
GO

-- ============================================================
-- TABLE: BOOKING_REQUEST
-- ============================================================
CREATE TABLE BOOKING_REQUEST (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    space_code VARCHAR(20) NOT NULL,
    requested_start_time DATETIME NOT NULL,
    requested_end_time DATETIME NOT NULL,
    purpose VARCHAR(500) NOT NULL,
    expected_participants INT NOT NULL CHECK (expected_participants > 0),
    booking_type VARCHAR(50) NOT NULL CHECK (booking_type IN ('Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event')),
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-show')),
    CONSTRAINT CHK_BookingTime Valid CHECK (requested_end_time > requested_start_time),
    CONSTRAINT FK_Booking_User FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Booking_Space FOREIGN KEY (space_code) REFERENCES SPACE(space_code) ON DELETE RESTRICT
);
GO

-- ============================================================
-- TABLE: BOOKING_APPROVAL
-- ============================================================
CREATE TABLE BOOKING_APPROVAL (
    approval_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    decided_by_user_id INT NOT NULL,
    decision_time DATETIME NOT NULL DEFAULT GETDATE(),
    decision_note VARCHAR(1000) NULL,
    rejection_reason VARCHAR(1000) NULL,
    CONSTRAINT FK_Approval_Booking FOREIGN KEY (booking_id) REFERENCES BOOKING_REQUEST(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_Approval_Decider FOREIGN KEY (decided_by_user_id) REFERENCES [USER](user_id) ON DELETE RESTRICT
);
GO

-- ============================================================
-- TABLE: USAGE_SESSION
-- ============================================================
CREATE TABLE USAGE_SESSION (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    actual_start_time DATETIME NULL,
    actual_end_time DATETIME NULL,
    checked_in_by_user_id INT NULL,
    completed_by_user_id INT NULL,
    initial_condition VARCHAR(500) NULL,
    final_condition VARCHAR(500) NULL,
    usage_notes VARCHAR(1000) NULL,
    -- BUG FIX: Ensured actual_start_time cannot be NULL if actual_end_time is populated
    CONSTRAINT CHK_SessionTime Valid CHECK (actual_end_time IS NULL OR (actual_start_time IS NOT NULL AND actual_end_time >= actual_start_time)),
    CONSTRAINT FK_Session_Booking FOREIGN KEY (booking_id) REFERENCES BOOKING_REQUEST(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_Session_CheckIn FOREIGN KEY (checked_in_by_user_id) REFERENCES [USER](user_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Session_Complete FOREIGN KEY (completed_by_user_id) REFERENCES [USER](user_id) ON DELETE RESTRICT
);
GO

-- ============================================================
-- TABLE: MAINTENANCE_RECORD
-- ============================================================
CREATE TABLE MAINTENANCE_RECORD (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    space_code VARCHAR(20) NOT NULL,
    reporter_user_id INT NOT NULL,
    assigned_staff_user_id INT NULL,
    problem_description VARCHAR(1000) NOT NULL,
    start_time DATETIME NOT NULL,
    completion_time DATETIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed')),
    result_note VARCHAR(1000) NULL,
    CONSTRAINT FK_Maintenance_Space FOREIGN KEY (space_code) REFERENCES SPACE(space_code) ON DELETE RESTRICT,
    CONSTRAINT FK_Maintenance_Reporter FOREIGN KEY (reporter_user_id) REFERENCES [USER](user_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Maintenance_Staff FOREIGN KEY (assigned_staff_user_id) REFERENCES [USER](user_id) ON DELETE SET NULL
);
GO

-- ============================================================
-- INDEXES
-- ============================================================
CREATE NONCLUSTERED INDEX IX_BookingRequest_User ON BOOKING_REQUEST(user_id);
GO
CREATE NONCLUSTERED INDEX IX_BookingApproval_Decider ON BOOKING_APPROVAL(decided_by_user_id);
GO
CREATE NONCLUSTERED INDEX IX_Maintenance_Space ON MAINTENANCE_RECORD(space_code);
GO
CREATE NONCLUSTERED INDEX IX_BookingRequest_Space_Time 
ON BOOKING_REQUEST(space_code, requested_start_time, requested_end_time)
WHERE status IN ('Approved', 'Checked In');
GO

-- ============================================================
-- TRIGGERS
-- ============================================================

-- 1. trg_PreventOverlappingBooking
CREATE TRIGGER trg_PreventOverlappingBooking
ON BOOKING_REQUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BOOKING_REQUEST existing ON i.space_code = existing.space_code
        WHERE i.status IN ('Approved', 'Checked In')
          AND i.booking_id <> existing.booking_id
          AND existing.status IN ('Approved', 'Checked In', 'Completed')
          AND i.requested_start_time < existing.requested_end_time
          AND i.requested_end_time > existing.requested_start_time
    )
    BEGIN
        RAISERROR ('Booking time overlaps with an existing approved booking.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 2. trg_CheckSpaceAvailability (Child to Parent Validation)
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
        RAISERROR ('Cannot book a space that is unavailable.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 3. trg_RequireRejectionReason
-- BUG FIX: Moved to BOOKING_REQUEST to prevent transaction order bypasses.
CREATE TRIGGER trg_RequireRejectionReason
ON BOOKING_REQUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN BOOKING_APPROVAL ba ON i.booking_id = ba.booking_id
        WHERE i.status = 'Rejected'
          AND (ba.rejection_reason IS NULL OR LTRIM(RTRIM(ba.rejection_reason)) = '')
    )
    BEGIN
        RAISERROR ('Rejection reason is required when a booking is rejected. Provide approval record first.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 4. trg_PreventMaintenanceWithActiveBookings (Parent to Child Validation)
-- BUG FIX: New trigger to prevent SPACE from going down while bookings exist.
CREATE TRIGGER trg_PreventMaintenanceWithActiveBookings
ON SPACE
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BOOKING_REQUEST br ON i.space_code = br.space_code
        WHERE i.current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
          AND br.status IN ('Approved', 'Checked In')
    )
    BEGIN
        RAISERROR ('Cannot put space under maintenance; it has active approved bookings.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
