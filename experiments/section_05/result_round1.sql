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

-- (Tables USER, SPACE, FACILITY, BOOKING_REQUEST created here. Same as R3)

CREATE TABLE BOOKING_APPROVAL (
    approval_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL, -- BUG: Missing UNIQUE
    decided_by_user_id INT NOT NULL,
    decision_time DATETIME NOT NULL DEFAULT GETDATE(),
    decision_note VARCHAR(1000) NULL,
    rejection_reason VARCHAR(1000) NULL
);
GO

CREATE TABLE USAGE_SESSION (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL, -- BUG: Missing UNIQUE
    actual_start_time DATETIME NULL,
    actual_end_time DATETIME NULL
);
GO

-- trg_CheckSpaceAvailability
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
        WHERE s.current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
        -- BUG: Missing scope `AND i.status IN ('Pending', 'Approved')`
    )
    BEGIN
        RAISERROR ('Cannot book a space that is unavailable.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
