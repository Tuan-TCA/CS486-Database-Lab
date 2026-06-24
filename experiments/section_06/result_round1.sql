-- ============================================================
-- SAMPLE DATA — G08
-- Idempotent: safe to run multiple times.
-- ============================================================

USE CampusSpaceBooking;
GO

-- Idempotent cleanup: delete in reverse FK dependency order
DELETE FROM USAGE_SESSION;
DELETE FROM BOOKING_APPROVAL;
DELETE FROM BOOKING_REQUEST;
DELETE FROM MAINTENANCE_RECORD;
DELETE FROM FACILITY;
DELETE FROM SPACE;
DELETE FROM [USER];
GO

-- ============================================================
-- USERS (7 records — all 6 roles + one suspended account)
-- ============================================================
SET IDENTITY_INSERT [USER] ON;
GO

INSERT INTO [USER] (user_id, full_name, email, phone, role, department, account_status) VALUES
(1, 'Somchai Phanarak',      'somchai.p@university.ac.th',   '081-234-5678', 'Student',                    'Computer Science',     'Active'),
(2, 'Dr. Ananya Wongkham',   'ananya.w@university.ac.th',    '089-876-5432', 'Lecturer',                   'Computer Science',     'Active'),
(3, 'Nattapong Srisuk',      'nattapong.s@university.ac.th', '082-111-2233', 'Teaching Assistant',          'Computer Science',     'Active'),
(4, 'Ploy Rattanaporn',      'ploy.r@university.ac.th',      '083-444-5566', 'Facility Staff',             'Facility Management',  'Active'),
(5, 'Kittisak Chaiyaporn',   'kittisak.c@university.ac.th',  '084-777-8899', 'Facility Manager',           'Facility Management',  'Active'),
(6, 'Wipada Thongchai',      'wipada.t@university.ac.th',    '085-222-3344', 'Department Administrator',   'Computer Science',     'Active'),
(7, 'Thanakorn Meesuk',      'thanakorn.m@university.ac.th', '086-999-0011', 'Student',                    'Computer Science',     'Suspended');
GO

SET IDENTITY_INSERT [USER] OFF;
GO

-- ============================================================
-- SPACES (7 records — all 6 types + all 5 statuses)
-- ============================================================
INSERT INTO SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy) VALUES
('SP01', 'Room 301',               'Classroom',         'Building A', 3, 'A301', 40,  'Available',           'Available for lectures and seminars during office hours'),
('SP02', 'Computer Lab 1',         'Computer Lab',      'Building B', 2, 'B201', 30,  'Available',           'Supervised use only; no food or drink allowed'),
('SP03', 'Executive Meeting Room', 'Meeting Room',      'Building A', 5, 'A501', 12,  'Available',           'Priority for department meetings; book 24 hours in advance'),
('SP04', 'Main Auditorium',        'Auditorium',        'Building C', 1, 'C101', 300, 'In Use',              'Events require approval from the Dean office'),
('SP05', 'Robotics Lab',           'Project Lab',       'Building B', 3, 'B301', 20,  'Under Maintenance',   'Currently closed for electrical system upgrade'),
('SP06', 'Small Meeting Room',     'Meeting Room',      'Building A', 2, 'A202', 8,   'Temporarily Closed',  'Closed for renovation until further notice'),
('SP07', 'Old Study Corner',       'Student Workspace', 'Building D', 1, 'D101', 15,  'Retired',             'Permanently decommissioned; replaced by new student hub');
GO

-- ============================================================
-- FACILITIES (10 records — including facilities for unavailable spaces)
-- ============================================================
-- Available spaces
INSERT INTO FACILITY (space_code, facility_name, description) VALUES
('SP01', 'Projector',          'Epson EB-X51 ceiling-mounted projector'),
('SP01', 'Whiteboard',         'Wall-mounted magnetic whiteboard 120x180cm'),
('SP02', 'Desktop Computer',   '30 Dell OptiPlex workstations with dual monitors'),
('SP02', 'Network Switch',     'Cisco Catalyst 48-port managed switch'),
('SP03', 'Video Conference',   'Logitech Rally Plus conference system'),
('SP03', 'Smart TV',           'Samsung 65-inch 4K display'),
('SP04', 'Sound System',       'JBL Professional line array speaker system'),
('SP04', 'Stage Lighting',     'LED stage lighting rig with DMX controller');
GO

