-- ============================================================================
-- 17-indexing-query-tuning-G08.sql
-- Campus Space Management System - G08
-- RUBRIC-ALIGNED BASELINE: Indexing and Query Tuning
--
-- Requirement addressed exactly:
--   "Tune the booking conflict check, room finder, and the two selected
--    reporting queries. Compare their execution plans and execution times
--    before and after indexing."
--
-- This file is the BEFORE-INDEX baseline only.
-- Reporting-query constraint: selected reports must come from Query 01-04.
-- We therefore use Q01 and Q02; Q03 is already the required room finder.
-- It benchmarks exactly four targets:
--   T1_BOOKING_CONFLICT  - dedicated overlap/conflict existence check
--   T2_ROOM_FINDER_Q03   - Query 03 from 16-analytical-queries-G08.sql
--   T3_REPORT_Q01        - Query 01: approved booking hours per space
--   T4_REPORT_Q02        - Query 02: approved booking distribution by weekday and hour
--
--   Q04 is not selected because its maintenance-escalation output is data-
--   dependent and may be empty, making it a weaker timing benchmark.
-- Method:
--   1. Verify Phase-2 schema and ensure no custom tuning indexes already exist.
--   2. Refresh statistics on relevant tables so BEFORE/AFTER differ by indexes,
--      not by stale statistics.
--   3. Create four temporary benchmark stored procedures mirroring the required
--      workloads.
--   4. Warm the buffer cache once, then reset the benchmark plan statistics.
--   5. Execute each target five measured times with result sets captured locally
--      (no client/network result-rendering noise in the measurements).
--   6. Report average logical reads, CPU time, elapsed time, and wall-clock time.
--   7. Report seek/scan operators from each cached execution plan.
--   8. Report workload-specific missing-index recommendations as evidence only.
--   9. Drop all benchmark-only procedures.
--
-- IMPORTANT:
--   - Run AFTER: 05 -> 06 -> 10 -> 14.
--   - Run BEFORE creating any custom performance indexes.
--   - Execute this WHOLE file in ONE query window/session.
--   - Do NOT run the previously generated 18-index-candidate-test-G08.sql first.
--   - This file creates NO production indexes.
--   - Do NOT create the DMV-generated index statements yourself.
--
-- WHAT TO SEND BACK:
--   Run this whole file 3 times, then send me the combined output.
--   RESULT A1, A2, A3, B, C, D and E are sufficient.
--   B and C are the most important for the final BEFORE/AFTER report.
-- ============================================================================

USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

PRINT '============================================================';
PRINT 'G08 RUBRIC-ALIGNED INDEX TUNING BASELINE - START';
PRINT 'Targets: conflict check, room finder, report Q01, report Q02';
PRINT 'Database: ' + DB_NAME();
PRINT '============================================================';
GO

-- ============================================================================
-- 0. SAFETY / SCHEMA VALIDATION
-- ============================================================================
IF OBJECT_ID(N'dbo.BOOKING_REQUEST', N'U') IS NULL
  OR OBJECT_ID(N'dbo.BOOKING_DECISION', N'U') IS NULL
  OR OBJECT_ID(N'dbo.SPACES', N'U') IS NULL
  OR OBJECT_ID(N'dbo.SPACE_TYPE', N'U') IS NULL
  OR OBJECT_ID(N'dbo.FACILITY', N'U') IS NULL
  OR OBJECT_ID(N'dbo.MAINTENANCE_RECORD', N'U') IS NULL
  OR COL_LENGTH(N'dbo.BOOKING_REQUEST', N'start_time') IS NULL
  OR COL_LENGTH(N'dbo.BOOKING_REQUEST', N'end_time') IS NULL
  OR COL_LENGTH(N'dbo.BOOKING_DECISION', N'is_approved') IS NULL
  OR COL_LENGTH(N'dbo.MAINTENANCE_RECORD', N'impact_level') IS NULL
BEGIN
  ;THROW 51000,
      'Expected Phase-2 schema not found. Run 05, 06, 10, and 14 before 17.',
      1;
END;
GO

