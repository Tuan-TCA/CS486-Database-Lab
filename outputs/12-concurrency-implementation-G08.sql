SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_G08_ApproveBookingConcurrentSafe
    @booking_id          VARCHAR(20),
    @is_automatic        BIT,
    @decided_by_staff    VARCHAR(20),
    @decision_reason     VARCHAR(MAX) = NULL,

    -- Test-only parameter used by the two-session demonstration.
    -- Production calls should leave this value at zero.
    @test_hold_seconds   TINYINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @test_hold_seconds > 30
        THROW 52101, 'test_hold_seconds cannot exceed 30.', 1;

    DECLARE
        @space_code       VARCHAR(20),
        @space_lock_code  VARCHAR(20),
        @start_time       DATETIME2(0),
        @end_time         DATETIME2(0),
        @status           VARCHAR(30),
        @decision_id      VARCHAR(20),
        @delay            CHAR(8);

    BEGIN TRY
        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Read and lock the booking request immediately.
        --
        -- UPDLOCK is held until COMMIT or ROLLBACK. This keeps the
        -- booking values stable for the rest of this transaction.
        -- Therefore, no second/reload read is required.
        ------------------------------------------------------------
        SELECT
            @space_code = br.space_code,
            @start_time = br.start_time,
            @end_time = br.end_time,
            @status = br.status
        FROM dbo.BOOKING_REQUEST AS br WITH (UPDLOCK)
        WHERE br.booking_id = @booking_id;

        IF @space_code IS NULL
            THROW 52102, 'Booking request was not found.', 1;

        IF @status <> 'pending'
            THROW 52103, 'Only a pending booking can be approved.', 1;

        ------------------------------------------------------------
        -- 2. Serialize all approvals for this space.
        --
        -- Every approval path for the same space_code must request
        -- an Update lock on the same existing SPACES row.
        --
        -- U + U is incompatible, so only one approval transaction
        -- for this space can enter the protected section at a time.
        ------------------------------------------------------------
        SET @space_lock_code = NULL;

        SELECT @space_lock_code = s.space_code
        FROM dbo.SPACES AS s WITH (UPDLOCK)
        WHERE s.space_code = @space_code;

        IF @space_lock_code IS NULL
            THROW 52104, 'The booking space does not exist.', 1;

        ------------------------------------------------------------
        -- 3. Test-only delay.
        --
        -- During this delay the transaction still holds:
        -- U(BOOKING_REQUEST @booking_id)
        -- U(SPACES @space_code)
        ------------------------------------------------------------
        IF @test_hold_seconds > 0
        BEGIN
            SET @delay = CONCAT(
                '00:00:',
                RIGHT(
                    CONCAT('00', CONVERT(VARCHAR(2), @test_hold_seconds)),
                    2
                )
            );

            WAITFOR DELAY @delay;
        END;

        ------------------------------------------------------------
        -- 4. Check for an approved overlapping booking.
        --
        -- Every compliant approval path first locks the same SPACES
        -- row, so only one approval transaction for this space can
        -- execute this check-and-write sequence at a time.
        ------------------------------------------------------------
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
        BEGIN
            THROW 52105,
                'Another approved booking overlaps this space and time.',
                1;
        END;

        ------------------------------------------------------------
        -- 5. Insert the approval decision.
        ------------------------------------------------------------
        SET @decision_id = CONCAT(
            'G08D',
            LEFT(
                REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''),
                16
            )
        );

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

        ------------------------------------------------------------
        -- 6. Update booking status.
        ------------------------------------------------------------
        UPDATE dbo.BOOKING_REQUEST
        SET status = 'approved'
        WHERE booking_id = @booking_id;

        ------------------------------------------------------------
        -- 7. Commit.
        --
        -- COMMIT releases both Update locks.
        ------------------------------------------------------------
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