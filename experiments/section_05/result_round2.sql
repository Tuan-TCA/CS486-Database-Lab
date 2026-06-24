-- ============================================================
-- DATABASE CREATION (idempotent: drop and recreate)
-- ============================================================

-- Drop triggers first (they depend on tables)
IF OBJECT_ID('dbo.trg_RequireRejectionReason', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_RequireRejectionReason;
GO
IF OBJECT_ID('dbo.trg_CheckSpaceAvailability', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_CheckSpaceAvailability;
GO
IF OBJECT_ID('dbo.trg_PreventOverlappingBooking', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_PreventOverlappingBooking;
GO

-- Drop tables in reverse dependency order (indexes drop automatically)
DROP TABLE IF EXISTS dbo.MAINTENANCE_RECORD;
GO
DROP TABLE IF EXISTS dbo.USAGE_SESSION;
GO
DROP TABLE IF EXISTS dbo.BOOKING_APPROVAL;
GO
DROP TABLE IF EXISTS dbo.BOOKING_REQUEST;
GO
DROP TABLE IF EXISTS dbo.FACILITY;
GO
DROP TABLE IF EXISTS dbo.SPACE;
GO
DROP TABLE IF EXISTS dbo.[USER];
GO

-- ============================================================
-- TABLE: USER
-- Stores university user accounts with roles and status.
-- ============================================================
CREATE TABLE dbo.[USER] (
    user_id             INT             IDENTITY(1,1)   NOT NULL,
    full_name           VARCHAR(100)                    NOT NULL,
    email               VARCHAR(255)                    NOT NULL,
    phone               VARCHAR(20)                     NULL,
    role                VARCHAR(50)                     NOT NULL,
    department          VARCHAR(100)                    NULL,
    account_status      VARCHAR(20)                     NOT NULL
        CONSTRAINT DF_User_AccountStatus DEFAULT 'Active',

    CONSTRAINT PK_User          PRIMARY KEY (user_id),
    CONSTRAINT UQ_User_Email    UNIQUE (email),
    CONSTRAINT CK_User_Role     CHECK (role IN (
        'Student', 'Lecturer', 'Teaching Assistant',
        'Facility Staff', 'Department Administrator', 'Facility Manager'
    )),
    CONSTRAINT CK_User_AccountStatus CHECK (account_status IN (
        'Active', 'Inactive', 'Suspended'
    ))
);
GO

-- ============================================================
-- TABLE: SPACE
-- Stores physical spaces available for booking.
-- ============================================================
CREATE TABLE dbo.SPACE (
    space_code          VARCHAR(20)                     NOT NULL,
    space_name          VARCHAR(100)                    NOT NULL,
    space_type          VARCHAR(50)                     NOT NULL,
    building            VARCHAR(100)                    NOT NULL,
    floor               INT                             NOT NULL,
    room_number         VARCHAR(20)                     NOT NULL,
    capacity            INT                             NOT NULL,
    current_status      VARCHAR(30)                     NOT NULL
        CONSTRAINT DF_Space_CurrentStatus DEFAULT 'Available',
    usage_policy        VARCHAR(255)                    NULL,

    CONSTRAINT PK_Space             PRIMARY KEY (space_code),
    CONSTRAINT UQ_Space_Location    UNIQUE (building, room_number),
    CONSTRAINT CK_Space_Type        CHECK (space_type IN (
        'Auditorium', 'Classroom', 'Computer Lab',
        'Project Lab', 'Meeting Room', 'Student Workspace'
    )),
    CONSTRAINT CK_Space_Status      CHECK (current_status IN (
        'Available', 'In Use', 'Under Maintenance',
        'Temporarily Closed', 'Retired'
    ))
);
GO

-- ============================================================
-- TABLE: FACILITY
-- Stores individual facilities/equipment belonging to a space.
-- ============================================================
CREATE TABLE dbo.FACILITY (
    facility_id         INT             IDENTITY(1,1)   NOT NULL,
    space_code          VARCHAR(20)                     NOT NULL,
    facility_name       VARCHAR(100)                    NOT NULL,
    description         VARCHAR(255)                    NULL,

    CONSTRAINT PK_Facility      PRIMARY KEY (facility_id),
    CONSTRAINT FK_Facility_Space FOREIGN KEY (space_code)
        REFERENCES dbo.SPACE (space_code) ON DELETE CASCADE
);
GO

-- ============================================================
-- TABLE: BOOKING_REQUEST
-- Stores requests made by users to book specific spaces and times.
-- ============================================================
CREATE TABLE dbo.BOOKING_REQUEST (
    booking_id              INT             IDENTITY(1,1)   NOT NULL,
    user_id                 INT                             NOT NULL,
    space_code              VARCHAR(20)                     NOT NULL,
    requested_start_time    DATETIME                        NOT NULL,
    requested_end_time      DATETIME                        NOT NULL,
    purpose                 VARCHAR(500)                    NULL,
    expected_participants   INT                             NULL,
    booking_type            VARCHAR(50)                     NOT NULL,
    status                  VARCHAR(20)                     NOT NULL
        CONSTRAINT DF_Booking_Status DEFAULT 'Pending',

    CONSTRAINT PK_BookingRequest    PRIMARY KEY (booking_id),
    CONSTRAINT FK_Booking_User      FOREIGN KEY (user_id)
        REFERENCES dbo.[USER] (user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_Booking_Space     FOREIGN KEY (space_code)
        REFERENCES dbo.SPACE (space_code) ON DELETE NO ACTION,
    CONSTRAINT CK_Booking_Time      CHECK (requested_end_time > requested_start_time),
    CONSTRAINT CK_Booking_Type      CHECK (booking_type IN (
        'Lecture', 'Examination', 'Seminar', 'Workshop',
        'Meeting', 'Student Activity', 'Administrative Event'
    )),
    CONSTRAINT CK_Booking_Status    CHECK (status IN (
        'Pending', 'Approved', 'Rejected', 'Cancelled',
        'Checked In', 'Completed', 'No-Show'
    ))
);
GO

-- ============================================================
-- TABLE: BOOKING_APPROVAL
-- Stores the approval/rejection decision for each booking request.
-- ============================================================
CREATE TABLE dbo.BOOKING_APPROVAL (
    approval_id         INT             IDENTITY(1,1)   NOT NULL,
    booking_id          INT                             NOT NULL,
    decided_by_user_id  INT                             NOT NULL,
    decision_time       DATETIME                        NOT NULL
        CONSTRAINT DF_Approval_DecisionTime DEFAULT GETDATE(),
    decision_note       VARCHAR(500)                    NULL,
    rejection_reason    VARCHAR(500)                    NULL,

    CONSTRAINT PK_BookingApproval           PRIMARY KEY (approval_id),
    CONSTRAINT UQ_BookingApproval_Booking   UNIQUE (booking_id),
    CONSTRAINT FK_Approval_Booking          FOREIGN KEY (booking_id)
        REFERENCES dbo.BOOKING_REQUEST (booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_Approval_Decider          FOREIGN KEY (decided_by_user_id)
        REFERENCES dbo.[USER] (user_id) ON DELETE NO ACTION
);
GO

-- ============================================================
-- TABLE: USAGE_SESSION
-- Stores check-in/check-out and condition records for actual usage.
-- ============================================================
CREATE TABLE dbo.USAGE_SESSION (
    session_id              INT             IDENTITY(1,1)   NOT NULL,
    booking_id              INT                             NOT NULL,
    actual_start_time       DATETIME                        NULL,
    actual_end_time         DATETIME                        NULL,
    checked_in_by_user_id   INT                             NULL,
    completed_by_user_id    INT                             NULL,
    initial_condition       VARCHAR(500)                    NULL,
    final_condition         VARCHAR(500)                    NULL,
    usage_notes             VARCHAR(1000)                   NULL,

    CONSTRAINT PK_UsageSession          PRIMARY KEY (session_id),
    CONSTRAINT UQ_UsageSession_Booking  UNIQUE (booking_id),
    CONSTRAINT FK_Usage_Booking         FOREIGN KEY (booking_id)
        REFERENCES dbo.BOOKING_REQUEST (booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_Usage_CheckIn         FOREIGN KEY (checked_in_by_user_id)
        REFERENCES dbo.[USER] (user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_Usage_Complete        FOREIGN KEY (completed_by_user_id)
        REFERENCES dbo.[USER] (user_id) ON DELETE NO ACTION
);
GO

-- ============================================================
-- TABLE: MAINTENANCE_RECORD
-- Stores maintenance issues, assignments, and resolution for spaces.
-- ============================================================
CREATE TABLE dbo.MAINTENANCE_RECORD (
    maintenance_id          INT             IDENTITY(1,1)   NOT NULL,
    space_code              VARCHAR(20)                     NOT NULL,
    reporter_user_id        INT                             NOT NULL,
    assigned_staff_user_id  INT                             NULL,
    problem_description     VARCHAR(1000)                   NOT NULL,
    start_time              DATETIME                        NOT NULL
        CONSTRAINT DF_Maintenance_StartTime DEFAULT GETDATE(),
    completion_time         DATETIME                        NULL,
    status                  VARCHAR(20)                     NOT NULL
        CONSTRAINT DF_Maintenance_Status DEFAULT 'Open',
    result_note             VARCHAR(1000)                   NULL,

    CONSTRAINT PK_MaintenanceRecord     PRIMARY KEY (maintenance_id),
    CONSTRAINT FK_Maintenance_Space     FOREIGN KEY (space_code)
        REFERENCES dbo.SPACE (space_code) ON DELETE NO ACTION,
    CONSTRAINT FK_Maintenance_Reporter  FOREIGN KEY (reporter_user_id)
        REFERENCES dbo.[USER] (user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_Maintenance_Staff     FOREIGN KEY (assigned_staff_user_id)
        REFERENCES dbo.[USER] (user_id) ON DELETE SET NULL,
    CONSTRAINT CK_Maintenance_Status    CHECK (status IN (
        'Open', 'In Progress', 'Resolved', 'Closed'
    ))
);
GO

-- ============================================================
-- INDEXES
-- ============================================================

-- Filtered index on the overlap-check hot path (only active bookings)
CREATE NONCLUSTERED INDEX IX_BookingRequest_Space_Time
    ON dbo.BOOKING_REQUEST (space_code, requested_start_time, requested_end_time)
    WHERE status IN ('Approved', 'Checked In');
GO

-- Plain index for user booking-history queries
CREATE NONCLUSTERED INDEX IX_BookingRequest_User
    ON dbo.BOOKING_REQUEST (user_id);
GO

-- Plain index for staff approval reports
CREATE NONCLUSTERED INDEX IX_BookingApproval_Decider
    ON dbo.BOOKING_APPROVAL (decided_by_user_id);
GO

-- Plain index for space maintenance queries
CREATE NONCLUSTERED INDEX IX_Maintenance_Space
    ON dbo.MAINTENANCE_RECORD (space_code);
GO

-- ============================================================
-- TRIGGERS
-- ============================================================

-- trg_PreventOverlappingBooking
-- Prevents two bookings from being approved for the same space
-- with overlapping time ranges.
-- Inserted-side scope: 'Approved', 'Checked In' (not 'Completed')
-- Existing-side scope: 'Approved', 'Checked In', 'Completed'
CREATE TRIGGER trg_PreventOverlappingBooking
ON dbo.BOOKING_REQUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.BOOKING_REQUEST b
            ON  i.space_code  = b.space_code
            AND i.booking_id <> b.booking_id
        WHERE i.status IN ('Approved', 'Checked In')
          AND b.status IN ('Approved', 'Checked In', 'Completed')
          AND i.requested_start_time < b.requested_end_time
          AND i.requested_end_time   > b.requested_start_time
    )
    BEGIN
        RAISERROR('Overlapping booking exists for this space and time range.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- trg_CheckSpaceAvailability
-- Prevents booking a space that is under maintenance, temporarily
-- closed, or retired.
-- CRITICAL: Scoped to status IN ('Pending', 'Approved') ONLY so that
-- historical updates (e.g. completing a booking, adding usage_notes)
-- are NOT blocked when the space has since gone under maintenance.
CREATE TRIGGER trg_CheckSpaceAvailability
ON dbo.BOOKING_REQUEST
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SPACE s
            ON i.space_code = s.space_code
        WHERE i.status IN ('Pending', 'Approved')
          AND s.current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
    )
    BEGIN
        RAISERROR('Space is currently unavailable for booking.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- trg_RequireRejectionReason
-- Ensures that when a booking is rejected, the corresponding
-- approval record must include a non-empty rejection_reason.
-- NOTE: BOOKING_APPROVAL has no 'decision' column. The rejection
-- status is determined by BOOKING_REQUEST.status = 'Rejected'.
-- The application must set BOOKING_REQUEST.status = 'Rejected'
-- before or in the same transaction as inserting/updating the
-- BOOKING_APPROVAL record for this trigger to enforce correctly.
CREATE TRIGGER trg_RequireRejectionReason
ON dbo.BOOKING_APPROVAL
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.BOOKING_REQUEST br
            ON i.booking_id = br.booking_id
        WHERE br.status = 'Rejected'
          AND (i.rejection_reason IS NULL
               OR LTRIM(RTRIM(i.rejection_reason)) = '')
    )
    BEGIN
        RAISERROR('Rejection reason is required when a booking is rejected.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