-- ============================================================================
-- 0A. RESET ONLY INDEXES CREATED BY OUR EARLIER TUNING EXPERIMENTS
--
-- This allows a clean new baseline on the current database without rebuilding
-- 05 -> 14. It does NOT remove PK/UNIQUE indexes or unknown user indexes.
-- ============================================================================
DROP INDEX IF EXISTS IX_G08_BR_Space_Start
ON dbo.BOOKING_REQUEST;

DROP INDEX IF EXISTS IX_G08_BR_Start
ON dbo.BOOKING_REQUEST;

DROP INDEX IF EXISTS IX_G08_BD_Approved_Booking
ON dbo.BOOKING_DECISION;

DROP INDEX IF EXISTS IX_G08_Facility_Space_Name
ON dbo.FACILITY;

DROP INDEX IF EXISTS IX_G08_Maint_Space_Impact_Status_Start
ON dbo.MAINTENANCE_RECORD;

DROP INDEX IF EXISTS IX_BOOKING_REQUEST_Space_Start
ON dbo.BOOKING_REQUEST;

DROP INDEX IF EXISTS IX_BOOKING_REQUEST_User
ON dbo.BOOKING_REQUEST;

DROP INDEX IF EXISTS IX_BOOKING_DECISION_Approved_Time
ON dbo.BOOKING_DECISION;
GO

-- A true BEFORE-index baseline must not already contain ad-hoc tuning indexes
-- on the tables involved in these four targets. PK/UNIQUE-constraint indexes
-- are part of the schema and are allowed.
IF EXISTS
(
    SELECT 1
FROM sys.indexes AS i
WHERE i.object_id IN
    (
        OBJECT_ID(N'dbo.BOOKING_REQUEST'),
        OBJECT_ID(N'dbo.BOOKING_DECISION'),
        OBJECT_ID(N'dbo.SPACES'),
        OBJECT_ID(N'dbo.FACILITY'),
        OBJECT_ID(N'dbo.MAINTENANCE_RECORD')
    )
  AND i.index_id > 0
  AND i.is_hypothetical = 0
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
)
BEGIN
  PRINT 'CUSTOM INDEXES DETECTED ON TARGET TABLES:';

  SELECT
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.filter_definition
  FROM sys.indexes AS i
  WHERE i.object_id IN
    (
        OBJECT_ID(N'dbo.BOOKING_REQUEST'),
        OBJECT_ID(N'dbo.BOOKING_DECISION'),
        OBJECT_ID(N'dbo.SPACES'),
        OBJECT_ID(N'dbo.FACILITY'),
        OBJECT_ID(N'dbo.MAINTENANCE_RECORD')
    )
    AND i.index_id > 0
    AND i.is_hypothetical = 0
    AND i.is_primary_key = 0
    AND i.is_unique_constraint = 0
  ORDER BY table_name, index_name;

  THROW 51001,
      'Baseline invalid: custom indexes already exist. Restore the pre-index database, then rerun 17.',
      1;
END;
GO

-- ============================================================================
-- 1. CONTROL STATISTICS
-- Refreshing both BEFORE and (later) AFTER runs isolates the effect of indexes.
-- ============================================================================
UPDATE STATISTICS dbo.BOOKING_REQUEST WITH FULLSCAN;
UPDATE STATISTICS dbo.BOOKING_DECISION WITH FULLSCAN;
UPDATE STATISTICS dbo.SPACES WITH FULLSCAN;
UPDATE STATISTICS dbo.SPACE_TYPE WITH FULLSCAN;
UPDATE STATISTICS dbo.FACILITY WITH FULLSCAN;
UPDATE STATISTICS dbo.MAINTENANCE_RECORD WITH FULLSCAN;
GO

-- ============================================================================
-- RESULT A1 - DATABASE + TABLE CARDINALITY
-- ============================================================================
PRINT 'RESULT A1 - BASELINE DATABASE AND TABLE CARDINALITY';

SELECT
  DB_NAME() AS database_name,
  CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(50)) AS sql_server_version,
  d.compatibility_level,
  d.is_auto_create_stats_on,
  d.is_auto_update_stats_on
FROM sys.databases AS d
WHERE d.database_id = DB_ID();

