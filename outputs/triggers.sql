-- =====================================================
-- Step 12: Create Triggers for Booking and Maintenance
-- Business-Rule Automation
--
-- No table definitions are changed in this step.
-- These triggers add operational behavior on top of the
-- Phase 2 schema created in Steps 1-11.
-- =====================================================

-- =====================================================
-- Trigger 1: Process newly inserted booking requests
--
-- For each new pending booking:
--   1. Lock the target SPACES row.
--   2. Reject immediately if active out_of_service
--      maintenance overlaps the requested interval.
--   3. Create ADVISORY notifications for overlapping
--      active advisory maintenance.
--   4. If the requester/space-type pair matches
--      AUTO_USAGE_POLICY, invoke the concurrent-safe
--      automatic approval procedure.
--
-- The trigger handles multi-row INSERT statements by
-- processing inserted bookings one at a time.
-- =====================================================
GO
CREATE TRIGGER trg_G08_ProcessNewBooking
ON BOOKING_REQUEST
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @booking_id       VARCHAR(20),
        @space_code       VARCHAR(20),
        @start_time       DATETIME2(0),
        @end_time         DATETIME2(0),
        @status           VARCHAR(30),
        @space_lock_code  VARCHAR(20),
        @is_auto          BIT,
        @decision_id      VARCHAR(20);

    DECLARE cur_new_booking CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            i.booking_id,
            i.space_code,
            i.start_time,
            i.end_time,
            i.status
        FROM inserted AS i
        ORDER BY i.space_code, i.booking_id;

    OPEN cur_new_booking;

    FETCH NEXT FROM cur_new_booking
    INTO @booking_id, @space_code, @start_time, @end_time, @status;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @status = 'pending'
        BEGIN
            --------------------------------------------------------
            -- Use the existing SPACES row as the per-space
            -- serialization point while maintenance is checked.
            --------------------------------------------------------
            SET @space_lock_code = NULL;

            SELECT @space_lock_code = s.space_code
            FROM dbo.SPACES AS s WITH (UPDLOCK)
            WHERE s.space_code = @space_code;

            IF @space_lock_code IS NULL
                THROW 52301, 'The requested booking space does not exist.', 1;

            --------------------------------------------------------
            -- Active out_of_service maintenance blocks the booking.
            -- Keep the request as historical data, create a rejected
            -- decision, and change the request status to rejected.
            --------------------------------------------------------
            IF EXISTS (
                SELECT 1
                FROM dbo.MAINTENANCE_RECORD AS m
                WHERE m.space_code = @space_code
                  AND m.impact_level = 'out_of_service'
                  AND m.status IN ('pending', 'in_progress')
                  AND m.start_time < @end_time
                  AND @start_time < m.end_time
            )
            BEGIN
                SET @decision_id = CONCAT(
                    'G08R',
                    LEFT(
                        REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''),
                        16
                    )
                );

                IF NOT EXISTS (
                    SELECT 1
                    FROM dbo.BOOKING_DECISION
                    WHERE booking_id = @booking_id
                )
                BEGIN
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
                        0,
                        1,
                        NULL,
                        'Automatically rejected: active out_of_service maintenance overlaps the requested period.',
                        SYSDATETIME()
                    );
                END;

                UPDATE dbo.BOOKING_REQUEST
                SET status = 'rejected'
                WHERE booking_id = @booking_id
                  AND status = 'pending';
            END
            ELSE
            BEGIN
                ----------------------------------------------------
                -- Advisory maintenance does not block the request.
                -- Record one notification per overlapping advisory
                -- maintenance record.
                ----------------------------------------------------
                INSERT INTO dbo.BOOKING_NOTIFICATION (
                    booking_id,
                    maintenance_id,
                    notification_type,
                    notification_time
                )
                SELECT
                    @booking_id,
                    m.maintenance_id,
                    'ADVISORY',
                    SYSDATETIME()
                FROM dbo.MAINTENANCE_RECORD AS m
                WHERE m.space_code = @space_code
                  AND m.impact_level = 'advisory'
                  AND m.status IN ('pending', 'in_progress')
                  AND m.start_time < @end_time
                  AND @start_time < m.end_time
                  AND NOT EXISTS (
                      SELECT 1
                      FROM dbo.BOOKING_NOTIFICATION AS bn
                      WHERE bn.booking_id = @booking_id
                        AND bn.maintenance_id = m.maintenance_id
                        AND bn.notification_type = 'ADVISORY'
                  );

                ----------------------------------------------------
                -- Check whether the booking is eligible for
                -- automatic processing.
                ----------------------------------------------------
                SET @is_auto = 0;

                IF EXISTS (
                    SELECT 1
                    FROM dbo.BOOKING_REQUEST AS br
                    JOIN dbo.USERS AS u
                      ON u.user_id = br.user_id
                    JOIN dbo.SPACES AS s
                      ON s.space_code = br.space_code
                    JOIN dbo.AUTO_USAGE_POLICY AS p
                      ON p.role_id = u.role_id
                     AND p.space_type_id = s.space_type_id
                    WHERE br.booking_id = @booking_id
                      AND br.status = 'pending'
                )
                    SET @is_auto = 1;

                ----------------------------------------------------
                -- Automatic approval still uses the same
                -- concurrent-safe approval procedure as the
                -- manual/staff workflow.
                ----------------------------------------------------
                IF @is_auto = 1
                BEGIN
                    EXEC dbo.usp_G08_ApproveBookingConcurrentSafe
                        @booking_id = @booking_id,
                        @is_automatic = 1,
                        @decided_by_staff = NULL,
                        @decision_reason = 'Automated approval based on policy';
                END;
            END;
        END;

        FETCH NEXT FROM cur_new_booking
        INTO @booking_id, @space_code, @start_time, @end_time, @status;
    END;

    CLOSE cur_new_booking;
    DEALLOCATE cur_new_booking;
