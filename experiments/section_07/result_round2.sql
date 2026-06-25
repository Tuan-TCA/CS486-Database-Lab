-- ============================================================
-- Section 07: Query Design — Round 2
-- Campus Space Booking System — G08
-- ============================================================

-- ============================================================
-- Schema Reference
--   [USER]: user_id (PK), full_name, email, phone, role, department, account_status
--   SPACE: space_code (PK), space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy
--   FACILITY: facility_id (PK), space_code (FK->SPACE), facility_name, description
--   BOOKING_REQUEST: booking_id (PK), user_id (FK->USER), space_code (FK->SPACE), requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status
--   BOOKING_APPROVAL: approval_id (PK), booking_id (FK->BR, UNIQUE), decided_by_user_id (FK->USER), decision_time, decision_note, rejection_reason
--   USAGE_SESSION: session_id (PK), booking_id (FK->BR, UNIQUE), actual_start_time, actual_end_time, checked_in_by_user_id (FK->USER), completed_by_user_id (FK->USER), initial_condition, final_condition, usage_notes
--   MAINTENANCE_RECORD: maintenance_id (PK), space_code (FK->SPACE), reporter_user_id (FK->USER), assigned_staff_user_id (FK->USER), problem_description, start_time, completion_time, status, result_note
-- ============================================================

-- ============================================================
-- Category 1: Booking Operations
-- ============================================================

-- Q1 — Pending Bookings Awaiting Approval
-- Business Question: Which booking requests are currently pending and waiting for a decision?
-- Target User(s): Facility Staff, Facility Manager
-- Explanation: Helps staff prioritize which requests need review, ensuring timely responses.
-- Index: Consider composite index on BOOKING_REQUEST(status, requested_start_time) for faster filtering.
SELECT
    BR.booking_id,
    U.full_name AS requester,
    U.role AS requester_role,
    S.space_name,
    BR.requested_start_time,
    BR.requested_end_time,
    BR.purpose,
    BR.booking_type
FROM BOOKING_REQUEST BR
INNER JOIN [USER] U ON U.user_id = BR.user_id
INNER JOIN SPACE S ON S.space_code = BR.space_code
WHERE BR.status = 'Pending'
ORDER BY BR.requested_start_time ASC;
GO

-- Q2 — Approved Upcoming Bookings
-- Business Question: Which approved bookings are scheduled for the future?
-- Target User(s): Facility Staff, Department Administrator
-- Explanation: Allows staff to prepare spaces for upcoming approved events.
-- Index: Consider composite index on BOOKING_REQUEST(status, requested_start_time) for faster filtering.
SELECT
    BR.booking_id,
    U.full_name AS requester,
    S.space_name,
    S.building,
    S.room_number,
    BR.requested_start_time,
    BR.requested_end_time,
    BR.purpose,
    BR.expected_participants
FROM BOOKING_REQUEST BR
INNER JOIN [USER] U ON U.user_id = BR.user_id
INNER JOIN SPACE S ON S.space_code = BR.space_code
WHERE BR.status = 'Approved'
  AND BR.requested_start_time > GETDATE()
ORDER BY BR.requested_start_time ASC;
GO

-- Q3 — User Booking History
-- Business Question: What is the complete booking history for a specific user?
-- Target User(s): Facility Staff, User
-- Explanation: Enables users and staff to review past, current, and future bookings.
SELECT
    BR.booking_id,
    S.space_name,
    BR.requested_start_time,
    BR.requested_end_time,
    BR.purpose,
    BR.booking_type,
    BR.status
FROM BOOKING_REQUEST BR
INNER JOIN SPACE S ON S.space_code = BR.space_code
WHERE BR.user_id = 1
ORDER BY BR.requested_start_time DESC;
GO

-- ============================================================
-- Category 2: Availability & Conflicts
-- ============================================================

