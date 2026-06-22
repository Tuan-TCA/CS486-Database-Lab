-- ============================================================
-- Query Design — G08
-- DBMS: Microsoft SQL Server
-- Description: 7 meaningful SQL queries answering business
--              questions for the Campus Space Booking System.
-- Sources: project_description.md, req/business-requirement.md
-- ============================================================

USE CampusSpaceBooking;
GO

-- ============================================================
-- Query 1: Upcoming approved bookings for a specific space
-- ---------------------------------------------------------
-- Business Question: What are the upcoming approved bookings
--                    for the Main Auditorium (A101)?
-- Target User: Facility Staff, Facility Manager
-- Explanation: Staff can see future commitments for a space
--              to plan maintenance or resolve scheduling
--              conflicts. This directly supports the
--              requirement "Staff should be able to view
--              upcoming bookings."
-- ============================================================
SELECT
    b.booking_id,
    u.full_name        AS requester,
    b.purpose,
    b.requested_start,
    b.requested_end,
    b.expected_participants,
    b.status
FROM Booking b
JOIN [User] u ON b.requester_id = u.user_id
WHERE b.space_code = 'A101'
  AND b.status IN ('Approved', 'Checked In')
  AND b.requested_start >= GETDATE()
ORDER BY b.requested_start ASC;
GO

-- ============================================================
-- Query 2: Spaces currently under maintenance
-- ---------------------------------------------------------
-- Business Question: Which spaces are currently unavailable
--                    due to maintenance, and what is the
--                    status of each issue?
-- Target User: Facility Staff, Facility Manager
-- Explanation: Quickly identify spaces that cannot be booked
--              and review the progress of ongoing repairs.
--              Supports the requirement "Staff should be able
--              to view spaces under maintenance."
-- ============================================================
SELECT
    s.space_code,
    s.space_name,
    s.building,
    s.room_number,
    m.maintenance_id,
    m.problem_description,
    m.status          AS maintenance_status,
    m.start_time,
    m.completion_time,
    assigned.full_name AS assigned_staff
FROM Space s
JOIN Maintenance m ON s.space_code = m.space_code
LEFT JOIN [User] assigned ON m.assigned_staff_id = assigned.user_id
WHERE s.current_status = 'Under Maintenance'
   OR m.status IN ('Open', 'In Progress')
ORDER BY m.start_time DESC;
GO

-- ============================================================
-- Query 3: No-show bookings in the last 30 days
-- ---------------------------------------------------------
-- Business Question: Which approved bookings resulted in
--                    no-shows during the last month?
-- Target User: Facility Manager
-- Explanation: Identify users who repeatedly fail to show up.
--              Enables the school to follow up with users
--              and consider policy changes to reduce wasted
--              space availability. Supports "Staff should be
--              able to view no-show bookings."
-- ============================================================
SELECT
    b.booking_id,
    u.full_name        AS requester,
    u.email,
    u.role,
    s.space_code,
    s.space_name,
    b.requested_start,
    b.requested_end,
    b.purpose
FROM Booking b
JOIN [User] u ON b.requester_id = u.user_id
JOIN Space s ON b.space_code = s.space_code
WHERE b.status = 'No-Show'
  AND b.requested_start >= DATEADD(DAY, -30, GETDATE())
ORDER BY b.requested_start DESC;
GO

-- ============================================================
-- Query 4: Booking history for a specific user
-- ---------------------------------------------------------
-- Business Question: What is the complete booking history
--                    for a specific student (user_id = 2)?
-- Target User: Department Administrator, Facility Staff
-- Explanation: Review a user's booking record, check for
--              policy violations, and verify usage patterns.
--              Supports "Staff should be able to view booking
--              history."
-- ============================================================
SELECT
    b.booking_id,
    s.space_name,
    s.space_code,
    b.purpose,
    b.requested_start,
    b.requested_end,
    b.status,
    b.booking_time,
    ba.decision,
    ba.decision_time,
    ba.rejection_reason,
    b.actual_start_time,
    b.actual_end_time,
    b.usage_notes
FROM Booking b
JOIN Space s ON b.space_code = s.space_code
LEFT JOIN Booking_Approval ba ON b.booking_id = ba.booking_id
WHERE b.requester_id = 2
ORDER BY b.requested_start DESC;
GO

-- ============================================================
-- Query 5: Monthly space utilization statistics
-- ---------------------------------------------------------
-- Business Question: How many completed bookings and total
--                    usage hours did each space have last
--                    month?
-- Target User: Facility Manager
-- Explanation: Analyze space utilization to make decisions
--              about resource allocation, maintenance
--              scheduling, and future capacity planning.
--              Answers the high-level goal of managing shared
--              campus spaces fairly and efficiently.
-- ============================================================
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    COUNT(b.booking_id)                                      AS total_bookings,
    SUM(DATEDIFF(HOUR, b.actual_start_time, b.actual_end_time)) AS total_usage_hours,
    AVG(b.expected_participants)                             AS avg_expected_participants,
    AVG(1.0 * b.expected_participants / NULLIF(s.capacity, 0)) * 100 AS avg_capacity_util_pct
FROM Space s
LEFT JOIN Booking b ON s.space_code = b.space_code
    AND b.status = 'Completed'
    AND b.actual_start_time >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()) - 1, 1)
    AND b.actual_start_time < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
GROUP BY s.space_code, s.space_name, s.space_type
ORDER BY total_usage_hours DESC;
GO

-- ============================================================
-- Query 6: Pending bookings awaiting approval
-- ---------------------------------------------------------
-- Business Question: Which bookings are still pending and
--                    how long have they been waiting for
--                    a decision?
-- Target User: Facility Staff, Facility Manager
-- Explanation: Staff can prioritize review of bookings that
--              have been pending the longest, ensuring timely
--              responses to space requests.
-- ============================================================
SELECT
    b.booking_id,
    u.full_name        AS requester,
    u.department,
    s.space_name,
    s.space_code,
    b.purpose,
    b.requested_start,
    b.requested_end,
    b.expected_participants,
    b.booking_time,
    DATEDIFF(HOUR, b.booking_time, GETDATE()) AS hours_since_submission
FROM Booking b
JOIN [User] u ON b.requester_id = u.user_id
JOIN Space s ON b.space_code = s.space_code
WHERE b.status = 'Pending'
ORDER BY b.booking_time ASC;
GO

-- ============================================================
-- Query 7: Facilities inventory by space
-- ---------------------------------------------------------
-- Business Question: Which spaces have the most facilities
--                    and what equipment do they offer?
-- Target User: All users (choosing a space), Facility Manager
-- Explanation: Helps users select appropriate spaces based
--              on available equipment (e.g., need a projector
--              and microphone). Also helps facility managers
--              audit equipment distribution across spaces.
-- ============================================================
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    COUNT(sf.facility_id)                        AS facility_count,
    STRING_AGG(f.facility_name, ', ')            AS facility_list
FROM Space s
LEFT JOIN Space_Facility sf ON s.space_code = sf.space_code
LEFT JOIN Facility f ON sf.facility_id = f.facility_id
GROUP BY s.space_code, s.space_name, s.space_type
ORDER BY facility_count DESC;
GO

PRINT 'All queries defined successfully.';
GO