END;
GO


-- =====================================================
-- Trigger 2: Generate notifications when maintenance
-- is inserted or changed
--
-- Handles:
--   * new advisory maintenance;
--   * new out_of_service maintenance;
--   * advisory -> out_of_service escalation;
--   * maintenance time/space/status changes that cause
--     additional approved bookings to become affected.
--
-- Notification history is preserved. The existing
-- composite primary key prevents duplicate notification
-- types for the same booking/maintenance pair.
-- =====================================================

CREATE TRIGGER trg_G08_MaintenanceBookingNotifications
ON MAINTENANCE_RECORD
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.BOOKING_NOTIFICATION (
        booking_id,
        maintenance_id,
        notification_type,
        notification_time
    )
    SELECT
        br.booking_id,
        i.maintenance_id,
        CASE
            WHEN i.impact_level = 'advisory'
                THEN 'ADVISORY'
            ELSE 'OUT_OF_SERVICE'
        END,
        SYSDATETIME()
    FROM inserted AS i
    JOIN dbo.BOOKING_REQUEST AS br
      ON br.space_code = i.space_code
     AND br.status <> 'cancelled'
     AND br.start_time < i.end_time
     AND i.start_time < br.end_time
    JOIN dbo.BOOKING_DECISION AS bd
      ON bd.booking_id = br.booking_id
     AND bd.is_approved = 1
    WHERE i.status IN ('pending', 'in_progress')
      AND i.impact_level IN ('advisory', 'out_of_service')
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.BOOKING_NOTIFICATION AS bn
          WHERE bn.booking_id = br.booking_id
            AND bn.maintenance_id = i.maintenance_id
            AND bn.notification_type =
                CASE
                    WHEN i.impact_level = 'advisory'
                        THEN 'ADVISORY'
                    ELSE 'OUT_OF_SERVICE'
                END
      );
END;
GO


-- =====================================================
-- Trigger 3: Protect the schedule of a decided booking
--
-- Once a booking has a BOOKING_DECISION, its space or
-- requested time interval cannot be edited directly.
-- A future rescheduling workflow should perform a new
-- validation instead of bypassing booking rules.
--
-- Status-only updates performed by the approval procedure
-- are still allowed.
-- =====================================================

CREATE TRIGGER trg_G08_ProtectDecidedBookingSchedule
ON BOOKING_REQUEST
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN deleted AS d
          ON d.booking_id = i.booking_id
        JOIN dbo.BOOKING_DECISION AS bd
          ON bd.booking_id = i.booking_id
        WHERE i.space_code <> d.space_code
           OR i.start_time <> d.start_time
           OR i.end_time <> d.end_time
    )
        THROW 52305,
            'The space or time interval of a booking with an existing decision cannot be changed directly.',
            1;
END;
GO


-- =====================================================
-- Trigger 5: A usage session requires an approved
-- booking decision
--
-- The foreign key only proves that the decision exists.
-- This trigger additionally requires is_approved = 1.
-- =====================================================

CREATE TRIGGER trg_G08_UsageSessionRequiresApproval
ON USAGE_SESSION
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.BOOKING_DECISION AS bd
          ON bd.decision_id = i.decision_id
        WHERE bd.is_approved <> 1
    )
        THROW 52306,
            'A usage session can only reference an approved booking decision.',
            1;
END;
GO