-- ============================================================================
-- 18-indexing-query-tuning-G08.sql
-- Campus Space Management System - G08
-- RUBRIC-ALIGNED AFTER-INDEX TEST
--
-- Requirement:
--   Tune the booking conflict check, room finder, and two selected reporting
--   queries. Compare execution plans and execution times before/after indexing.
--
-- Exact four targets (same SQL as 17):
--   T1_BOOKING_CONFLICT  - booking overlap/conflict existence check
--   T2_ROOM_FINDER_Q03   - room finder / Query 03
--   T3_REPORT_Q01        - approved booking hours per space
--   T4_REPORT_Q02        - approved booking distribution by weekday/hour
--
-- Baseline:
--   The BEFORE values embedded below are the mean of the three independent
--   runs supplied after executing 17. Every run used five measured executions.
--
-- Candidate indexes are deliberately consolidated:
--   1. BOOKING_REQUEST(space_code, start_time) INCLUDE(end_time, status)
--      -> booking conflict check + room finder.
--   2. BOOKING_REQUEST(start_time) INCLUDE(space_code, end_time, status)
--      -> Reporting Query 01 semester range.
--   3. Filtered BOOKING_DECISION(booking_id) WHERE is_approved = 1
--      -> approved-only joins used by conflict, room finder and Q01.
--   4. Filtered BOOKING_DECISION(decision_time) INCLUDE(booking_id)
--      WHERE is_approved = 1
--      -> Reporting Query 02 decision-time range.
--   5. FACILITY(space_code, facility_name)
--      -> room-finder facility correlation.
--   6. MAINTENANCE_RECORD(space_code, impact_level, status, start_time)
--      INCLUDE(end_time)
--      -> room-finder maintenance overlap checks.
--
-- Notes:
--   * SPACES is intentionally NOT indexed for current_status/capacity because
--     it has only 62 rows in the baseline; a scan is cheap.
--   * No index hint is used. SQL Server must freely choose whether each index
--     is beneficial.
--   * This script leaves the six tuning indexes in place after benchmarking.
--   * Benchmark-only stored procedures are removed at the end.
--   * The script is repeatable: its own indexes are dropped/recreated first.
--
-- RUN:
--   Run on the same database produced by 05 -> 06 -> 10 -> 14.
--   Do NOT rerun 05/06/10/14 between your BEFORE (17) and AFTER (18) tests.
-- ============================================================================

USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

PRINT '============================================================';
PRINT 'G08 RUBRIC-ALIGNED AFTER-INDEX TEST - START';
PRINT 'Targets: conflict check, room finder, report Q01, report Q02';
PRINT '============================================================';
GO

-- ============================================================================
-- 0. SCHEMA + EXPERIMENT SAFETY
-- ============================================================================
IF OBJECT_ID(N'dbo.BOOKING_REQUEST', N'U') IS NULL
  OR OBJECT_ID(N'dbo.BOOKING_DECISION', N'U') IS NULL
  OR OBJECT_ID(N'dbo.SPACES', N'U') IS NULL
  OR OBJECT_ID(N'dbo.SPACE_TYPE', N'U') IS NULL
  OR OBJECT_ID(N'dbo.FACILITY', N'U') IS NULL
  OR OBJECT_ID(N'dbo.MAINTENANCE_RECORD', N'U') IS NULL
BEGIN
  ;THROW 51100,
      'Expected Phase-2 schema not found. Run 05, 06, 10 and 14 first.',
      1;
END;
GO

-- Do not allow unrelated custom indexes to contaminate the controlled test.
IF EXISTS
(
    SELECT 1
FROM sys.indexes AS i
WHERE i.object_id IN
    (
        OBJECT_ID(N'dbo.BOOKING_REQUEST'),
        OBJECT_ID(N'dbo.BOOKING_DECISION'),
        OBJECT_ID(N'dbo.FACILITY'),
        OBJECT_ID(N'dbo.MAINTENANCE_RECORD'),
        OBJECT_ID(N'dbo.SPACES')
    )
  AND i.index_id > 0
  AND i.is_hypothetical = 0
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
  AND i.name NOT IN
      (
          N'IX_G08_BR_Space_Start',
          N'IX_G08_BR_Start',
          N'IX_G08_BD_Approved_Booking',
          N'IX_G08_BD_Approved_DecisionTime',
          N'IX_G08_Facility_Space_Name',
          N'IX_G08_Maint_Space_Impact_Status_Start'
      )
)
BEGIN
  SELECT
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS unexpected_custom_index
  FROM sys.indexes AS i
  WHERE i.object_id IN
    (
        OBJECT_ID(N'dbo.BOOKING_REQUEST'),
        OBJECT_ID(N'dbo.BOOKING_DECISION'),
        OBJECT_ID(N'dbo.FACILITY'),
        OBJECT_ID(N'dbo.MAINTENANCE_RECORD'),
        OBJECT_ID(N'dbo.SPACES')
    )
    AND i.index_id > 0
    AND i.is_hypothetical = 0
    AND i.is_primary_key = 0
    AND i.is_unique_constraint = 0
    AND i.name NOT IN
      (
          N'IX_G08_BR_Space_Start',
          N'IX_G08_BR_Start',
          N'IX_G08_BD_Approved_Booking',
          N'IX_G08_BD_Approved_DecisionTime',
          N'IX_G08_Facility_Space_Name',
          N'IX_G08_Maint_Space_Impact_Status_Start'
      );

  THROW 51101,
      'Unexpected custom indexes found. Remove them before running controlled AFTER test.',
      1;
END;
GO

-- ============================================================================
-- 1. RECREATE THE CONTROLLED CANDIDATE INDEX SET
-- ============================================================================

DROP INDEX IF EXISTS IX_G08_BR_Space_Start
ON dbo.BOOKING_REQUEST;

DROP INDEX IF EXISTS IX_G08_BR_Start
ON dbo.BOOKING_REQUEST;

DROP INDEX IF EXISTS IX_G08_BD_Approved_Booking
ON dbo.BOOKING_DECISION;

