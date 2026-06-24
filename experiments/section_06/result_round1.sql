-- ============================================================
-- SAMPLE DATA — G08
-- Idempotent: safe to run multiple times.
-- ============================================================

USE campus_space_management;
GO

-- Idempotent cleanup: delete in reverse FK dependency order
DELETE FROM USAGE_SESSION;
DELETE FROM BOOKING_APPROVAL;
DELETE FROM BOOKING_REQUEST;
DELETE FROM MAINTENANCE_RECORD;
DELETE FROM FACILITY;
DELETE FROM SPACES;
DELETE FROM USERS;
GO

-- ============================================================
-- USERS (N records — all roles + one suspended account)
-- ============================================================
INSERT INTO USERS (user_id, full_name, email, phone_number, role, department, account_status) VALUES
('U01', 'Alice Student', 'alice@university.edu', '1234567890', 'student', 'Computer Science', 'active'),
('U02', 'Bob Lecturer', 'bob@university.edu', '1234567891', 'lecturer', 'Computer Science', 'active'),
('U03', 'Charlie TA', 'charlie@university.edu', '1234567892', 'teaching_assistant', 'Computer Science', 'active'),
('U04', 'David Staff', 'david@university.edu', '1234567893', 'facility_staff', 'Facilities', 'active'),
('U05', 'Eve Manager', 'eve@university.edu', '1234567894', 'facility_manager', 'Facilities', 'active'),
('U06', 'Frank Admin', 'frank@university.edu', '1234567895', 'department_administrator', 'Computer Science', 'active'),
('U07', 'Grace Suspended', 'grace@university.edu', '1234567896', 'student', 'Computer Science', 'suspended');
GO

-- ============================================================
-- SPACES (N records — all types + all statuses)
-- ============================================================
INSERT INTO SPACES (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy) VALUES
('SP01', 'Classroom 101', 'Classroom', 'Building A', 1, '101', 30, 'available', 'Standard classroom policy'),
('SP02', 'Computer Lab A', 'Computer Lab', 'Building A', 1, '102', 40, 'available', 'No food or drink'),
('SP03', 'Meeting Room 1', 'Meeting Room', 'Building B', 2, '201', 10, 'available', 'Bookings max 2 hours'),
('SP04', 'Main Auditorium', 'Auditorium', 'Building B', 1, '100', 200, 'available', 'Events only'),
('SP05', 'Project Lab X', 'Project Lab', 'Building C', 3, '301', 20, 'under_maintenance', 'Hardware projects only'),
('SP06', 'Meeting Room 2', 'Meeting Room', 'Building B', 2, '202', 12, 'temporarily_closed', 'Closed for cleaning'),
('SP07', 'Study Space Z', 'Student Workspace', 'Building A', 2, '205', 50, 'retired', 'No longer available');
GO

-- ============================================================
-- FACILITIES (N records)
-- ============================================================
INSERT INTO FACILITY (facility_id, space_code, facility_name, description) VALUES
('F01', 'SP01', 'Projector', 'Standard 1080p projector'),
('F02', 'SP02', 'Computers', '40 Desktop workstations'),
('F03', 'SP03', 'Whiteboard', 'Large magnetic whiteboard'),
('F04', 'SP04', 'PA System', 'Full auditorium sound system'),
('F05', 'SP05', '3D Printer', 'MakerBot Replicator'),
('F06', 'SP06', 'Video Conf', 'Polycom video conferencing'),
('F07', 'SP07', 'Desks', 'Study desks with power outlets');
GO

-- ============================================================
-- BOOKING REQUESTS (N records — all statuses covered)
-- ============================================================
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
('BK01', 'U01', 'SP01', '2026-05-10 10:00:00', '2026-05-10 12:00:00', 'Student meeting', 15, 'student_activity', 'completed'),
('BK02', 'U02', 'SP01', '2026-05-11 10:00:00', '2026-05-11 12:00:00', 'Database Lecture', 25, 'lecture', 'completed'),
('BK03', 'U03', 'SP02', '2026-06-24 18:00:00', '2026-06-24 20:00:00', 'SQL Workshop', 30, 'workshop', 'checked_in'),
('BK04', 'U02', 'SP03', '2026-06-26 10:00:00', '2026-06-26 12:00:00', 'Faculty Meeting', 8, 'meeting', 'approved'),
('BK05', 'U01', 'SP04', '2026-06-27 10:00:00', '2026-06-27 14:00:00', 'Tech Symposium', 150, 'student_activity', 'pending'),
('BK06', 'U01', 'SP01', '2026-05-15 10:00:00', '2026-05-15 12:00:00', 'Club Meeting', 20, 'student_activity', 'rejected'),
('BK07', 'U02', 'SP02', '2026-05-20 10:00:00', '2026-05-20 12:00:00', 'Extra Lecture', 35, 'lecture', 'cancelled'),
('BK08', 'U01', 'SP03', '2026-05-25 10:00:00', '2026-05-25 12:00:00', 'Group Study', 5, 'student_activity', 'no_show');
GO

-- ============================================================
-- BOOKING APPROVALS (N records — Approved + Rejected decisions)
-- ============================================================
INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
('AP01', 'BK01', 'U04', '2026-05-09 10:00:00', 'Approved for student group.', NULL),
('AP02', 'BK02', 'U05', '2026-05-09 10:00:00', 'Approved for lecture series.', NULL),
('AP03', 'BK03', 'U04', '2026-06-23 10:00:00', 'Approved for TA workshop.', NULL),
('AP04', 'BK04', 'U04', '2026-06-25 10:00:00', 'Approved meeting.', NULL),
('AP06', 'BK06', 'U05', '2026-05-14 10:00:00', 'Rejected request.', 'Space is unavailable due to conflicting exams.'),
('AP08', 'BK08', 'U04', '2026-05-24 10:00:00', 'Approved study group.', NULL);
GO

-- ============================================================
-- USAGE SESSIONS (N records — Completed + Checked In)
-- ============================================================
INSERT INTO USAGE_SESSION (session_id, booking_id, actual_start_time, actual_end_time, checked_in_by_user_id, completed_by_user_id, initial_condition, final_condition, usage_notes) VALUES
('US01', 'BK01', '2026-05-10 09:55:00', '2026-05-10 12:05:00', 'U04', 'U04', 'Clean and ready', 'Clean', 'No issues during session.'),
('US02', 'BK02', '2026-05-11 09:50:00', '2026-05-11 12:10:00', 'U04', 'U04', 'Clean', 'Clean', 'Lecture proceeded normally.'),
('US03', 'BK03', '2026-06-24 17:55:00', NULL, 'U04', NULL, 'Clean', NULL, NULL);
GO

-- ============================================================
-- MAINTENANCE RECORDS (N records — all statuses covered)
-- ============================================================
-- Note: 'assigned_staff_user_id' is NOT NULL in DDL, so it cannot be NULL despite requirements suggesting an unassigned test case.
INSERT INTO MAINTENANCE_RECORD (maintenance_id, space_code, reporter_user_id, assigned_staff_user_id, problem_description, start_time, completion_time, status, result_note) VALUES
('M01', 'SP05', 'U01', 'U04', 'Projector bulb burned out', '2026-05-01 10:00:00', '2026-05-02 10:00:00', 'completed', 'Replaced bulb'),
('M02', 'SP05', 'U02', 'U04', 'AC unit leaking water', '2026-06-20 10:00:00', NULL, 'in_progress', NULL),
('M03', 'SP06', 'U03', 'U04', 'Broken chair', '2026-06-24 10:00:00', NULL, 'pending', NULL);
GO
