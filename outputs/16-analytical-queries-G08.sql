-- ============================================================================
-- 16-analytical-queries-G08.sql
-- Campus Space Management System - G08
-- Phase 2 Analytical Queries (Microsoft SQL Server)
--
-- Each query documents the business question, target users, reasoning, and a
-- commented expected output derived from the deterministic data generator
-- (14-data-generator-G08.sql, which creates exactly 100,000 bookings).
--
-- Query-to-requirement traceability:
--   01  total approved booking hours per space        -> BOOKING_DECISION, SPACE_TYPE
--   02  approved booking distribution weekday/hour   -> BOOKING_DECISION
--   03  available-space search                       -> BOOKING_DECISION, MAINTENANCE_RECORD
--   04  bookings affected by maintenance escalation  -> MAINTENANCE_RECORD, BOOKING_DECISION
--   05  automatic vs staff approval breakdown        -> is_automatic, SPACE_TYPE
--   06  booking notification history                 -> BOOKING_NOTIFICATION
--   07  utilization rate per space type              -> SPACE_TYPE, BOOKING_DECISION
--   08  role-based booking activity                  -> ROLE
--   09  maintenance impact analysis                  -> impact_level, BOOKING_NOTIFICATION
--   10  top spaces with most rejections              -> BOOKING_DECISION.decision_reason
--
-- Run after 10-schema-migration-G08.sql and 14-data-generator-G08.sql.
-- All queries are read-only SELECTs.
-- ============================================================================

USE campus_space_management;
GO

SET NOCOUNT ON;
GO

-- ============================================================================
-- Query 01 — Total approved booking hours per space (within a semester)
-- ============================================================================
--
-- Business question:
--   What is the total number of approved booking hours for each space within
--   a given semester?
--
-- Target users:
--   Facility Manager
--
-- Why useful:
--   Measures space utilization to identify overused and underused spaces for
--   capacity planning.
--
-- Expected Output:
-- (approximately 50 rows from generated spaces, plus a few Phase 1 spaces)
--
-- space_code | space_name                | space_type_name      | approved_booking_count | total_approved_hours
-- -----------|---------------------------|----------------------|------------------------|--------------------
-- GSP001     | generated_classroom_001   | classroom            |                   ~237 |             ~533.00
-- GSP002     | generated_computer_lab_002| computer_laboratory  |                   ~237 |             ~711.00
-- GSP003     | generated_meeting_room_003| meeting_room         |                   ~237 |             ~474.00
-- GSP004     | generated_project_lab_004 | project_laboratory   |                   ~237 |             ~711.00
-- GSP005     | generated_auditorium_005  | auditorium           |                   ~237 |             ~711.00
-- ...
--
-- Notes:
--   Approved means BOOKING_DECISION.is_approved = 1 AND status <> 'cancelled'.
--   Classroom hours are lower because most bookings are 2h (75%) with some 3h (25%).
--   Meeting room hours are 2h per booking. Other types are 3h per booking.
--   ~237 approved bookings per space in this semester (85% of ~279 total per space).
-- ============================================================================

DECLARE @SemesterStart DATETIME = '2025-09-01';
DECLARE @SemesterEnd   DATETIME = '2026-02-01';

SELECT
  s.space_code,
  s.space_name,
  st.space_type_name,
  COUNT(*) AS approved_booking_count,
  CAST(SUM(DATEDIFF(MINUTE, br.start_time, br.end_time)) / 60.0
         AS DECIMAL(10,2)) AS total_approved_hours
FROM BOOKING_REQUEST AS br
  JOIN BOOKING_DECISION AS bd ON bd.booking_id = br.booking_id
  JOIN SPACES AS s ON s.space_code = br.space_code
  JOIN SPACE_TYPE AS st ON st.space_type_id = s.space_type_id
WHERE bd.is_approved = 1
  AND br.status <> 'cancelled'
  AND br.start_time >= @SemesterStart
  AND br.start_time <  @SemesterEnd
GROUP BY s.space_code, s.space_name, st.space_type_name
ORDER BY total_approved_hours DESC;
GO

