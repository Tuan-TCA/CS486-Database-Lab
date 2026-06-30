-- ============================================================
-- Section 07: Query Design (Round 2)
-- ============================================================

-- ============================================================
-- Category 1: Booking Operations
-- ============================================================

-- Query 1: Find All Upcoming Approved Events
-- Business Question: Which approved bookings are scheduled to occur in the future?
-- Target User(s): Facility Manager
-- Explanation: Helps facility staff prepare rooms for upcoming events.
SELECT booking_id, requested_start_time, s.space_name
FROM BOOKING_REQUEST br
JOIN SPACE s ON br.space_code = s.space_code
WHERE br.status = 'Approved' AND br.requested_start_time > GETDATE(); -- BUG: Static sample data makes GETDATE() return 0 rows

-- Query 2: Pending Requests
-- Business Question: What booking requests are pending?
-- Target User(s): Facility Manager
-- Explanation: Operational queue.
SELECT booking_id, u.full_name
FROM BOOKING_REQUEST br
JOIN [USER] u ON br.user_id = u.user_id
WHERE br.status = 'Pending';

-- Query 3: Cancelled Bookings
-- Business Question: How many bookings were cancelled per space type?
-- Target User(s): Facility Manager
-- Explanation: Analyze cancellation rates.
SELECT s.space_type, COUNT(br.booking_id) AS total_cancelled
FROM BOOKING_REQUEST br
JOIN SPACE s ON br.space_code = s.space_code
WHERE br.status = 'Cancelled'
GROUP BY s.space_type;

-- ============================================================
-- Category 2: Availability & Conflicts
-- ============================================================

-- Query 4: Find Free Classrooms
-- Business Question: Which Classrooms are currently available?
-- Target User(s): Student
-- Explanation: Find a room.
SELECT space_code, space_name
FROM SPACE
WHERE space_type = 'Classroom' AND current_status != 'Under Maintenance'; -- FIXED: current_status

-- Query 5: Blocked by Maintenance
-- Business Question: Are there pending bookings overlapping with maintenance?
-- Target User(s): Facility Staff
-- Explanation: Prevent approving broken rooms.
SELECT br.booking_id, mr.maintenance_id
FROM BOOKING_REQUEST br
JOIN MAINTENANCE_RECORD mr ON br.space_code = mr.space_code
WHERE br.status = 'Pending' AND mr.status = 'Open';

-- Query 6: Spaces In Use
-- Business Question: Which spaces are actively used?
-- Target User(s): Security
-- Explanation: Real-time visibility.
SELECT space_code FROM SPACE WHERE current_status = 'In Use';

-- ============================================================
-- Category 3: Usage & Check-in
-- ============================================================

-- Query 7: Zombie Sessions
-- Business Question: Checked-in sessions without checkout?
-- Target User(s): Facility Staff
-- Explanation: Requires intervention.
SELECT session_id FROM USAGE_SESSION WHERE actual_end_time IS NULL;

-- Query 8: Top 3 No-Show Offenders
-- Business Question: Highest 'No-Show' users?
-- Target User(s): Dept Admin
-- Explanation: Issue warnings.
SELECT TOP 3 WITH TIES u.user_id, COUNT(br.booking_id) AS no_shows
FROM [USER] u
JOIN BOOKING_REQUEST br ON u.user_id = br.user_id
WHERE br.status = 'No-show'
GROUP BY u.user_id
ORDER BY no_shows DESC; -- FIXED: TOP 3 WITH TIES

-- Query 9: Avg Check-In Delay
-- Business Question: Avg minutes late?
-- Target User(s): Facility Manager
-- Explanation: Adjust policies.
SELECT AVG(DATEDIFF(MINUTE, requested_start_time, actual_start_time))
FROM BOOKING_REQUEST br
JOIN USAGE_SESSION us ON br.booking_id = us.booking_id;

-- ============================================================
-- Category 4: Maintenance
-- ============================================================

-- Query 10: Open Maintenance
-- Business Question: Open tasks?
-- Target User(s): Facility Manager
-- Explanation: Dashboard.
SELECT maintenance_id FROM MAINTENANCE_RECORD WHERE status = 'Open';

