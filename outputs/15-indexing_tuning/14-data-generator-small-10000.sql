-- ============================================================================
-- 14-data-generator-G08.sql
-- Campus Space Management System - G08
-- Deterministic Phase 2 data generator (Microsoft SQL Server)
--
-- Small test output
--   * exactly 10,000 BOOKING_REQUEST rows with the reserved GB######### IDs;
--   * bookings still span three academic years: 2023-09-01 through 2026-08-31;
--   * 2,000 requester accounts, three processing/staff accounts, 50 spaces;
--   * decisions, completed usage sessions, cancellations, no-shows,
--     rejections, pending requests, maintenance at both impact levels, and
--     booking notifications;
--   * no overlapping generated approved/non-cancelled bookings per space.
--
-- Normal run order:
--   1. 10-schema-migration-G08.sql
--   2. 12-concurrency-implementation-G08.sql
--   3. triggers.sql
--   4. this generator
--
-- The generator also works when the booking trigger is absent/disabled.
-- It is deterministic and rerunnable: rows belonging to generated GB bookings
-- are replaced, including decisions created by trg_G08_ProcessNewBooking,
-- while migrated Phase 1 rows and unrelated rows are left unchanged.
--
-- Reserved generated ID namespaces
--   GU######      users                 GSP###       spaces
--   GF#####       facilities            GB#########  bookings
--   GD#########   decisions             GSN######### usage sessions
--   GM#########   maintenance records   ADVISORY     booking notifications
--   GSTAFF01, GSTAFF02, GMANAGER01 are generated staff/manager accounts.
--   Legacy GSYSTEM01 is removed on rerun but is no longer recreated or used.
-- ============================================================================

USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @BookingCount INT = 10000;
DECLARE @RequesterCount INT = 2000;
DECLARE @SpaceCount INT = 50;
DECLARE @DataStart DATE = '2023-09-01';
DECLARE @DataEndExclusive DATE = '2026-09-01';
DECLARE @DataDays INT = DATEDIFF(DAY, @DataStart, @DataEndExclusive);

IF @BookingCount <> 10000
    THROW 52000, 'This small test generator is validated for exactly 10,000 booking records.', 1;

-- --------------------------------------------------------------------------
-- Target-schema preflight
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.ROLE', N'U') IS NULL
   OR OBJECT_ID(N'dbo.USERS', N'U') IS NULL
   OR OBJECT_ID(N'dbo.SPACES', N'U') IS NULL
   OR OBJECT_ID(N'dbo.FACILITY', N'U') IS NULL
   OR OBJECT_ID(N'dbo.SPACE_TYPE', N'U') IS NULL
   OR OBJECT_ID(N'dbo.AUTO_USAGE_POLICY', N'U') IS NULL
   OR OBJECT_ID(N'dbo.BOOKING_REQUEST', N'U') IS NULL
   OR OBJECT_ID(N'dbo.BOOKING_DECISION', N'U') IS NULL
   OR OBJECT_ID(N'dbo.USAGE_SESSION', N'U') IS NULL
   OR OBJECT_ID(N'dbo.MAINTENANCE_RECORD', N'U') IS NULL
   OR OBJECT_ID(N'dbo.BOOKING_NOTIFICATION', N'U') IS NULL
    THROW 52003, 'The Phase 2 schema is incomplete. Run 10-schema-migration-G08.sql first.', 1;

IF COL_LENGTH(N'dbo.BOOKING_REQUEST', N'start_time') IS NULL
   OR COL_LENGTH(N'dbo.BOOKING_REQUEST', N'end_time') IS NULL
   OR COL_LENGTH(N'dbo.MAINTENANCE_RECORD', N'impact_level') IS NULL
   OR COL_LENGTH(N'dbo.USAGE_SESSION', N'decision_id') IS NULL
   OR COL_LENGTH(N'dbo.SPACES', N'space_type_id') IS NULL
    THROW 52004, 'The database does not match updated design 09.', 1;

DECLARE @student_role INT = (
    SELECT MIN(role_id) FROM dbo.ROLE WHERE role_name = 'student'
);
DECLARE @lecturer_role INT = (
    SELECT MIN(role_id) FROM dbo.ROLE WHERE role_name = 'lecturer'
);
DECLARE @ta_role INT = (
    SELECT MIN(role_id) FROM dbo.ROLE WHERE role_name = 'teaching_assistant'
);
DECLARE @staff_role INT = (
    SELECT MIN(role_id) FROM dbo.ROLE WHERE role_name = 'facility_staff'
);
DECLARE @admin_role INT = (
    SELECT MIN(role_id) FROM dbo.ROLE WHERE role_name = 'department_administrator'
);
DECLARE @manager_role INT = (
    SELECT MIN(role_id) FROM dbo.ROLE WHERE role_name = 'facility_manager'
);

IF @student_role IS NULL OR @lecturer_role IS NULL OR @ta_role IS NULL
   OR @staff_role IS NULL OR @admin_role IS NULL OR @manager_role IS NULL
    THROW 52005, 'One or more required role names are missing.', 1;

