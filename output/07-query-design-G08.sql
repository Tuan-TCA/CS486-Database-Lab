-- =====================================================
-- 07-query-design-G08.sql
--
-- IMPORTANT
--
-- According to the project requirement,
-- each query MUST include:
--
-- 1. Business Question
-- 2. Target User(s)
-- 3. Short Explanation Of Why The Query Is Useful
-- 4. SQL Statement
--
-- The comments below are requirements only.
-- Team members will implement the SQL statements.
-- =====================================================



-- =====================================================
-- QUERY 01
-- =====================================================
    
/*

Business Question:
Which spaces are scheduled to be used in the future?

Target User(s):
- Facility Staff
- Facility Manager

Why Useful:
Allows staff to prepare facilities, equipment, and schedules for upcoming activities. It also helps avoid operational conflicts and improves resource planning.

*/
SELECT * FROM SPACES s
JOIN BOOKING_REQUEST br ON s.space_code = br.space_code 
WHERE br.status = 'approved' AND GETDATE() < br.requested_start_time;

-- =====================================================
-- QUERY 02
-- =====================================================

/*

Business Question:
Which spaces are currently unavailable because they are under maintenance?

Target User(s):
- Facility Staff
- Facility Manager

Why Useful:
Allows staff to quickly identify unavailable spaces and avoid assigning or approving bookings for those spaces.

*/
SELECT * FROM SPACES
WHERE current_status = 'under_maintenance'


-- =====================================================
-- QUERY 03
-- =====================================================

/*

Business Question:
Which users reserved spaces but never showed up?

Target User(s):
- Facility Manager

Why Useful:
Helps identify wasted resources and detect users who repeatedly reserve spaces without using them.

*/
SELECT * FROM USERS u
JOIN BOOKING_REQUEST  br ON u.user_id = br.user_id
WHERE br.status = 'no_show'





-- =====================================================
-- QUERY 04
-- =====================================================

/*

Business Question:
Which booking requests were rejected and why were they rejected?

Target User(s):
- Facility Manager
- Department Administrator

Why Useful:
Provides transparency in the approval process and helps analyze common causes of rejection.

*/
SELECT br.*, ba.rejection_reason FROM BOOKING_REQUEST br
JOIN BOOKING_APPROVAL ba ON br.booking_id = ba.booking_id
WHERE br.status = 'rejected'
-- =====================================================
-- QUERY 05
-- =====================================================

/*

Business Question:
Which spaces are used most frequently?

Target User(s):
- Facility Manager

Why Useful:
Helps evaluate space utilization and supports future planning and fair resource allocation.

*/
SELECT TOP 1 WITH TIES
    s.space_code, 
    s.space_name, 
    COUNT(br.booking_id) AS usage_frequency
FROM SPACES s
JOIN BOOKING_REQUEST br ON s.space_code = br.space_code
WHERE br.status IN ('approved', 'checked_in', 'completed') 
GROUP BY s.space_code, s.space_name
ORDER BY usage_frequency DESC;
-- =====================================================
-- QUERY 06
-- =====================================================

/*

Business Question:
How many maintenance tasks is each staff member responsible for?

Target User(s):
- Facility Manager

Why Useful:
Helps distribute maintenance workloads fairly and identify overloaded staff members.

*/
SELECT u.user_id, u.full_name, COUNT(m.maintenance_id) AS num_tasks
FROM USERS u
LEFT JOIN MAINTENANCE_RECORD m 
ON u.user_id = m.assigned_staff_user_id AND m.status IN ('in_progress', 'pending')
WHERE u.role = 'facility_staff'
GROUP BY u.user_id, u.full_name
ORDER BY num_tasks ASC;
-- =====================================================
-- QUERY 07
-- =====================================================

/*

Business Question:
What is the complete booking history of all spaces?

Target User(s):
- Facility Staff
- Facility Manager

Why Useful:
Provides historical records for auditing, reporting, and operational analysis.

*/
SELECT s.space_code, s.space_name, br.booking_id, br.purpose, br.status, br.requested_start_time, br.requested_end_time
FROM SPACES s
LEFT JOIN BOOKING_REQUEST br ON s.space_code = br.space_code
ORDER BY 
    s.space_code ASC, 
    br.requested_start_time DESC;



-- =====================================================
-- QUERY 08
-- =====================================================

