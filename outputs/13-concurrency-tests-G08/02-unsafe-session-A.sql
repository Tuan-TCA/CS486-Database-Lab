-- 02-unsafe-session-A.sql
-- Run first in Window A.
-- During the 12-second delay, run 03-unsafe-session-B.sql in Window B.

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
    WHERE br.booking_id = 'G08_UNSAFE_B1';

    ------------------------------------------------------------
    -- Unsafe check-then-act overlap test.
    ------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM dbo.BOOKING_REQUEST AS existing_booking
        JOIN dbo.BOOKING_DECISION AS existing_decision
          ON existing_decision.booking_id = existing_booking.booking_id
         AND existing_decision.is_approved = 1
        WHERE existing_booking.space_code = @space_code
          AND existing_booking.booking_id <> 'G08_UNSAFE_B1'
          AND existing_booking.status <> 'cancelled'
          AND existing_booking.start_time < @end_time
          AND @start_time < existing_booking.end_time
    )
        THROW 52600, 'Session A unexpectedly found an existing conflict.', 1;

    PRINT 'Session A found no conflict. Run 03-unsafe-session-B.sql now.';

    WAITFOR DELAY '00:00:12';

    ------------------------------------------------------------
    -- Session A acts on the old result without re-checking.
    ------------------------------------------------------------
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
        'G08_UNSAFE_D1',
        'G08_UNSAFE_B1',
        1,
        0,
        'G08_STAFF_1',
        'Unsafe Session A',
        SYSDATETIME()
    );

    UPDATE dbo.BOOKING_REQUEST
    SET status = 'approved'
    WHERE booking_id = 'G08_UNSAFE_B1';

    COMMIT TRANSACTION;

    PRINT 'Session A committed G08_UNSAFE_B1.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