-- Q4 — Available Spaces for a Given Time Slot
-- Business Question: Which spaces are available for booking during a specific time window?
-- Target User(s): All Users
-- Explanation: Helps users find free spaces without manually checking schedules, preventing double-booking.
-- Index: Composite index on BOOKING_REQUEST(space_code, status, requested_start_time) improves overlap checks.
DECLARE @WantStart DATETIME = '2026-07-15 09:00:00';
DECLARE @WantEnd DATETIME = '2026-07-15 12:00:00';
SELECT
    S.space_code,
    S.space_name,
    S.space_type,
    S.building,
    S.floor,
    S.room_number,
    S.capacity,
    S.usage_policy
FROM SPACE S
WHERE S.current_status NOT IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
  AND NOT EXISTS (
      SELECT 1
      FROM BOOKING_REQUEST BR
      WHERE BR.space_code = S.space_code
        AND BR.status IN ('Approved', 'Checked In')
        AND BR.requested_start_time < @WantEnd
        AND BR.requested_end_time > @WantStart
  )
  AND NOT EXISTS (
      SELECT 1
      FROM MAINTENANCE_RECORD MR
      WHERE MR.space_code = S.space_code
        AND MR.status IN ('Open', 'In Progress')
  )
ORDER BY S.space_type, S.capacity DESC;
GO

-- Q5 — Overlapping Approved Bookings Detection
-- Business Question: Are there any approved bookings that overlap in time for the same space?
-- Target User(s): Facility Manager, Facility Staff
-- Explanation: Identifies scheduling conflicts so staff can resolve them proactively.
SELECT
    BR1.booking_id AS booking_1,
    BR2.booking_id AS booking_2,
    S.space_name,
    BR1.requested_start_time,
    BR1.requested_end_time,
    BR2.requested_start_time AS conflict_start,
    BR2.requested_end_time AS conflict_end
FROM BOOKING_REQUEST BR1
INNER JOIN BOOKING_REQUEST BR2
    ON BR1.space_code = BR2.space_code
    AND BR1.booking_id < BR2.booking_id
    AND BR1.requested_start_time < BR2.requested_end_time
    AND BR1.requested_end_time > BR2.requested_start_time
INNER JOIN SPACE S ON S.space_code = BR1.space_code
WHERE BR1.status IN ('Approved', 'Checked In')
  AND BR2.status IN ('Approved', 'Checked In')
ORDER BY S.space_name, BR1.requested_start_time;
GO

-- Q6 — Spaces with No Recent Bookings
-- Business Question: Which spaces have had zero completed bookings in the past 30 days?
-- Target User(s): Facility Manager
-- Explanation: Reveals underutilized spaces that could be repurposed or promoted.
SELECT
    S.space_code,
    S.space_name,
    S.space_type,
    S.building,
    S.capacity
FROM SPACE S
LEFT JOIN BOOKING_REQUEST BR
    ON BR.space_code = S.space_code
    AND BR.status = 'Completed'
    AND BR.requested_end_time >= DATEADD(DAY, -30, GETDATE())
WHERE BR.booking_id IS NULL
ORDER BY S.space_type, S.space_name;
GO

-- ============================================================
-- Category 3: Usage & Check-in
-- ============================================================

-- Q7 — Currently Active (Checked In) Sessions
-- Business Question: Which bookings are currently checked in and in progress?
-- Target User(s): Facility Staff, Facility Manager
-- Explanation: Provides a real-time view of occupied spaces for managing walk-in requests.
SELECT
    BR.booking_id,
    U.full_name AS requester,
    S.space_name,
    US.actual_start_time AS checked_in_at,
    BR.requested_end_time AS expected_end,
    US.initial_condition,
    US.checked_in_by_user_id
FROM BOOKING_REQUEST BR
INNER JOIN USAGE_SESSION US ON US.booking_id = BR.booking_id
INNER JOIN [USER] U ON U.user_id = BR.user_id
INNER JOIN SPACE S ON S.space_code = BR.space_code
WHERE BR.status = 'Checked In'
  AND US.actual_end_time IS NULL
