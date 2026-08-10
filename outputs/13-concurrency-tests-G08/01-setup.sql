-- 01-setup.sql
-- Creates isolated rows used only by the G08 concurrency demonstration.

USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.usp_G08_ApproveBookingConcurrentSafe', N'P') IS NULL
    THROW 52500, 'Run 12-concurrency-implementation-G08.sql first.', 1;

DECLARE @student_role_id INT = (
    SELECT TOP (1) role_id
    FROM dbo.ROLE
    WHERE role_name = 'student'
    ORDER BY role_id
);

DECLARE @staff_role_id INT = (
    SELECT TOP (1) role_id
    FROM dbo.ROLE
    WHERE role_name = 'facility_staff'
    ORDER BY role_id
);

DECLARE @classroom_type_id INT = (
    SELECT TOP (1) space_type_id
    FROM dbo.SPACE_TYPE
    WHERE space_type_name = 'classroom'
    ORDER BY space_type_id
);

IF @student_role_id IS NULL
    THROW 52501, 'Required student role was not found.', 1;

IF @staff_role_id IS NULL
    THROW 52502, 'Required facility_staff role was not found.', 1;

IF @classroom_type_id IS NULL
    THROW 52503, 'Required classroom SPACE_TYPE was not found.', 1;

------------------------------------------------------------
-- Remove rows from a previous test run.
------------------------------------------------------------
DELETE FROM dbo.BOOKING_DECISION
WHERE booking_id IN (
    'G08_UNSAFE_B1',
    'G08_UNSAFE_B2',
    'G08_SAFE_B1',
    'G08_SAFE_B2'
)
OR decision_id IN (
    'G08_UNSAFE_D1',
    'G08_UNSAFE_D2'
);

DELETE FROM dbo.BOOKING_REQUEST
WHERE booking_id IN (
    'G08_UNSAFE_B1',
    'G08_UNSAFE_B2',
    'G08_SAFE_B1',
    'G08_SAFE_B2'
);

DELETE FROM dbo.SPACES
WHERE space_code = 'G08_CONC_ROOM';

DELETE FROM dbo.USERS
WHERE user_id IN (
    'G08_REQ_1',
    'G08_STAFF_1'
);

------------------------------------------------------------
-- Create requester and staff test accounts.
------------------------------------------------------------
INSERT INTO dbo.USERS (
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

------------------------------------------------------------
-- Create one test space.
------------------------------------------------------------
INSERT INTO dbo.SPACES (
    space_code,
    space_name,
    building,
    floor,
    room_number,
    capacity,
    current_status,
    space_type_id
)
VALUES (
    'G08_CONC_ROOM',
    'G08 Concurrency Test Room',
    'TEST',
    1,
    'T-101',
    50,
    'available',
    @classroom_type_id
);

------------------------------------------------------------
-- Create two unsafe and two safe overlapping booking pairs.
------------------------------------------------------------
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
    '2077-03-10 21:00:00',
    '2077-03-10 23:00:00',
    'Unsafe concurrency test A',
    10,
    'meeting',
    'pending'
),
(
    'G08_UNSAFE_B2',
    'G08_REQ_1',
    'G08_CONC_ROOM',
    '2077-03-20 21:00:00',
    '2077-03-20 23:00:00',
    'Unsafe concurrency test B',
    10,
    'meeting',
    'pending'
),
(
    'G08_SAFE_B1',
    'G08_REQ_1',
    'G08_CONC_ROOM',
    '2077-03-11 21:00:00',
    '2077-03-11 23:00:00',
    'Protected concurrency test A',
    10,
    'meeting',
    'pending'
),
(
    'G08_SAFE_B2',
    'G08_REQ_1',
    'G08_CONC_ROOM',
    '2077-03-11 22:00:00',
    '2077-03-11 23:00:00',
    'Protected concurrency test B',
    10,
    'meeting',
    'pending'
);

SELECT
    booking_id,
    space_code,
    start_time,
    end_time,
    status
FROM dbo.BOOKING_REQUEST
WHERE booking_id IN (
    'G08_UNSAFE_B1',
    'G08_UNSAFE_B2',
    'G08_SAFE_B1',
    'G08_SAFE_B2'
)
ORDER BY start_time, booking_id;

PRINT 'G08 concurrency test data created.';
GO