-- ============================================================================
-- Query 02 — Approved booking distribution by weekday and hour
-- ============================================================================
--
-- Business question:
--   How are approved booking decisions distributed across weekdays and hours
--   for a given semester?
--
-- Target users:
--   Facility Manager, Department Administrator
--
-- Why useful:
--   Reveals peak booking decision periods for operational planning and helps
--   identify when booking approval activity is highest.
--
-- Expected Output:
--   (variable — depends on the selected semester and hourly interval)
--
--   With the default interval @FromHour = 7 and @ToHour = 19:
--
-- weekday_name | weekday_number | decision_hour | booking_count
-- -------------|----------------|---------------|--------------
-- Sunday       |              1 |             7 |           ...
-- Sunday       |              1 |             8 |           ...
-- Sunday       |              1 |             9 |           ...
-- ...          |            ... |           ... |           ...
-- Monday       |              2 |             7 |           ...
-- Monday       |              2 |             8 |           ...
-- ...          |            ... |           ... |           ...
--
-- Notes:
--   BOOKING_DECISION.decision_time is used to determine the weekday and hour
--   associated with each approved booking decision.
--   Results are grouped first by weekday and then by hour.
--   @FromHour and @ToHour allow the user to select the hourly interval.
--   The default interval is 07:00 through 18:59.
--   Only approved, non-cancelled bookings are included.
-- ============================================================================

DECLARE @SemesterStart DATETIME = '2025-09-01';
DECLARE @SemesterEnd   DATETIME = '2026-02-01';

DECLARE @FromHour INT = 7;
DECLARE @ToHour   INT = 18;

SELECT
  DATENAME(WEEKDAY, bd.decision_time) AS weekday_name,
  DATEPART(WEEKDAY, bd.decision_time) AS weekday_number,
  DATEPART(HOUR, bd.decision_time)    AS decision_hour,
  COUNT(*)                            AS booking_count
FROM BOOKING_DECISION AS bd
  JOIN BOOKING_REQUEST AS br ON br.booking_id = bd.booking_id
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
GO

-- ============================================================================
-- Query 03 — Available-space search
-- ============================================================================
--
-- Business question:
--   Which spaces are available for a booking with specific requirements?
--
-- Target users:
--   Students, Lecturers, Teaching Assistants, Facility Staff
--
-- Why useful:
--   Helps find spaces matching capacity, facilities, and
--   time constraints.
--
-- Expected Output:
--   (variable — depends on the chosen parameters)
--
--   For the default parameters (@RequestedStart = '2026-10-01 09:00',
--   @RequestedEnd = '2026-10-01 12:00', @MinCapacity = 30,
--   required facilities = 'projector' + 'computer'):
--
-- space_code | space_name                    | space_type_name      | capacity | building | has_advisory_maintenance
-- -----------|-------------------------------|----------------------|----------|----------|------------------------
-- GSP002     | generated_computer_lab_002    | computer_laboratory  |       40 | GB       | YES or NO
-- GSP012     | generated_computer_lab_012    | computer_laboratory  |       45 | GB       | NO
-- GSP004     | generated_project_lab_004     | project_laboratory   |       35 | GD       | NO
-- ...
--
-- Notes:
--   Spaces returned must satisfy ALL of:
--     1. current_status = 'available'
--     2. capacity >= 30
--     3. Has BOTH 'projector' AND 'computer' facilities
--     4. No approved non-cancelled booking overlaps 09:00-12:00
--     5. No active out_of_service maintenance overlaps 09:00-12:00
--   Advisory maintenance does NOT exclude a space (just flagged).
-- ============================================================================

DECLARE @RequestedStart    DATETIME = '2026-10-01 09:00';
DECLARE @RequestedEnd      DATETIME = '2026-10-01 12:00';
DECLARE @MinCapacity       INT = 30;

DECLARE @RequiredFacilities TABLE (facility_name VARCHAR(100));
INSERT INTO @RequiredFacilities
VALUES
  ('projector'),
  ('computer');

DECLARE @RequiredFacilityCount INT = (SELECT COUNT(*)
FROM @RequiredFacilities);