DROP INDEX IF EXISTS IX_G08_BD_Approved_DecisionTime
ON dbo.BOOKING_DECISION;

DROP INDEX IF EXISTS IX_G08_Facility_Space_Name
ON dbo.FACILITY;

DROP INDEX IF EXISTS IX_G08_Maint_Space_Impact_Status_Start
ON dbo.MAINTENANCE_RECORD;
GO

-- T1 + T2: same-space overlap lookup.
CREATE NONCLUSTERED INDEX IX_G08_BR_Space_Start
ON dbo.BOOKING_REQUEST
(
    space_code,
    start_time
)
INCLUDE
(
    end_time,
    status
);
GO

-- T3/Q01: booking start-time semester range.
CREATE NONCLUSTERED INDEX IX_G08_BR_Start
ON dbo.BOOKING_REQUEST
(
    start_time
)
INCLUDE
(
    space_code,
    end_time,
    status
);
GO

-- Approved-only joins in all four targets.
-- Filtering is preferable to making low-cardinality BIT column is_approved
-- the leading key while still allowing a seek by booking_id.
CREATE NONCLUSTERED INDEX IX_G08_BD_Approved_Booking
ON dbo.BOOKING_DECISION
(
    booking_id
)
WHERE is_approved = 1;
GO

-- Q02: range-seek approved decisions by decision_time.
-- The filtered definition avoids storing rejected decisions.
CREATE NONCLUSTERED INDEX IX_G08_BD_Approved_DecisionTime
ON dbo.BOOKING_DECISION
(
    decision_time
)
INCLUDE
(
    booking_id
)
WHERE is_approved = 1;
GO

-- Room finder facility correlation.
CREATE NONCLUSTERED INDEX IX_G08_Facility_Space_Name
ON dbo.FACILITY
(
    space_code,
    facility_name
);
GO

-- Room finder advisory/out-of-service overlap correlation.
CREATE NONCLUSTERED INDEX IX_G08_Maint_Space_Impact_Status_Start
ON dbo.MAINTENANCE_RECORD
(
    space_code,
    impact_level,
    status,
    start_time
)
INCLUDE
(
    end_time
);
GO

-- Same statistics policy as 17 so index effect is not confused with stale stats.
UPDATE STATISTICS dbo.BOOKING_REQUEST WITH FULLSCAN;
UPDATE STATISTICS dbo.BOOKING_DECISION WITH FULLSCAN;
UPDATE STATISTICS dbo.SPACES WITH FULLSCAN;
UPDATE STATISTICS dbo.SPACE_TYPE WITH FULLSCAN;
UPDATE STATISTICS dbo.FACILITY WITH FULLSCAN;
UPDATE STATISTICS dbo.MAINTENANCE_RECORD WITH FULLSCAN;
GO

-- ============================================================================
-- RESULT A1 - INDEX DEFINITIONS CREATED
-- ============================================================================
PRINT 'RESULT A1 - CONTROLLED INDEX SET';

