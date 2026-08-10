-- =====================================================
-- 10-schema-migration-G08.sql
-- Campus Space Management System
-- Phase 1 -> Phase 2 Schema Migration (Data-Preserving)
--
-- Migrates the Phase 1 database (created by
-- 05-db-definition-G08.sql and populated by
-- 06-sample-data-G08.sql) to the Phase 2 schema defined
-- in 09-updated-erd-and-logical-design-G08.md.
--
-- The migration preserves all Phase 1 data:
--   20 users, 12 spaces, 32 facilities, 30 booking requests,
--   25 booking approvals, 16 usage sessions, 12 maintenance records.
-- =====================================================

USE campus_space_management;
GO

SET NOCOUNT ON;
GO

-- =====================================================
-- Step 1: Create ROLE lookup table and populate
-- =====================================================

CREATE TABLE ROLE (
    role_id   INT IDENTITY(1,1),
    role_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (role_id),
    UNIQUE (role_name)
);
GO

INSERT INTO ROLE (role_name) VALUES
    ('student'),
    ('lecturer'),
    ('teaching_assistant'),
    ('facility_staff'),
    ('department_administrator'),
    ('facility_manager');
GO

-- =====================================================
-- Step 2: Modify USERS
-- Replace role string with role_id foreign key
-- =====================================================

ALTER TABLE USERS ADD role_id INT;
GO

UPDATE u
SET u.role_id = r.role_id
FROM USERS AS u
JOIN ROLE AS r ON r.role_name = u.role;
GO

-- Drop the CHECK constraint on role (name was auto-generated)
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql
    + N'ALTER TABLE dbo.USERS DROP CONSTRAINT '
    + QUOTENAME(cc.name) + N';'
FROM sys.check_constraints AS cc
WHERE cc.parent_object_id = OBJECT_ID(N'dbo.USERS')
  AND COL_NAME(cc.parent_object_id, cc.parent_column_id) = N'role';

IF @sql <> N''
    EXEC sp_executesql @sql;
GO

ALTER TABLE USERS DROP COLUMN role;
GO

ALTER TABLE USERS ALTER COLUMN role_id INT NOT NULL;
GO

ALTER TABLE USERS ADD FOREIGN KEY (role_id) REFERENCES ROLE(role_id);
GO

-- =====================================================
-- Step 3: Create SPACE_TYPE lookup table
-- and populate from existing SPACES data
-- =====================================================

CREATE TABLE SPACE_TYPE (
    space_type_id   INT IDENTITY(1,1),
    space_type_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (space_type_id),
    UNIQUE (space_type_name)
);
GO

INSERT INTO SPACE_TYPE (space_type_name)
SELECT DISTINCT space_type
FROM SPACES
ORDER BY space_type;
GO

-- =====================================================
-- Step 4: Modify SPACES
-- Replace space_type with space_type_id foreign key,
-- drop usage_policy
-- =====================================================

ALTER TABLE SPACES ADD space_type_id INT;
GO

UPDATE s
SET s.space_type_id = st.space_type_id
FROM SPACES AS s
JOIN SPACE_TYPE AS st ON st.space_type_name = s.space_type;
GO

ALTER TABLE SPACES DROP COLUMN space_type;
GO

ALTER TABLE SPACES ALTER COLUMN space_type_id INT NOT NULL;
GO

ALTER TABLE SPACES ADD FOREIGN KEY (space_type_id) REFERENCES SPACE_TYPE(space_type_id);
GO

ALTER TABLE SPACES DROP COLUMN usage_policy;
GO

-- =====================================================
-- Step 5: Create AUTO_USAGE_POLICY table
-- (empty -- no Phase 1 data to migrate)
-- =====================================================

CREATE TABLE AUTO_USAGE_POLICY (
    space_type_id INT,
    role_id       INT,
    PRIMARY KEY (space_type_id, role_id),
    FOREIGN KEY (space_type_id) REFERENCES SPACE_TYPE(space_type_id),
    FOREIGN KEY (role_id)       REFERENCES ROLE(role_id)
);
GO

-- =====================================================
-- Step 6: Rename columns in BOOKING_REQUEST
-- requested_start_time -> start_time
-- requested_end_time   -> end_time
-- =====================================================

-- Drop the time-interval CHECK constraint before renaming
-- (sp_rename cannot rename columns referenced by a CHECK)
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql
    + N'ALTER TABLE dbo.BOOKING_REQUEST DROP CONSTRAINT '
    + QUOTENAME(cc.name) + N';'