SELECT
  s.space_code,
  s.space_name,
  st.space_type_name,
  s.capacity,
  s.building,
  CASE WHEN EXISTS (
    SELECT 1
    FROM MAINTENANCE_RECORD AS m
    WHERE m.space_code = s.space_code
      AND m.impact_level = 'advisory'
      AND m.status IN ('pending', 'in_progress')
      AND m.start_time < @RequestedEnd
      AND (m.end_time IS NULL OR m.end_time > @RequestedStart)
  ) THEN 'YES' ELSE 'NO' END AS has_advisory_maintenance
FROM SPACES AS s
  JOIN SPACE_TYPE AS st ON st.space_type_id = s.space_type_id
WHERE s.current_status = 'available'
  AND s.capacity >= @MinCapacity
  AND (
    @RequiredFacilityCount = 0
    OR @RequiredFacilityCount = (
      SELECT COUNT(DISTINCT f.facility_name)
      FROM FACILITY AS f
        JOIN @RequiredFacilities AS rf ON f.facility_name = rf.facility_name
      WHERE f.space_code = s.space_code
    )
  )
  AND NOT EXISTS (
    SELECT 1
    FROM BOOKING_REQUEST AS existing_br
      JOIN BOOKING_DECISION AS existing_bd ON existing_bd.booking_id = existing_br.booking_id
    WHERE existing_br.space_code = s.space_code
      AND existing_bd.is_approved = 1
      AND existing_br.status <> 'cancelled'
      AND existing_br.start_time < @RequestedEnd
      AND existing_br.end_time   > @RequestedStart
  )
  AND NOT EXISTS (
    SELECT 1
    FROM MAINTENANCE_RECORD AS m
    WHERE m.space_code = s.space_code
      AND m.impact_level = 'out_of_service'
      AND m.status IN ('pending', 'in_progress')
      AND m.start_time < @RequestedEnd
      AND (m.end_time IS NULL OR m.end_time > @RequestedStart)
  )
ORDER BY s.capacity, s.space_code;
GO

-- ============================================================================
-- Query 04 — Approved bookings affected by maintenance escalation
-- ============================================================================
--
-- Business question:
--   After a specific maintenance record has been escalated from 'advisory' to
--   'out_of_service', which previously approved bookings were affected?
--
-- Target users:
--   Facility Staff, Facility Manager
--
-- Why useful:
--   Lets staff retrieve approved bookings affected by an actual maintenance
--   escalation so that the corresponding users can be informed and the
--   affected bookings can be handled or cancelled.
--
-- Expected Output:
--   (variable — depends on the chosen maintenance_id)
--
--   For @MaintenanceId = 'GM900000001':
--
-- booking_id | user_id | full_name | email | space_code | start_time | end_time | purpose | booking_status | decision_time | escalation_notification_time | maintenance_id | problem_description | impact_level | maintenance_status
-- -----------|---------|-----------|-------|------------|------------|----------|---------|----------------|---------------|------------------------------|----------------|---------------------|--------------|-------------------
-- ...        | ...     | ...       | ...   | ...        | ...        | ...      | ...     | cancelled      | ...           | ...                          | GM900000001    | ...                 | out_of_service| ...
--
-- Notes:
--   BOOKING_NOTIFICATION is used as the record of an actual maintenance
--   escalation affecting a booking.
--   notification_type = 'OUT_OF_SERVICE' identifies bookings affected after
--   maintenance was escalated from advisory to out_of_service.
--   The booking must have an approved BOOKING_DECISION before the escalation
--   notification was generated.
-- ============================================================================

DECLARE @MaintenanceId VARCHAR(20) = 'GM900000001';

SELECT
  br.booking_id,
  br.user_id,
  u.full_name,
  u.email,
  br.space_code,
  br.start_time,
  br.end_time,
  br.purpose,
  br.status AS booking_status,
  bd.decision_time,
  bn.notification_time AS escalation_notification_time,
  m.maintenance_id,
  m.problem_description,
  m.impact_level,
  m.status AS maintenance_status