SELECT
  OBJECT_NAME(i.object_id) AS table_name,
  i.name AS index_name,
  i.type_desc,
  i.has_filter,
  i.filter_definition,
  key_columns = STUFF((
        SELECT ', ' + QUOTENAME(c.name)
             + CASE WHEN ic2.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
  FROM sys.index_columns AS ic2
    JOIN sys.columns AS c
    ON c.object_id = ic2.object_id
      AND c.column_id = ic2.column_id
  WHERE ic2.object_id = i.object_id
    AND ic2.index_id = i.index_id
    AND ic2.key_ordinal > 0
  ORDER BY ic2.key_ordinal
  FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)'), 1, 2, ''),
  included_columns = STUFF((
        SELECT ', ' + QUOTENAME(c.name)
  FROM sys.index_columns AS ic3
    JOIN sys.columns AS c
    ON c.object_id = ic3.object_id
      AND c.column_id = ic3.column_id
  WHERE ic3.object_id = i.object_id
    AND ic3.index_id = i.index_id
    AND ic3.is_included_column = 1
  ORDER BY ic3.index_column_id
  FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)'), 1, 2, '')
FROM sys.indexes AS i
WHERE i.name IN
(
    N'IX_G08_BR_Space_Start',
    N'IX_G08_BR_Start',
    N'IX_G08_BD_Approved_Booking',
    N'IX_G08_BD_Approved_DecisionTime',
    N'IX_G08_Facility_Space_Name',
    N'IX_G08_Maint_Space_Impact_Status_Start'
)
ORDER BY table_name, index_name;
GO

-- ============================================================================
-- RESULT A2 - INDEX STORAGE OVERHEAD
-- ============================================================================
PRINT 'RESULT A2 - INDEX STORAGE OVERHEAD';

SELECT
  OBJECT_NAME(i.object_id) AS table_name,
  i.name AS index_name,
  SUM(ps.row_count) AS index_rows,
  CAST(SUM(ps.reserved_page_count) * 8.0 / 1024 AS DECIMAL(12,2))
        AS reserved_mb,
  CAST(SUM(ps.used_page_count) * 8.0 / 1024 AS DECIMAL(12,2))
        AS used_mb
FROM sys.indexes AS i
  JOIN sys.dm_db_partition_stats AS ps
  ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE i.name IN
(
    N'IX_G08_BR_Space_Start',
    N'IX_G08_BR_Start',
    N'IX_G08_BD_Approved_Booking',
    N'IX_G08_BD_Approved_DecisionTime',
    N'IX_G08_Facility_Space_Name',
    N'IX_G08_Maint_Space_Impact_Status_Start'
)
GROUP BY i.object_id, i.name
ORDER BY table_name, index_name;
GO

-- ============================================================================
-- 2. EMBED THE THREE-RUN BEFORE BASELINE
--
-- Means of the three supplied VALID Q01/Q02 executions of 17:
--   T1: reads 55.00, CPU 0.31 ms, elapsed 0.31 ms, wall 1.08 ms
--   T2: reads 35152.20, CPU 787.48 ms, elapsed 787.54 ms, wall 790.32 ms
--   T3: reads 2760.00, CPU 42.28 ms, elapsed 42.31 ms, wall 45.22 ms
--   T4: reads 2677.00, CPU 41.35 ms, elapsed 41.38 ms, wall 42.46 ms
-- ============================================================================
DROP TABLE IF EXISTS #Baseline;

CREATE TABLE #Baseline
(
  target_id            VARCHAR(40)   PRIMARY KEY,
  before_logical_reads DECIMAL(18,2) NOT NULL,
  before_cpu_ms        DECIMAL(18,2) NOT NULL,
  before_elapsed_ms    DECIMAL(18,2) NOT NULL,
  before_wall_ms       DECIMAL(18,2) NOT NULL
);

INSERT INTO #Baseline
  (
  target_id,
  before_logical_reads,
  before_cpu_ms,
  before_elapsed_ms,
  before_wall_ms
  )
VALUES
  ('T1_BOOKING_CONFLICT', 55.00, 0.31, 0.31, 1.08),
  ('T2_ROOM_FINDER_Q03', 35152.20, 787.48, 787.54, 790.32),
  ('T3_REPORT_Q01', 2760.00, 42.28, 42.31, 45.22),
  ('T4_REPORT_Q02', 2677.00, 41.35, 41.38, 42.46);

PRINT 'RESULT A3 - THREE-RUN BEFORE BASELINE USED FOR COMPARISON';
SELECT *
FROM #Baseline
ORDER BY target_id;
GO

-- ============================================================================
-- 3. CHOOSE THE SAME REPRODUCIBLE POSITIVE CONFLICT CASE AS 17
-- ============================================================================
DROP TABLE IF EXISTS #ConflictCase;

SELECT TOP (1)
  br.booking_id AS reference_booking_id,
  br.space_code,
  br.start_time AS requested_start,
  br.end_time AS requested_end
INTO #ConflictCase
FROM dbo.BOOKING_REQUEST AS br
  JOIN dbo.BOOKING_DECISION AS bd
  ON bd.booking_id = br.booking_id
WHERE bd.is_approved = 1
  AND br.status <> 'cancelled'
  AND br.end_time > br.start_time
ORDER BY br.start_time, br.booking_id;

IF NOT EXISTS (SELECT 1
FROM #ConflictCase)
BEGIN
  ;THROW 51102,
      'No approved non-cancelled booking exists for the conflict test.',
      1;
END;

PRINT 'RESULT A4 - AFTER-INDEX CONFLICT TEST CASE';
SELECT *
FROM #ConflictCase;
GO

-- ============================================================================
-- 4. SNAPSHOT USAGE + MISSING INDEX DMVS AFTER INDEX CREATION, BEFORE WORKLOAD
-- ============================================================================
DROP TABLE IF EXISTS #IndexUsageBefore;

SELECT
  i.object_id,
  i.index_id,
  COALESCE(us.user_seeks, 0) AS user_seeks,
  COALESCE(us.user_scans, 0) AS user_scans,
  COALESCE(us.user_lookups, 0) AS user_lookups,
  COALESCE(us.user_updates, 0) AS user_updates
INTO #IndexUsageBefore
FROM sys.indexes AS i
  LEFT JOIN sys.dm_db_index_usage_stats AS us
  ON us.database_id = DB_ID()
    AND us.object_id = i.object_id
    AND us.index_id = i.index_id
WHERE i.object_id IN
(
    OBJECT_ID(N'dbo.BOOKING_REQUEST'),
    OBJECT_ID(N'dbo.BOOKING_DECISION'),
    OBJECT_ID(N'dbo.SPACES'),
    OBJECT_ID(N'dbo.SPACE_TYPE'),
    OBJECT_ID(N'dbo.FACILITY'),
    OBJECT_ID(N'dbo.MAINTENANCE_RECORD')
)
  AND i.index_id > 0;

DROP TABLE IF EXISTS #MissingBefore;

SELECT
  mig.index_group_handle,
  mid.index_handle,
  COALESCE(migs.user_seeks, 0) AS user_seeks,
  COALESCE(migs.user_scans, 0) AS user_scans,
  COALESCE(migs.unique_compiles, 0) AS unique_compiles
INTO #MissingBefore
FROM sys.dm_db_missing_index_group_stats AS migs
  JOIN sys.dm_db_missing_index_groups AS mig
  ON mig.index_group_handle = migs.group_handle
  JOIN sys.dm_db_missing_index_details AS mid
  ON mid.index_handle = mig.index_handle
WHERE mid.database_id = DB_ID();
GO
-- ============================================================================
-- 5. BENCHMARK PROCEDURES - EXACTLY THE SAME FOUR RUBRIC TARGETS
-- ============================================================================
DROP PROCEDURE IF EXISTS dbo.__IDX18_CONFLICT;
DROP PROCEDURE IF EXISTS dbo.__IDX18_ROOM_FINDER;
DROP PROCEDURE IF EXISTS dbo.__IDX18_REPORT_Q01;
DROP PROCEDURE IF EXISTS dbo.__IDX18_REPORT_Q02;
GO

-- ----------------------------------------------------------------------------
-- T1 - BOOKING CONFLICT CHECK
-- A hypothetical booking conflicts when an approved, non-cancelled booking for
-- the same space overlaps the requested half-open interval [start, end).
-- ----------------------------------------------------------------------------
CREATE PROCEDURE dbo.__IDX18_CONFLICT
  @SpaceCode      VARCHAR(20),
  @RequestedStart DATETIME,
  @RequestedEnd   DATETIME
AS
BEGIN
  SET NOCOUNT ON;

  SELECT CAST(
        CASE WHEN EXISTS
        (
            SELECT 1
    FROM dbo.BOOKING_REQUEST AS existing_br
      JOIN dbo.BOOKING_DECISION AS existing_bd
      ON existing_bd.booking_id = existing_br.booking_id
    WHERE existing_br.space_code = @SpaceCode
      AND existing_bd.is_approved = 1
      AND existing_br.status <> 'cancelled'
      AND existing_br.start_time < @RequestedEnd
      AND existing_br.end_time > @RequestedStart
        ) THEN 1 ELSE 0 END
        AS BIT
    ) AS has_conflict;
END;
GO

-- ----------------------------------------------------------------------------
-- T2 - ROOM FINDER = Query 03 from 16-analytical-queries-G08.sql
-- ----------------------------------------------------------------------------
CREATE PROCEDURE dbo.__IDX18_ROOM_FINDER
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @RequestedStart DATETIME = '2026-10-01 09:00';
  DECLARE @RequestedEnd   DATETIME = '2026-10-01 12:00';
  DECLARE @MinCapacity    INT = 30;

  DECLARE @RequiredFacilities TABLE (facility_name VARCHAR(100));
  INSERT INTO @RequiredFacilities
  VALUES
    ('projector'),
    ('computer');

  DECLARE @RequiredFacilityCount INT =
        (SELECT COUNT(*)
  FROM @RequiredFacilities);

  SELECT
    s.space_code,
    s.space_name,
    st.space_type_name,
    s.capacity,
    s.building,
    CASE WHEN EXISTS
        (
            SELECT 1
    FROM dbo.MAINTENANCE_RECORD AS m
    WHERE m.space_code = s.space_code
      AND m.impact_level = 'advisory'
      AND m.status IN ('pending', 'in_progress')
      AND m.start_time < @RequestedEnd
      AND (m.end_time IS NULL OR m.end_time > @RequestedStart)
        ) THEN 'YES' ELSE 'NO' END AS has_advisory_maintenance
  FROM dbo.SPACES AS s
    JOIN dbo.SPACE_TYPE AS st
    ON st.space_type_id = s.space_type_id
  WHERE s.current_status = 'available'
    AND s.capacity >= @MinCapacity
    AND
    (
          @RequiredFacilityCount = 0
    OR @RequiredFacilityCount =
          (
              SELECT COUNT(DISTINCT f.facility_name)
    FROM dbo.FACILITY AS f
      JOIN @RequiredFacilities AS rf
      ON rf.facility_name = f.facility_name
    WHERE f.space_code = s.space_code
          )
      )
    AND NOT EXISTS
      (
          SELECT 1
    FROM dbo.BOOKING_REQUEST AS existing_br
      JOIN dbo.BOOKING_DECISION AS existing_bd
      ON existing_bd.booking_id = existing_br.booking_id
    WHERE existing_br.space_code = s.space_code
      AND existing_bd.is_approved = 1
      AND existing_br.status <> 'cancelled'
      AND existing_br.start_time < @RequestedEnd
      AND existing_br.end_time > @RequestedStart
      )
    AND NOT EXISTS
      (
          SELECT 1
    FROM dbo.MAINTENANCE_RECORD AS m
    WHERE m.space_code = s.space_code
      AND m.impact_level = 'out_of_service'
      AND m.status IN ('pending', 'in_progress')
      AND m.start_time < @RequestedEnd
      AND (m.end_time IS NULL OR m.end_time > @RequestedStart)
      )
  ORDER BY s.capacity, s.space_code;
END;
GO

-- ----------------------------------------------------------------------------
-- T3 - REPORTING QUERY 01 = approved booking hours per space
-- ----------------------------------------------------------------------------
CREATE PROCEDURE dbo.__IDX18_REPORT_Q01
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @SemesterStart DATETIME = '2025-09-01';
  DECLARE @SemesterEnd   DATETIME = '2026-02-01';

  SELECT
    s.space_code,
    s.space_name,
    st.space_type_name,
    COUNT(*) AS approved_booking_count,
    CAST(
            SUM(DATEDIFF(MINUTE, br.start_time, br.end_time)) / 60.0
            AS DECIMAL(10,2)
        ) AS total_approved_hours
  FROM dbo.BOOKING_REQUEST AS br
    JOIN dbo.BOOKING_DECISION AS bd
    ON bd.booking_id = br.booking_id
    JOIN dbo.SPACES AS s
    ON s.space_code = br.space_code
    JOIN dbo.SPACE_TYPE AS st
    ON st.space_type_id = s.space_type_id
  WHERE bd.is_approved = 1
    AND br.status <> 'cancelled'
    AND br.start_time >= @SemesterStart
    AND br.start_time < @SemesterEnd
  GROUP BY s.space_code, s.space_name, st.space_type_name
  ORDER BY total_approved_hours DESC;
END;
GO

-- ----------------------------------------------------------------------------
-- T4 - REPORTING QUERY 02 = approved booking distribution by weekday and hour
-- Selected from the permitted Query 01-04 reporting range.
-- ----------------------------------------------------------------------------
CREATE PROCEDURE dbo.__IDX18_REPORT_Q02
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @SemesterStart DATETIME = '2025-09-01';
  DECLARE @SemesterEnd   DATETIME = '2026-02-01';
  DECLARE @FromHour      INT = 7;
  DECLARE @ToHour        INT = 18;

  SELECT
    DATENAME(WEEKDAY, bd.decision_time) AS weekday_name,
    DATEPART(WEEKDAY, bd.decision_time) AS weekday_number,
    DATEPART(HOUR, bd.decision_time)    AS decision_hour,
    COUNT(*)                            AS booking_count
  FROM dbo.BOOKING_DECISION AS bd
    JOIN dbo.BOOKING_REQUEST AS br
    ON br.booking_id = bd.booking_id
  WHERE bd.is_approved = 1
    AND br.status <> 'cancelled'
    AND bd.decision_time >= @SemesterStart
    AND bd.decision_time <  @SemesterEnd
    AND DATEPART(HOUR, bd.decision_time) BETWEEN @FromHour AND @ToHour
  GROUP BY
        DATENAME(WEEKDAY, bd.decision_time),
        DATEPART(WEEKDAY, bd.decision_time),
        DATEPART(HOUR, bd.decision_time)
  ORDER BY weekday_number, decision_hour;
END;
GO

-- ============================================================================
-- 5. LOCAL RESULT SINKS
-- Capture procedure results so result rendering/network transfer does not
-- dominate benchmark elapsed time.
-- ============================================================================
DROP TABLE IF EXISTS #SinkConflict;
DROP TABLE IF EXISTS #SinkRoomFinder;
DROP TABLE IF EXISTS #SinkQ01;
DROP TABLE IF EXISTS #SinkQ02;
DROP TABLE IF EXISTS #RunTiming;

CREATE TABLE #SinkConflict
(
  has_conflict BIT NOT NULL
);

CREATE TABLE #SinkRoomFinder
(
  space_code               VARCHAR(50)  NULL,
  space_name               VARCHAR(200) NULL,
  space_type_name          VARCHAR(200) NULL,
  capacity                 INT          NULL,
  building                 VARCHAR(200) NULL,
  has_advisory_maintenance VARCHAR(3)   NULL
);

CREATE TABLE #SinkQ01
(
  space_code             VARCHAR(50)   NULL,
  space_name             VARCHAR(200)  NULL,
  space_type_name        VARCHAR(200)  NULL,
  approved_booking_count BIGINT        NULL,
  total_approved_hours   DECIMAL(10,2) NULL
);

CREATE TABLE #SinkQ02
(
  weekday_name   NVARCHAR(100) NULL,
  weekday_number INT           NULL,
  decision_hour  INT           NULL,
  booking_count  BIGINT        NULL
);

CREATE TABLE #RunTiming
(
  target_id  VARCHAR(40)   NOT NULL,
  run_no     INT           NOT NULL,
  elapsed_ms DECIMAL(18,3) NOT NULL,
  PRIMARY KEY (target_id, run_no)
);
GO

-- ============================================================================
-- 6. WARM-UP PASS
-- ============================================================================
PRINT 'WARM-UP PASS - result rows are captured locally';

DECLARE
    @ConflictSpace VARCHAR(20),
    @ConflictStart DATETIME,
    @ConflictEnd DATETIME;

SELECT
  @ConflictSpace = space_code,
  @ConflictStart = requested_start,
  @ConflictEnd = requested_end
FROM #ConflictCase;

TRUNCATE TABLE #SinkConflict;
INSERT INTO #SinkConflict
EXEC dbo.__IDX18_CONFLICT
    @SpaceCode = @ConflictSpace,
    @RequestedStart = @ConflictStart,
    @RequestedEnd = @ConflictEnd;

TRUNCATE TABLE #SinkRoomFinder;
INSERT INTO #SinkRoomFinder
EXEC dbo.__IDX18_ROOM_FINDER;

TRUNCATE TABLE #SinkQ01;
INSERT INTO #SinkQ01
EXEC dbo.__IDX18_REPORT_Q01;

TRUNCATE TABLE #SinkQ02;
INSERT INTO #SinkQ02
EXEC dbo.__IDX18_REPORT_Q02;
GO

-- Reset benchmark procedure cache statistics after warm-up.
EXEC sys.sp_recompile N'dbo.__IDX18_CONFLICT';
EXEC sys.sp_recompile N'dbo.__IDX18_ROOM_FINDER';
EXEC sys.sp_recompile N'dbo.__IDX18_REPORT_Q01';
EXEC sys.sp_recompile N'dbo.__IDX18_REPORT_Q02';
GO

-- ============================================================================
-- 7. FIVE MEASURED PASSES
-- ============================================================================
PRINT 'MEASURED PASSES 1-5';

DECLARE
    @Run INT = 1,
    @T0 DATETIME2(7),
    @Elapsed DECIMAL(18,3),
    @ConflictSpace2 VARCHAR(20),
    @ConflictStart2 DATETIME,
    @ConflictEnd2 DATETIME;

SELECT
  @ConflictSpace2 = space_code,
  @ConflictStart2 = requested_start,
  @ConflictEnd2 = requested_end
FROM #ConflictCase;

WHILE @Run <= 5
BEGIN
  -- T1: booking conflict check
  TRUNCATE TABLE #SinkConflict;
  SET @T0 = SYSDATETIME();
  INSERT INTO #SinkConflict
  EXEC dbo.__IDX18_CONFLICT
        @SpaceCode = @ConflictSpace2,
        @RequestedStart = @ConflictStart2,
        @RequestedEnd = @ConflictEnd2;
  SET @Elapsed = DATEDIFF_BIG(MICROSECOND, @T0, SYSDATETIME()) / 1000.0;
  INSERT INTO #RunTiming
  VALUES
    ('T1_BOOKING_CONFLICT', @Run, @Elapsed);

  -- T2: room finder (Q03)
  TRUNCATE TABLE #SinkRoomFinder;
  SET @T0 = SYSDATETIME();
  INSERT INTO #SinkRoomFinder
  EXEC dbo.__IDX18_ROOM_FINDER;
  SET @Elapsed = DATEDIFF_BIG(MICROSECOND, @T0, SYSDATETIME()) / 1000.0;
  INSERT INTO #RunTiming
  VALUES
    ('T2_ROOM_FINDER_Q03', @Run, @Elapsed);

  -- T3: report Q01
  TRUNCATE TABLE #SinkQ01;
  SET @T0 = SYSDATETIME();
  INSERT INTO #SinkQ01
  EXEC dbo.__IDX18_REPORT_Q01;
  SET @Elapsed = DATEDIFF_BIG(MICROSECOND, @T0, SYSDATETIME()) / 1000.0;
  INSERT INTO #RunTiming
  VALUES
    ('T3_REPORT_Q01', @Run, @Elapsed);

  -- T4: report Q02
  TRUNCATE TABLE #SinkQ02;
  SET @T0 = SYSDATETIME();
  INSERT INTO #SinkQ02
  EXEC dbo.__IDX18_REPORT_Q02;
  SET @Elapsed = DATEDIFF_BIG(MICROSECOND, @T0, SYSDATETIME()) / 1000.0;
  INSERT INTO #RunTiming
  VALUES
    ('T4_REPORT_Q02', @Run, @Elapsed);

  SET @Run += 1;
END;
GO


-- ============================================================================
-- RESULT B - AFTER INDEXING PERFORMANCE
-- ============================================================================
PRINT 'RESULT B - AFTER INDEXING PERFORMANCE (FOUR REQUIRED TARGETS)';

DROP TABLE IF EXISTS #AfterMetrics;

;WITH
  ProcMetrics
  AS
  (
    SELECT
      target_id = CASE p.name
            WHEN '__IDX18_CONFLICT'     THEN 'T1_BOOKING_CONFLICT'
            WHEN '__IDX18_ROOM_FINDER'  THEN 'T2_ROOM_FINDER_Q03'
            WHEN '__IDX18_REPORT_Q01'   THEN 'T3_REPORT_Q01'
            WHEN '__IDX18_REPORT_Q02'   THEN 'T4_REPORT_Q02'
        END,
      ps.execution_count,
      CAST(ps.total_logical_reads * 1.0 / NULLIF(ps.execution_count, 0)
             AS DECIMAL(18,2)) AS avg_logical_reads,
      CAST(ps.total_physical_reads * 1.0 / NULLIF(ps.execution_count, 0)
             AS DECIMAL(18,2)) AS avg_physical_reads,
      CAST(ps.total_worker_time / 1000.0 / NULLIF(ps.execution_count, 0)
             AS DECIMAL(18,2)) AS avg_cpu_ms,
      CAST(ps.total_elapsed_time / 1000.0 / NULLIF(ps.execution_count, 0)
             AS DECIMAL(18,2)) AS avg_elapsed_ms_dmv
    FROM sys.dm_exec_procedure_stats AS ps
      JOIN sys.procedures AS p
      ON p.object_id = ps.object_id
    WHERE ps.database_id = DB_ID()
      AND p.name IN
      (
          '__IDX18_CONFLICT',
          '__IDX18_ROOM_FINDER',
          '__IDX18_REPORT_Q01',
          '__IDX18_REPORT_Q02'
      )
  ),
  WallMetrics
  AS
  (
    SELECT
      target_id,
      COUNT(*) AS measured_runs,
      CAST(AVG(elapsed_ms) AS DECIMAL(18,2)) AS avg_wall_ms,
      CAST(MIN(elapsed_ms) AS DECIMAL(18,2)) AS min_wall_ms,
      CAST(MAX(elapsed_ms) AS DECIMAL(18,2)) AS max_wall_ms
    FROM #RunTiming
    GROUP BY target_id
  )
SELECT
  p.target_id,
  p.execution_count,
  w.measured_runs,
  p.avg_logical_reads,
  p.avg_physical_reads,
  p.avg_cpu_ms,
  p.avg_elapsed_ms_dmv,
  w.avg_wall_ms,
  w.min_wall_ms,
  w.max_wall_ms
INTO #AfterMetrics
FROM ProcMetrics AS p
  JOIN WallMetrics AS w
  ON w.target_id = p.target_id;

SELECT *
FROM #AfterMetrics
ORDER BY target_id;
GO

PRINT 'RESULT B2 - AFTER-INDEX PER-RUN WALL-CLOCK DETAIL';
SELECT target_id, run_no, elapsed_ms
FROM #RunTiming
ORDER BY target_id, run_no;
GO

-- ============================================================================
-- RESULT C - DIRECT BEFORE VS AFTER COMPARISON
-- Positive percentages mean improvement/reduction.
-- ============================================================================
PRINT 'RESULT C - BEFORE VS AFTER PERFORMANCE COMPARISON';

SELECT
  b.target_id,

  b.before_logical_reads,
  a.avg_logical_reads AS after_logical_reads,
  CAST(
        100.0 * (b.before_logical_reads - a.avg_logical_reads)
        / NULLIF(b.before_logical_reads, 0)
        AS DECIMAL(10,2)
    ) AS logical_read_reduction_pct,

  b.before_cpu_ms,
  a.avg_cpu_ms AS after_cpu_ms,
  CAST(
        100.0 * (b.before_cpu_ms - a.avg_cpu_ms)
        / NULLIF(b.before_cpu_ms, 0)
        AS DECIMAL(10,2)
    ) AS cpu_time_reduction_pct,

  b.before_elapsed_ms,
  a.avg_elapsed_ms_dmv AS after_elapsed_ms,
  CAST(
        100.0 * (b.before_elapsed_ms - a.avg_elapsed_ms_dmv)
        / NULLIF(b.before_elapsed_ms, 0)
        AS DECIMAL(10,2)
    ) AS elapsed_time_reduction_pct,

  b.before_wall_ms,
  a.avg_wall_ms AS after_wall_ms,
  CAST(
        100.0 * (b.before_wall_ms - a.avg_wall_ms)
        / NULLIF(b.before_wall_ms, 0)
        AS DECIMAL(10,2)
    ) AS wall_time_reduction_pct
FROM #Baseline AS b
  JOIN #AfterMetrics AS a
  ON a.target_id = b.target_id
ORDER BY b.target_id;
GO

-- ============================================================================
-- RESULT D1 - COMPACT BEFORE PLAN SUMMARY
-- This is based on the three 17 runs; all three produced the same access shape.
-- ============================================================================
PRINT 'RESULT D1 - BEFORE EXECUTION PLAN SUMMARY';

SELECT *
FROM
  (
    VALUES
    ('T1_BOOKING_CONFLICT',
      'BOOKING_REQUEST: Clustered Index Scan; BOOKING_DECISION: UQ booking_id seek + clustered lookup'),

    ('T2_ROOM_FINDER_Q03',
      'BOOKING_REQUEST: Clustered Index Scan; FACILITY: Clustered Index Scan; MAINTENANCE_RECORD: 2 Clustered Index Scans; BOOKING_DECISION: seek + clustered lookup'),

    ('T3_REPORT_Q01',
      'BOOKING_REQUEST: Clustered Index Scan; BOOKING_DECISION: Clustered Index Scan'),

    ('T4_REPORT_Q02',
      'BOOKING_REQUEST: Clustered Index Scan; BOOKING_DECISION: Clustered Index Scan')
) AS v(target_id, before_plan_summary)
ORDER BY target_id;
GO
-- ============================================================================
-- RESULT D2 - AFTER-INDEX EXECUTION PLAN ACCESS OPERATORS
--
-- This is the compact plan evidence for the report: whether SQL Server is
-- scanning or seeking each relevant table/index before indexing.
-- ============================================================================
PRINT 'RESULT D2 - AFTER INDEXING EXECUTION PLAN ACCESS OPERATORS';

;
WITH
  XMLNAMESPACES
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
  target_id = CASE p.name
        WHEN '__IDX18_CONFLICT'     THEN 'T1_BOOKING_CONFLICT'
        WHEN '__IDX18_ROOM_FINDER'  THEN 'T2_ROOM_FINDER_Q03'
        WHEN '__IDX18_REPORT_Q01'   THEN 'T3_REPORT_Q01'
        WHEN '__IDX18_REPORT_Q02'   THEN 'T4_REPORT_Q02'
    END,
  rop.value('@NodeId', 'int') AS node_id,
  rop.value('@PhysicalOp', 'nvarchar(100)') AS physical_operator,
  rop.value('@LogicalOp', 'nvarchar(100)') AS logical_operator,
  obj.value('@Table', 'nvarchar(256)') AS table_name,
  obj.value('@Index', 'nvarchar(256)') AS index_name,
  rop.value('@EstimateRows', 'float') AS estimated_rows,
  rop.value('@EstimatedTotalSubtreeCost', 'float') AS estimated_subtree_cost
FROM sys.dm_exec_procedure_stats AS ps
  JOIN sys.procedures AS p
  ON p.object_id = ps.object_id
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) AS qp
CROSS APPLY qp.query_plan.nodes(
    '//RelOp[@PhysicalOp="Index Seek"
          or @PhysicalOp="Clustered Index Seek"
          or @PhysicalOp="Index Scan"
          or @PhysicalOp="Clustered Index Scan"
          or @PhysicalOp="Table Scan"]'
) AS r(rop)
OUTER APPLY r.rop.nodes('.//Object[1]') AS o(obj)
WHERE ps.database_id = DB_ID()
  AND p.name IN
  (
      '__IDX18_CONFLICT',
      '__IDX18_ROOM_FINDER',
      '__IDX18_REPORT_Q01',
      '__IDX18_REPORT_Q02'
  )
  AND
  (
      obj.value('@Table', 'nvarchar(256)') IS NULL
  OR obj.value('@Table', 'nvarchar(256)') IN
      (
          '[BOOKING_REQUEST]',
          '[BOOKING_DECISION]',
          '[SPACES]',
          '[SPACE_TYPE]',
          '[FACILITY]',
          '[MAINTENANCE_RECORD]',
          '[@RequiredFacilities]'
      )
  )
ORDER BY target_id, estimated_subtree_cost DESC, node_id;
GO

-- ============================================================================
-- RESULT D3 - FULL AFTER-INDEX CACHED PLAN XML (OPTIONAL SCREENSHOT EVIDENCE)
--
-- In SSMS/Azure Data Studio, the XML can be opened/saved if your report needs
-- a visual plan screenshot. You do NOT need to paste all XML back to ChatGPT.
-- ============================================================================
PRINT 'RESULT D3 - FULL AFTER-INDEX CACHED EXECUTION PLAN XML (OPTIONAL)';

SELECT
  target_id = CASE p.name
        WHEN '__IDX18_CONFLICT'     THEN 'T1_BOOKING_CONFLICT'
        WHEN '__IDX18_ROOM_FINDER'  THEN 'T2_ROOM_FINDER_Q03'
        WHEN '__IDX18_REPORT_Q01'   THEN 'T3_REPORT_Q01'
        WHEN '__IDX18_REPORT_Q02'   THEN 'T4_REPORT_Q02'
    END,
  qp.query_plan AS cached_plan_xml
FROM sys.dm_exec_procedure_stats AS ps
  JOIN sys.procedures AS p
  ON p.object_id = ps.object_id
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) AS qp
WHERE ps.database_id = DB_ID()
  AND p.name IN
  (
      '__IDX18_CONFLICT',
      '__IDX18_ROOM_FINDER',
      '__IDX18_REPORT_Q01',
      '__IDX18_REPORT_Q02'
  )