FROM sys.check_constraints AS cc
WHERE cc.parent_object_id = OBJECT_ID(N'dbo.BOOKING_REQUEST')
  AND EXISTS (
      SELECT 1
      FROM sys.sql_expression_dependencies AS d
      WHERE d.referencing_id = cc.object_id
        AND d.referenced_minor_id IN (
            COLUMNPROPERTY(OBJECT_ID(N'dbo.BOOKING_REQUEST'), N'requested_start_time', 'ColumnId'),
            COLUMNPROPERTY(OBJECT_ID(N'dbo.BOOKING_REQUEST'), N'requested_end_time', 'ColumnId')
        )
  );

IF @sql <> N''
    EXEC sp_executesql @sql;
GO

EXEC sp_rename 'BOOKING_REQUEST.requested_start_time', 'start_time', 'COLUMN';
GO

EXEC sp_rename 'BOOKING_REQUEST.requested_end_time', 'end_time', 'COLUMN';
GO

-- Re-add the time-interval CHECK constraint with the new column names
ALTER TABLE BOOKING_REQUEST ADD CHECK (end_time > start_time);
GO

-- =====================================================
-- Step 7: Create BOOKING_DECISION
-- and migrate data from BOOKING_APPROVAL
-- =====================================================

CREATE TABLE BOOKING_DECISION (
    decision_id       VARCHAR(20),
    booking_id        VARCHAR(20)  NOT NULL,
    is_approved       BIT          NOT NULL,
    is_automatic      BIT          NOT NULL DEFAULT 0,
    decided_by_staff  VARCHAR(20),
    decision_reason   VARCHAR(MAX),
    decision_time     DATETIME     NOT NULL,

    PRIMARY KEY (decision_id),
    UNIQUE (booking_id),
    FOREIGN KEY (booking_id)       REFERENCES BOOKING_REQUEST(booking_id),
    FOREIGN KEY (decided_by_staff) REFERENCES USERS(user_id)
);
GO

INSERT INTO BOOKING_DECISION (
    decision_id, booking_id, is_approved, is_automatic,
    decided_by_staff, decision_reason, decision_time
)
SELECT
    ba.approval_id,
    ba.booking_id,
    CASE WHEN ba.decision_note = 'approved' THEN 1 ELSE 0 END,
    0,
    ba.decided_by_user_id,
    COALESCE(ba.rejection_reason, ba.decision_note),
    ba.decision_time
FROM BOOKING_APPROVAL AS ba;
GO

-- =====================================================
-- Step 8: Modify USAGE_SESSION
-- Replace booking_id with decision_id,
-- rename time and staff columns
-- =====================================================

ALTER TABLE USAGE_SESSION ADD decision_id VARCHAR(20);
GO

UPDATE us
SET us.decision_id = bd.decision_id
FROM USAGE_SESSION AS us
JOIN BOOKING_DECISION AS bd ON bd.booking_id = us.booking_id;
GO

-- Drop the foreign key on booking_id (name was auto-generated)
DECLARE @fk_name sysname;
DECLARE @drop_fk_sql NVARCHAR(MAX);

SELECT TOP (1) @fk_name = fk.name
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc
    ON fkc.constraint_object_id = fk.object_id
WHERE fk.parent_object_id = OBJECT_ID(N'dbo.USAGE_SESSION')
  AND COL_NAME(fk.parent_object_id, fkc.parent_column_id) = N'booking_id';

IF @fk_name IS NOT NULL
BEGIN
    SET @drop_fk_sql = N'ALTER TABLE dbo.USAGE_SESSION DROP CONSTRAINT '
        + QUOTENAME(@fk_name);
    EXEC (@drop_fk_sql);
END
GO

-- Drop the unique constraint on booking_id (name was auto-generated)
DECLARE @uq_name sysname;
DECLARE @drop_uq_sql NVARCHAR(MAX);

SELECT TOP (1) @uq_name = i.name
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID(N'dbo.USAGE_SESSION')
  AND i.is_unique_constraint = 1
  AND EXISTS (
      SELECT 1
      FROM sys.index_columns AS ic
      WHERE ic.object_id = i.object_id
        AND ic.index_id = i.index_id
        AND COL_NAME(ic.object_id, ic.column_id) = N'booking_id'
  );

IF @uq_name IS NOT NULL
BEGIN
    SET @drop_uq_sql = N'ALTER TABLE dbo.USAGE_SESSION DROP CONSTRAINT '
        + QUOTENAME(@uq_name);
    EXEC (@drop_uq_sql);
END
GO

ALTER TABLE USAGE_SESSION DROP COLUMN booking_id;
GO

ALTER TABLE USAGE_SESSION ALTER COLUMN decision_id VARCHAR(20) NOT NULL;
GO

ALTER TABLE USAGE_SESSION ADD FOREIGN KEY (decision_id) REFERENCES BOOKING_DECISION(decision_id);
GO

ALTER TABLE USAGE_SESSION ADD UNIQUE (decision_id);
GO

