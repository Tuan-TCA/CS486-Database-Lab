-- 04-verify-unsafe.sql
USE campus_space_management;
GO

SET NOCOUNT ON;

SELECT
    br.booking_id,
    br.start_time,
    br.end_time,
    br.status,
    d.is_approved
FROM dbo.BOOKING_REQUEST AS br
LEFT JOIN dbo.BOOKING_DECISION AS d
  ON d.booking_id = br.booking_id
WHERE br.booking_id IN ('G08_UNSAFE_B1', 'G08_UNSAFE_B2')
ORDER BY br.booking_id;

DECLARE @approved_count INT = (
    SELECT COUNT(*)
    FROM dbo.BOOKING_REQUEST AS br
    JOIN dbo.BOOKING_DECISION AS d
      ON d.booking_id = br.booking_id
     AND d.is_approved = 1
    WHERE br.booking_id IN ('G08_UNSAFE_B1', 'G08_UNSAFE_B2')
);

DECLARE @overlap_count INT = (
    SELECT COUNT(*)
    FROM dbo.BOOKING_REQUEST AS a
    JOIN dbo.BOOKING_DECISION AS da
      ON da.booking_id = a.booking_id
     AND da.is_approved = 1
    JOIN dbo.BOOKING_REQUEST AS b
      ON b.space_code = a.space_code
     AND b.booking_id > a.booking_id
     AND a.start_time < b.end_time
     AND b.start_time < a.end_time
    JOIN dbo.BOOKING_DECISION AS db
      ON db.booking_id = b.booking_id
     AND db.is_approved = 1
    WHERE a.booking_id IN ('G08_UNSAFE_B1', 'G08_UNSAFE_B2')
      AND b.booking_id IN ('G08_UNSAFE_B1', 'G08_UNSAFE_B2')
      AND a.status <> 'cancelled'
      AND b.status <> 'cancelled'
);

SELECT
    @approved_count AS approved_booking_count,
    @overlap_count AS overlapping_approved_pair_count;

IF @approved_count <> 2 OR @overlap_count <> 1
    THROW 52602, 'Unsafe conflict was not reproduced; repeat the session timing.', 1;

PRINT 'PASS: the unsafe scripts produced two overlapping approved bookings.';
GO
