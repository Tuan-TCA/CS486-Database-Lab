USE campus_space_management;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* ============================================================
   TEST 19
   PURPOSE:
   Measure INSERT overhead caused by the two additional
   BOOKING_REQUEST indexes.

   We create:

       #BR_NoExtraIndex
           Original/basic structure

       #BR_WithIndexes
           Same structure
           + IX_G08_BR_Space_Start
           + IX_G08_BR_Start

   Then insert the SAME data into both tables repeatedly.

   Therefore:

       extra time = index maintenance overhead
   ============================================================ */


/* ============================================================
   STEP 1 - CLEAN UP
   ============================================================ */

DROP TABLE IF EXISTS #BR_NoExtraIndex;
DROP TABLE IF EXISTS #BR_WithIndexes;
DROP TABLE IF EXISTS #WriteBenchmark;


/* ============================================================
   STEP 2 - CREATE TWO IDENTICAL TEST TABLES

   SELECT TOP (0) copies the column definitions,
   but does NOT copy PK/FK/indexes.
   ============================================================ */

SELECT TOP (0) *
INTO #BR_NoExtraIndex
FROM dbo.BOOKING_REQUEST;


SELECT TOP (0) *
INTO #BR_WithIndexes
FROM dbo.BOOKING_REQUEST;


/* ============================================================
   STEP 3 - GIVE BOTH TABLES THE SAME BASELINE CLUSTERED INDEX

   BOOKING_REQUEST normally has a clustered primary-key index
   on booking_id.

   Both test tables receive the same clustered index so that
   the ONLY important difference is the two tuning indexes.
   ============================================================ */

CREATE UNIQUE CLUSTERED INDEX CX_Test_NoIndex_BookingID
ON #BR_NoExtraIndex(booking_id);


CREATE UNIQUE CLUSTERED INDEX CX_Test_WithIndex_BookingID
ON #BR_WithIndexes(booking_id);


/* ============================================================
   STEP 4 - ADD YOUR TWO TUNING INDEXES TO ONLY ONE TABLE
   ============================================================ */

CREATE NONCLUSTERED INDEX IX_Test_BR_Space_Start
ON #BR_WithIndexes
(
    space_code,
    start_time
)
INCLUDE
(
    end_time,
    status
);


CREATE NONCLUSTERED INDEX IX_Test_BR_Start
ON #BR_WithIndexes
(
    start_time
)
INCLUDE
(
    space_code,
    end_time,
    status
);


/* ============================================================
   STEP 5 - TABLE FOR SAVING RESULTS
   ============================================================ */

CREATE TABLE #WriteBenchmark
(
    run_no       INT            NOT NULL,
    test_name    VARCHAR(40)    NOT NULL,
    rows_inserted BIGINT        NOT NULL,
    elapsed_ms   DECIMAL(18,3)  NOT NULL
);


/* ============================================================
   STEP 6 - RUN THE INSERT TEST 5 TIMES

   We alternate execution order:

   Run 1:
       No index
       With indexes

   Run 2:
       With indexes
       No index

   This reduces bias from always executing one test first.
   ============================================================ */

DECLARE @run INT = 1;

DECLARE @start_time DATETIME2(7);

DECLARE @elapsed_ms DECIMAL(18,3);

DECLARE @rows BIGINT;