FROM BOOKING_NOTIFICATION AS bn
  JOIN BOOKING_REQUEST AS br ON br.booking_id = bn.booking_id
  JOIN BOOKING_DECISION AS bd ON bd.booking_id = br.booking_id
  JOIN MAINTENANCE_RECORD AS m ON m.maintenance_id = bn.maintenance_id
  JOIN USERS AS u ON u.user_id = br.user_id
WHERE bn.maintenance_id = @MaintenanceId
  AND bn.notification_type = 'OUT_OF_SERVICE'
  AND bd.is_approved = 1
ORDER BY bn.notification_time, br.start_time;
GO

-- ============================================================================
-- Query 05 — Automatic vs staff approval breakdown by space type
-- ============================================================================
-- Business question:
--   What proportion of decisions were automatic vs staff made, by space type?
--
-- Target users:
--   Facility Manager
--
-- Why useful:
--   Evaluates effectiveness of auto-approval; informs AUTO_USAGE_POLICY tuning.
--
-- Expected Output:
--   (5 rows — one per space type)
--
-- space_type_name      | total_decisions | auto_approved | staff_approved | rejected | automatic_pct
-- ---------------------|-----------------|---------------|----------------|----------|--------------
-- meeting_room         |          ~19600 |         ~8330 |          ~8070 |    ~1200 |        ~49.80
-- project_laboratory   |          ~19600 |         ~8330 |          ~8070 |    ~1200 |        ~49.80
-- classroom            |          ~19600 |             0 |        ~18400  |    ~1200 |          0.00
-- computer_laboratory  |          ~19600 |             0 |        ~18400  |    ~1200 |          0.00
-- auditorium           |          ~19600 |             0 |        ~18400  |    ~1200 |          0.00
--
-- Notes:
--   is_automatic = 1 only for meeting_room and project_laboratory when
--   space_cycle % 2 = 0 (i.e., ~50% of non-pending bookings for those types).
--   Total decisions = 98,000 (all non-pending). Per type: 98000/5 = 19,600.
--   Rejected per type: 6000/5 = 1,200.
-- ============================================================================