ORDER BY target_id;
GO

-- ============================================================================
-- RESULT E - INDEX USAGE CAUSED BY THESE FOUR TARGETS
-- ============================================================================
PRINT 'RESULT E - AFTER-INDEX INDEX USAGE DELTA (FOUR TARGETS ONLY)';

SELECT
  OBJECT_NAME(i.object_id) AS table_name,
  i.name AS index_name,
  i.type_desc,
  COALESCE(us.user_seeks, 0) - b.user_seeks AS benchmark_seeks,
  COALESCE(us.user_scans, 0) - b.user_scans AS benchmark_scans,
  COALESCE(us.user_lookups, 0) - b.user_lookups AS benchmark_lookups
FROM #IndexUsageBefore AS b
  JOIN sys.indexes AS i
  ON i.object_id = b.object_id
    AND i.index_id = b.index_id
  LEFT JOIN sys.dm_db_index_usage_stats AS us
  ON us.database_id = DB_ID()
    AND us.object_id = b.object_id
    AND us.index_id = b.index_id
WHERE (COALESCE(us.user_seeks, 0) - b.user_seeks) <> 0
  OR (COALESCE(us.user_scans, 0) - b.user_scans) <> 0
  OR (COALESCE(us.user_lookups, 0) - b.user_lookups) <> 0
