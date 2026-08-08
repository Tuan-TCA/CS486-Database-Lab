
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_G08_ApproveBookingConcurrentSafe
    @booking_id          VARCHAR(20),
    @is_automatic        BIT,
    @decided_by_staff    VARCHAR(20),
    @decision_reason     VARCHAR(MAX) = NULL,
    @lock_timeout_ms     INT = 10000,

    -- Test-only parameter used by the two-session demonstration.
    -- Production calls should leave this value at zero.
    @test_hold_seconds   TINYINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @lock_timeout_ms < 0
        THROW 52100, 'lock_timeout_ms must be zero or positive.', 1;

    IF @test_hold_seconds > 30
        THROW 52101, 'test_hold_seconds cannot exceed 30.', 1;

    DECLARE
        @space_code         VARCHAR(20),
        @locked_space_code  VARCHAR(20),
        @start_time         DATETIME2(0),
        @end_time           DATETIME2(0),
        @status             VARCHAR(30),
        @lock_resource      NVARCHAR(255),
        @lock_result        INT,
        @decision_id        VARCHAR(20),
        @delay              CHAR(8);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Discovery read only. The row is reloaded after the space lock is held.
        SELECT @space_code = br.space_code
        FROM dbo.BOOKING_REQUEST AS br
        WHERE br.booking_id = @booking_id;

        IF @space_code IS NULL
            THROW 52102, 'Booking request was not found.', 1;

        SET @lock_resource = CONCAT(N'SPACE_BOOKING:', @space_code);

        EXEC @lock_result = sys.sp_getapplock
            @Resource = @lock_resource,
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = @lock_timeout_ms,
            @DbPrincipal = 'public';

        IF @lock_result < 0
            THROW 52103, 'Could not obtain the booking lock for this space.', 1;

        -- Reload the booking after acquiring the serialization lock.
        SELECT
            @locked_space_code = br.space_code,
            @start_time = br.start_time,
            @end_time = br.end_time,
            @status = br.status
        FROM dbo.BOOKING_REQUEST AS br WITH (UPDLOCK, HOLDLOCK)
        WHERE br.booking_id = @booking_id;

        IF @locked_space_code IS NULL
            THROW 52104, 'Booking request disappeared during processing.', 1;

        IF @locked_space_code <> @space_code
            THROW 52105, 'Booking space changed during processing.', 1;

        IF @status <> 'pending'
            THROW 52106, 'Only a pending booking can be approved.', 1;

        -- Hold the application lock so the test can start a competing session.
        IF @test_hold_seconds > 0
        BEGIN
            SET @delay = CONCAT(
                '00:00:',
                RIGHT(CONCAT('00', CONVERT(VARCHAR(2), @test_hold_seconds)), 2)
            );
            WAITFOR DELAY @delay;
        END;

        -- Concurrency-specific business predicate.
        IF EXISTS (
            SELECT 1
            FROM dbo.BOOKING_REQUEST AS existing_booking
            JOIN dbo.BOOKING_DECISION AS existing_decision
              ON existing_decision.booking_id = existing_booking.booking_id
             AND existing_decision.is_approved = 1
            WHERE existing_booking.space_code = @space_code
              AND existing_booking.booking_id <> @booking_id
              AND existing_booking.status <> 'cancelled'
              AND existing_booking.start_time < @end_time
              AND @start_time < existing_booking.end_time
        )
            THROW 52107, 'Another approved booking overlaps this space and time.', 1;

        SET @decision_id = CONCAT(
            'G08D',
            LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 16)
        );

        -- Existing constraints and triggers continue to validate these writes.
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
            @decision_id,
            @booking_id,
            1,
            @is_automatic,
            @decided_by_staff,
            @decision_reason,
            SYSDATETIME()
        );

        UPDATE dbo.BOOKING_REQUEST
        SET status = 'approved'
        WHERE booking_id = @booking_id;

        COMMIT TRANSACTION;

        SELECT
            @decision_id AS decision_id,
            @booking_id AS booking_id,
            @space_code AS space_code,
            'approved' AS result;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

PRINT 'dbo.usp_G08_ApproveBookingConcurrentSafe created or altered.';
GO