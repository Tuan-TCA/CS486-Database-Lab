-- ============================================================
-- Database Definition — G08
-- DBMS: Microsoft SQL Server
-- Description: DDL for the Campus Space Booking System.
-- Sources: project_description.md, req/business-requirement.md
-- ============================================================

-- Idempotent: drop existing database objects before creation
USE master;
GO

IF DB_ID('CampusSpaceBooking') IS NOT NULL
BEGIN
    ALTER DATABASE CampusSpaceBooking SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CampusSpaceBooking;
END
GO

CREATE DATABASE CampusSpaceBooking;
GO

USE CampusSpaceBooking;
GO

-- ============================================================
-- TABLE: [User]
-- Stores university account information for all system users.
-- ============================================================
CREATE TABLE [User] (
    user_id         INT             NOT NULL IDENTITY(1,1),
    full_name       NVARCHAR(100)   NOT NULL,
    email           NVARCHAR(255)   NOT NULL,
    phone           NVARCHAR(20)    NULL,
    role            NVARCHAR(30)    NOT NULL
        CHECK (role IN ('Student','Lecturer','TA','Facility Staff','Dept Administrator','Facility Manager')),
    department      NVARCHAR(100)   NOT NULL,
    account_status  NVARCHAR(20)    NOT NULL DEFAULT 'Active'
        CHECK (account_status IN ('Active','Inactive','Suspended')),
    CONSTRAINT PK_User PRIMARY KEY (user_id),
    CONSTRAINT UQ_User_Email UNIQUE (email)
);
GO

-- ============================================================
-- TABLE: Space
-- Stores information about bookable campus spaces.
-- ============================================================
CREATE TABLE Space (
    space_code      NVARCHAR(20)    NOT NULL,
    space_name      NVARCHAR(100)   NOT NULL,
    space_type      NVARCHAR(30)    NOT NULL
        CHECK (space_type IN ('Auditorium','Classroom','Computer Lab','Project Lab','Meeting Room','Workspace')),
    building        NVARCHAR(100)   NOT NULL,
    floor           INT             NOT NULL,
    room_number     NVARCHAR(20)    NOT NULL,
    capacity        INT             NOT NULL CHECK (capacity > 0),
    current_status  NVARCHAR(30)    NOT NULL DEFAULT 'Available'
        CHECK (current_status IN ('Available','In Use','Under Maintenance','Temporarily Closed','Retired')),
    usage_policy    NVARCHAR(MAX)   NULL,
    CONSTRAINT PK_Space PRIMARY KEY (space_code)
);
GO

-- ============================================================
-- TABLE: Facility
-- Catalogue of equipment/facilities that can be present in spaces.
-- ============================================================
CREATE TABLE Facility (
    facility_id     INT             NOT NULL IDENTITY(1,1),
    facility_name   NVARCHAR(100)   NOT NULL,
    description     NVARCHAR(MAX)   NULL,
    CONSTRAINT PK_Facility PRIMARY KEY (facility_id),
    CONSTRAINT UQ_Facility_Name UNIQUE (facility_name)
);
GO

-- ============================================================
-- TABLE: Space_Facility
-- Many-to-many relationship between Space and Facility,
-- with per-space quantity tracking.
-- ============================================================
CREATE TABLE Space_Facility (
    space_code      NVARCHAR(20)    NOT NULL,
    facility_id     INT             NOT NULL,
    quantity        INT             NOT NULL DEFAULT 1 CHECK (quantity > 0),
    CONSTRAINT PK_Space_Facility PRIMARY KEY (space_code, facility_id),
    CONSTRAINT FK_SpaceFacility_Space FOREIGN KEY (space_code)
        REFERENCES Space(space_code)
        ON DELETE CASCADE,
    CONSTRAINT FK_SpaceFacility_Facility FOREIGN KEY (facility_id)
        REFERENCES Facility(facility_id)
        ON DELETE CASCADE
);
GO

-- ============================================================
-- TABLE: Booking
-- Records space booking requests and usage sessions.
-- Tracks full lifecycle: submission -> approval -> check-in -> completion.
-- ============================================================
CREATE TABLE Booking (
    booking_id            INT             NOT NULL IDENTITY(1,1),
    requester_id          INT             NOT NULL,
    space_code            NVARCHAR(20)    NOT NULL,
    requested_start       DATETIME2       NOT NULL,
    requested_end         DATETIME2       NOT NULL,
    purpose               NVARCHAR(30)    NOT NULL
        CHECK (purpose IN ('Lecture','Examination','Seminar','Workshop','Meeting','Student Activity','Administrative Event')),
    expected_participants INT             NOT NULL CHECK (expected_participants > 0),
    status                NVARCHAR(20)    NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending','Approved','Rejected','Cancelled','Checked In','Completed','No-Show')),
    booking_time          DATETIME2       NOT NULL DEFAULT GETDATE(),
    actual_start_time     DATETIME2       NULL,
    checkin_staff_id      INT             NULL,
    initial_condition     NVARCHAR(MAX)   NULL,
    actual_end_time       DATETIME2       NULL,
    final_condition       NVARCHAR(MAX)   NULL,
    usage_notes           NVARCHAR(MAX)   NULL,
    CONSTRAINT PK_Booking PRIMARY KEY (booking_id),
    CONSTRAINT FK_Booking_Requester FOREIGN KEY (requester_id)
        REFERENCES [User](user_id),
    CONSTRAINT FK_Booking_Space FOREIGN KEY (space_code)
        REFERENCES Space(space_code),
    CONSTRAINT FK_Booking_CheckinStaff FOREIGN KEY (checkin_staff_id)
        REFERENCES [User](user_id),
    CONSTRAINT CK_Booking_TimeRange CHECK (requested_end > requested_start)
);
GO