-- If Trigger 1 is installed and enabled, its automatic approval path depends
-- on the concurrency-safe procedure from Step 12.
DECLARE @ProcessBookingTriggerEnabled BIT =
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.triggers
            WHERE object_id = OBJECT_ID(N'dbo.trg_G08_ProcessNewBooking')
              AND is_disabled = 0
        ) THEN 1
        ELSE 0
    END;

IF @ProcessBookingTriggerEnabled = 1
   AND OBJECT_ID(N'dbo.usp_G08_ApproveBookingConcurrentSafe', N'P') IS NULL
    THROW 52007,
        'trg_G08_ProcessNewBooking is enabled but usp_G08_ApproveBookingConcurrentSafe is missing. Run Step 12 first.',
        1;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ----------------------------------------------------------------------
    -- Remove only rows from this generator's reserved namespaces.
    -- ----------------------------------------------------------------------
    DELETE FROM dbo.BOOKING_NOTIFICATION
    WHERE (LEFT(booking_id, 2) = 'GB'
           AND TRY_CONVERT(BIGINT, SUBSTRING(booking_id, 3, 18)) IS NOT NULL)
       OR (LEFT(maintenance_id, 2) = 'GM'
           AND TRY_CONVERT(BIGINT, SUBSTRING(maintenance_id, 3, 18)) IS NOT NULL);

    -- Remove usage sessions and decisions by generated booking ownership,
    -- not only by decision_id prefix. This also removes G08D... decisions
    -- created automatically by trg_G08_ProcessNewBooking on a previous run.
    DELETE us
    FROM dbo.USAGE_SESSION AS us
    JOIN dbo.BOOKING_DECISION AS bd
      ON bd.decision_id = us.decision_id
    JOIN dbo.BOOKING_REQUEST AS br
      ON br.booking_id = bd.booking_id
    WHERE LEFT(br.booking_id, 2) = 'GB'
      AND TRY_CONVERT(BIGINT, SUBSTRING(br.booking_id, 3, 18)) IS NOT NULL;

    DELETE bd
    FROM dbo.BOOKING_DECISION AS bd
    JOIN dbo.BOOKING_REQUEST AS br
      ON br.booking_id = bd.booking_id
    WHERE LEFT(br.booking_id, 2) = 'GB'
      AND TRY_CONVERT(BIGINT, SUBSTRING(br.booking_id, 3, 18)) IS NOT NULL;

    DELETE FROM dbo.BOOKING_REQUEST
    WHERE SUBSTRING(booking_id, 1, 2) = 'GB'
      AND TRY_CONVERT(BIGINT, SUBSTRING(booking_id, 3, 18)) IS NOT NULL;

    DELETE FROM dbo.MAINTENANCE_RECORD
    WHERE SUBSTRING(maintenance_id, 1, 2) = 'GM'
      AND TRY_CONVERT(BIGINT, SUBSTRING(maintenance_id, 3, 18)) IS NOT NULL;

    DELETE FROM dbo.FACILITY
    WHERE SUBSTRING(space_code, 1, 3) = 'GSP'
      AND TRY_CONVERT(INT, SUBSTRING(space_code, 4, 17)) IS NOT NULL;

    DELETE FROM dbo.SPACES
    WHERE SUBSTRING(space_code, 1, 3) = 'GSP'
      AND TRY_CONVERT(INT, SUBSTRING(space_code, 4, 17)) IS NOT NULL;

    DELETE FROM dbo.USERS
    WHERE (LEFT(user_id, 2) = 'GU'
           AND TRY_CONVERT(INT, SUBSTRING(user_id, 3, 18)) IS NOT NULL)
       OR user_id IN ('GSTAFF01', 'GSTAFF02', 'GMANAGER01', 'GSYSTEM01');

    -- A reusable deterministic integer set. The six decimal digits support up
    -- to 1,000,000 seed rows without depending on the size of system catalogs.
    CREATE TABLE #N (
        n INT NOT NULL PRIMARY KEY
    );

    ;WITH
    E1(d) AS (
        SELECT d
        FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS digits(d)
    ),
    E2(n) AS (
        SELECT a.d * 10 + b.d
        FROM E1 AS a CROSS JOIN E1 AS b
    ),
    E4(n) AS (
        SELECT a.n * 100 + b.n
        FROM E2 AS a CROSS JOIN E2 AS b
    ),
    E6(n) AS (
        SELECT a.n * 10000 + b.n
        FROM E2 AS a CROSS JOIN E4 AS b
    )
    INSERT INTO #N (n)
    SELECT TOP (@BookingCount) n + 1
    FROM E6
    ORDER BY n;

    IF (SELECT COUNT_BIG(*) FROM #N) <> @BookingCount
        THROW 52006, 'Integer seed generation failed.', 1;

    -- ----------------------------------------------------------------------
    -- Users
    -- ----------------------------------------------------------------------
    INSERT INTO dbo.USERS (
        user_id, role_id, full_name, email, phone_number, department, account_status
    )
    VALUES
        ('GSTAFF01', @staff_role, 'Generated Facility Staff 01',
         'gstaff01@g08.example', '0908000001', 'Facilities', 'active'),
        ('GSTAFF02', @staff_role, 'Generated Facility Staff 02',
         'gstaff02@g08.example', '0908000002', 'Facilities', 'active'),
        ('GMANAGER01', @manager_role, 'Generated Facility Manager 01',
         'gmanager01@g08.example', '0908000003', 'Facilities', 'active');

    INSERT INTO dbo.USERS (
        user_id, role_id, full_name, email, phone_number, department, account_status
    )
    SELECT
        CONCAT('GU', RIGHT(CONCAT('000000', n), 6)),
        CASE
            WHEN n <= 1200 THEN @student_role
            WHEN n <= 1600 THEN @lecturer_role
            WHEN n <= 1800 THEN @ta_role
            WHEN n <= 1880 THEN @staff_role
            WHEN n <= 1960 THEN @admin_role
            ELSE @manager_role
        END,
        CONCAT('Generated User ', RIGHT(CONCAT('000000', n), 6)),
        CONCAT('gu', RIGHT(CONCAT('000000', n), 6), '@g08.example'),
        CONCAT('091', RIGHT(CONCAT('0000000', n), 7)),
        CASE n % 6
            WHEN 0 THEN 'Computer Science'
            WHEN 1 THEN 'Software Engineering'
            WHEN 2 THEN 'Data Science'
            WHEN 3 THEN 'Artificial Intelligence'
            WHEN 4 THEN 'Information Systems'
            ELSE 'Administration'
        END,
        'active'
    FROM #N
    WHERE n <= @RequesterCount;

    -- ----------------------------------------------------------------------
    -- Spaces, facilities, and role-based auto usage policies
    -- ----------------------------------------------------------------------
    INSERT INTO dbo.SPACES (
        space_code, space_name, space_type_id, building, floor, room_number,
        capacity, current_status
    )
    SELECT
        CONCAT('GSP', RIGHT(CONCAT('000', nums.n), 3)),
        CONCAT('generated_',
            CASE (nums.n - 1) % 5
                WHEN 0 THEN 'classroom'
                WHEN 1 THEN 'computer_lab'
                WHEN 2 THEN 'meeting_room'
                WHEN 3 THEN 'project_lab'
                ELSE 'auditorium'
            END, '_', RIGHT(CONCAT('000', nums.n), 3)),
        st.space_type_id,
        CONCAT('G', CHAR(65 + ((nums.n - 1) % 5))),
        1 + ((nums.n - 1) % 5),
        CONVERT(VARCHAR(20), 100 + nums.n),
        CASE (nums.n - 1) % 5
            WHEN 0 THEN 60 + (nums.n % 3) * 20
            WHEN 1 THEN 35 + (nums.n % 4) * 5
            WHEN 2 THEN 16 + (nums.n % 5) * 4
            WHEN 3 THEN 30 + (nums.n % 4) * 5
            ELSE 180 + (nums.n % 4) * 40
        END,
        'available'
    FROM #N AS nums
    CROSS APPLY (VALUES (
        CASE (nums.n - 1) % 5
            WHEN 0 THEN 'classroom'
            WHEN 1 THEN 'computer_laboratory'
            WHEN 2 THEN 'meeting_room'
            WHEN 3 THEN 'project_laboratory'
            ELSE 'auditorium'
        END
    )) AS type_calc(space_type_name)
    JOIN dbo.SPACE_TYPE AS st ON st.space_type_name = type_calc.space_type_name
    WHERE nums.n <= @SpaceCount;

    INSERT INTO dbo.FACILITY (facility_id, space_code, facility_name, description)
    SELECT
        CONCAT(
            'GF', RIGHT(CONCAT('000', x.space_number), 3),
            RIGHT(CONCAT('00', v.facility_number), 2)
        ),
        s.space_code,
        CASE v.facility_number
            WHEN 1 THEN 'projector'
            WHEN 2 THEN CASE
                WHEN st.space_type_name IN ('computer_laboratory', 'project_laboratory')
                    THEN 'computer'
                WHEN st.space_type_name = 'auditorium' THEN 'microphone'
                ELSE 'whiteboard'
            END
            ELSE CASE
                WHEN st.space_type_name = 'computer_laboratory' THEN 'printer'
                WHEN st.space_type_name = 'auditorium' THEN 'speaker'
                ELSE 'air_conditioner'
            END
        END,
        CONCAT('generated facility ', v.facility_number, ' for ', s.space_code)
    FROM dbo.SPACES AS s
    JOIN dbo.SPACE_TYPE AS st ON st.space_type_id = s.space_type_id
    CROSS APPLY (VALUES (TRY_CONVERT(INT, SUBSTRING(s.space_code, 4, 17)))) AS x(space_number)
    CROSS JOIN (VALUES (1), (2), (3)) AS v(facility_number)
    WHERE LEFT(s.space_code, 3) = 'GSP'
      AND x.space_number IS NOT NULL;

    -- Add the generator's default policies without deleting or overwriting
    -- unrelated policies that may already exist. This keeps the script rerunnable
    -- while preserving externally managed AUTO_USAGE_POLICY rows.
    ;WITH desired_policy AS (
        SELECT st.space_type_id, @student_role AS role_id
        FROM dbo.SPACE_TYPE AS st
        WHERE st.space_type_name IN ('classroom', 'computer_laboratory', 'meeting_room', 'project_laboratory')

        UNION ALL

        SELECT st.space_type_id, @lecturer_role
        FROM dbo.SPACE_TYPE AS st

        UNION ALL

        SELECT st.space_type_id, @ta_role
        FROM dbo.SPACE_TYPE AS st
        WHERE st.space_type_name IN ('classroom', 'computer_laboratory', 'meeting_room', 'project_laboratory')

        UNION ALL

        SELECT st.space_type_id, @staff_role
        FROM dbo.SPACE_TYPE AS st
        WHERE st.space_type_name = 'meeting_room'

        UNION ALL

        SELECT st.space_type_id, @admin_role
        FROM dbo.SPACE_TYPE AS st
        WHERE st.space_type_name IN ('classroom', 'meeting_room', 'auditorium')

        UNION ALL

        SELECT st.space_type_id, @manager_role
        FROM dbo.SPACE_TYPE AS st
        WHERE st.space_type_name IN ('meeting_room', 'auditorium')
    )
    INSERT INTO dbo.AUTO_USAGE_POLICY (space_type_id, role_id)
    SELECT dp.space_type_id, dp.role_id
    FROM desired_policy AS dp
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.AUTO_USAGE_POLICY AS existing_policy
        WHERE existing_policy.space_type_id = dp.space_type_id
          AND existing_policy.role_id = dp.role_id
    );

    -- ----------------------------------------------------------------------
    -- Booking seed: two non-overlapping daily slots per generated space.
    -- Multiplication by 37 permutes booking days across the full three-year
    -- interval (37 and @DataDays are coprime), avoiding a synthetic date ramp.
    -- ----------------------------------------------------------------------
    CREATE TABLE #BookingSeed (
        n                     INT          NOT NULL PRIMARY KEY,
        booking_id            VARCHAR(20)  NOT NULL,
        user_id               VARCHAR(20)  NOT NULL,
        space_code            VARCHAR(20)  NOT NULL,
        space_type_name       VARCHAR(50)  NOT NULL,
        capacity              INT          NOT NULL,
        start_time            DATETIME2(0) NOT NULL,
        end_time              DATETIME2(0) NOT NULL,
        purpose               VARCHAR(200) NOT NULL,
        expected_participants INT          NOT NULL,
        booking_type          VARCHAR(50)  NOT NULL,
        status                VARCHAR(30)  NOT NULL
    );

    INSERT INTO #BookingSeed (
        n, booking_id, user_id, space_code, space_type_name, capacity,
        start_time, end_time, purpose, expected_participants,
        booking_type, status
    )
    SELECT
        nums.n,
        CONCAT('GB', RIGHT(CONCAT('000000000', nums.n), 9)),
        CONCAT('GU', RIGHT(CONCAT('000000', usr.user_number), 6)),
        sp.space_code,
        st.space_type_name,
        sp.capacity,
        tm.start_time,
        DATEADD(HOUR, attrs.duration_hours, tm.start_time),
        CONCAT('generated_', attrs.booking_type, '_',
               RIGHT(CONCAT('000000000', nums.n), 9)),
        CASE
            WHEN stat.status = 'rejected' AND nums.n % 2 = 0
                THEN sp.capacity + 1 + (nums.n % 20)
            ELSE 1 + ((nums.n * 13) % sp.capacity)
        END,
        attrs.booking_type,
        stat.status
    FROM #N AS nums
    CROSS APPLY (VALUES (
        1 + ((nums.n - 1) % @SpaceCount),
        (nums.n - 1) / @SpaceCount
    )) AS seq(space_number, space_cycle)
    JOIN dbo.SPACES AS sp
        ON sp.space_code = CONCAT('GSP', RIGHT(CONCAT('000', seq.space_number), 3))
    JOIN dbo.SPACE_TYPE AS st
        ON st.space_type_id = sp.space_type_id
    CROSS APPLY (VALUES (
        seq.space_cycle % 2,
        seq.space_cycle / 2
    )) AS slot(slot_number, day_sequence)
    CROSS APPLY (VALUES (
        (slot.day_sequence * 37 + seq.space_number * 11) % @DataDays
    )) AS cal(day_offset)
    CROSS APPLY (VALUES (
        CONVERT(DATETIME2(0), DATEADD(
            HOUR,
            CASE slot.slot_number WHEN 0 THEN 8 ELSE 13 END,
            CONVERT(DATETIME2(0), DATEADD(DAY, cal.day_offset, @DataStart))
        ))
    )) AS tm(start_time)
    CROSS APPLY (VALUES (
        CASE
            WHEN seq.space_cycle % 100 < 72 THEN 'completed'
            WHEN seq.space_cycle % 100 < 80 THEN 'no_show'
            WHEN seq.space_cycle % 100 < 87 THEN 'cancelled'
            WHEN seq.space_cycle % 100 < 93 THEN 'rejected'
            WHEN seq.space_cycle % 100 < 98 THEN 'approved'
            ELSE 'pending'
        END
    )) AS stat(status)
    CROSS APPLY (VALUES (
        CASE st.space_type_name
            WHEN 'classroom' THEN
                CASE WHEN seq.space_cycle % 4 = 0 THEN 'examination' ELSE 'lecture' END
            WHEN 'computer_laboratory' THEN 'workshop'
            WHEN 'meeting_room' THEN
                CASE WHEN seq.space_cycle % 3 = 0 THEN 'administrative_event' ELSE 'meeting' END
            WHEN 'project_laboratory' THEN
                CASE WHEN seq.space_cycle % 3 = 0 THEN 'student_activity' ELSE 'workshop' END
            ELSE
                CASE WHEN seq.space_cycle % 4 = 0 THEN 'administrative_event' ELSE 'seminar' END
        END,
        CASE st.space_type_name
            WHEN 'classroom' THEN CASE WHEN seq.space_cycle % 4 = 0 THEN 3 ELSE 2 END
            WHEN 'meeting_room' THEN 2
            ELSE 3
        END
    )) AS attrs(booking_type, duration_hours)
    CROSS APPLY (VALUES (
        -- Deliberately generate both policy-eligible and non-eligible role/type
        -- pairs. BOOKING_DECISION.is_automatic is derived later from the actual
        -- AUTO_USAGE_POLICY table, never from this selection pattern itself.
        CASE st.space_type_name
            WHEN 'classroom' THEN CASE
                WHEN seq.space_cycle % 2 = 0 THEN 1 + ((nums.n * 17) % 1200)       -- student: eligible
                ELSE 1961 + ((nums.n * 17) % 40)                                  -- manager: staff workflow
            END
            WHEN 'computer_laboratory' THEN CASE
                WHEN seq.space_cycle % 2 = 0 THEN 1 + ((nums.n * 17) % 1200)       -- student: eligible
                ELSE 1881 + ((nums.n * 17) % 80)                                  -- administrator: staff workflow
            END
            WHEN 'meeting_room' THEN CASE
                WHEN seq.space_cycle % 2 = 0 THEN 1201 + ((nums.n * 17) % 400)     -- lecturer: eligible
                ELSE 1801 + ((nums.n * 17) % 80)                                  -- facility staff: eligible
            END
            WHEN 'project_laboratory' THEN CASE
                WHEN seq.space_cycle % 2 = 0 THEN 1601 + ((nums.n * 17) % 200)     -- teaching assistant: eligible
                ELSE 1881 + ((nums.n * 17) % 80)                                  -- administrator: staff workflow
            END
            ELSE CASE
                WHEN seq.space_cycle % 2 = 0 THEN 1201 + ((nums.n * 17) % 400)     -- lecturer: eligible
                ELSE 1 + ((nums.n * 17) % 1200)                                   -- student: staff workflow
            END
        END
    )) AS usr(user_number);

    INSERT INTO dbo.BOOKING_REQUEST (
        booking_id, user_id, space_code, start_time, end_time, purpose,
        expected_participants, booking_type, status
    )
    SELECT
        booking_id, user_id, space_code, start_time, end_time, purpose,
        expected_participants, booking_type, status
    FROM #BookingSeed;

    -- Pending requests have no decision. Cancelled rows retain their historical
    -- approved decision, while current conflict queries exclude cancellation.
    -- AUTO_USAGE_POLICY is the single source of truth for automatic processing.
    -- Automatic decisions have no deciding staff member; manual decisions do.
    INSERT INTO dbo.BOOKING_DECISION (
        decision_id, booking_id, is_approved, is_automatic,
        decided_by_staff, decision_reason, decision_time
    )
    SELECT
        CONCAT('GD', RIGHT(CONCAT('000000000', b.n), 9)),
        b.booking_id,
        CONVERT(BIT, CASE WHEN b.status = 'rejected' THEN 0 ELSE 1 END),
        CONVERT(BIT, CASE WHEN policy.role_id IS NOT NULL THEN 1 ELSE 0 END),
        CASE
            WHEN policy.role_id IS NOT NULL THEN NULL
            WHEN b.n % 3 = 0 THEN 'GMANAGER01'
            WHEN b.n % 2 = 0 THEN 'GSTAFF02'
            ELSE 'GSTAFF01'
        END,
        CASE
            WHEN b.status = 'rejected' AND b.expected_participants > b.capacity
                THEN 'capacity_exceeded'
            WHEN b.status = 'rejected'
                THEN 'operating_condition_not_satisfied'
            WHEN b.status = 'cancelled'
                THEN 'approved_before_later_cancellation'
            WHEN policy.role_id IS NOT NULL
                THEN 'usage_policy_and_availability_checks_passed'
            ELSE 'staff_approval_and_availability_checks_passed'
        END,
        DATEADD(DAY, -(1 + b.n % 30), b.start_time)
    FROM #BookingSeed AS b
    JOIN dbo.USERS AS requester
      ON requester.user_id = b.user_id
    JOIN dbo.SPACES AS booked_space
      ON booked_space.space_code = b.space_code
    LEFT JOIN dbo.AUTO_USAGE_POLICY AS policy
      ON policy.role_id = requester.role_id
     AND policy.space_type_id = booked_space.space_type_id
    WHERE b.status <> 'pending';

    INSERT INTO dbo.USAGE_SESSION (
        session_id, decision_id, checked_in_by_staff, completed_by_staff,
        start_time, end_time, initial_condition, final_condition, usage_note
    )
    SELECT
        CONCAT('GSN', RIGHT(CONCAT('000000000', b.n), 9)),
        CONCAT('GD', RIGHT(CONCAT('000000000', b.n), 9)),
        CASE WHEN b.n % 2 = 0 THEN 'GSTAFF02' ELSE 'GSTAFF01' END,
        CASE WHEN b.n % 5 = 0 THEN 'GMANAGER01'
             WHEN b.n % 2 = 0 THEN 'GSTAFF02' ELSE 'GSTAFF01' END,
        DATEADD(MINUTE, (b.n % 11) - 5, b.start_time),
        DATEADD(MINUTE, (b.n % 13) - 6, b.end_time),
        CASE WHEN b.n % 20 = 0 THEN 'minor_preexisting_wear' ELSE 'good_condition' END,
        CASE WHEN b.n % 25 = 0 THEN 'minor_issue_reported' ELSE 'good_condition' END,
        CONCAT('generated completed ', b.booking_type, ' session')
    FROM #BookingSeed AS b
    WHERE b.status = 'completed';

    -- ----------------------------------------------------------------------
    -- Maintenance history and booking notifications
    -- ----------------------------------------------------------------------
    ;WITH candidates AS (
        SELECT TOP (750)
            ROW_NUMBER() OVER (ORDER BY b.n) AS maintenance_number,
            b.*
        FROM #BookingSeed AS b
        WHERE b.n % 131 = 0
        ORDER BY b.n
    )
    INSERT INTO dbo.MAINTENANCE_RECORD (
        maintenance_id, space_code, report_user, assigned_staff,
        problem_description, start_time, end_time, status, result_note,
        impact_level
    )
    SELECT
        CONCAT('GM', RIGHT(CONCAT('000000000', maintenance_number), 9)),
        space_code,
        user_id,
        CASE WHEN maintenance_number % 2 = 0 THEN 'GSTAFF02' ELSE 'GSTAFF01' END,
        CASE maintenance_number % 5
            WHEN 0 THEN 'electrical_repair'
            WHEN 1 THEN 'projector_fault'
            WHEN 2 THEN 'air_conditioner_fault'
            WHEN 3 THEN 'whiteboard_damage'
            ELSE 'floor_repair'
        END,
        DATEADD(MINUTE, -30, start_time),
        DATEADD(MINUTE, 30, end_time),
        'completed',
        'generated maintenance completed',
        CASE WHEN maintenance_number % 5 IN (1, 2, 3)
             THEN 'advisory' ELSE 'out_of_service' END
    FROM candidates;

    -- Open records are placed after the generated booking horizon, so they do
    -- not invalidate an already-generated approval. They support active-room
    -- finder tests at both impact levels.
    INSERT INTO dbo.MAINTENANCE_RECORD (
        maintenance_id, space_code, report_user, assigned_staff,
        problem_description, start_time, end_time, status, result_note,
        impact_level
    )
    SELECT
        CONCAT('GM9', RIGHT(CONCAT('00000000', n), 8)),
        CONCAT('GSP', RIGHT(CONCAT('000', 1 + ((n - 1) % @SpaceCount)), 3)),
        CASE WHEN n % 2 = 0 THEN 'GSTAFF02' ELSE 'GSTAFF01' END,
        CASE WHEN n % 2 = 0 THEN 'GSTAFF01' ELSE 'GSTAFF02' END,
        CASE WHEN n % 2 = 0 THEN 'open_equipment_advisory' ELSE 'open_space_repair' END,
        DATEADD(DAY, n, CONVERT(DATETIME2(0), @DataEndExclusive)),
        NULL,
        CASE WHEN n % 3 = 0 THEN 'pending' ELSE 'in_progress' END,
        NULL,
        CASE WHEN n % 2 = 0 THEN 'advisory' ELSE 'out_of_service' END
    FROM #N
    WHERE n <= 20;

    -- A booking notification remains historical evidence after maintenance
    -- closes. Each generated completed advisory is joined to every overlapping
    -- request.
    INSERT INTO dbo.BOOKING_NOTIFICATION (
        booking_id, maintenance_id, notification_type, notification_time
    )
    SELECT
        b.booking_id,
        m.maintenance_id,
        'ADVISORY',
        DATEADD(MINUTE, 5, m.start_time)
    FROM dbo.MAINTENANCE_RECORD AS m
    JOIN #BookingSeed AS b
      ON b.space_code = m.space_code
     AND m.start_time < b.end_time
     AND b.start_time < m.end_time
    WHERE LEFT(m.maintenance_id, 2) = 'GM'
      AND TRY_CONVERT(BIGINT, SUBSTRING(m.maintenance_id, 3, 18)) IS NOT NULL
      AND m.impact_level = 'advisory'
      AND m.status = 'completed';

    -- ----------------------------------------------------------------------
    -- Required volume, realism, and integrity validations
    -- ----------------------------------------------------------------------
    IF (SELECT COUNT_BIG(*) FROM dbo.BOOKING_REQUEST
        WHERE LEFT(booking_id, 2) = 'GB'
          AND TRY_CONVERT(BIGINT, SUBSTRING(booking_id, 3, 18)) IS NOT NULL
       ) <> @BookingCount
        THROW 52010, 'Generated booking count is not exactly 10,000.', 1;

    DECLARE @AcademicYearCount INT = (
        SELECT COUNT(DISTINCT
            CASE WHEN MONTH(start_time) >= 9
                 THEN YEAR(start_time) ELSE YEAR(start_time) - 1 END)
        FROM #BookingSeed
    );
    IF @AcademicYearCount < 3
        THROW 52011, 'Generated bookings do not span at least three academic years.', 1;

    IF NOT EXISTS (SELECT 1 FROM #BookingSeed WHERE status = 'cancelled')
       OR NOT EXISTS (SELECT 1 FROM #BookingSeed WHERE status = 'no_show')
       OR NOT EXISTS (SELECT 1 FROM #BookingSeed WHERE status = 'rejected')
       OR NOT EXISTS (SELECT 1 FROM #BookingSeed WHERE status = 'pending')
        THROW 52012, 'Required booking lifecycle cases are missing.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.MAINTENANCE_RECORD
        WHERE LEFT(maintenance_id, 2) = 'GM' AND impact_level = 'advisory'
    ) OR NOT EXISTS (
        SELECT 1 FROM dbo.MAINTENANCE_RECORD
        WHERE LEFT(maintenance_id, 2) = 'GM' AND impact_level = 'out_of_service'
    )
        THROW 52013, 'Both maintenance impact levels are required.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.BOOKING_NOTIFICATION
        WHERE LEFT(booking_id, 2) = 'GB'
    )
        THROW 52014, 'No booking notifications were generated.', 1;

    IF EXISTS (
        SELECT 1
        FROM #BookingSeed AS b
        JOIN dbo.SPACES AS s ON s.space_code = b.space_code
        JOIN dbo.BOOKING_DECISION AS d ON d.booking_id = b.booking_id
        WHERE d.is_approved = 1
          AND b.expected_participants > s.capacity
    )
        THROW 52015, 'An approved generated booking exceeds space capacity.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.USAGE_SESSION AS us
        JOIN dbo.BOOKING_DECISION AS d ON d.decision_id = us.decision_id
        WHERE LEFT(us.session_id, 3) = 'GSN'
          AND d.is_approved <> 1
    )
        THROW 52016, 'A generated usage session references a rejected decision.', 1;

    -- Automatic/manual workflow must agree exactly with AUTO_USAGE_POLICY.
    IF EXISTS (
        SELECT 1
        FROM dbo.BOOKING_DECISION AS d
        JOIN dbo.BOOKING_REQUEST AS br ON br.booking_id = d.booking_id
        JOIN dbo.USERS AS u ON u.user_id = br.user_id
        JOIN dbo.SPACES AS s ON s.space_code = br.space_code
        LEFT JOIN dbo.AUTO_USAGE_POLICY AS p
          ON p.role_id = u.role_id
         AND p.space_type_id = s.space_type_id
        WHERE LEFT(br.booking_id, 2) = 'GB'
          AND TRY_CONVERT(BIGINT, SUBSTRING(br.booking_id, 3, 18)) IS NOT NULL
          AND d.is_automatic <> CONVERT(BIT, CASE WHEN p.role_id IS NOT NULL THEN 1 ELSE 0 END)
    )
        THROW 52019, 'A generated decision does not match AUTO_USAGE_POLICY eligibility.', 1;

    -- Automatic decisions are system-produced and therefore have no staff
    -- decision maker; manual decisions must identify the responsible staff user.
    IF EXISTS (
        SELECT 1
        FROM dbo.BOOKING_DECISION AS d
        JOIN dbo.BOOKING_REQUEST AS br
          ON br.booking_id = d.booking_id
        WHERE LEFT(br.booking_id, 2) = 'GB'
          AND TRY_CONVERT(BIGINT, SUBSTRING(br.booking_id, 3, 18)) IS NOT NULL
          AND (
              (d.is_automatic = 1 AND d.decided_by_staff IS NOT NULL)
              OR
              (d.is_automatic = 0 AND d.decided_by_staff IS NULL)
          )
    )
        THROW 52020, 'Generated decided_by_staff values do not match the processing workflow.', 1;

    -- Because every generated request occupies one of two separated daily
    -- slots, checking the previous approved interval per space is sufficient.
    IF EXISTS (
        SELECT 1
        FROM (
            SELECT
                b.space_code,
                b.start_time,
                LAG(b.end_time) OVER (
                    PARTITION BY b.space_code ORDER BY b.start_time, b.booking_id
                ) AS previous_end_time
            FROM #BookingSeed AS b
            JOIN dbo.BOOKING_DECISION AS d ON d.booking_id = b.booking_id
            WHERE d.is_approved = 1 AND b.status <> 'cancelled'
        ) AS ordered_approved
        WHERE previous_end_time > start_time
    )
        THROW 52017, 'Generated approved bookings overlap for a space.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.MAINTENANCE_RECORD AS m
        JOIN #BookingSeed AS b
          ON b.space_code = m.space_code
         AND m.start_time < b.end_time
         AND b.start_time < m.end_time
        WHERE LEFT(m.maintenance_id, 2) = 'GM'
          AND m.impact_level = 'advisory'
          AND m.status = 'completed'
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.BOOKING_NOTIFICATION AS bn
              WHERE bn.booking_id = b.booking_id
                AND bn.maintenance_id = m.maintenance_id
                AND bn.notification_type = 'ADVISORY'
          )
    )
        THROW 52018, 'An overlapping generated advisory lacks a booking notification.', 1;

    -- ----------------------------------------------------------------------
    -- Trigger-aware validation
    -- ----------------------------------------------------------------------
    -- The seed intentionally includes pending rows. With Trigger 1 enabled,
    -- policy-eligible pending rows must be auto-approved; policy-ineligible
    -- pending rows must remain pending and decision-free.
    IF @ProcessBookingTriggerEnabled = 1
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM #BookingSeed AS b
            JOIN dbo.BOOKING_REQUEST AS br
              ON br.booking_id = b.booking_id
            JOIN dbo.USERS AS u
              ON u.user_id = br.user_id
            JOIN dbo.SPACES AS s
              ON s.space_code = br.space_code
            JOIN dbo.AUTO_USAGE_POLICY AS p
              ON p.role_id = u.role_id
             AND p.space_type_id = s.space_type_id
            WHERE b.status = 'pending'
              AND (
                  br.status <> 'approved'
                  OR NOT EXISTS (
                      SELECT 1
                      FROM dbo.BOOKING_DECISION AS d
                      WHERE d.booking_id = br.booking_id
                        AND d.is_approved = 1
                        AND d.is_automatic = 1
                  )
              )
        )
            THROW 52021,
                'Trigger validation failed: a policy-eligible pending booking was not automatically approved.',
                1;

        IF EXISTS (
            SELECT 1
            FROM #BookingSeed AS b
            JOIN dbo.BOOKING_REQUEST AS br
              ON br.booking_id = b.booking_id
            JOIN dbo.USERS AS u
              ON u.user_id = br.user_id
            JOIN dbo.SPACES AS s
              ON s.space_code = br.space_code
            LEFT JOIN dbo.AUTO_USAGE_POLICY AS p
              ON p.role_id = u.role_id
             AND p.space_type_id = s.space_type_id
            WHERE b.status = 'pending'
              AND p.role_id IS NULL
              AND (
                  br.status <> 'pending'
                  OR EXISTS (
                      SELECT 1
                      FROM dbo.BOOKING_DECISION AS d
                      WHERE d.booking_id = br.booking_id
                  )
              )
        )
            THROW 52022,
                'Trigger validation failed: a policy-ineligible pending booking was changed or received a decision.',
                1;
    END
    ELSE
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM #BookingSeed AS b
            JOIN dbo.BOOKING_REQUEST AS br
              ON br.booking_id = b.booking_id
            WHERE b.status = 'pending'
              AND (
                  br.status <> 'pending'
                  OR EXISTS (
                      SELECT 1
                      FROM dbo.BOOKING_DECISION AS d
                      WHERE d.booking_id = br.booking_id
                  )
              )
        )
            THROW 52023,
                'Trigger-disabled validation failed: an initially pending booking was unexpectedly processed.',
                1;
    END;

    COMMIT TRANSACTION;

    SELECT
        'generation_succeeded' AS result,
        @BookingCount AS generated_booking_rows,
        @AcademicYearCount AS academic_years,
        MIN(start_time) AS earliest_booking_start,
        MAX(end_time) AS latest_booking_end,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_bookings,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings,
        SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) AS no_show_bookings,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected_bookings,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_bookings,
        @ProcessBookingTriggerEnabled AS booking_trigger_enabled,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS initially_pending_bookings,
        (SELECT COUNT_BIG(*)
         FROM dbo.BOOKING_REQUEST AS br
         JOIN #BookingSeed AS b ON b.booking_id = br.booking_id
         WHERE br.status = 'pending') AS remaining_pending_bookings,
        (SELECT COUNT_BIG(*)
         FROM dbo.BOOKING_REQUEST AS br
         JOIN #BookingSeed AS b ON b.booking_id = br.booking_id
         WHERE b.status = 'pending' AND br.status = 'approved') AS trigger_approved_from_pending,
        (SELECT COUNT_BIG(*)
         FROM dbo.BOOKING_DECISION AS d
         JOIN #BookingSeed AS b ON b.booking_id = d.booking_id) AS generated_decisions,
        (SELECT COUNT_BIG(*)
         FROM dbo.BOOKING_DECISION AS d
         JOIN #BookingSeed AS b ON b.booking_id = d.booking_id
         WHERE d.is_automatic = 1) AS automatic_decisions,
        (SELECT COUNT_BIG(*)
         FROM dbo.BOOKING_DECISION AS d
         JOIN #BookingSeed AS b ON b.booking_id = d.booking_id
         WHERE d.is_automatic = 0) AS manual_decisions,
        (SELECT COUNT_BIG(*) FROM dbo.USAGE_SESSION
         WHERE LEFT(session_id, 3) = 'GSN') AS generated_usage_sessions,
        (SELECT COUNT_BIG(*) FROM dbo.MAINTENANCE_RECORD
         WHERE LEFT(maintenance_id, 2) = 'GM') AS generated_maintenance_rows,
        (SELECT COUNT_BIG(*) FROM dbo.BOOKING_NOTIFICATION
         WHERE LEFT(booking_id, 2) = 'GB') AS generated_notifications
    FROM #BookingSeed;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