WHILE @run <= 5
BEGIN

    PRINT '============================================';
    PRINT CONCAT('RUN ', @run);
    PRINT '============================================';


    /* Remove data from previous run */
    TRUNCATE TABLE #BR_NoExtraIndex;
    TRUNCATE TABLE #BR_WithIndexes;


    /* --------------------------------------------------------
       ODD RUNS
       No-index table first
       -------------------------------------------------------- */

    IF @run % 2 = 1
    BEGIN

        /* ================================================
           TEST A - WITHOUT EXTRA INDEXES
           ================================================ */

        SET @start_time = SYSDATETIME();


        INSERT INTO #BR_NoExtraIndex
        SELECT *
        FROM dbo.BOOKING_REQUEST;


        SET @rows = @@ROWCOUNT;


        SET @elapsed_ms =
            DATEDIFF_BIG
            (
                MICROSECOND,
                @start_time,
                SYSDATETIME()
            ) / 1000.0;


        INSERT INTO #WriteBenchmark
        (
            run_no,
            test_name,
            rows_inserted,
            elapsed_ms
        )
        VALUES
        (
            @run,
            'WITHOUT EXTRA INDEXES',
            @rows,
            @elapsed_ms
        );



        /* ================================================
           TEST B - WITH TWO EXTRA INDEXES
           ================================================ */

        SET @start_time = SYSDATETIME();


        INSERT INTO #BR_WithIndexes
        SELECT *
        FROM dbo.BOOKING_REQUEST;


        SET @rows = @@ROWCOUNT;


        SET @elapsed_ms =
            DATEDIFF_BIG
            (
                MICROSECOND,
                @start_time,
                SYSDATETIME()
            ) / 1000.0;


        INSERT INTO #WriteBenchmark
        (
            run_no,
            test_name,
            rows_inserted,
            elapsed_ms
        )
        VALUES
        (
            @run,
            'WITH TWO EXTRA INDEXES',
            @rows,
            @elapsed_ms
        );

    END


    /* --------------------------------------------------------
       EVEN RUNS
       Indexed table first
       -------------------------------------------------------- */

    ELSE
    BEGIN

        /* ================================================
           TEST B - WITH TWO EXTRA INDEXES
           ================================================ */

        SET @start_time = SYSDATETIME();


        INSERT INTO #BR_WithIndexes
        SELECT *
        FROM dbo.BOOKING_REQUEST;


        SET @rows = @@ROWCOUNT;


        SET @elapsed_ms =
            DATEDIFF_BIG
            (
                MICROSECOND,
                @start_time,
                SYSDATETIME()
            ) / 1000.0;


        INSERT INTO #WriteBenchmark
        (
            run_no,
            test_name,
            rows_inserted,
            elapsed_ms
        )
        VALUES
        (
            @run,
            'WITH TWO EXTRA INDEXES',
            @rows,
            @elapsed_ms
        );



        /* ================================================
           TEST A - WITHOUT EXTRA INDEXES
           ================================================ */

        SET @start_time = SYSDATETIME();


        INSERT INTO #BR_NoExtraIndex
        SELECT *
        FROM dbo.BOOKING_REQUEST;


        SET @rows = @@ROWCOUNT;


        SET @elapsed_ms =
            DATEDIFF_BIG
            (
                MICROSECOND,
                @start_time,
                SYSDATETIME()
            ) / 1000.0;


        INSERT INTO #WriteBenchmark
        (
            run_no,
            test_name,
            rows_inserted,
            elapsed_ms
        )
        VALUES
        (
            @run,
            'WITHOUT EXTRA INDEXES',
            @rows,
            @elapsed_ms
        );

    END;


    SET @run = @run + 1;

END;


/* ============================================================
   STEP 7 - SHOW EVERY RUN
   ============================================================ */

PRINT '';
PRINT '============================================';
PRINT 'RAW RESULTS';
PRINT '============================================';


SELECT
    run_no,
    test_name,
    rows_inserted,
    elapsed_ms
FROM #WriteBenchmark
ORDER BY
    run_no,
    test_name;


/* ============================================================
   STEP 8 - SHOW AVERAGE RESULTS
   ============================================================ */

PRINT '';
PRINT '============================================';
PRINT 'AVERAGE RESULTS';
PRINT '============================================';


SELECT
    test_name,

    COUNT(*) AS measured_runs,

    MAX(rows_inserted) AS rows_per_run,

    CAST
    (
        AVG(elapsed_ms)
        AS DECIMAL(18,3)
    ) AS avg_elapsed_ms,

    CAST
    (
        MIN(elapsed_ms)
        AS DECIMAL(18,3)
    ) AS min_elapsed_ms,

    CAST
    (
        MAX(elapsed_ms)
        AS DECIMAL(18,3)
    ) AS max_elapsed_ms

FROM #WriteBenchmark

GROUP BY
    test_name

ORDER BY
    test_name;


/* ============================================================
   STEP 9 - CALCULATE INDEX WRITE OVERHEAD %
   ============================================================ */

PRINT '';
PRINT '============================================';
PRINT 'INDEX WRITE OVERHEAD';
PRINT '============================================';


WITH AverageTimes AS
(
    SELECT

        AVG
        (
            CASE
                WHEN test_name = 'WITHOUT EXTRA INDEXES'
                THEN elapsed_ms
            END
        ) AS avg_without_indexes,


        AVG
        (
            CASE
                WHEN test_name = 'WITH TWO EXTRA INDEXES'
                THEN elapsed_ms
            END
        ) AS avg_with_indexes

    FROM #WriteBenchmark
)

SELECT

    CAST
    (
        avg_without_indexes
        AS DECIMAL(18,3)
    ) AS avg_without_indexes_ms,


    CAST
    (
        avg_with_indexes
        AS DECIMAL(18,3)
    ) AS avg_with_indexes_ms,


    CAST
    (
        avg_with_indexes
        -
        avg_without_indexes
        AS DECIMAL(18,3)
    ) AS additional_write_time_ms,


    CAST
    (
        (
            avg_with_indexes
            -
            avg_without_indexes
        )
        /
        NULLIF(avg_without_indexes, 0)
        * 100

        AS DECIMAL(10,2)
    ) AS write_overhead_percent

FROM AverageTimes;


/* ============================================================
   STEP 10 - CLEAN UP

   Optional because local temp tables disappear automatically
   when your SQL session ends.
   ============================================================ */

DROP TABLE IF EXISTS #BR_NoExtraIndex;
DROP TABLE IF EXISTS #BR_WithIndexes;
DROP TABLE IF EXISTS #WriteBenchmark;

GO