SELECT
  OBJECT_SCHEMA_NAME(ps.object_id) AS schema_name,
  OBJECT_NAME(ps.object_id) AS table_name,
  SUM(ps.row_count) AS row_count,
  CAST(SUM(ps.reserved_page_count) * 8.0 / 1024 AS DECIMAL(12,2)) AS reserved_mb,
  CAST(SUM(ps.used_page_count) * 8.0 / 1024 AS DECIMAL(12,2)) AS used_mb
FROM sys.dm_db_partition_stats AS ps
WHERE ps.index_id IN (0, 1)
  AND ps.object_id IN
  (
      OBJECT_ID(N'dbo.BOOKING_REQUEST'),
      OBJECT_ID(N'dbo.BOOKING_DECISION'),
      OBJECT_ID(N'dbo.SPACES'),
      OBJECT_ID(N'dbo.SPACE_TYPE'),
      OBJECT_ID(N'dbo.FACILITY'),
      OBJECT_ID(N'dbo.MAINTENANCE_RECORD')
  )
GROUP BY ps.object_id
ORDER BY row_count DESC, table_name;
GO

-- ============================================================================
-- RESULT A2 - CURRENT INDEXES ON THE FOUR-TARGET WORKLOAD TABLES
-- ============================================================================
PRINT 'RESULT A2 - PRE-INDEX INDEX INVENTORY';

SELECT
  OBJECT_NAME(i.object_id) AS table_name,
  i.name AS index_name,
  i.type_desc,
  i.is_primary_key,
  i.is_unique,
  i.is_unique_constraint,
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
    ).value('.', 'nvarchar(max)'), 1, 2, ''),
  i.filter_definition
FROM sys.indexes AS i
WHERE i.object_id IN
(
    OBJECT_ID(N'dbo.BOOKING_REQUEST'),
    OBJECT_ID(N'dbo.BOOKING_DECISION'),
    OBJECT_ID(N'dbo.SPACES'),
    OBJECT_ID(N'dbo.SPACE_TYPE'),
    OBJECT_ID(N'dbo.FACILITY'),
    OBJECT_ID(N'dbo.MAINTENANCE_RECORD')
)
  AND i.index_id > 0
  AND i.is_hypothetical = 0
ORDER BY table_name, i.index_id;
GO

-- ============================================================================
-- 2. CHOOSE A REPRODUCIBLE POSITIVE CONFLICT CASE
--
-- We select an existing approved, non-cancelled booking and test a hypothetical
-- new booking with the same space/time. This guarantees that the conflict check
-- has a meaningful positive case without hard-coding a booking ID.
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
  ;THROW 51002,
      'No approved non-cancelled booking exists to build a reproducible conflict case.',
      1;
END;

PRINT 'RESULT A3 - REPRESENTATIVE BOOKING CONFLICT TEST CASE';
SELECT *
FROM #ConflictCase;
GO

-- ============================================================================
-- 3. SNAPSHOT INDEX-USAGE + MISSING-INDEX DMVS BEFORE THE FOUR-TARGET WORKLOAD
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
-- 4. BENCHMARK PROCEDURES - EXACTLY FOUR RUBRIC TARGETS
-- ============================================================================
DROP PROCEDURE IF EXISTS dbo.__IDX17_CONFLICT;
DROP PROCEDURE IF EXISTS dbo.__IDX17_ROOM_FINDER;
DROP PROCEDURE IF EXISTS dbo.__IDX17_REPORT_Q01;
DROP PROCEDURE IF EXISTS dbo.__IDX17_REPORT_Q02;
GO

-- ----------------------------------------------------------------------------
-- T1 - BOOKING CONFLICT CHECK
-- A hypothetical booking conflicts when an approved, non-cancelled booking for
-- the same space overlaps the requested half-open interval [start, end).
-- ----------------------------------------------------------------------------
CREATE PROCEDURE dbo.__IDX17_CONFLICT
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
CREATE PROCEDURE dbo.__IDX17_ROOM_FINDER
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
CREATE PROCEDURE dbo.__IDX17_REPORT_Q01
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
-- Selected from the permitted Query 01-04 range.
-- ----------------------------------------------------------------------------
CREATE PROCEDURE dbo.__IDX17_REPORT_Q02
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
EXEC dbo.__IDX17_CONFLICT
    @SpaceCode = @ConflictSpace,
    @RequestedStart = @ConflictStart,
    @RequestedEnd = @ConflictEnd;

