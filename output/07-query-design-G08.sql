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