SELECT
  st.space_type_name,
  COUNT(*) AS total_decisions,
  SUM(CASE WHEN bd.is_automatic = 1 AND bd.is_approved = 1 THEN 1 ELSE 0 END)
        AS auto_approved,
  SUM(CASE WHEN bd.is_automatic = 0 AND bd.is_approved = 1 THEN 1 ELSE 0 END)
        AS staff_approved,
  SUM(CASE WHEN bd.is_approved = 0 THEN 1 ELSE 0 END)
        AS rejected,
  CAST(100.0 * SUM(CASE WHEN bd.is_automatic = 1 THEN 1 ELSE 0 END)
         / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS automatic_pct
FROM BOOKING_DECISION AS bd
  JOIN BOOKING_REQUEST AS br ON br.booking_id = bd.booking_id
  JOIN SPACES AS s ON s.space_code = br.space_code
  JOIN SPACE_TYPE AS st ON st.space_type_id = s.space_type_id
GROUP BY st.space_type_name
ORDER BY automatic_pct DESC;
GO

-- ============================================================================
-- Query 06 — Booking notification history for a specific space
-- ============================================================================
--
-- Business question:
--   What maintenance-related booking notifications have been generated for a
--   specific space, and why was each notification generated?
--
-- Target users:
--   Facility Staff, Facility Manager
--
-- Why useful:
--   Provides an audit trail of maintenance events affecting booking requests
--   and distinguishes advisory notifications from notifications caused by
--   maintenance escalation.
--
-- Expected Output:
--   (variable — depends on the chosen space)
--
--   For @SpaceCode = 'GSP001':
--
-- booking_id | maintenance_id | notification_type | notification_time | booking_start | booking_end | booking_status | problem_description | impact_level | maintenance_status
-- -----------|----------------|-------------------|-------------------|---------------|-------------|----------------|---------------------|--------------|-------------------
-- ...        | ...            | ADVISORY          | ...               | ...           | ...         | approved       | ...                 | advisory     | ...
-- ...        | ...            | OUT_OF_SERVICE    | ...               | ...           | ...         | cancelled      | ...                 | out_of_service| ...
--
-- Notes:
--   BOOKING_NOTIFICATION supports two notification types.
--
--   'ADVISORY':
--     Generated when a booking request is made while an overlapping advisory
--     maintenance record exists. Advisory maintenance does not block the
--     booking request, but the user must be informed about the maintenance.
--
--   'OUT_OF_SERVICE':
--     Generated when a booking request has already been approved and an
--     overlapping maintenance record is later escalated from 'advisory' to
--     'out_of_service'. The notification identifies the affected approved
--     booking so the administrator can inform the user. The affected booking
--     is then cancelled.
--
--   The same booking and maintenance pair may therefore have both notification
--   types at different times because notification_type is part of the
--   BOOKING_NOTIFICATION primary key.
-- ============================================================================

DECLARE @SpaceCode VARCHAR(20) = 'GSP001';

SELECT
  bn.booking_id,
  bn.maintenance_id,
  bn.notification_type,
  bn.notification_time,
  br.start_time AS booking_start,
  br.end_time   AS booking_end,
  br.status     AS booking_status,
  m.problem_description,
  m.impact_level,
  m.status AS maintenance_status
FROM BOOKING_NOTIFICATION AS bn
  JOIN BOOKING_REQUEST AS br ON br.booking_id = bn.booking_id
  JOIN MAINTENANCE_RECORD AS m ON m.maintenance_id = bn.maintenance_id
WHERE br.space_code = @SpaceCode
ORDER BY bn.notification_time DESC;
GO

-- ============================================================================
-- Query 07 — Utilization rate per space type within a semester
-- ============================================================================
--
-- Business question:
--   What percentage of available hours are actually booked for each space type?
--
-- Target users:
--   Facility Manager
--
-- Why useful:
--   Measures how efficiently each category of space is used.
--
-- Expected Output:
--   (5 rows — one per space type)
--
-- space_type_name      | space_count | weekdays_in_semester | total_available_hours | total_booked_hours | utilization_pct
-- ---------------------|-------------|----------------------|-----------------------|--------------------|-----------------
-- auditorium            |          11 |                  110 |                 12100 |            ~7173   |         ~59.28
-- project_laboratory    |          12 |                  110 |                 13200 |            ~7137   |         ~54.07
-- computer_laboratory   |          13 |                  110 |                 14300 |            ~7123   |         ~49.81
-- classroom             |          13 |                  110 |                 14300 |            ~5356   |         ~37.45
-- meeting_room          |          12 |                  110 |                 13200 |            ~4782   |         ~36.23
--
-- Notes:
--   Available hours = space_count x weekdays x 10 hours/day.
--   Semester 2025-09-01 to 2026-02-01 has approximately 110 weekdays.
--   Booked hours are from approved non-cancelled bookings in the period.
--   Space counts include the Phase 1 migrated spaces plus the 50 generated
--   spaces, so values are higher than a generated-only estimate would be.
--   The workspace type is included with ~0 booked hours (no generated bookings
--   use it).
-- ============================================================================

DECLARE @WeekdayCount INT;
;WITH DateSeries AS (
    SELECT @SemesterStart AS d
  UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM DateSeries
    WHERE d < DATEADD(DAY, -2, @SemesterEnd)
)
SELECT @WeekdayCount = COUNT(*)
FROM DateSeries
WHERE DATEPART(WEEKDAY, d) NOT IN (1, 7)
OPTION (MAXRECURSION 0)

SELECT
  st.space_type_name,
  COUNT(DISTINCT s.space_code) AS space_count,
  @WeekdayCount AS weekdays_in_semester,
  COUNT(DISTINCT s.space_code) * @WeekdayCount * 10 AS total_available_hours,
  CAST(SUM(CASE WHEN bd.is_approved = 1 AND br.status <> 'cancelled'
                  THEN DATEDIFF(MINUTE, br.start_time, br.end_time)
                  ELSE 0 END) / 60.0 AS DECIMAL(10,2)) AS total_booked_hours,
  CAST(100.00 * SUM(CASE WHEN bd.is_approved = 1 AND br.status <> 'cancelled'
                           THEN DATEDIFF(MINUTE, br.start_time, br.end_time)
                           ELSE 0 END) / 60.0
         / NULLIF(COUNT(DISTINCT s.space_code) * @WeekdayCount * 10, 0)
         AS DECIMAL(5,2)) AS utilization_pct
FROM SPACES AS s
  JOIN SPACE_TYPE AS st ON st.space_type_id = s.space_type_id
  LEFT JOIN BOOKING_REQUEST AS br ON br.space_code = s.space_code
    AND br.start_time >= @SemesterStart
    AND br.start_time <  @SemesterEnd
  LEFT JOIN BOOKING_DECISION AS bd ON bd.booking_id = br.booking_id
GROUP BY st.space_type_name
ORDER BY utilization_pct DESC;
GO

-- ============================================================================
-- Query 08 — Role-based booking activity analysis
-- ============================================================================
--
-- Business question:
--   How many bookings does each user role submit, and what are their
--   approval/completion rates?
--
-- Target users:
--   Facility Manager, Department Administrator
--
-- Why useful:
--   Shows which roles drive demand and face higher rejection rates.
--
-- Expected Output:
--   (5 rows — facility_staff users exist but receive no generated bookings,
--    so that role has no rows here)
--
-- role_name                | total_requests | approved | rejected | completed | no_shows | cancelled | pending | approval_rate_pct
-- -------------------------|---------------|----------|----------|-----------|----------|-----------|---------|-------------------
-- student                  |       ~30006  |  ~27603  |   ~1800  |   ~21600  |   ~2402   |    ~2401  |  ~602   |           ~91.99
-- lecturer                 |       ~26686  |  ~24544  |   ~1601  |   ~19210  |   ~2130   |    ~1870  |  ~540   |           ~91.97
-- teaching_assistant       |       ~20004  |  ~18403  |   ~1201  |   ~14402  |   ~1600   |    ~1200  |  ~400   |           ~92.00
-- department_administrator |       ~16674  |  ~15343  |   ~1000  |   ~12002  |   ~1340   |    ~1060  |  ~330   |           ~92.02
-- facility_manager         |        ~6660  |   ~6130  |    ~400  |    ~4800  |    ~530    |     ~470  |  ~130   |           ~92.04
--
-- Notes:
--   The distribution follows the generator's user-assignment formula, which
--   maps each space type's bookings to a specific user range (students for
--   classrooms/labs, lecturers for meetings, etc.).
--   Facility staff (role range 1801-1880) are never assigned requests.
--   Approval rate is consistently ~92% across roles because status
--   distribution is determined by space_cycle, not by user role.
-- ============================================================================