TRUNCATE TABLE #SinkRoomFinder;
INSERT INTO #SinkRoomFinder
EXEC dbo.__IDX17_ROOM_FINDER;

TRUNCATE TABLE #SinkQ01;
INSERT INTO #SinkQ01
EXEC dbo.__IDX17_REPORT_Q01;

TRUNCATE TABLE #SinkQ02;
INSERT INTO #SinkQ02
EXEC dbo.__IDX17_REPORT_Q02;
GO

-- Reset benchmark procedure cache statistics after warm-up.
EXEC sys.sp_recompile N'dbo.__IDX17_CONFLICT';
EXEC sys.sp_recompile N'dbo.__IDX17_ROOM_FINDER';
EXEC sys.sp_recompile N'dbo.__IDX17_REPORT_Q01';
EXEC sys.sp_recompile N'dbo.__IDX17_REPORT_Q02';
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
  EXEC dbo.__IDX17_CONFLICT
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
  EXEC dbo.__IDX17_ROOM_FINDER;
  SET @Elapsed = DATEDIFF_BIG(MICROSECOND, @T0, SYSDATETIME()) / 1000.0;
  INSERT INTO #RunTiming
  VALUES
    ('T2_ROOM_FINDER_Q03', @Run, @Elapsed);

  -- T3: report Q01
  TRUNCATE TABLE #SinkQ01;
  SET @T0 = SYSDATETIME();
  INSERT INTO #SinkQ01
  EXEC dbo.__IDX17_REPORT_Q01;
  SET @Elapsed = DATEDIFF_BIG(MICROSECOND, @T0, SYSDATETIME()) / 1000.0;
  INSERT INTO #RunTiming
  VALUES
    ('T3_REPORT_Q01', @Run, @Elapsed);

  -- T4: report Q02
  TRUNCATE TABLE #SinkQ02;
  SET @T0 = SYSDATETIME();
  INSERT INTO #SinkQ02
  EXEC dbo.__IDX17_REPORT_Q02;
  SET @Elapsed = DATEDIFF_BIG(MICROSECOND, @T0, SYSDATETIME()) / 1000.0;
  INSERT INTO #RunTiming
  VALUES
    ('T4_REPORT_Q02', @Run, @Elapsed);

  SET @Run += 1;
END;
GO

-- ============================================================================
-- RESULT B - BASELINE PERFORMANCE FOR EXACTLY FOUR REQUIRED TARGETS
--
-- avg_logical_reads: primary I/O metric
-- avg_cpu_ms:         CPU consumed by SQL Server
-- avg_elapsed_ms_dmv: SQL Server procedure elapsed time
-- avg_wall_ms:        independently measured server-side wall-clock time
-- ============================================================================
PRINT 'RESULT B - BEFORE INDEXING PERFORMANCE (FOUR REQUIRED TARGETS)';