ORDER BY US.actual_start_time;
GO

-- Q8 — Completed Sessions: Actual vs. Requested Duration
-- Business Question: How long did each completed session actually take compared to the requested duration?
-- Target User(s): Facility Staff, Department Administrator
-- Explanation: Identifies overruns or early finishes to inform scheduling policies.
SELECT
    BR.booking_id,
    S.space_name,
    U.full_name AS requester,
    BR.requested_start_time,
    BR.requested_end_time,
    DATEDIFF(MINUTE, BR.requested_start_time, BR.requested_end_time) AS requested_duration_min,
    US.actual_start_time,
    US.actual_end_time,
    DATEDIFF(MINUTE, US.actual_start_time, US.actual_end_time) AS actual_duration_min,
    DATEDIFF(MINUTE, US.actual_end_time, BR.requested_end_time) AS variance_min
FROM BOOKING_REQUEST BR
INNER JOIN USAGE_SESSION US ON US.booking_id = BR.booking_id
INNER JOIN SPACE S ON S.space_code = BR.space_code
INNER JOIN [USER] U ON U.user_id = BR.user_id
WHERE BR.status = 'Completed'
  AND US.actual_end_time IS NOT NULL
ORDER BY BR.requested_start_time;
GO

-- Q9 — No-Show Bookings
-- Business Question: Which approved bookings resulted in no-shows?
-- Target User(s): Facility Manager, Facility Staff
-- Explanation: Tracks wasted reservations for follow-up and penalty policy consideration.
SELECT
    BR.booking_id,
    U.full_name AS requester,
    U.email,
    U.role,
    S.space_name,
    BR.requested_start_time,
    BR.requested_end_time,
    BR.purpose,
    BA.decision_time AS approved_time,
    BA.decided_by_user_id AS approved_by
FROM BOOKING_REQUEST BR
INNER JOIN [USER] U ON U.user_id = BR.user_id
INNER JOIN SPACE S ON S.space_code = BR.space_code
LEFT JOIN BOOKING_APPROVAL BA ON BA.booking_id = BR.booking_id
WHERE BR.status = 'No-Show'
ORDER BY BR.requested_start_time;
GO

-- ============================================================
-- Category 4: Maintenance
-- ============================================================

-- Q10 — Spaces Currently Under Active Maintenance
-- Business Question: Which spaces have active (open or in-progress) maintenance records?
-- Target User(s): Facility Staff, Facility Manager
-- Explanation: Snapshot of unavailable spaces due to maintenance.
SELECT
    S.space_code,
    S.space_name,
    S.building,
    S.room_number,
    MR.maintenance_id,
    MR.problem_description,
    MR.status AS maintenance_status,
    MR.start_time,
    U1.full_name AS reporter,
    U2.full_name AS assigned_staff
FROM MAINTENANCE_RECORD MR
INNER JOIN SPACE S ON S.space_code = MR.space_code
INNER JOIN [USER] U1 ON U1.user_id = MR.reporter_user_id
LEFT JOIN [USER] U2 ON U2.user_id = MR.assigned_staff_user_id
WHERE MR.status IN ('Open', 'In Progress')
ORDER BY MR.start_time;
GO

-- Q11 — Maintenance History for a Specific Space
-- Business Question: What is the complete maintenance history for a given space?
-- Target User(s): Facility Manager, Facility Staff
-- Explanation: Tracks recurring issues for a specific space.
SELECT
    MR.maintenance_id,
    MR.problem_description,
    MR.start_time,
    MR.completion_time,
    MR.status,
    MR.result_note,
    U1.full_name AS reporter,
    U2.full_name AS assigned_staff
FROM MAINTENANCE_RECORD MR
INNER JOIN [USER] U1 ON U1.user_id = MR.reporter_user_id
LEFT JOIN [USER] U2 ON U2.user_id = MR.assigned_staff_user_id
WHERE MR.space_code = 'SP01'
ORDER BY MR.start_time DESC;
GO