-- Drop the time-interval CHECK constraint before renaming
-- (sp_rename cannot rename columns referenced by a CHECK)
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql
    + N'ALTER TABLE dbo.USAGE_SESSION DROP CONSTRAINT '
    + QUOTENAME(cc.name) + N';'
FROM sys.check_constraints AS cc
WHERE cc.parent_object_id = OBJECT_ID(N'dbo.USAGE_SESSION')
  AND EXISTS (
      SELECT 1
      FROM sys.sql_expression_dependencies AS d
      WHERE d.referencing_id = cc.object_id
        AND d.referenced_minor_id IN (
            COLUMNPROPERTY(OBJECT_ID(N'dbo.USAGE_SESSION'), N'actual_start_time', 'ColumnId'),
            COLUMNPROPERTY(OBJECT_ID(N'dbo.USAGE_SESSION'), N'actual_end_time', 'ColumnId')
        )
  );

IF @sql <> N''
    EXEC sp_executesql @sql;
GO

EXEC sp_rename 'USAGE_SESSION.actual_start_time', 'start_time', 'COLUMN';
GO

EXEC sp_rename 'USAGE_SESSION.actual_end_time', 'end_time', 'COLUMN';
GO

EXEC sp_rename 'USAGE_SESSION.checked_in_by_user_id', 'checked_in_by_staff', 'COLUMN';
GO

EXEC sp_rename 'USAGE_SESSION.completed_by_user_id', 'completed_by_staff', 'COLUMN';
GO

EXEC sp_rename 'USAGE_SESSION.usage_notes', 'usage_note', 'COLUMN';
GO

-- Re-add the time-interval CHECK constraint with the new column names
ALTER TABLE USAGE_SESSION
    ADD CHECK (
        end_time IS NULL
        OR end_time >= start_time
    );
GO

-- =====================================================
-- Step 9: Modify MAINTENANCE_RECORD
-- Add impact_level, rename staff and time columns
-- =====================================================

ALTER TABLE MAINTENANCE_RECORD
    ADD impact_level VARCHAR(20)
        NOT NULL
        DEFAULT 'out_of_service';
GO

ALTER TABLE MAINTENANCE_RECORD
    ADD CHECK (impact_level IN ('advisory', 'out_of_service'));
GO

-- Drop the time-interval CHECK constraint before renaming
-- (sp_rename cannot rename columns referenced by a CHECK)
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql
    + N'ALTER TABLE dbo.MAINTENANCE_RECORD DROP CONSTRAINT '
    + QUOTENAME(cc.name) + N';'
FROM sys.check_constraints AS cc
WHERE cc.parent_object_id = OBJECT_ID(N'dbo.MAINTENANCE_RECORD')
  AND EXISTS (
      SELECT 1
      FROM sys.sql_expression_dependencies AS d
      WHERE d.referencing_id = cc.object_id
        AND d.referenced_minor_id = COLUMNPROPERTY(
            OBJECT_ID(N'dbo.MAINTENANCE_RECORD'),
            N'completion_time', 'ColumnId'
        )
  );

IF @sql <> N''
    EXEC sp_executesql @sql;
GO

EXEC sp_rename 'MAINTENANCE_RECORD.reporter_user_id', 'report_user', 'COLUMN';
GO

EXEC sp_rename 'MAINTENANCE_RECORD.assigned_staff_user_id', 'assigned_staff', 'COLUMN';
GO

EXEC sp_rename 'MAINTENANCE_RECORD.completion_time', 'end_time', 'COLUMN';
GO

-- Re-add the time-interval CHECK constraint with the new column names
ALTER TABLE MAINTENANCE_RECORD
    ADD CHECK (
        end_time IS NULL
        OR end_time >= start_time
    );
GO

-- =====================================================
-- Step 10: Create BOOKING_NOTIFICATION table
-- (empty -- new concept, no Phase 1 data)
-- =====================================================

CREATE TABLE BOOKING_NOTIFICATION (
    booking_id        VARCHAR(20),
    maintenance_id    VARCHAR(20),
    notification_type VARCHAR(50),
    notification_time DATETIME     NOT NULL,

    PRIMARY KEY (booking_id, maintenance_id, notification_type),
    FOREIGN KEY (booking_id)     REFERENCES BOOKING_REQUEST(booking_id),
    FOREIGN KEY (maintenance_id) REFERENCES MAINTENANCE_RECORD(maintenance_id),

    Check(notification_type IN ('ADVISORY', 'OUT_OF_SERVICE'))
);
GO

-- =====================================================
-- Step 11: Drop BOOKING_APPROVAL
-- (data migrated to BOOKING_DECISION in Step 7)
-- =====================================================