ORDER BY table_name, index_name;
GO

-- ============================================================================
-- RESULT F - REMAINING WORKLOAD-SPECIFIC MISSING INDEX EVIDENCE
--
-- These are SQL Server hints generated/increased after the controlled index
-- set was created. Remaining high-impact suggestions may indicate that a
-- candidate needs refinement; do not create them automatically.
-- ============================================================================
PRINT 'RESULT F - REMAINING FOUR-TARGET MISSING INDEX EVIDENCE';

;
WITH
  CurrentMissing
  AS
  (
    SELECT
      mig.index_group_handle,
      mid.index_handle,
      mid.object_id,
      mid.statement,
      mid.equality_columns,
      mid.inequality_columns,
      mid.included_columns,
      migs.unique_compiles,
      migs.user_seeks,
      migs.user_scans,
      migs.avg_total_user_cost,
      migs.avg_user_impact
    FROM sys.dm_db_missing_index_group_stats AS migs
      JOIN sys.dm_db_missing_index_groups AS mig
      ON mig.index_group_handle = migs.group_handle
      JOIN sys.dm_db_missing_index_details AS mid
      ON mid.index_handle = mig.index_handle
    WHERE mid.database_id = DB_ID()
      AND mid.object_id IN
      (
          OBJECT_ID(N'dbo.BOOKING_REQUEST'),
          OBJECT_ID(N'dbo.BOOKING_DECISION'),
          OBJECT_ID(N'dbo.SPACES'),
          OBJECT_ID(N'dbo.FACILITY'),
          OBJECT_ID(N'dbo.MAINTENANCE_RECORD')
      )
  ),
  Delta
  AS
  (
    SELECT
      c.*,
      c.user_seeks - COALESCE(b.user_seeks, 0) AS benchmark_user_seeks,
      c.user_scans - COALESCE(b.user_scans, 0) AS benchmark_user_scans,
      c.unique_compiles - COALESCE(b.unique_compiles, 0) AS benchmark_compiles
    FROM CurrentMissing AS c
      LEFT JOIN #MissingBefore AS b
      ON b.index_group_handle = c.index_group_handle
        AND b.index_handle = c.index_handle
  )
