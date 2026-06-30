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

CREATE TABLE MAINTENANCE_RECORD (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    space_code VARCHAR(20) NOT NULL,
    reporter_user_id INT NOT NULL,
    assigned_staff_user_id INT NULL,
    problem_description VARCHAR(1000) NOT NULL,
    start_time DATETIME NOT NULL,
    completion_time DATETIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Open',
    result_note VARCHAR(1000) NULL,
    CONSTRAINT FK_Maintenance_Staff FOREIGN KEY (assigned_staff_user_id) REFERENCES [USER](user_id) ON DELETE RESTRICT -- BUG: Should be SET NULL
);
GO

-- trg_PreventOverlappingBooking
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
        WHERE i.status IN ('Approved', 'Checked In', 'Completed') -- BUG: Included Completed here
          AND i.booking_id <> existing.booking_id
          AND existing.status IN ('Approved', 'Checked In', 'Completed')
          AND i.requested_start_time < existing.requested_end_time
          AND i.requested_end_time > existing.requested_start_time
    )
    BEGIN
        RAISERROR ('Booking time overlaps.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