-- ============================================================
-- TABLE: Booking_Approval
-- Records the approval or rejection decision for a booking.
-- One-to-one with Booking: each booking has at most one decision.
-- ============================================================
CREATE TABLE Booking_Approval (
    approval_id     INT             NOT NULL IDENTITY(1,1),
    booking_id      INT             NOT NULL,
    staff_id        INT             NOT NULL,
    decision_time   DATETIME2       NOT NULL DEFAULT GETDATE(),
    decision        NVARCHAR(10)    NOT NULL
        CHECK (decision IN ('Approved','Rejected')),
    decision_note   NVARCHAR(MAX)   NULL,
    rejection_reason NVARCHAR(MAX)  NULL,
    CONSTRAINT PK_Booking_Approval PRIMARY KEY (approval_id),
    CONSTRAINT UQ_Approval_Booking UNIQUE (booking_id),
    CONSTRAINT FK_Approval_Booking FOREIGN KEY (booking_id)
        REFERENCES Booking(booking_id),
    CONSTRAINT FK_Approval_Staff FOREIGN KEY (staff_id)
        REFERENCES [User](user_id)
);
GO

-- ============================================================
-- TABLE: Maintenance
-- Records maintenance issues reported for spaces.
-- ============================================================
CREATE TABLE Maintenance (
    maintenance_id        INT             NOT NULL IDENTITY(1,1),
    space_code            NVARCHAR(20)    NOT NULL,
    reporter_id           INT             NOT NULL,
    assigned_staff_id     INT             NULL,
    problem_description   NVARCHAR(MAX)   NOT NULL,
    problem_type          NVARCHAR(30)    NULL
        CHECK (problem_type IN ('Broken Projector','AC Failure','Damaged Furniture','Cleaning Issue','Network Problem')),
    start_time            DATETIME2       NOT NULL DEFAULT GETDATE(),
    completion_time       DATETIME2       NULL,
    status                NVARCHAR(20)    NOT NULL DEFAULT 'Open'
        CHECK (status IN ('Open','In Progress','Resolved','Closed')),
    result_note           NVARCHAR(MAX)   NULL,
    CONSTRAINT PK_Maintenance PRIMARY KEY (maintenance_id),
    CONSTRAINT FK_Maintenance_Space FOREIGN KEY (space_code)
        REFERENCES Space(space_code),
    CONSTRAINT FK_Maintenance_Reporter FOREIGN KEY (reporter_id)
        REFERENCES [User](user_id),
    CONSTRAINT FK_Maintenance_AssignedStaff FOREIGN KEY (assigned_staff_id)
        REFERENCES [User](user_id)
);
GO

-- ============================================================
-- INDEXES
-- ============================================================

-- Index for overlap detection queries
CREATE INDEX IX_Booking_Space_Time ON Booking (space_code, requested_start, requested_end)
    WHERE status IN ('Approved','Checked In','Completed');
GO

-- Index for user booking history
CREATE INDEX IX_Booking_Requester ON Booking (requester_id);
GO

-- Index for staff approval history
CREATE INDEX IX_BookingApproval_Staff ON Booking_Approval (staff_id);
GO

-- Index for maintenance by space
CREATE INDEX IX_Maintenance_Space ON Maintenance (space_code);
GO

-- Index for maintenance by assigned staff
CREATE INDEX IX_Maintenance_AssignedStaff ON Maintenance (assigned_staff_id);
GO

-- ============================================================
-- TRIGGERS
-- Enforce business rules at the database level.
-- ============================================================

-- Trigger 1: Prevent overlapping approved/active bookings
CREATE TRIGGER trg_PreventOverlappingBooking
ON Booking
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.status IN ('Approved', 'Checked In', 'Completed')
          AND EXISTS (
              SELECT 1
              FROM Booking b
              WHERE b.space_code = i.space_code
                AND b.booking_id <> i.booking_id
                AND b.status IN ('Approved', 'Checked In', 'Completed')
                AND i.requested_start < b.requested_end
                AND i.requested_end > b.requested_start
          )
    )
    BEGIN
        RAISERROR('Overlapping booking: the selected time period conflicts with an existing active booking for this space.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger 2: Prevent booking when space is unavailable
CREATE TRIGGER trg_CheckSpaceAvailability
ON Booking
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Space s ON i.space_code = s.space_code
        WHERE s.current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
    )
    BEGIN
        RAISERROR('Cannot book this space: it is currently under maintenance, temporarily closed, or retired.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger 3: Require rejection reason when decision is Rejected
CREATE TRIGGER trg_RequireRejectionReason
ON Booking_Approval
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.decision = 'Rejected'
          AND (i.rejection_reason IS NULL OR i.rejection_reason = '')
    )
    BEGIN
        RAISERROR('A rejection reason is required when the booking decision is Rejected.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

PRINT 'CampusSpaceBooking database schema created successfully.';
GO