SELECT
  OBJECT_NAME(object_id) AS table_name,
  equality_columns,
  inequality_columns,
  included_columns,
  benchmark_user_seeks,
  benchmark_user_scans,
  benchmark_compiles,
  CAST(avg_user_impact AS DECIMAL(8,2)) AS estimated_impact_pct,
  CAST(avg_total_user_cost AS DECIMAL(18,4)) AS avg_estimated_query_cost,
  CAST(
        avg_total_user_cost
        * (avg_user_impact / 100.0)
        * (benchmark_user_seeks + benchmark_user_scans)
        AS DECIMAL(18,2)
    ) AS workload_priority_score,
  'CREATE INDEX ' + QUOTENAME(
        LEFT(
            'IX_Candidate_' + OBJECT_NAME(object_id) + '_'
            + CAST(index_handle AS VARCHAR(20)),
            128
        )
    )
    + ' ON ' + statement + ' ('
    + COALESCE(equality_columns, '')
    + CASE
        WHEN equality_columns IS NOT NULL
    AND inequality_columns IS NOT NULL
        THEN ', '
        ELSE ''
      END
    + COALESCE(inequality_columns, '') + ')'
    + CASE
        WHEN included_columns IS NOT NULL
        THEN ' INCLUDE (' + included_columns + ')'
        ELSE ''
      END
    + ';' AS candidate_create_statement