;
WITH
  ProcMetrics
  AS
  (
    SELECT
      target_id = CASE p.name
            WHEN '__IDX17_CONFLICT'     THEN 'T1_BOOKING_CONFLICT'
            WHEN '__IDX17_ROOM_FINDER'  THEN 'T2_ROOM_FINDER_Q03'
            WHEN '__IDX17_REPORT_Q01'   THEN 'T3_REPORT_Q01'
            WHEN '__IDX17_REPORT_Q02'   THEN 'T4_REPORT_Q02'
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
          '__IDX17_CONFLICT',
          '__IDX17_ROOM_FINDER',
          '__IDX17_REPORT_Q01',
          '__IDX17_REPORT_Q02'
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
FROM ProcMetrics AS p
  JOIN WallMetrics AS w
  ON w.target_id = p.target_id
ORDER BY p.target_id;
GO

-- Optional per-run timing detail for reproducibility.
PRINT 'RESULT B2 - PER-RUN WALL-CLOCK DETAIL';
SELECT target_id, run_no, elapsed_ms
FROM #RunTiming
ORDER BY target_id, run_no;
GO

-- ============================================================================
-- RESULT C - BASELINE EXECUTION PLAN ACCESS OPERATORS
--
-- This is the compact plan evidence for the report: whether SQL Server is
-- scanning or seeking each relevant table/index before indexing.
-- ============================================================================
PRINT 'RESULT C - BEFORE INDEXING EXECUTION PLAN ACCESS OPERATORS';

;
WITH
  XMLNAMESPACES
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
  target_id = CASE p.name
        WHEN '__IDX17_CONFLICT'     THEN 'T1_BOOKING_CONFLICT'
        WHEN '__IDX17_ROOM_FINDER'  THEN 'T2_ROOM_FINDER_Q03'
        WHEN '__IDX17_REPORT_Q01'   THEN 'T3_REPORT_Q01'
        WHEN '__IDX17_REPORT_Q02'   THEN 'T4_REPORT_Q02'
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
      '__IDX17_CONFLICT',
      '__IDX17_ROOM_FINDER',
      '__IDX17_REPORT_Q01',
      '__IDX17_REPORT_Q02'
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
-- RESULT C2 - FULL CACHED PLAN XML (OPTIONAL SCREENSHOT EVIDENCE)
--
-- In SSMS/Azure Data Studio, the XML can be opened/saved if your report needs
-- a visual plan screenshot. You do NOT need to paste all XML back to ChatGPT.
-- ============================================================================
PRINT 'RESULT C2 - FULL CACHED EXECUTION PLAN XML (OPTIONAL)';

SELECT
  target_id = CASE p.name
        WHEN '__IDX17_CONFLICT'     THEN 'T1_BOOKING_CONFLICT'
        WHEN '__IDX17_ROOM_FINDER'  THEN 'T2_ROOM_FINDER_Q03'
        WHEN '__IDX17_REPORT_Q01'   THEN 'T3_REPORT_Q01'
        WHEN '__IDX17_REPORT_Q02'   THEN 'T4_REPORT_Q02'
    END,
  qp.query_plan AS cached_plan_xml
FROM sys.dm_exec_procedure_stats AS ps
  JOIN sys.procedures AS p
  ON p.object_id = ps.object_id
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) AS qp
WHERE ps.database_id = DB_ID()
  AND p.name IN
  (
      '__IDX17_CONFLICT',
      '__IDX17_ROOM_FINDER',
      '__IDX17_REPORT_Q01',
      '__IDX17_REPORT_Q02'
  )
ORDER BY target_id;
GO

-- ============================================================================
-- RESULT D - EXISTING INDEX USAGE CAUSED BY THESE FOUR TARGETS
-- ============================================================================
PRINT 'RESULT D - PRE-INDEX INDEX USAGE DELTA (FOUR TARGETS ONLY)';

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
-- RESULT E - WORKLOAD-SPECIFIC MISSING INDEX EVIDENCE
--
-- These are SQL Server hints generated/increased by ONLY the four measured
-- targets. They are evidence, not instructions. Do NOT execute the generated
-- CREATE INDEX statements yet; 18 will consolidate them intelligently.
-- ============================================================================
PRINT 'RESULT E - FOUR-TARGET WORKLOAD MISSING INDEX EVIDENCE';

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
-- 8. CLEANUP BENCHMARK-ONLY PROCEDURES
-- ============================================================================
DROP PROCEDURE IF EXISTS dbo.__IDX17_CONFLICT;
DROP PROCEDURE IF EXISTS dbo.__IDX17_ROOM_FINDER;
DROP PROCEDURE IF EXISTS dbo.__IDX17_REPORT_Q01;
DROP PROCEDURE IF EXISTS dbo.__IDX17_REPORT_Q02;
GO

PRINT '============================================================';
PRINT 'G08 RUBRIC-ALIGNED BASELINE - COMPLETE';
PRINT 'Send back RESULT A1, A2, A3, B, C, D and E.';
PRINT 'B + C are the key BEFORE-index evidence.';
PRINT 'Do NOT create any indexes yet.';
PRINT 'I will generate 18 from these results.';
PRINT '============================================================';
GO