-- Q12 — Spaces Blocked by Active Maintenance
-- Business Question: Which bookable spaces are currently blocked by unresolved maintenance?
-- Target User(s): All Users
-- Explanation: Prevents users from attempting to book unavailable spaces.
SELECT
    S.space_code,
    S.space_name,
    S.space_type,
    S.building,
    S.room_number,
    S.current_status,
    MR.maintenance_id,
    MR.problem_description,
    MR.status AS maintenance_status,
    MR.start_time
FROM SPACE S
INNER JOIN MAINTENANCE_RECORD MR ON MR.space_code = S.space_code
WHERE MR.status IN ('Open', 'In Progress')
ORDER BY S.space_name;
GO

-- ============================================================
-- Category 5: User Activity
-- ============================================================

-- Q13 — Most Active Users by Booking Count (with DENSE_RANK)
-- Business Question: Which users have made the most bookings overall?
-- Target User(s): Facility Manager, Department Administrator
-- Explanation: Identifies frequent space users; DENSE_RANK handles ties properly.
SELECT
    DENSE_RANK() OVER (ORDER BY COUNT(BR.booking_id) DESC) AS rank,
    U.user_id,
    U.full_name,
    U.role,
    U.department,
    COUNT(BR.booking_id) AS total_bookings,
    SUM(CASE WHEN BR.status = 'Completed' THEN 1 ELSE 0 END) AS completed_bookings,
    SUM(CASE WHEN BR.status = 'No-Show' THEN 1 ELSE 0 END) AS no_shows
FROM [USER] U
LEFT JOIN BOOKING_REQUEST BR ON BR.user_id = U.user_id
GROUP BY U.user_id, U.full_name, U.role, U.department
ORDER BY rank;
GO

-- Q14 — Detailed Booking History for a User
-- Business Question: What is a specific user's complete booking timeline?
-- Target User(s): Facility Staff, User
-- Explanation: Comprehensive audit trail for a user's booking activity.
SELECT
    BR.booking_id,
    S.space_name,
    S.building,
    S.room_number,
    BR.requested_start_time,
    BR.requested_end_time,
    DATEDIFF(HOUR, BR.requested_start_time, BR.requested_end_time) AS requested_hours,
    BR.purpose,
    BR.booking_type,
    BR.status,
    BA.decision_time,
    BA.rejection_reason,
    US.actual_start_time,
    US.actual_end_time
FROM BOOKING_REQUEST BR
INNER JOIN SPACE S ON S.space_code = BR.space_code
LEFT JOIN BOOKING_APPROVAL BA ON BA.booking_id = BR.booking_id
LEFT JOIN USAGE_SESSION US ON US.booking_id = BR.booking_id
WHERE BR.user_id = 2
ORDER BY BR.requested_start_time DESC;
GO

-- Q15 — Users with Pending Approvals by Role
-- Business Question: Which users currently have pending booking requests, grouped by role?
-- Target User(s): Facility Staff, Facility Manager
-- Explanation: Helps prioritize approvals based on user role (e.g., lecturers first).
SELECT
    U.role,
    U.full_name,
    U.email,
    COUNT(BR.booking_id) AS pending_count,
    MIN(BR.requested_start_time) AS earliest_pending
FROM [USER] U
INNER JOIN BOOKING_REQUEST BR ON BR.user_id = U.user_id AND BR.status = 'Pending'
GROUP BY U.role, U.full_name, U.email
ORDER BY U.role, pending_count DESC;
GO

-- ============================================================
-- Category 6: Approval Tracking
-- ============================================================

