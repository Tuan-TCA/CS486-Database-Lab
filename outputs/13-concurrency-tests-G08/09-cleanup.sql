-- 09-cleanup.sql
-- Remove all rows created by the G08 concurrency demonstration.

USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

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

PRINT 'G08 concurrency test data removed.';
GO
