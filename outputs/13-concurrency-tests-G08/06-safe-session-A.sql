-- 06-safe-session-A.sql
-- Run first in Window A.
-- During the 12-second hold, run 07-safe-session-B.sql in Window B.

USE campus_space_management;
GO

EXEC dbo.usp_G08_ApproveBookingConcurrentSafe
    @booking_id = 'G08_SAFE_B1',
    @is_automatic = 0,
    @decided_by_staff = 'G08_STAFF_1',
    @decision_reason = 'Protected Session A',
    @test_hold_seconds = 12;
GO