FROM Delta
WHERE benchmark_user_seeks > 0
  OR benchmark_user_scans > 0
  OR benchmark_compiles > 0
ORDER BY workload_priority_score DESC;
GO


-- ============================================================================
-- RESULT G - CANDIDATE INDEX EFFECTIVENESS CHECK
-- Any zero-use candidate should be questioned in the final report.
-- ============================================================================
PRINT 'RESULT G - CANDIDATE INDEX EFFECTIVENESS CHECK';

;
WITH
  CandidateUsage
  AS
  (
    SELECT
      OBJECT_NAME(i.object_id) AS table_name,
      i.name AS index_name,
      COALESCE(us.user_seeks, 0) - COALESCE(b.user_seeks, 0) AS benchmark_seeks,
      COALESCE(us.user_scans, 0) - COALESCE(b.user_scans, 0) AS benchmark_scans,
      COALESCE(us.user_lookups, 0) - COALESCE(b.user_lookups, 0) AS benchmark_lookups
    FROM sys.indexes AS i
      LEFT JOIN #IndexUsageBefore AS b
      ON b.object_id = i.object_id
        AND b.index_id = i.index_id
      LEFT JOIN sys.dm_db_index_usage_stats AS us
      ON us.database_id = DB_ID()
        AND us.object_id = i.object_id
        AND us.index_id = i.index_id
    WHERE i.name IN
    (
        N'IX_G08_BR_Space_Start',
        N'IX_G08_BR_Start',
        N'IX_G08_BD_Approved_Booking',
        N'IX_G08_Facility_Space_Name',
        N'IX_G08_Maint_Space_Impact_Status_Start'
    )
  )
