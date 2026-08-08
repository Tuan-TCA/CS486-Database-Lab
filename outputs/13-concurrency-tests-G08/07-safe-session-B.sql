-- 07-safe-session-B.sql
-- Run in Window B while Session A holds the BOOKING_REQUEST and SPACES
-- update locks.

USE campus_space_management;
GO

BEGIN TRY
    EXEC dbo.usp_G08_ApproveBookingConcurrentSafe
        @booking_id = 'G08_SAFE_B2',
        @is_automatic = 0,
        @decided_by_staff = 'G08_STAFF_1',
        @decision_reason = 'Protected Session B',
        @test_hold_seconds = 0;

    THROW 52610,
        'UNEXPECTED: Session B was approved instead of detecting the overlap.',
        1;
END TRY
BEGIN CATCH
    -- The protected procedure must fail specifically with its overlap error.
    IF ERROR_NUMBER() <> 52105
        THROW;

    SELECT
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message,
        'EXPECTED: Session B waited for the SPACES update lock and then detected the overlap.'
            AS result;
END CATCH;
GO