SELECT
  r.role_name,
  COUNT(br.booking_id) AS total_requests,
  SUM(CASE WHEN bd.is_approved = 1 THEN 1 ELSE 0 END) AS approved,
  SUM(CASE WHEN bd.is_approved = 0 THEN 1 ELSE 0 END) AS rejected,
  SUM(CASE WHEN br.status = 'completed' THEN 1 ELSE 0 END) AS completed,
  SUM(CASE WHEN br.status = 'no_show'     THEN 1 ELSE 0 END) AS no_shows,
  SUM(CASE WHEN br.status = 'cancelled'   THEN 1 ELSE 0 END) AS cancelled,
  SUM(CASE WHEN br.status = 'pending'     THEN 1 ELSE 0 END) AS pending,
  CAST(100.0 * SUM(CASE WHEN bd.is_approved = 1 THEN 1 ELSE 0 END)
         / NULLIF(COUNT(br.booking_id), 0) AS DECIMAL(5,2)) AS approval_rate_pct
FROM USERS AS u
  JOIN ROLE AS r ON r.role_id = u.role_id
  JOIN BOOKING_REQUEST AS br ON br.user_id = u.user_id
  LEFT JOIN BOOKING_DECISION AS bd ON bd.booking_id = br.booking_id
GROUP BY r.role_name
ORDER BY total_requests DESC;
GO