SELECT
  *,
  CASE
        WHEN benchmark_seeks + benchmark_scans + benchmark_lookups > 0
        THEN 'USED BY MEASURED WORKLOAD'
        ELSE 'NOT USED - REVIEW/DROP CANDIDATE'
    END AS effectiveness
FROM CandidateUsage
ORDER BY table_name, index_name;
GO

-- ============================================================================
-- CLEANUP BENCHMARK-ONLY OBJECTS
-- Candidate tuning indexes intentionally remain for inspection/reporting.
-- ============================================================================
DROP PROCEDURE IF EXISTS dbo.__IDX18_CONFLICT;
DROP PROCEDURE IF EXISTS dbo.__IDX18_ROOM_FINDER;
DROP PROCEDURE IF EXISTS dbo.__IDX18_REPORT_Q01;
DROP PROCEDURE IF EXISTS dbo.__IDX18_REPORT_Q02;
GO

PRINT '============================================================';
PRINT 'G08 RUBRIC-ALIGNED AFTER-INDEX TEST - COMPLETE';
PRINT 'Send back RESULT A1, A2, B, C, D1, D2, E, F and G.';
PRINT 'Most important: C (before/after), D2 (after plan), E (index use).';
PRINT 'Run this whole file 3 times.';
PRINT '============================================================';
GO
