-- 03-unsafe-session-B.sql
-- Run in Window B during Session A's wait.
USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE
        @space_code VARCHAR(20),
        @start_time DATETIME2(0),
        @end_time DATETIME2(0);

    SELECT
        @space_code = space_code,
        @start_time = start_time,
        @end_time = end_time
    FROM dbo.BOOKING_REQUEST
    WHERE booking_id = 'G08_UNSAFE_B2';

    IF EXISTS (
        SELECT 1
        FROM dbo.BOOKING_REQUEST AS br
        JOIN dbo.BOOKING_DECISION AS d
          ON d.booking_id = br.booking_id
         AND d.is_approved = 1
        WHERE br.space_code = @space_code
          AND br.status <> 'cancelled'
          AND br.start_time < @end_time
          AND @start_time < br.end_time
    )
        THROW 52601, 'Session B unexpectedly found an existing conflict.', 1;

    INSERT INTO dbo.BOOKING_DECISION (
        decision_id,
        booking_id,
        is_approved,
        is_automatic,
        decided_by_staff,
        decision_reason,
        decision_time
    )
    VALUES (
        'G08_UNSAFE_D2',
        'G08_UNSAFE_B2',
        1,
        0,
        'G08_STAFF_1',
        'Unsafe Session B',
        SYSDATETIME()
    );

    UPDATE dbo.BOOKING_REQUEST
    SET status = 'approved'
    WHERE booking_id = 'G08_UNSAFE_B2';

    COMMIT TRANSACTION;
    PRINT 'Session B committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
