-- 01-setup.sql
USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.usp_G08_ApproveBookingConcurrentSafe', N'P') IS NULL
    THROW 52500, 'Run 12-concurrency-implementation-G08.sql first.', 1;

DECLARE @student_role_id INT = (
    SELECT TOP (1) role_id
    FROM dbo.[ROLE]
    WHERE role_name = 'student'
    ORDER BY role_id
);

DECLARE @staff_role_id INT = (
    SELECT TOP (1) role_id
    FROM dbo.[ROLE]
    WHERE role_name = 'facility_staff'
    ORDER BY role_id
);

IF @student_role_id IS NULL OR @staff_role_id IS NULL
    THROW 52501, 'Required student and facility_staff roles were not found.', 1;

-- Remove a previous test run.
DELETE FROM dbo.ADVISORY_ACKNOWLEDGEMENT
WHERE booking_id IN (
    'G08_UNSAFE_B1', 'G08_UNSAFE_B2',
    'G08_SAFE_B1', 'G08_SAFE_B2'
);

DELETE FROM dbo.BOOKING_DECISION
WHERE booking_id IN (
    'G08_UNSAFE_B1', 'G08_UNSAFE_B2',
    'G08_SAFE_B1', 'G08_SAFE_B2'
)
OR decision_id IN ('G08_UNSAFE_D1', 'G08_UNSAFE_D2');

DELETE FROM dbo.BOOKING_REQUEST
WHERE booking_id IN (
    'G08_UNSAFE_B1', 'G08_UNSAFE_B2',
    'G08_SAFE_B1', 'G08_SAFE_B2'
);

DELETE FROM dbo.SPACE_USAGE_POLICY
WHERE space_code = 'G08_CONC_ROOM';

DELETE FROM dbo.SPACE
WHERE space_code = 'G08_CONC_ROOM';

DELETE FROM dbo.[USER]
WHERE user_id IN ('G08_REQ_1', 'G08_STAFF_1');

INSERT INTO dbo.[USER] (
    user_id,
    role_id,
    full_name,
    email,
    phone_number,
    department,
    account_status
)
VALUES
    (
        'G08_REQ_1',
        @student_role_id,
        'G08 Test Requester',
        'g08-requester@test.invalid',
        NULL,
        'Testing',
        'active'
    ),
    (
        'G08_STAFF_1',
        @staff_role_id,
        'G08 Test Staff',
        'g08-staff@test.invalid',
        NULL,
        'Testing',
        'active'
    );

INSERT INTO dbo.SPACE (
    space_code,
    space_name,
    space_type,
    building,
    floor,
    room_number,
    capacity,
    current_status
)
VALUES (
    'G08_CONC_ROOM',
    'G08 Concurrency Test Room',
    'classroom',
    'TEST',
    1,
    'T-101',
    50,
    'available'
);

INSERT INTO dbo.SPACE_USAGE_POLICY (space_code, role_id)
VALUES ('G08_CONC_ROOM', @student_role_id);

INSERT INTO dbo.BOOKING_REQUEST (
    booking_id,
    user_id,
    space_code,
    start_time,
    end_time,
    purpose,
    expected_participants,
    booking_type,
    status
)
VALUES
    (
        'G08_UNSAFE_B1',
        'G08_REQ_1',
        'G08_CONC_ROOM',
        '2035-03-10 09:00:00',
        '2035-03-10 11:00:00',
        'Unsafe concurrency test A',
        10,
        'meeting',
        'pending'
    ),
    (
        'G08_UNSAFE_B2',
        'G08_REQ_1',
        'G08_CONC_ROOM',
        '2035-03-10 10:00:00',
        '2035-03-10 12:00:00',
        'Unsafe concurrency test B',
        10,
        'meeting',
        'pending'
    ),
    (
        'G08_SAFE_B1',
        'G08_REQ_1',
        'G08_CONC_ROOM',
        '2035-03-11 09:00:00',
        '2035-03-11 11:00:00',
        'Protected concurrency test A',
        10,
        'meeting',
        'pending'
    ),
    (
        'G08_SAFE_B2',
        'G08_REQ_1',
        'G08_CONC_ROOM',
        '2035-03-11 10:00:00',
        '2035-03-11 12:00:00',
        'Protected concurrency test B',
        10,
        'meeting',
        'pending'
    );

SELECT booking_id, start_time, end_time, status
FROM dbo.BOOKING_REQUEST
WHERE booking_id IN (
    'G08_UNSAFE_B1', 'G08_UNSAFE_B2',
    'G08_SAFE_B1', 'G08_SAFE_B2'
)
ORDER BY start_time, booking_id;

PRINT 'G08 concurrency test data created.';
GO