-- Q16 — Bookings Awaiting Approval Decision
-- Business Question: Which pending bookings have been waiting the longest?
-- Target User(s): Facility Manager, Facility Staff
-- Explanation: Flags overdue pending requests. Uses requested_start_time as a proxy for submission time because no created_at column exists.
SELECT
    BR.booking_id,
    U.full_name AS requester,
    U.role,
    S.space_name,
    BR.requested_start_time,
    BR.requested_end_time,
    BR.purpose,
    DATEDIFF(DAY, BR.requested_start_time, GETDATE()) AS days_since_request
FROM BOOKING_REQUEST BR
INNER JOIN [USER] U ON U.user_id = BR.user_id
INNER JOIN SPACE S ON S.space_code = BR.space_code
WHERE BR.status = 'Pending'
ORDER BY BR.requested_start_time ASC;
GO

-- Q17 — Rejection Reasons Summary
-- Business Question: What are the most common reasons for booking rejections?
-- Target User(s): Facility Manager, Department Administrator
-- Explanation: Reveals patterns in rejection causes to inform policy adjustments.
SELECT
    BA.rejection_reason,
    COUNT(BR.booking_id) AS rejection_count,
    STRING_AGG(BR.booking_id, ', ') AS rejected_booking_ids
FROM BOOKING_REQUEST BR
INNER JOIN BOOKING_APPROVAL BA ON BA.booking_id = BR.booking_id
WHERE BR.status = 'Rejected'
  AND BA.rejection_reason IS NOT NULL
GROUP BY BA.rejection_reason
ORDER BY rejection_count DESC;
GO

