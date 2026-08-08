-- 05-reset.sql
-- Reset all four test bookings before running the protected test.

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

UPDATE dbo.BOOKING_REQUEST
SET status = 'pending'
WHERE booking_id IN (
    'G08_UNSAFE_B1',
    'G08_UNSAFE_B2',
    'G08_SAFE_B1',
    'G08_SAFE_B2'
);

PRINT 'All G08 concurrency test bookings reset to pending.';
GO
