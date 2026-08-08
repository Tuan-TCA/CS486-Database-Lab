-- 03-unsafe-session-B.sql
-- Run in Window B while 02-unsafe-session-A.sql is inside its delay.

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
        @end_time   DATETIME2(0);

    ------------------------------------------------------------
    -- Unsafe read: no UPDLOCK on the booking and no per-space
    -- serialization lock.
    ------------------------------------------------------------
    SELECT
        @space_code = br.space_code,
        @start_time = br.start_time,
        @end_time = br.end_time
    FROM dbo.BOOKING_REQUEST AS br
    WHERE br.booking_id = 'G08_UNSAFE_B2';

    ------------------------------------------------------------
    -- Because Session A has not committed yet, this session also
    -- sees no approved overlap.
    ------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM dbo.BOOKING_REQUEST AS existing_booking
        JOIN dbo.BOOKING_DECISION AS existing_decision
          ON existing_decision.booking_id = existing_booking.booking_id
         AND existing_decision.is_approved = 1
        WHERE existing_booking.space_code = @space_code
          AND existing_booking.booking_id <> 'G08_UNSAFE_B2'
          AND existing_booking.status <> 'cancelled'
          AND existing_booking.start_time < @end_time
          AND @start_time < existing_booking.end_time
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

    PRINT 'Session B committed G08_UNSAFE_B2.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