-- Q18 — Approval-to-Rejection Ratio by Staff
-- Business Question: How does each staff member's approval-to-rejection ratio compare?
-- Target User(s): Facility Manager
-- Explanation: Monitors decision-making patterns of staff handling approvals.
SELECT
    U.full_name AS staff_member,
    U.role,
    COUNT(BA.approval_id) AS total_decisions,
    SUM(CASE WHEN BR.status = 'Approved' THEN 1 ELSE 0 END) AS approvals,
    SUM(CASE WHEN BR.status = 'Rejected' THEN 1 ELSE 0 END) AS rejections,
    ROUND(
        CAST(SUM(CASE WHEN BR.status = 'Approved' THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(SUM(CASE WHEN BR.status = 'Rejected' THEN 1 ELSE 0 END), 0),
        2
    ) AS approval_to_rejection_ratio
FROM BOOKING_APPROVAL BA
INNER JOIN [USER] U ON U.user_id = BA.decided_by_user_id
INNER JOIN BOOKING_REQUEST BR ON BR.booking_id = BA.booking_id
GROUP BY U.user_id, U.full_name, U.role
ORDER BY total_decisions DESC;
GO

-- ============================================================
-- Category 7: Aggregations & Reports
-- ============================================================

-- Q19 — Booking Distribution by Space Type
-- Business Question: What percentage of total bookings does each space type account for?
-- Target User(s): Facility Manager, Department Administrator
-- Explanation: Reveals which space types are in highest demand. Metric is booking distribution, not true occupancy.
SELECT
    S.space_type,
    COUNT(BR.booking_id) AS total_bookings,
    ROUND(
        100.0 * COUNT(BR.booking_id) / NULLIF((SELECT COUNT(*) FROM BOOKING_REQUEST), 0),
        1
    ) AS booking_distribution_pct
FROM SPACE S
LEFT JOIN BOOKING_REQUEST BR ON BR.space_code = S.space_code
GROUP BY S.space_type
ORDER BY total_bookings DESC;
GO

-- Q20 — Monthly Booking Trends
-- Business Question: How many bookings were made per month over the past year?
-- Target User(s): Facility Manager, Department Administrator
-- Explanation: Tracks seasonal demand patterns for resource allocation.
SELECT
    YEAR(BR.requested_start_time) AS year,
    MONTH(BR.requested_start_time) AS month,
    COUNT(BR.booking_id) AS total_bookings,
    COUNT(DISTINCT BR.user_id) AS unique_users,
    SUM(BR.expected_participants) AS total_expected_participants
FROM BOOKING_REQUEST BR
WHERE BR.requested_start_time >= DATEADD(YEAR, -1, GETDATE())
GROUP BY YEAR(BR.requested_start_time), MONTH(BR.requested_start_time)
ORDER BY year DESC, month DESC;
GO

-- Q21 — Peak Usage Hours Analysis
-- Business Question: Which hours of the day have the most booking requests?
-- Target User(s): Facility Manager
-- Explanation: Identifies peak demand hours for staffing and scheduling decisions.
SELECT
    DATEPART(HOUR, BR.requested_start_time) AS hour_of_day,
    COUNT(BR.booking_id) AS booking_count,
    COUNT(DISTINCT BR.space_code) AS distinct_spaces_used,
    AVG(BR.expected_participants) AS avg_participants
FROM BOOKING_REQUEST BR
WHERE BR.status NOT IN ('Cancelled', 'Rejected')
GROUP BY DATEPART(HOUR, BR.requested_start_time)
ORDER BY booking_count DESC;
GO

-- ============================================================
-- Category 8: Advanced Analytics
-- ============================================================

-- Q22 — Facility Usage Patterns
-- Business Question: Which facilities are available in the most-booked spaces?
-- Target User(s): Facility Manager, Facility Staff
-- Explanation: Correlates facility availability with booking demand to identify high-value equipment.
SELECT
    F.facility_name,
    COUNT(DISTINCT F.space_code) AS spaces_with_facility,
    COUNT(BR.booking_id) AS bookings_in_those_spaces
FROM FACILITY F
LEFT JOIN BOOKING_REQUEST BR
    ON BR.space_code = F.space_code
    AND BR.status NOT IN ('Cancelled', 'Rejected')
GROUP BY F.facility_name
ORDER BY bookings_in_those_spaces DESC;
GO

-- Q23 — Average Booking Duration by Type
-- Business Question: What is the average requested duration for each booking type?
-- Target User(s): Facility Manager, Department Administrator
-- Explanation: Helps set appropriate time slot templates.
SELECT
    BR.booking_type,
    COUNT(BR.booking_id) AS total_bookings,
    AVG(DATEDIFF(MINUTE, BR.requested_start_time, BR.requested_end_time)) AS avg_duration_min,
    MIN(DATEDIFF(MINUTE, BR.requested_start_time, BR.requested_end_time)) AS min_duration_min,
    MAX(DATEDIFF(MINUTE, BR.requested_start_time, BR.requested_end_time)) AS max_duration_min
FROM BOOKING_REQUEST BR
GROUP BY BR.booking_type
ORDER BY avg_duration_min DESC;
GO

-- Q24 — Space Capacity Utilization Comparison
-- Business Question: How does expected participant count compare to each space's maximum capacity?
-- Target User(s): Facility Manager, Department Administrator
-- Explanation: Identifies overbooked or underutilized spaces relative to capacity.
SELECT
    S.space_name,
    S.space_type,
    S.capacity,
    AVG(BR.expected_participants) AS avg_expected_participants,
    ROUND(
        AVG(CAST(BR.expected_participants AS FLOAT)) / NULLIF(S.capacity, 0) * 100,
        1
    ) AS capacity_utilization_pct,
    MAX(BR.expected_participants) AS max_expected_participants,
    CASE
        WHEN MAX(BR.expected_participants) > S.capacity THEN 'Over Capacity Risk'
        WHEN AVG(CAST(BR.expected_participants AS FLOAT)) / NULLIF(S.capacity, 0) * 100 < 30 THEN 'Underutilized'
        ELSE 'Appropriate'
    END AS utilization_category
FROM SPACE S
INNER JOIN BOOKING_REQUEST BR ON BR.space_code = S.space_code
WHERE BR.status NOT IN ('Cancelled', 'Rejected')
GROUP BY S.space_code, S.space_name, S.space_type, S.capacity
ORDER BY capacity_utilization_pct DESC;
GO