/*

Business Question:
Which users reserve spaces most frequently?

Target User(s):
- Facility Manager
- Department Administrator

Why Useful:
Helps analyze user behavior and monitor fair usage of shared campus resources.

*/
SELECT TOP 1 WITH TIES
    u.user_id,  
    u.full_name,
    COUNT(br.booking_id) AS usage_frequency
FROM USERS u
JOIN BOOKING_REQUEST br ON u.user_id = br.user_id
GROUP BY u.user_id, u.full_name
ORDER BY usage_frequency DESC;



-- =====================================================
-- QUERY 09
-- =====================================================

/*

Business Question:
Which buildings have the highest space usage?

Target User(s):
- Facility Manager

Why Useful:
Helps evaluate facility utilization and supports future infrastructure planning.

*/

SELECT TOP 1 WITH TIES
    s.building,
    COUNT(br.booking_id) AS total_usage
FROM SPACES s
JOIN BOOKING_REQUEST br ON s.space_code = br.space_code
WHERE br.status IN ('approved', 'checked_in', 'completed')
GROUP BY s.building
ORDER BY total_usage DESC;

-- =====================================================
-- QUERY 10
-- =====================================================

    /*

Business Question:
Which activity types occupy campus spaces most frequently?

Target User(s):
- Facility Manager
- Department Administrator

Why Useful:
Helps understand demand patterns and supports future scheduling decisions.

*/

SELECT TOP 1 WITH TIES 
br.booking_type,
COUNT(br.space_code) AS activity_frequency
FROM BOOKING_REQUEST br
WHERE br.status IN ('approved', 'checked_in', 'completed') 
GROUP BY br.booking_type
ORDER BY activity_frequency DESC;

-- =====================================================
-- QUERY 11
-- =====================================================

/*

Business Question:
Which bookings are currently in progress and which bookings have been completed?

Target User(s):
- Facility Staff

Why Useful:
Helps staff monitor ongoing operations and track completed usage sessions.

*/

SELECT 
    br.booking_id, 
    s.space_code,
    s.space_name,
    br.status,
    us.actual_start_time,
    us.actual_end_time
FROM BOOKING_REQUEST br
JOIN SPACES s ON br.space_code = s.space_code
LEFT JOIN USAGE_SESSION us ON br.booking_id = us.booking_id
WHERE br.status IN ('checked_in', 'completed');


-- =====================================================
-- QUERY 12
-- =====================================================

/*

Business Question:
Which available spaces contain specific facilities such as projectors, computers, or livestreaming equipment?

Target User(s):
- Students
- Lecturers
- Teaching Assistants

Why Useful:
Helps users quickly find suitable spaces that satisfy their equipment requirements.

*/
SELECT s.space_code, s.space_name, f.facility_name, f.description FROM FACILITY f
JOIN SPACES s ON s.space_code = f.space_code
WHERE s.current_status = 'available' AND f.facility_name IN ('projector', 'computer', 'livestreaming_equipment');

-- =====================================================
-- QUERY 13
-- =====================================================

/*
Business Question:
Which pending booking requests have events starting soonest?

Why Useful:
Helps staff prioritize pending requests that are dangerously close to their requested start time to avoid last-minute cancellations.
*/
SELECT 
    br.booking_id, 
    u.full_name, 
    s.space_name, 
    DATEDIFF(HOUR, GETDATE(), br.requested_start_time) AS hours_until_event
FROM BOOKING_REQUEST br
JOIN USERS u ON br.user_id = u.user_id
JOIN SPACES s ON br.space_code = s.space_code
WHERE br.status = 'pending'
  AND br.requested_start_time > GETDATE()
ORDER BY hours_until_event ASC;


-- =====================================================
-- QUERY 14
-- =====================================================

/*
Business Question:
What is the average actual session duration for each space type?

Target User(s):
- Facility Manager

Why Useful:
Reveals whether certain space types are being used for longer or shorter than their booking window, which informs capacity planning and default booking time-slot policies.
*/
SELECT 
    s.space_type, 
    AVG(DATEDIFF(MINUTE, us.actual_start_time, us.actual_end_time)) AS avg_duration_minutes
FROM USAGE_SESSION us
JOIN BOOKING_REQUEST br ON us.booking_id = br.booking_id
JOIN SPACES s ON br.space_code = s.space_code
WHERE br.status = 'completed' 
  AND us.actual_end_time IS NOT NULL
GROUP BY s.space_type;


-- =====================================================
-- QUERY 15
-- =====================================================

