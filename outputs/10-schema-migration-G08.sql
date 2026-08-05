-- ============================================================================
-- 10-schema-migration-G08.sql
-- Campus Space Management System - G08
-- Phase 1 -> Phase 2 schema and data migration (Microsoft SQL Server)
--
-- Source schema: 05-db-definition-G08.sql
-- Target schema: 09-updated-erd-and-logical-design-G08.md
--
-- Migration policy
--   * The migration is atomic: Phase 1 tables are staged, Phase 2 tables are
--     populated and validated, and staged tables are dropped only on success.
--   * Every legacy maintenance row is classified as out_of_service because
--     Phase 1 treated every active maintenance record as booking-blocking.
--   * Known Phase 1 usage_policy labels are mapped to role rows below. An
--     unknown non-null label stops the migration for explicit manual mapping.
--   * Phase 1 allowed an in-progress USAGE_SESSION to have no end/completing
--     staff. Phase 2 models only complete sessions. Such a row is retained by
--     using the scheduled booking end (never earlier than the actual start),
--     defaulting the completing staff to the check-in staff, and appending an
--     auditable note. No legacy usage row is silently discarded.
--   * ADVISORY_ACKNOWLEDGEMENT starts empty: Phase 1 recorded no such fact.
--
-- Re-run policy: this script intentionally stops if the Phase 2 schema already
-- exists. Restore a Phase 1 backup before running it again.
-- ============================================================================

USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- --------------------------------------------------------------------------
-- Phase 1 preflight checks
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.USERS', N'U') IS NULL
    THROW 51000, 'Phase 1 table dbo.USERS was not found.', 1;
IF OBJECT_ID(N'dbo.SPACES', N'U') IS NULL
    THROW 51001, 'Phase 1 table dbo.SPACES was not found.', 1;
IF OBJECT_ID(N'dbo.FACILITY', N'U') IS NULL
    THROW 51002, 'Phase 1 table dbo.FACILITY was not found.', 1;
IF OBJECT_ID(N'dbo.BOOKING_REQUEST', N'U') IS NULL
    THROW 51003, 'Phase 1 table dbo.BOOKING_REQUEST was not found.', 1;
IF OBJECT_ID(N'dbo.BOOKING_APPROVAL', N'U') IS NULL
    THROW 51004, 'Phase 1 table dbo.BOOKING_APPROVAL was not found.', 1;
IF OBJECT_ID(N'dbo.USAGE_SESSION', N'U') IS NULL
    THROW 51005, 'Phase 1 table dbo.USAGE_SESSION was not found.', 1;
IF OBJECT_ID(N'dbo.MAINTENANCE_RECORD', N'U') IS NULL
    THROW 51006, 'Phase 1 table dbo.MAINTENANCE_RECORD was not found.', 1;