DROP TABLE BOOKING_APPROVAL;
GO

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
-- Trigger 3: Validate every approved BOOKING_DECISION
-- and create any missing advisory notifications
--
-- This is a safety net for every approval path, including
-- direct/manual decision inserts that do not originate
-- from the automatic booking trigger.
--
-- It:
--   * blocks approval during active out_of_service
--     maintenance;
--   * blocks approval if another approved booking already
--     overlaps the same space and time;
--   * records advisory notifications at approval time.
-- =====================================================

CREATE TRIGGER trg_G08_ValidateApprovedBooking
ON BOOKING_DECISION
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @booking_id       VARCHAR(20),
        @space_code       VARCHAR(20),
        @start_time       DATETIME2(0),
        @end_time         DATETIME2(0),
        @space_lock_code  VARCHAR(20);

    DECLARE cur_approved_booking CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            br.booking_id,
            br.space_code,
            br.start_time,
            br.end_time
        FROM inserted AS i
        JOIN dbo.BOOKING_REQUEST AS br
          ON br.booking_id = i.booking_id
        WHERE i.is_approved = 1
        ORDER BY br.space_code, br.booking_id;

    OPEN cur_approved_booking;

    FETCH NEXT FROM cur_approved_booking
    INTO @booking_id, @space_code, @start_time, @end_time;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @space_lock_code = NULL;

        SELECT @space_lock_code = s.space_code
        FROM dbo.SPACES AS s WITH (UPDLOCK)
        WHERE s.space_code = @space_code;

        IF @space_lock_code IS NULL
            THROW 52302, 'Approved booking references a space that does not exist.', 1;

        ------------------------------------------------------------
        -- An approved booking cannot overlap active
        -- out_of_service maintenance.
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM dbo.MAINTENANCE_RECORD AS m
            WHERE m.space_code = @space_code
              AND m.impact_level = 'out_of_service'
              AND m.status IN ('pending', 'in_progress')
              AND m.start_time < @end_time
              AND @start_time < m.end_time
        )
            THROW 52303,
                'Booking cannot be approved because active out_of_service maintenance overlaps the requested period.',
                1;

        ------------------------------------------------------------
        -- Protect the central booking invariant even when an
        -- approval is inserted outside the normal procedure.
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM dbo.BOOKING_REQUEST AS other_br
            JOIN dbo.BOOKING_DECISION AS other_bd
              ON other_bd.booking_id = other_br.booking_id
             AND other_bd.is_approved = 1
            WHERE other_br.space_code = @space_code
              AND other_br.booking_id <> @booking_id
              AND other_br.status <> 'cancelled'
              AND other_br.start_time < @end_time
              AND @start_time < other_br.end_time
        )
            THROW 52304,
                'Booking cannot be approved because another approved booking overlaps the same space and time.',
                1;

        ------------------------------------------------------------
        -- If approval occurs while advisory maintenance is active,
        -- make sure the notification exists.
        ------------------------------------------------------------
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

        FETCH NEXT FROM cur_approved_booking
        INTO @booking_id, @space_code, @start_time, @end_time;
    END;

    CLOSE cur_approved_booking;
    DEALLOCATE cur_approved_booking;
END;
GO


-- =====================================================
-- Trigger 4: Protect the schedule of a decided booking
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

-- =====================================================
-- Step 13: Post-migration verification
--
-- Expected row counts:
--   ROLE                  6
--   SPACE_TYPE            6
--   USERS                 20
--   SPACES                12
--   FACILITY              32
--   AUTO_USAGE_POLICY     0
--   BOOKING_REQUEST       30
--   BOOKING_DECISION      25
--   USAGE_SESSION         16
--   MAINTENANCE_RECORD    12
--   BOOKING_NOTIFICATION  0
-- =====================================================

SELECT 'ROLE'                  AS table_name, COUNT(*) AS row_count FROM ROLE
UNION ALL SELECT 'SPACE_TYPE',                 COUNT(*)             FROM SPACE_TYPE
UNION ALL SELECT 'USERS',                      COUNT(*)             FROM USERS
UNION ALL SELECT 'SPACES',                     COUNT(*)             FROM SPACES
UNION ALL SELECT 'FACILITY',                   COUNT(*)             FROM FACILITY
UNION ALL SELECT 'AUTO_USAGE_POLICY',          COUNT(*)             FROM AUTO_USAGE_POLICY
UNION ALL SELECT 'BOOKING_REQUEST',            COUNT(*)             FROM BOOKING_REQUEST
UNION ALL SELECT 'BOOKING_DECISION',           COUNT(*)             FROM BOOKING_DECISION
UNION ALL SELECT 'USAGE_SESSION',              COUNT(*)             FROM USAGE_SESSION
UNION ALL SELECT 'MAINTENANCE_RECORD',         COUNT(*)             FROM MAINTENANCE_RECORD
UNION ALL SELECT 'BOOKING_NOTIFICATION',       COUNT(*)             FROM BOOKING_NOTIFICATION
ORDER BY table_name;
GO