/*
Business Question:
Which spaces have never received any booking request?

Target User(s):
- Facility Manager

Why Useful:
Identifies underutilised or unknown spaces that may need better promotion, a policy review, or consideration for repurposing.
*/
SELECT 
    s.space_code, 
    s.space_name
FROM SPACES s
LEFT JOIN BOOKING_REQUEST br ON s.space_code = br.space_code
WHERE br.booking_id IS NULL;


-- =====================================================
-- QUERY 16
-- =====================================================

/*
Business Question:
What is the no-show rate for each user who has made at least one booking?

Target User(s):
- Facility Manager
- Department Administrator

Why Useful:
Identifies users with a pattern of reserving spaces and not showing up, enabling the school to enforce usage policies or introduce booking limits for repeat offenders.
*/
SELECT 
    u.user_id, 
    u.full_name, 
    COUNT(br.booking_id) AS total_bookings,
    SUM(CASE WHEN br.status = 'no_show' THEN 1 ELSE 0 END) AS no_show_count,
    CAST(
        100.0 * SUM(CASE WHEN br.status = 'no_show' THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(br.booking_id), 0) 
        AS DECIMAL(5,2)
    ) AS no_show_rate_pct
FROM USERS u
JOIN BOOKING_REQUEST br ON u.user_id = br.user_id
GROUP BY u.user_id, u.full_name
HAVING COUNT(br.booking_id) > 0
ORDER BY no_show_rate_pct DESC;


-- =====================================================
-- QUERY 17
-- =====================================================

/*
Business Question:
Which departments submit the most booking requests, and what is their approval rate?

Target User(s):
- Facility Manager
- Department Administrator

Why Useful:
Provides a per-department breakdown of booking volume and outcomes, helping the school understand demand distribution and whether certain departments face disproportionate rejection rates.
*/
SELECT 
    u.department, 
    COUNT(br.booking_id) AS total_requests,
    SUM(CASE WHEN br.status IN ('approved','checked_in','completed') THEN 1 ELSE 0 END) AS approved_count,
    CAST(
        100.0 * SUM(CASE WHEN br.status IN ('approved','checked_in','completed') THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(br.booking_id), 0) 
        AS DECIMAL(5,2)
    ) AS approval_rate_pct
FROM USERS u
JOIN BOOKING_REQUEST br ON u.user_id = br.user_id
GROUP BY u.department
ORDER BY total_requests DESC;


-- =====================================================
-- QUERY 18
-- =====================================================

/*
Business Question:
Which spaces are available to book right now (no active session and no approved booking in progress)?

Target User(s):
- Students
- Lecturers
- Teaching Assistants
- Facility Staff

Why Useful:
Gives users an instant view of spaces they can walk into or submit a same-day request for, reducing the need to contact staff by phone or email.
*/
SELECT 
    s.space_code, 
    s.space_name
FROM SPACES s
WHERE s.current_status = 'available'
  AND NOT EXISTS (
      SELECT 1 
      FROM BOOKING_REQUEST br
      WHERE br.space_code = s.space_code
        AND br.status IN ('approved', 'checked_in')
        AND GETDATE() BETWEEN br.requested_start_time AND br.requested_end_time
  );


-- =====================================================
-- QUERY 19
-- =====================================================

/*
Business Question:
What is the average resolution time for completed maintenance tasks per facility staff member?

Target User(s):
- Facility Manager

Why Useful:
Helps the manager evaluate staff efficiency, identify potential bottlenecks in facility repairs, and provide better estimates for how long spaces will be unavailable during future maintenance.
*/
SELECT 
    u.user_id, 
    u.full_name, 
    COUNT(m.maintenance_id) AS tasks_completed,
    AVG(DATEDIFF(HOUR, m.start_time, m.completion_time)) AS avg_resolution_hours
FROM USERS u
JOIN MAINTENANCE_RECORD m ON u.user_id = m.assigned_staff_user_id
WHERE m.status = 'completed' 
  AND m.completion_time IS NOT NULL
GROUP BY u.user_id, u.full_name
ORDER BY avg_resolution_hours ASC;


-- =====================================================
-- QUERY 20
-- =====================================================