IF OBJECT_ID(N'dbo.[USER]', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.[ROLE]', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.SPACE', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.SPACE_USAGE_POLICY', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.BOOKING_DECISION', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.ADVISORY_ACKNOWLEDGEMENT', N'U') IS NOT NULL
    THROW 51007, 'A Phase 2 target table already exists; migration was not started.', 1;

IF OBJECT_ID(N'dbo.P1_USERS_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P1_SPACES_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P1_FACILITY_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P1_BOOKING_REQUEST_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P1_BOOKING_APPROVAL_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P1_USAGE_SESSION_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P1_MAINTENANCE_RECORD_G08', N'U') IS NOT NULL
    THROW 51008, 'A G08 migration staging table already exists; migration was not started.', 1;

-- Four Phase 2 table names collide with Phase 1 table names.  They are built
-- under temporary names so SQL Server cannot bind statements later in this
-- batch to the old table definitions before sp_rename executes.
IF OBJECT_ID(N'dbo.P2_FACILITY_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P2_BOOKING_REQUEST_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P2_USAGE_SESSION_G08', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.P2_MAINTENANCE_RECORD_G08', N'U') IS NOT NULL
    THROW 51015, 'A G08 Phase 2 build table already exists; migration was not started.', 1;

IF EXISTS (
    SELECT 1
    FROM dbo.USERS
    WHERE role NOT IN (
        'student', 'lecturer', 'teaching_assistant', 'facility_staff',
        'department_administrator', 'facility_manager'
    )
)
BEGIN
    SELECT DISTINCT role AS unmapped_role
    FROM dbo.USERS
    WHERE role NOT IN (
        'student', 'lecturer', 'teaching_assistant', 'facility_staff',
        'department_administrator', 'facility_manager'
    );
    THROW 51009, 'Unmapped Phase 1 user role(s) found. Add an explicit mapping and rerun.', 1;
END;

IF EXISTS (
    SELECT 1
    FROM dbo.SPACES
    WHERE usage_policy IS NOT NULL
      AND usage_policy NOT IN (
          'general_teaching', 'authorized_users_only', 'meetings_only',
          'project_work', 'large_events', 'student_workspace'
      )
)
BEGIN
    SELECT DISTINCT usage_policy AS unmapped_usage_policy
    FROM dbo.SPACES
    WHERE usage_policy IS NOT NULL
      AND usage_policy NOT IN (
          'general_teaching', 'authorized_users_only', 'meetings_only',
          'project_work', 'large_events', 'student_workspace'
      );
    THROW 51010, 'Unmapped Phase 1 usage_policy value(s) found. Add an explicit mapping and rerun.', 1;
END;

IF EXISTS (
    SELECT 1
    FROM dbo.MAINTENANCE_RECORD
    WHERE status = 'completed' AND completion_time IS NULL
)
    THROW 51011, 'A completed legacy maintenance row has no completion_time.', 1;

IF EXISTS (
    SELECT 1
    FROM dbo.USAGE_SESSION AS us
    LEFT JOIN dbo.BOOKING_APPROVAL AS ba ON ba.booking_id = us.booking_id
    WHERE ba.booking_id IS NULL
)
    THROW 51012, 'A legacy usage session has no booking approval/decision to reference.', 1;

IF EXISTS (
    SELECT 1
    FROM dbo.USAGE_SESSION AS us
    JOIN dbo.BOOKING_REQUEST AS br ON br.booking_id = us.booking_id
    JOIN dbo.BOOKING_APPROVAL AS ba ON ba.booking_id = us.booking_id
    WHERE br.status = 'rejected'
       OR NULLIF(LTRIM(RTRIM(ba.rejection_reason)), '') IS NOT NULL
)
    THROW 51013, 'A legacy usage session is attached to a rejected booking.', 1;

IF EXISTS (SELECT 1 FROM dbo.USERS WHERE user_id = 'SYS_AUTO_G08')
    THROW 51014, 'Reserved automatic-decision account SYS_AUTO_G08 already exists.', 1;

DECLARE @p1_user_count        BIGINT = (SELECT COUNT_BIG(*) FROM dbo.USERS);
DECLARE @p1_space_count       BIGINT = (SELECT COUNT_BIG(*) FROM dbo.SPACES);
DECLARE @p1_facility_count    BIGINT = (SELECT COUNT_BIG(*) FROM dbo.FACILITY);
DECLARE @p1_booking_count     BIGINT = (SELECT COUNT_BIG(*) FROM dbo.BOOKING_REQUEST);
DECLARE @p1_approval_count    BIGINT = (SELECT COUNT_BIG(*) FROM dbo.BOOKING_APPROVAL);
DECLARE @p1_session_count     BIGINT = (SELECT COUNT_BIG(*) FROM dbo.USAGE_SESSION);
DECLARE @p1_maintenance_count BIGINT = (SELECT COUNT_BIG(*) FROM dbo.MAINTENANCE_RECORD);

BEGIN TRY
    BEGIN TRANSACTION;

    -- Preserve every source table under a temporary name while the target is
    -- built. Foreign keys continue to reference the same staged objects.
    EXEC sys.sp_rename N'dbo.USERS',             N'P1_USERS_G08',             N'OBJECT';
    EXEC sys.sp_rename N'dbo.SPACES',            N'P1_SPACES_G08',            N'OBJECT';
    EXEC sys.sp_rename N'dbo.FACILITY',          N'P1_FACILITY_G08',          N'OBJECT';
    EXEC sys.sp_rename N'dbo.BOOKING_REQUEST',   N'P1_BOOKING_REQUEST_G08',   N'OBJECT';
    EXEC sys.sp_rename N'dbo.BOOKING_APPROVAL',  N'P1_BOOKING_APPROVAL_G08',  N'OBJECT';
    EXEC sys.sp_rename N'dbo.USAGE_SESSION',     N'P1_USAGE_SESSION_G08',     N'OBJECT';
    EXEC sys.sp_rename N'dbo.MAINTENANCE_RECORD',N'P1_MAINTENANCE_RECORD_G08',N'OBJECT';

    -- ----------------------------------------------------------------------
    -- Phase 2 schema: exact relations and attributes from design 09
    -- ----------------------------------------------------------------------
    CREATE TABLE dbo.[ROLE] (
        role_id   INT         NOT NULL,
        role_name VARCHAR(50) NOT NULL,
        CONSTRAINT PK_ROLE PRIMARY KEY (role_id)
    );

    CREATE TABLE dbo.[USER] (
        user_id        VARCHAR(20)  NOT NULL,
        role_id        INT          NOT NULL,
        full_name      VARCHAR(100) NOT NULL,
        email          VARCHAR(100) NOT NULL,
        phone_number   VARCHAR(20)  NULL,
        department     VARCHAR(100) NULL,
        account_status VARCHAR(30)  NOT NULL
            CONSTRAINT DF_USER_account_status DEFAULT ('active'),
        CONSTRAINT PK_USER PRIMARY KEY (user_id),
        CONSTRAINT FK_USER_ROLE FOREIGN KEY (role_id)
            REFERENCES dbo.[ROLE](role_id),
        CONSTRAINT CK_USER_account_status CHECK (
            account_status IN ('active', 'inactive', 'suspended')
        )
    );

    CREATE TABLE dbo.SPACE (
        space_code     VARCHAR(20)  NOT NULL,
        space_name     VARCHAR(100) NOT NULL,
        space_type     VARCHAR(50)  NOT NULL,
        building       VARCHAR(50)  NOT NULL,
        floor          INT          NOT NULL,
        room_number    VARCHAR(20)  NOT NULL,
        capacity       INT          NOT NULL,
        current_status VARCHAR(30)  NOT NULL
            CONSTRAINT DF_SPACE_current_status DEFAULT ('available'),
        CONSTRAINT PK_SPACE PRIMARY KEY (space_code),
        CONSTRAINT CK_SPACE_capacity CHECK (capacity > 0),
        CONSTRAINT CK_SPACE_current_status CHECK (
            current_status IN ('available', 'in_use', 'temporarily_closed', 'retired')
        )
    );

    CREATE TABLE dbo.P2_FACILITY_G08 (
        facility_id   VARCHAR(20)  NOT NULL,
        space_code    VARCHAR(20)  NOT NULL,
        facility_name VARCHAR(100) NOT NULL,
        description   VARCHAR(MAX) NULL,
        CONSTRAINT PK_FACILITY PRIMARY KEY (facility_id),
        CONSTRAINT FK_FACILITY_SPACE FOREIGN KEY (space_code)
            REFERENCES dbo.SPACE(space_code)
    );

    CREATE TABLE dbo.SPACE_USAGE_POLICY (
        space_code VARCHAR(20) NOT NULL,
        role_id    INT         NOT NULL,
        CONSTRAINT PK_SPACE_USAGE_POLICY PRIMARY KEY (space_code, role_id),
        CONSTRAINT FK_SPACE_USAGE_POLICY_SPACE FOREIGN KEY (space_code)
            REFERENCES dbo.SPACE(space_code),
        CONSTRAINT FK_SPACE_USAGE_POLICY_ROLE FOREIGN KEY (role_id)
            REFERENCES dbo.[ROLE](role_id)
    );

    CREATE TABLE dbo.P2_BOOKING_REQUEST_G08 (
        booking_id           VARCHAR(20)  NOT NULL,
        user_id              VARCHAR(20)  NOT NULL,
        space_code           VARCHAR(20)  NOT NULL,
        start_time           DATETIME2(0) NOT NULL,
        end_time             DATETIME2(0) NOT NULL,
        purpose              VARCHAR(MAX) NULL,
        expected_participants INT         NOT NULL,
        booking_type         VARCHAR(50)  NOT NULL,
        status               VARCHAR(30)  NOT NULL
            CONSTRAINT DF_BOOKING_REQUEST_status DEFAULT ('pending'),
        CONSTRAINT PK_BOOKING_REQUEST PRIMARY KEY (booking_id),
        CONSTRAINT FK_BOOKING_REQUEST_USER FOREIGN KEY (user_id)
            REFERENCES dbo.[USER](user_id),
        CONSTRAINT FK_BOOKING_REQUEST_SPACE FOREIGN KEY (space_code)
            REFERENCES dbo.SPACE(space_code),
        CONSTRAINT CK_BOOKING_REQUEST_interval CHECK (end_time > start_time),
        CONSTRAINT CK_BOOKING_REQUEST_participants CHECK (expected_participants > 0),
        CONSTRAINT CK_BOOKING_REQUEST_type CHECK (
            booking_type IN (
                'lecture', 'examination', 'seminar', 'workshop', 'meeting',
                'student_activity', 'administrative_event'
            )
        ),
        CONSTRAINT CK_BOOKING_REQUEST_status CHECK (
            status IN (
                'pending', 'approved', 'rejected', 'cancelled',
                'checked_in', 'completed', 'no_show'
            )
        )
    );

    CREATE TABLE dbo.BOOKING_DECISION (
        decision_id       VARCHAR(20)  NOT NULL,
        booking_id        VARCHAR(20)  NOT NULL,
        is_approved       BIT          NOT NULL,
        is_automatic      BIT          NOT NULL,
        decided_by_staff  VARCHAR(20)  NOT NULL,
        decision_reason   VARCHAR(MAX) NULL,
        decision_time     DATETIME2(0) NOT NULL,
        CONSTRAINT PK_BOOKING_DECISION PRIMARY KEY (decision_id),
        CONSTRAINT UQ_BOOKING_DECISION_booking UNIQUE (booking_id),
        CONSTRAINT FK_BOOKING_DECISION_BOOKING FOREIGN KEY (booking_id)
            REFERENCES dbo.P2_BOOKING_REQUEST_G08(booking_id),
        CONSTRAINT FK_BOOKING_DECISION_USER FOREIGN KEY (decided_by_staff)
            REFERENCES dbo.[USER](user_id),
        CONSTRAINT CK_BOOKING_DECISION_rejection_reason CHECK (
            is_approved = 1
            OR NULLIF(LTRIM(RTRIM(decision_reason)), '') IS NOT NULL
        )
    );

    CREATE TABLE dbo.P2_USAGE_SESSION_G08 (
        session_id           VARCHAR(20)  NOT NULL,
        decision_id          VARCHAR(20)  NOT NULL,
        checked_in_by_staff  VARCHAR(20)  NOT NULL,
        completed_by_staff   VARCHAR(20)  NOT NULL,
        start_time           DATETIME2(0) NOT NULL,
        end_time             DATETIME2(0) NOT NULL,
        initial_condition    VARCHAR(MAX) NULL,
        final_condition      VARCHAR(MAX) NULL,
        usage_note           VARCHAR(MAX) NULL,
        CONSTRAINT PK_USAGE_SESSION PRIMARY KEY (session_id),
        CONSTRAINT UQ_USAGE_SESSION_decision UNIQUE (decision_id),
        CONSTRAINT FK_USAGE_SESSION_DECISION FOREIGN KEY (decision_id)
            REFERENCES dbo.BOOKING_DECISION(decision_id),
        CONSTRAINT FK_USAGE_SESSION_CHECKIN_USER FOREIGN KEY (checked_in_by_staff)
            REFERENCES dbo.[USER](user_id),
        CONSTRAINT FK_USAGE_SESSION_COMPLETION_USER FOREIGN KEY (completed_by_staff)
            REFERENCES dbo.[USER](user_id),
        CONSTRAINT CK_USAGE_SESSION_interval CHECK (end_time >= start_time)
    );

    CREATE TABLE dbo.P2_MAINTENANCE_RECORD_G08 (
        maintenance_id      VARCHAR(20)  NOT NULL,
        space_code          VARCHAR(20)  NOT NULL,
        report_user         VARCHAR(20)  NOT NULL,
        assigned_staff      VARCHAR(20)  NOT NULL,
        problem_description VARCHAR(MAX) NOT NULL,
        start_time          DATETIME2(0) NOT NULL,
        end_time            DATETIME2(0) NULL,
        status              VARCHAR(30)  NOT NULL
            CONSTRAINT DF_MAINTENANCE_RECORD_status DEFAULT ('pending'),
        result_note         VARCHAR(MAX) NULL,
        impact_level        VARCHAR(20)  NOT NULL,
        CONSTRAINT PK_MAINTENANCE_RECORD PRIMARY KEY (maintenance_id),
        CONSTRAINT FK_MAINTENANCE_RECORD_SPACE FOREIGN KEY (space_code)
            REFERENCES dbo.SPACE(space_code),
        CONSTRAINT FK_MAINTENANCE_RECORD_REPORT_USER FOREIGN KEY (report_user)
            REFERENCES dbo.[USER](user_id),
        CONSTRAINT FK_MAINTENANCE_RECORD_ASSIGNED_USER FOREIGN KEY (assigned_staff)
            REFERENCES dbo.[USER](user_id),
        CONSTRAINT CK_MAINTENANCE_RECORD_interval CHECK (
            end_time IS NULL OR end_time >= start_time
        ),
        CONSTRAINT CK_MAINTENANCE_RECORD_status CHECK (
            status IN ('pending', 'in_progress', 'completed', 'cancelled')
        ),
        CONSTRAINT CK_MAINTENANCE_RECORD_impact CHECK (
            impact_level IN ('advisory', 'out_of_service')
        ),
        CONSTRAINT CK_MAINTENANCE_RECORD_completed_end CHECK (
            status <> 'completed' OR end_time IS NOT NULL
        )
    );

    CREATE TABLE dbo.ADVISORY_ACKNOWLEDGEMENT (
        booking_id       VARCHAR(20)  NOT NULL,
        maintenance_id   VARCHAR(20)  NOT NULL,
        acknowledge_time DATETIME2(0) NOT NULL,
        CONSTRAINT PK_ADVISORY_ACKNOWLEDGEMENT
            PRIMARY KEY (booking_id, maintenance_id),
        CONSTRAINT FK_ADVISORY_ACKNOWLEDGEMENT_BOOKING FOREIGN KEY (booking_id)
            REFERENCES dbo.P2_BOOKING_REQUEST_G08(booking_id),
        CONSTRAINT FK_ADVISORY_ACKNOWLEDGEMENT_MAINTENANCE FOREIGN KEY (maintenance_id)
            REFERENCES dbo.P2_MAINTENANCE_RECORD_G08(maintenance_id)
    );

    -- ----------------------------------------------------------------------
    -- Phase 1 -> Phase 2 data mappings
    -- ----------------------------------------------------------------------
    INSERT INTO dbo.[ROLE] (role_id, role_name)
    VALUES
        (1, 'student'),
        (2, 'lecturer'),
        (3, 'teaching_assistant'),
        (4, 'facility_staff'),
        (5, 'department_administrator'),
        (6, 'facility_manager');

    INSERT INTO dbo.[USER] (
        user_id, role_id, full_name, email, phone_number, department, account_status
    )
    SELECT
        u.user_id,
        r.role_id,
        u.full_name,
        u.email,
        u.phone_number,
        u.department,
        u.account_status
    FROM dbo.P1_USERS_G08 AS u
    JOIN dbo.[ROLE] AS r ON r.role_name = u.role;

    -- The ERD requires a USER foreign key even for automatic decisions.
    INSERT INTO dbo.[USER] (
        user_id, role_id, full_name, email, phone_number, department, account_status
    )
    SELECT
        'SYS_AUTO_G08', role_id, 'G08 automatic booking service',
        'sys-auto-g08@local.invalid', NULL, 'System', 'active'
    FROM dbo.[ROLE]
    WHERE role_name = 'facility_manager';

    INSERT INTO dbo.SPACE (
        space_code, space_name, space_type, building, floor, room_number,
        capacity, current_status
    )
    SELECT
        space_code,
        space_name,
        space_type,
        building,
        floor,
        room_number,
        capacity,
        CASE WHEN current_status = 'under_maintenance'
             THEN 'available'
             ELSE current_status
        END
    FROM dbo.P1_SPACES_G08;

    INSERT INTO dbo.P2_FACILITY_G08 (facility_id, space_code, facility_name, description)
    SELECT facility_id, space_code, facility_name, description
    FROM dbo.P1_FACILITY_G08;

    -- Documented conversion of the six known Phase 1 free-text policies.
    -- A policy row is created only for the roles listed here.
    INSERT INTO dbo.SPACE_USAGE_POLICY (space_code, role_id)
    SELECT s.space_code, r.role_id
    FROM dbo.P1_SPACES_G08 AS s
    JOIN (VALUES
        ('general_teaching',      'student'),
        ('general_teaching',      'lecturer'),
        ('general_teaching',      'teaching_assistant'),
        ('general_teaching',      'department_administrator'),
        ('authorized_users_only', 'lecturer'),
        ('authorized_users_only', 'teaching_assistant'),
        ('authorized_users_only', 'facility_staff'),
        ('authorized_users_only', 'facility_manager'),
        ('meetings_only',         'student'),
        ('meetings_only',         'lecturer'),
        ('meetings_only',         'teaching_assistant'),
        ('meetings_only',         'facility_staff'),
        ('meetings_only',         'department_administrator'),
        ('meetings_only',         'facility_manager'),
        ('project_work',          'student'),
        ('project_work',          'lecturer'),
        ('project_work',          'teaching_assistant'),
        ('large_events',          'lecturer'),
        ('large_events',          'department_administrator'),
        ('large_events',          'facility_manager'),
        ('student_workspace',     'student'),
        ('student_workspace',     'teaching_assistant')
    ) AS m(usage_policy, role_name)
        ON m.usage_policy = s.usage_policy
    JOIN dbo.[ROLE] AS r
        ON r.role_name = m.role_name;

    INSERT INTO dbo.P2_BOOKING_REQUEST_G08 (
        booking_id, user_id, space_code, start_time, end_time, purpose,
        expected_participants, booking_type, status
    )
    SELECT
        booking_id,
        user_id,
        space_code,
        CONVERT(DATETIME2(0), requested_start_time),
        CONVERT(DATETIME2(0), requested_end_time),
        purpose,
        expected_participants,
        booking_type,
        status
    FROM dbo.P1_BOOKING_REQUEST_G08;

    INSERT INTO dbo.BOOKING_DECISION (
        decision_id, booking_id, is_approved, is_automatic,
        decided_by_staff, decision_reason, decision_time
    )
    SELECT
        ba.approval_id,
        ba.booking_id,
        CASE
            WHEN br.status = 'rejected'
              OR NULLIF(LTRIM(RTRIM(ba.rejection_reason)), '') IS NOT NULL
            THEN CONVERT(BIT, 0)
            ELSE CONVERT(BIT, 1)
        END,
        CONVERT(BIT, 0),
        ba.decided_by_user_id,
        CASE
            WHEN NULLIF(LTRIM(RTRIM(ba.rejection_reason)), '') IS NOT NULL
             AND NULLIF(LTRIM(RTRIM(ba.decision_note)), '') IS NOT NULL
             AND ba.rejection_reason <> ba.decision_note
                THEN CONCAT(ba.decision_note, '; ', ba.rejection_reason)
            ELSE COALESCE(
                NULLIF(LTRIM(RTRIM(ba.rejection_reason)), ''),
                NULLIF(LTRIM(RTRIM(ba.decision_note)), ''),
                CASE WHEN br.status = 'rejected'
                     THEN 'legacy_rejection_without_recorded_reason' END
            )
        END,
        CONVERT(DATETIME2(0), ba.decision_time)
    FROM dbo.P1_BOOKING_APPROVAL_G08 AS ba
    JOIN dbo.P1_BOOKING_REQUEST_G08 AS br
        ON br.booking_id = ba.booking_id;

    INSERT INTO dbo.P2_USAGE_SESSION_G08 (
        session_id, decision_id, checked_in_by_staff, completed_by_staff,
        start_time, end_time, initial_condition, final_condition, usage_note
    )
    SELECT
        us.session_id,
        d.decision_id,
        us.checked_in_by_user_id,
        COALESCE(us.completed_by_user_id, us.checked_in_by_user_id),
        CONVERT(DATETIME2(0), us.actual_start_time),
        CONVERT(DATETIME2(0),
            COALESCE(
                us.actual_end_time,
                CASE
                    WHEN br.end_time >= CONVERT(DATETIME2(0), us.actual_start_time)
                        THEN br.end_time
                    ELSE CONVERT(DATETIME2(0), us.actual_start_time)
                END
            )
        ),
        us.initial_condition,
        COALESCE(us.final_condition, us.initial_condition),
        CASE
            WHEN us.actual_end_time IS NULL OR us.completed_by_user_id IS NULL
                THEN CONCAT(
                    CASE WHEN NULLIF(us.usage_notes, '') IS NULL
                         THEN '' ELSE CONCAT(us.usage_notes, '; ') END,
                    'MIGRATION: incomplete Phase 1 session retained; scheduled end ',
                    'and/or check-in staff used for required completion fields'
                )
            ELSE us.usage_notes
        END
    FROM dbo.P1_USAGE_SESSION_G08 AS us
    JOIN dbo.BOOKING_DECISION AS d
        ON d.booking_id = us.booking_id AND d.is_approved = 1
    JOIN dbo.P2_BOOKING_REQUEST_G08 AS br
        ON br.booking_id = us.booking_id;

    INSERT INTO dbo.P2_MAINTENANCE_RECORD_G08 (
        maintenance_id, space_code, report_user, assigned_staff,
        problem_description, start_time, end_time, status, result_note,
        impact_level
    )
    SELECT
        maintenance_id,
        space_code,
        reporter_user_id,
        assigned_staff_user_id,
        problem_description,
        CONVERT(DATETIME2(0), start_time),
        CONVERT(DATETIME2(0), completion_time),
        status,
        result_note,
        'out_of_service'
    FROM dbo.P1_MAINTENANCE_RECORD_G08;

    -- No INSERT into ADVISORY_ACKNOWLEDGEMENT: Phase 1 had no acknowledgement
    -- facts and inventing historical acknowledgements would be incorrect.

    -- ----------------------------------------------------------------------
    -- Migration validation before any source table is removed
    -- ----------------------------------------------------------------------
    IF (SELECT COUNT_BIG(*) FROM dbo.[USER]) <> @p1_user_count + 1
        THROW 51020, 'USER row-count validation failed.', 1;
    IF (SELECT COUNT_BIG(*) FROM dbo.SPACE) <> @p1_space_count
        THROW 51021, 'SPACE row-count validation failed.', 1;
    IF (SELECT COUNT_BIG(*) FROM dbo.P2_FACILITY_G08) <> @p1_facility_count
        THROW 51022, 'FACILITY row-count validation failed.', 1;
    IF (SELECT COUNT_BIG(*) FROM dbo.P2_BOOKING_REQUEST_G08) <> @p1_booking_count
        THROW 51023, 'BOOKING_REQUEST row-count validation failed.', 1;
    IF (SELECT COUNT_BIG(*) FROM dbo.BOOKING_DECISION) <> @p1_approval_count
        THROW 51024, 'BOOKING_DECISION row-count validation failed.', 1;
    IF (SELECT COUNT_BIG(*) FROM dbo.P2_USAGE_SESSION_G08) <> @p1_session_count
        THROW 51025, 'USAGE_SESSION row-count validation failed.', 1;
    IF (SELECT COUNT_BIG(*) FROM dbo.P2_MAINTENANCE_RECORD_G08) <> @p1_maintenance_count
        THROW 51026, 'MAINTENANCE_RECORD row-count validation failed.', 1;
    IF EXISTS (SELECT 1 FROM dbo.P2_MAINTENANCE_RECORD_G08 WHERE impact_level <> 'out_of_service')
        THROW 51027, 'Legacy maintenance impact-level validation failed.', 1;
    IF EXISTS (
        SELECT 1
        FROM dbo.P1_SPACES_G08 AS old_space
        WHERE old_space.usage_policy IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.SPACE_USAGE_POLICY AS policy
              WHERE policy.space_code = old_space.space_code
          )
    )
        THROW 51028, 'SPACE_USAGE_POLICY coverage validation failed.', 1;
    IF EXISTS (
        SELECT 1
        FROM dbo.P2_USAGE_SESSION_G08 AS us
        JOIN dbo.BOOKING_DECISION AS d ON d.decision_id = us.decision_id
        WHERE d.is_approved <> 1
    )
        THROW 51029, 'A migrated usage session does not reference an approved decision.', 1;
    IF EXISTS (
        SELECT booking_id
        FROM dbo.BOOKING_DECISION
        GROUP BY booking_id
        HAVING COUNT_BIG(*) > 1
    )
        THROW 51030, 'More than one decision was migrated for a booking.', 1;
    IF (SELECT COUNT_BIG(*) FROM dbo.ADVISORY_ACKNOWLEDGEMENT) <> 0
        THROW 51031, 'ADVISORY_ACKNOWLEDGEMENT must be empty after Phase 1 migration.', 1;

    -- Drop staged Phase 1 objects in dependency order only after validation.
    DROP TABLE dbo.P1_USAGE_SESSION_G08;
    DROP TABLE dbo.P1_BOOKING_APPROVAL_G08;
    DROP TABLE dbo.P1_MAINTENANCE_RECORD_G08;
    DROP TABLE dbo.P1_BOOKING_REQUEST_G08;
    DROP TABLE dbo.P1_FACILITY_G08;
    DROP TABLE dbo.P1_SPACES_G08;
    DROP TABLE dbo.P1_USERS_G08;

    -- The original names are now free.  Foreign-key metadata follows these
    -- object renames, so all relationships retain their validated targets.
    EXEC sys.sp_rename N'dbo.P2_FACILITY_G08',          N'FACILITY',          N'OBJECT';
    EXEC sys.sp_rename N'dbo.P2_BOOKING_REQUEST_G08',   N'BOOKING_REQUEST',   N'OBJECT';
    EXEC sys.sp_rename N'dbo.P2_USAGE_SESSION_G08',     N'USAGE_SESSION',     N'OBJECT';
    EXEC sys.sp_rename N'dbo.P2_MAINTENANCE_RECORD_G08',N'MAINTENANCE_RECORD',N'OBJECT';

    COMMIT TRANSACTION;

    SELECT
        'migration_succeeded' AS result,
        (SELECT COUNT_BIG(*) FROM dbo.[ROLE]) AS role_rows,
        (SELECT COUNT_BIG(*) FROM dbo.[USER]) AS user_rows,
        (SELECT COUNT_BIG(*) FROM dbo.SPACE) AS space_rows,
        (SELECT COUNT_BIG(*) FROM dbo.SPACE_USAGE_POLICY) AS policy_rows,
        (SELECT COUNT_BIG(*) FROM dbo.BOOKING_REQUEST) AS booking_rows,
        (SELECT COUNT_BIG(*) FROM dbo.BOOKING_DECISION) AS decision_rows,
        (SELECT COUNT_BIG(*) FROM dbo.USAGE_SESSION) AS usage_session_rows,
        (SELECT COUNT_BIG(*) FROM dbo.MAINTENANCE_RECORD) AS maintenance_rows,
        (SELECT COUNT_BIG(*) FROM dbo.ADVISORY_ACKNOWLEDGEMENT) AS acknowledgement_rows;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
