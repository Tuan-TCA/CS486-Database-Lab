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
-- Step 12: Create Trigger for Automated Approval
--
-- Automatically approves booking requests that match the
-- requirements defined in AUTO_USAGE_POLICY.
-- =====================================================

GO
CREATE TRIGGER trg_G08_AutoApproveBooking
ON BOOKING_REQUEST
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @booking_id VARCHAR(20);

    DECLARE cur_auto_approve CURSOR LOCAL FOR
        SELECT i.booking_id
        FROM inserted i
        JOIN USERS u ON i.user_id = u.user_id
        JOIN SPACES s ON i.space_code = s.space_code
        JOIN AUTO_USAGE_POLICY p ON p.role_id = u.role_id AND p.space_type_id = s.space_type_id
        WHERE i.status = 'pending';

    OPEN cur_auto_approve;
    FETCH NEXT FROM cur_auto_approve INTO @booking_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Execute the concurrent-safe approval procedure for this booking.
        -- Note: If this procedure throws an error (e.g., due to overlapping time),
        -- it rolls back the transaction. Since this trigger is part of the INSERT
        -- statement's transaction, the INSERT will fail and be rolled back.
        EXEC dbo.usp_G08_ApproveBookingConcurrentSafe
            @booking_id = @booking_id,
            @is_automatic = 1,
            @decided_by_staff = NULL,
            @decision_reason = 'Automated approval based on policy';

        FETCH NEXT FROM cur_auto_approve INTO @booking_id;
    END

    CLOSE cur_auto_approve;
    DEALLOCATE cur_auto_approve;
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