-- Unavailable spaces still have physical facilities (Common Mistake #6)
INSERT INTO FACILITY (space_code, facility_name, description) VALUES
('SP05', '3D Printer',         'Ultimaker S5 Pro — currently offline for maintenance'),
('SP06', 'Whiteboard',         'Glass whiteboard 90x120cm');
GO

-- ============================================================
-- BOOKING REQUESTS (8 records — all 7 statuses covered)
-- Dates: May 2026 = historical, June 2026 = current, July 2026 = future
-- All bookings target Available/In Use spaces to avoid trigger conflicts.
-- ============================================================
SET IDENTITY_INSERT BOOKING_REQUEST ON;
GO

-- BK01: Completed (happy path #1 — classroom lecture, last month)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(1, 2, 'SP01', '2026-05-18 09:00:00', '2026-05-18 12:00:00', 'CS486 Database Systems lecture — midterm review session', 35, 'Lecture', 'Completed');

-- BK02: Completed (happy path #2 — same space, different time slot, last month)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(2, 2, 'SP01', '2026-05-25 13:00:00', '2026-05-25 16:00:00', 'CS486 Database Systems lab — ER diagram workshop', 35, 'Workshop', 'Completed');

-- BK03: Checked In (in-progress session — computer lab, today)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(3, 3, 'SP02', '2026-06-24 13:00:00', '2026-06-24 16:00:00', 'Programming fundamentals lab session — Python exercises', 28, 'Lecture', 'Checked In');

-- BK04: Approved (future booking awaiting check-in)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(4, 6, 'SP04', '2026-07-10 09:00:00', '2026-07-10 12:00:00', 'Department annual planning meeting and budget review', 50, 'Administrative Event', 'Approved');

-- BK05: Pending (awaiting approval decision)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(5, 1, 'SP03', '2026-07-15 14:00:00', '2026-07-15 16:00:00', 'Student club meeting — CS Society semester planning', 10, 'Student Activity', 'Pending');

-- BK06: Rejected (with rejection reason — must insert before approval row)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(6, 1, 'SP04', '2026-05-20 09:00:00', '2026-05-20 17:00:00', 'Student gaming tournament — full day event', 200, 'Student Activity', 'Rejected');

-- BK07: Cancelled (user-cancelled before any decision)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(7, 3, 'SP03', '2026-06-20 10:00:00', '2026-06-20 11:00:00', 'TA weekly sync meeting — cancelled due to schedule conflict', 5, 'Meeting', 'Cancelled');

-- BK08: No-Show (was approved but user never showed up — needs approval record)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(8, 1, 'SP02', '2026-05-22 09:00:00', '2026-05-22 11:00:00', 'Examination preparation — individual study session', 1, 'Seminar', 'No-Show');
GO

SET IDENTITY_INSERT BOOKING_REQUEST OFF;
GO

-- ============================================================
-- BOOKING APPROVALS (5 records — for Completed×2, Checked In, 
-- Approved, Rejected, and No-Show bookings)
-- ============================================================
SET IDENTITY_INSERT BOOKING_APPROVAL ON;
GO

-- Approval for BK01 (Completed)
INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
(1, 1, 5, '2026-05-15 10:30:00', 'Approved — regular lecture slot for CS486', NULL);

-- Approval for BK02 (Completed)
INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
(2, 2, 5, '2026-05-22 09:15:00', 'Approved — workshop follows the regular lecture schedule', NULL);

-- Approval for BK03 (Checked In)
INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
(3, 3, 4, '2026-06-22 14:00:00', 'Approved — lab confirmed available with all workstations operational', NULL);

-- Approval for BK04 (Approved, future)
INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
(4, 4, 5, '2026-07-01 11:00:00', 'Approved — auditorium reserved for department annual event', NULL);

-- Rejection for BK06 (Rejected — requires non-empty, meaningful rejection_reason)
INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
(5, 6, 5, '2026-05-17 16:45:00', 'Rejected — see rejection reason', 'The auditorium is reserved for academic events only. Student gaming tournaments do not meet the usage policy requirements. Please consider booking an off-campus venue.');

-- Approval for BK08 (No-Show — MUST have a prior approved record)
INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
(6, 8, 4, '2026-05-20 08:30:00', 'Approved — study session in computer lab', NULL);
GO

SET IDENTITY_INSERT BOOKING_APPROVAL OFF;
GO

-- ============================================================
-- USAGE SESSIONS (3 records — Completed×2 + Checked In×1)
-- ============================================================
SET IDENTITY_INSERT USAGE_SESSION ON;
GO

-- Session for BK01 (Completed — full check-in and check-out)
INSERT INTO USAGE_SESSION (session_id, booking_id, actual_start_time, actual_end_time, checked_in_by_user_id, completed_by_user_id, initial_condition, final_condition, usage_notes) VALUES
(1, 1, '2026-05-18 08:55:00', '2026-05-18 11:50:00', 4, 4,
 'Room clean and ready. Projector operational. 35 chairs arranged in lecture format.',
 'Room left in good condition. Whiteboard erased. All equipment powered off.',
 'Lecture ran smoothly. Midterm review covered chapters 5-8. Full attendance.');

-- Session for BK02 (Completed — full check-in and check-out)
INSERT INTO USAGE_SESSION (session_id, booking_id, actual_start_time, actual_end_time, checked_in_by_user_id, completed_by_user_id, initial_condition, final_condition, usage_notes) VALUES
(2, 2, '2026-05-25 13:05:00', '2026-05-25 15:45:00', 4, 4,
 'Room in standard condition. Tables rearranged for group work.',
 'Room restored to lecture layout. Minor whiteboard marker residue noted.',
 'Workshop completed. Students worked in groups of 4 on ER diagram exercises.');

-- Session for BK03 (Checked In — in progress, no check-out yet)
INSERT INTO USAGE_SESSION (session_id, booking_id, actual_start_time, actual_end_time, checked_in_by_user_id, completed_by_user_id, initial_condition, final_condition, usage_notes) VALUES
(3, 3, '2026-06-24 13:10:00', NULL, 4, NULL,
 'All 30 workstations powered on and logged into lab image. Network connectivity verified.',
 NULL,
 NULL);
GO

SET IDENTITY_INSERT USAGE_SESSION OFF;
GO

-- ============================================================
-- MAINTENANCE RECORDS (4 records — all 4 statuses covered)
-- ============================================================
SET IDENTITY_INSERT MAINTENANCE_RECORD ON;
GO

-- M01: Resolved — completed maintenance for SP01
INSERT INTO MAINTENANCE_RECORD (maintenance_id, space_code, reporter_user_id, assigned_staff_user_id, problem_description, start_time, completion_time, status, result_note) VALUES
(1, 'SP01', 2, 4,
 'Ceiling projector displaying intermittent color artifacts on the right side of the projected image.',
 '2026-05-10 09:00:00', '2026-05-12 14:00:00', 'Resolved',
 'Replaced the projector lamp and cleaned the color wheel. Test projection confirmed normal operation.');

-- M02: In Progress — active maintenance on SP05 (Under Maintenance space)
INSERT INTO MAINTENANCE_RECORD (maintenance_id, space_code, reporter_user_id, assigned_staff_user_id, problem_description, start_time, completion_time, status, result_note) VALUES
(2, 'SP05', 5, 4,
 'Electrical system upgrade required — multiple power outlets showing voltage irregularities affecting 3D printer and workstation equipment.',
 '2026-06-15 08:00:00', NULL, 'In Progress',
 NULL);

-- M03: Open — unassigned issue (NULL assigned_staff_user_id)
INSERT INTO MAINTENANCE_RECORD (maintenance_id, space_code, reporter_user_id, assigned_staff_user_id, problem_description, start_time, completion_time, status, result_note) VALUES
(3, 'SP06', 3, NULL,
 'Water stain observed on ceiling tiles near the air conditioning unit. Possible leak from the floor above.',
 '2026-06-20 11:30:00', NULL, 'Open',
 NULL);

-- M04: Closed — fully resolved and closed out
INSERT INTO MAINTENANCE_RECORD (maintenance_id, space_code, reporter_user_id, assigned_staff_user_id, problem_description, start_time, completion_time, status, result_note) VALUES
(4, 'SP02', 4, 4,
 'Network switch in server rack showing intermittent port failures on ports 12-16.',
 '2026-04-01 10:00:00', '2026-04-05 16:30:00', 'Closed',
 'Replaced faulty Cisco switch with new unit. All 48 ports tested and confirmed operational. Old switch sent for warranty claim.');
GO

SET IDENTITY_INSERT MAINTENANCE_RECORD OFF;
GO