-- ============================================================================
-- Query 09 — Maintenance impact analysis: advisory vs out-of-service
-- ============================================================================
--
-- Business question:
--   How are maintenance records distributed between impact levels, and what is
--   the average resolution time for each?
--
-- Target users:
--   Facility Manager
--
-- Why useful:
--   Evaluates whether the two-level maintenance system is used effectively.
--
-- Expected Output:
--   (2 rows — one per impact level)
--
-- impact_level   | total_records | completed | still_active | cancelled | avg_resolution_hours | bookings_notified
-- ---------------|---------------|-----------|--------------|-----------|----------------------|------------------
-- advisory       |           460 |        450|           10 |         0 |          ~3.xx        | ~xxxx
-- out_of_service |           310 |        300|           10 |         0 |          ~3.xx        | 0
--
--   Resolution time = end_time - start_time for completed records.
--   Only advisory completed maintenance generates BOOKING_NOTIFICATION rows,
--   so bookings_notified is 0 for out_of_service.
-- ============================================================================

SELECT
  m.impact_level,
  COUNT(*) AS total_records,
  SUM(CASE WHEN m.status = 'completed' THEN 1 ELSE 0 END) AS completed_records,
  SUM(CASE WHEN m.status IN ('pending', 'in_progress') THEN 1 ELSE 0 END)
        AS still_active,
  SUM(CASE WHEN m.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
  CAST(AVG(CASE WHEN m.status = 'completed' AND m.end_time IS NOT NULL
             THEN CAST(DATEDIFF(MINUTE, m.start_time, m.end_time) AS FLOAT)
        END) / 60.0 AS DECIMAL(10,2)) AS avg_resolution_hours,
  (SELECT COUNT(DISTINCT bn.booking_id)
  FROM BOOKING_NOTIFICATION AS bn
    JOIN MAINTENANCE_RECORD AS m2 ON m2.maintenance_id = bn.maintenance_id
  WHERE m2.impact_level = m.impact_level
  ) AS bookings_notified
FROM MAINTENANCE_RECORD AS m
GROUP BY m.impact_level
ORDER BY m.impact_level;
GO

-- ============================================================================
-- Query 10 — Top 10 spaces with the most rejected bookings
-- ============================================================================
--
-- Business question:
--   Which spaces have the most rejected bookings, and what are their common
--   rejection reasons?
--
-- Target users:
--   Facility Manager
--
-- Why useful:
--   Identifies high-demand spaces where supply doesn't meet demand.
--
-- Expected Output:
--   (10 rows — top 10 most-rejected spaces)
--
-- space_code | space_name | space_type_name | rejected_booking_count | capacity_rejections | other_rejections
-- -----------|------------|-----------------|------------------------|---------------------|-----------------
-- GSP007     | generated_computer_lab_007 | computer_laboratory | ~120 | 0 | ~120
-- GSP024     | generated_project_lab_024  | project_laboratory  | ~120 | ~120 | 0
-- ...
--
-- Notes:
--   Each generated space has exactly ~120 rejected bookings (6% of 2000).
--   The generator gives every booking of a space the same n parity, so all
--   rejections on a space share one reason: 'capacity_exceeded' for even
--   space numbers, 'operating_condition_not_satisfied' for odd ones.
--   Phase 1 spaces may also appear with small counts.
-- ============================================================================

SELECT TOP 10
  s.space_code,
  s.space_name,
  st.space_type_name,
  COUNT(*) AS rejected_booking_count,
  SUM(CASE WHEN bd.decision_reason = 'capacity_exceeded' THEN 1 ELSE 0 END)
        AS capacity_rejections,
  SUM(CASE WHEN bd.decision_reason <> 'capacity_exceeded' THEN 1 ELSE 0 END)
        AS other_rejections
FROM BOOKING_DECISION AS bd
  JOIN BOOKING_REQUEST AS br ON br.booking_id = bd.booking_id
  JOIN SPACES AS s ON s.space_code = br.space_code
  JOIN SPACE_TYPE AS st ON st.space_type_id = s.space_type_id
WHERE bd.is_approved = 0
GROUP BY s.space_code, s.space_name, st.space_type_name
ORDER BY rejected_booking_count DESC;
GO

PRINT 'All analytical queries executed successfully.';
GO