-- Query 11: Avg Resolution Time
-- Business Question: How long to fix?
-- Target User(s): Facility Manager
-- Explanation: Efficiency metric.
SELECT AVG(DATEDIFF(HOUR, start_time, completion_time)) FROM MAINTENANCE_RECORD WHERE status = 'Closed';

-- Query 12: Offline Spaces
-- Business Question: Spaces offline?
-- Target User(s): Student
-- Explanation: Transparency.
SELECT space_code FROM SPACE WHERE current_status = 'Under Maintenance';

-- ============================================================
-- Category 5: User Activity
-- ============================================================

-- Query 13: Booking History
-- Business Question: Total bookings per student?
-- Target User(s): Admin
-- Explanation: Engagement.
SELECT u.user_id, COUNT(br.booking_id)
FROM [USER] u
INNER JOIN BOOKING_REQUEST br ON u.user_id = br.user_id -- BUG: Still using INNER JOIN
WHERE u.role = 'Student'
GROUP BY u.user_id;

-- Query 14: High Rejection Rates
-- Business Question: Users with >50% rejection?
-- Target User(s): Facility Manager
-- Explanation: Identify spammers.
SELECT user_id, CAST(SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(booking_id), 0) AS rate
FROM BOOKING_REQUEST
GROUP BY user_id; -- FIXED: NULLIF used

-- Query 15: Busiest Departments
-- Business Question: Depts with most events?
-- Target User(s): Admin
-- Explanation: Budget allocation.
SELECT department, COUNT(*) FROM [USER] GROUP BY department;

-- ============================================================
-- Category 6: Approval Tracking
-- ============================================================

-- Query 16: Rejection Reasons
-- Business Question: Common reasons?
-- Target User(s): Manager
-- Explanation: Systemic issues.
SELECT rejection_reason, COUNT(*) FROM BOOKING_APPROVAL GROUP BY rejection_reason;

-- Query 17: Approver Workload
-- Business Question: Decisions per staff?
-- Target User(s): Admin
-- Explanation: Audit workload.
SELECT decided_by_user_id, COUNT(*) FROM BOOKING_APPROVAL GROUP BY decided_by_user_id;

-- Query 18: Time to Decision
-- Business Question: Hours to decide?
-- Target User(s): Manager
-- Explanation: SLA tracking.
SELECT AVG(DATEDIFF(HOUR, decision_time, decision_time)) FROM BOOKING_APPROVAL;

-- ============================================================
-- Category 7: Aggregations & Reports
-- ============================================================

-- Query 19: Monthly Utilization
-- Business Question: Booked hours per space?
-- Target User(s): Manager
-- Explanation: Primary metric.
SELECT space_code, SUM(DATEDIFF(HOUR, requested_start_time, requested_end_time))
FROM BOOKING_REQUEST
GROUP BY space_code;

-- Query 20: Event Size Efficiency
-- Business Question: Event size vs Capacity?
-- Target User(s): Manager
-- Explanation: Resource allocation.
SELECT AVG(expected_participants) / NULLIF(AVG(capacity), 0)
FROM BOOKING_REQUEST JOIN SPACE ON BOOKING_REQUEST.space_code = SPACE.space_code; -- FIXED: NULLIF

-- Query 21: Busiest Buildings
-- Business Question: Highest volume building?
-- Target User(s): Admin
-- Explanation: Janitorial routing.
SELECT building, COUNT(*) FROM SPACE JOIN BOOKING_REQUEST ON SPACE.space_code = BOOKING_REQUEST.space_code GROUP BY building;

-- ============================================================
-- Category 8: Advanced Analytics
-- ============================================================

-- Query 22: Popularity Rank
-- Business Question: Rank spaces?
-- Target User(s): Manager
-- Explanation: Best in class.
SELECT space_code, RANK() OVER(ORDER BY COUNT(*) DESC) FROM BOOKING_REQUEST GROUP BY space_code;

-- Query 23: Asset Distribution
-- Business Question: Equipment count?
-- Target User(s): Manager
-- Explanation: Spot under-equipped rooms.
SELECT space_code, COUNT(*) FROM FACILITY GROUP BY space_code;

-- Query 24: Condition Deterioration
-- Business Question: Worsened conditions?
-- Target User(s): Manager
-- Explanation: Damage tracking.
SELECT session_id FROM USAGE_SESSION WHERE initial_condition = 'Good' AND final_condition = 'Damaged';