/*
Business Question:
Which maintenance issues have been pending or in progress for more than 7 days without being resolved?

Target User(s):
- Facility Manager

Why Useful:
Flags overdue maintenance tasks that may be blocking space availability and causing booking disruptions. Prompts action on stalled repairs.
*/
SELECT 
    m.maintenance_id, 
    s.space_name, 
    m.problem_description,
    u_rep.full_name AS reporter_name,
    u_asgn.full_name AS assigned_staff_name,
    DATEDIFF(DAY, m.start_time, GETDATE()) AS days_open
FROM MAINTENANCE_RECORD m
JOIN SPACES s ON m.space_code = s.space_code
JOIN USERS u_rep ON m.reporter_user_id = u_rep.user_id
LEFT JOIN USERS u_asgn ON m.assigned_staff_user_id = u_asgn.user_id
WHERE m.status IN ('pending', 'in_progress') 
  AND DATEDIFF(DAY, m.start_time, GETDATE()) > 7;


-- =====================================================
-- QUERY 21
-- =====================================================

/*
Business Question:
Which users have a history of overstaying in a space beyond their approved requested end time?

Target User(s):
- Facility Manager

Why Useful:
Helps the manager identify users who consistently violate booking policies by hoarding rooms. This data can be used to issue warnings or temporarily suspend booking privileges to ensure fair access for everyone.
*/
SELECT 
    u.user_id, 
    u.full_name, 
    COUNT(br.booking_id) AS total_overstays,
    MAX(DATEDIFF(MINUTE, br.requested_end_time, us.actual_end_time)) AS max_overstay_minutes
FROM USERS u
JOIN BOOKING_REQUEST br ON u.user_id = br.user_id
JOIN USAGE_SESSION us ON br.booking_id = us.booking_id
WHERE br.status = 'completed'
  AND us.actual_end_time > br.requested_end_time
GROUP BY u.user_id, u.full_name
ORDER BY total_overstays DESC, max_overstay_minutes DESC;


-- =====================================================
-- QUERY 22
-- =====================================================

/*
Business Question:
Which spaces have both a high number of bookings and a history of maintenance issues?

Target User(s):
- Facility Manager

Why Useful:
Identifies high-demand spaces that are also prone to maintenance problems, helping the manager prioritise preventive maintenance schedules to avoid disruptions to heavily used areas.
*/
SELECT 
    s.space_code, 
    s.space_name,
    COUNT(DISTINCT br.booking_id) AS total_bookings,
    COUNT(DISTINCT m.maintenance_id) AS total_maintenance_records
FROM SPACES s
JOIN BOOKING_REQUEST br ON s.space_code = br.space_code
JOIN MAINTENANCE_RECORD m ON s.space_code = m.space_code
GROUP BY s.space_code, s.space_name
ORDER BY total_bookings DESC, total_maintenance_records DESC;


-- =====================================================
-- QUERY 23
-- =====================================================

/*
Business Question:
What bookings are scheduled to take place today?

Target User(s):
- Facility Staff

Why Useful:
Gives staff a daily operations view so they can prepare rooms, confirm check-ins on time, and coordinate any last-minute issues before sessions begin.
*/
SELECT 
    br.booking_id, 
    u.full_name, 
    s.space_name, 
    br.requested_start_time, 
    br.requested_end_time
FROM BOOKING_REQUEST br
JOIN USERS u ON br.user_id = u.user_id
JOIN SPACES s ON br.space_code = s.space_code
WHERE CAST(br.requested_start_time AS DATE) = CAST(GETDATE() AS DATE)
  AND br.status IN ('approved', 'checked_in', 'completed')
ORDER BY br.requested_start_time ASC;


-- =====================================================
-- QUERY 24
-- =====================================================

/*
Business Question:
What is the expected occupancy rate for each upcoming approved booking compared to the space's maximum capacity?

Target User(s):
- Facility Staff
- Facility Manager

Why Useful:
Highlights bookings where the expected number of participants is close to or exceeds the space's capacity, allowing staff to intervene early — either to suggest a larger space or to flag a potential safety concern.
*/
SELECT 
    br.booking_id, 
    s.space_name, 
    br.expected_participants, 
    s.capacity,
    CAST(
        100.0 * br.expected_participants / NULLIF(s.capacity, 0) 
        AS DECIMAL(5,2)
    ) AS occupancy_rate_pct
FROM BOOKING_REQUEST br
JOIN SPACES s ON br.space_code = s.space_code
WHERE br.status = 'approved' 
  AND br.requested_start_time > GETDATE()
ORDER BY occupancy_rate_pct DESC;