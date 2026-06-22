-- ============================================================
-- Sample Data — G08
-- DBMS: Microsoft SQL Server
-- Description: Realistic sample data covering normal operations
--              and important exceptional cases.
-- Sources: project_description.md, req/business-requirement.md
-- Idempotent: safe to run multiple times.
-- ============================================================

USE CampusSpaceBooking;
GO

-- ============================================================
-- Idempotent cleanup: delete existing data in reverse FK order
-- ============================================================
DELETE FROM Booking_Approval;
DELETE FROM Maintenance;
DELETE FROM Booking;
DELETE FROM Space_Facility;
DELETE FROM Facility;
DELETE FROM Space;
DELETE FROM [User];
GO

-- ============================================================
-- Users (10 records)
-- Covers all roles: Student, Lecturer, TA, Facility Staff,
-- Facility Manager, Dept Administrator.
-- Also covers an inactive/suspended account.
-- ============================================================
SET IDENTITY_INSERT [User] ON;
GO

INSERT INTO [User] (user_id, full_name, email, phone, role, department, account_status)
VALUES
    (1, 'Alice Nguyen',   'alice.nguyen@university.edu.vn', '0901000001', 'Lecturer',           'Computer Science', 'Active'),
    (2, 'Bob Tran',       'bob.tran@university.edu.vn',     '0901000002', 'Student',            'Computer Science', 'Active'),
    (3, 'Carol Le',       'carol.le@university.edu.vn',     '0901000003', 'TA',                 'Computer Science', 'Active'),
    (4, 'Danh Pham',      'danh.pham@university.edu.vn',    '0901000004', 'Facility Staff',     'Facilities',       'Active'),
    (5, 'Eve Hoang',      'eve.hoang@university.edu.vn',    '0901000005', 'Facility Manager',   'Facilities',       'Active'),
    (6, 'Frank Vu',       'frank.vu@university.edu.vn',     '0901000006', 'Dept Administrator', 'Computer Science', 'Active'),
    (7, 'Grace Ngo',      'grace.ngo@university.edu.vn',    '0901000007', 'Student',            'Computer Science', 'Active'),
    (8, 'Henry Dang',     'henry.dang@university.edu.vn',   '0901000008', 'Lecturer',           'Computer Science', 'Active'),
    (9, 'Ivy Vo',         'ivy.vo@university.edu.vn',       '0901000009', 'Student',            'Computer Science', 'Suspended'),
    (10, 'Jack Bui',      'jack.bui@university.edu.vn',     '0901000010', 'Facility Staff',     'Facilities',       'Active');
GO

SET IDENTITY_INSERT [User] OFF;
GO

-- ============================================================
-- Spaces (10 records)
-- Covers all space types and statuses.
-- Includes spaces that are: Available, Under Maintenance,
-- Temporarily Closed, and Retired.
-- ============================================================
INSERT INTO Space (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES
    ('A101', 'Main Auditorium',       'Auditorium',     'Building A', 1, '101', 200, 'Available',           'Available for lectures, seminars, and academic events.'),
    ('A102', 'Lecture Hall A',        'Classroom',      'Building A', 1, '102', 80,  'Available',           'Standard lecture sessions.'),
    ('B201', 'Computer Lab 1',        'Computer Lab',   'Building B', 2, '201', 40,  'Available',           'Only for computer science practical sessions.'),
    ('B202', 'Computer Lab 2',        'Computer Lab',   'Building B', 2, '202', 35,  'Under Maintenance',   'Closed until further notice due to electrical issues.'),
    ('C301', 'Project Lab Alpha',     'Project Lab',    'Building C', 3, '301', 20,  'Available',           'For student project groups. Booking max 4 hours.'),
    ('C302', 'Meeting Room 1',        'Meeting Room',   'Building C', 3, '302', 12,  'Available',           'For staff meetings and small group discussions.'),
    ('A103', 'Student Workspace',     'Workspace',      'Building A', 1, '103', 30,  'Available',           'Open workspace for students. Max 2 hours per booking.'),
    ('B101', 'Seminar Room',          'Meeting Room',   'Building B', 1, '101', 25,  'Temporarily Closed',  'Under renovation. Expected reopening 2026-07-01.'),
    ('C201', 'Advanced Lab',          'Project Lab',    'Building C', 2, '201', 15,  'Retired',             'No longer in use. Replaced by Building D facilities.'),
    ('A201', 'Lecture Hall B',        'Classroom',      'Building A', 2, '201', 60,  'Available',           'Standard lecture sessions.');
GO

-- ============================================================
-- Facilities (8 records)
-- Covers equipment types listed in the business requirements.
-- ============================================================
SET IDENTITY_INSERT Facility ON;
GO

INSERT INTO Facility (facility_id, facility_name, description)
VALUES
    (1, 'Projector',                'HD projector with HDMI and VGA inputs'),
    (2, 'Whiteboard',               'Standard whiteboard with markers'),
    (3, 'Microphone',               'Wireless microphone system'),
    (4, 'Computer',                 'Desktop computer with standard software'),
    (5, 'Livestreaming Equipment',  'Camera, microphone, and streaming setup'),
    (6, 'Air Conditioner',          'Ceiling-mounted air conditioning unit'),
    (7, 'Speaker System',           'Wall-mounted speakers'),
    (8, 'Smart TV',                 '55-inch smart TV with screen mirroring');
GO

SET IDENTITY_INSERT Facility OFF;
GO

-- ============================================================
-- Space_Facility
-- Maps facilities to spaces with quantity counts.
-- ============================================================
INSERT INTO Space_Facility (space_code, facility_id, quantity)
VALUES
    ('A101', 1, 2),
    ('A101', 2, 1),
    ('A101', 3, 2),
    ('A101', 5, 1),
    ('A101', 6, 4),
    ('A101', 7, 1),
    ('A102', 1, 1),
    ('A102', 2, 1),
    ('A102', 6, 2),
    ('B201', 1, 1),
    ('B201', 4, 40),
    ('B201', 6, 2),
    ('B202', 1, 1),
    ('B202', 4, 35),
    ('B202', 6, 2),
    ('C301', 1, 1),
    ('C301', 2, 1),
    ('C301', 4, 5),
    ('C301', 6, 1),
    ('C302', 1, 1),
    ('C302', 2, 1),
    ('C302', 6, 1),
    ('C302', 8, 1),
    ('A103', 6, 2),
    ('A103', 8, 1),
    ('B101', 1, 1),
    ('B101', 2, 1),
    ('B101', 6, 1),
    ('A201', 1, 1),
    ('A201', 2, 1),
    ('A201', 6, 2);
GO

-- ============================================================
-- Bookings (8 records)
-- Covers statuses: Pending, Approved, Checked In, Completed,
-- Rejected, Cancelled, No-Show.
-- ============================================================
SET IDENTITY_INSERT Booking ON;
GO

INSERT INTO Booking (booking_id, requester_id, space_code, requested_start, requested_end, purpose, expected_participants, status, booking_time, actual_start_time, checkin_staff_id, initial_condition, actual_end_time, final_condition, usage_notes)
VALUES
    (1, 1, 'A102', '2026-06-01 08:00:00', '2026-06-01 10:00:00', 'Lecture', 70, 'Completed', '2026-05-25 09:00:00',
     '2026-06-01 08:05:00', 4, 'Clean, all equipment working', '2026-06-01 10:10:00', 'Clean, no issues', 'Lecture went well.'),

    (2, 2, 'C301', '2026-06-10 13:00:00', '2026-06-10 17:00:00', 'Student Activity', 5, 'Checked In', '2026-06-05 14:00:00',
     '2026-06-10 13:00:00', 4, 'Clean, computers working', NULL, NULL, NULL),

    (3, 3, 'A101', '2026-06-15 09:00:00', '2026-06-15 12:00:00', 'Seminar', 150, 'Pending', '2026-06-12 10:00:00',
     NULL, NULL, NULL, NULL, NULL, NULL),

    (4, 7, 'C302', '2026-06-20 10:00:00', '2026-06-20 11:30:00', 'Meeting', 10, 'Approved', '2026-06-10 08:00:00',
     NULL, NULL, NULL, NULL, NULL, NULL),

    (5, 2, 'A103', '2026-06-08 14:00:00', '2026-06-08 16:00:00', 'Student Activity', 25, 'Rejected', '2026-06-06 11:00:00',
     NULL, NULL, NULL, NULL, NULL, NULL),

    (6, 8, 'A201', '2026-06-18 08:00:00', '2026-06-18 10:00:00', 'Lecture', 55, 'Cancelled', '2026-06-01 07:00:00',
     NULL, NULL, NULL, NULL, NULL, NULL),

    (7, 7, 'A103', '2026-06-03 09:00:00', '2026-06-03 11:00:00', 'Student Activity', 5, 'No-Show', '2026-06-01 16:00:00',
     NULL, NULL, NULL, NULL, NULL, NULL),

    (8, 1, 'A102', '2026-06-03 08:00:00', '2026-06-03 10:00:00', 'Lecture', 75, 'Completed', '2026-05-28 10:00:00',
     '2026-06-03 08:00:00', 4, 'Clean', '2026-06-03 10:05:00', 'Clean', 'Regular lecture.');
GO

SET IDENTITY_INSERT Booking OFF;
GO

-- ============================================================
-- Booking Approvals (4 records)
-- Covers both Approved and Rejected decisions.
-- Booking 3 (Pending) has no approval record yet.
-- Booking 6 (Cancelled by requester) has no approval record.
-- ============================================================
SET IDENTITY_INSERT Booking_Approval ON;
GO

INSERT INTO Booking_Approval (approval_id, booking_id, staff_id, decision_time, decision, decision_note, rejection_reason)
VALUES
    (1, 1, 4, '2026-05-26 10:00:00', 'Approved', 'Approved for lecture session.', NULL),
    (2, 2, 5, '2026-06-07 09:00:00', 'Approved', 'Approved for student project work.', NULL),
    (3, 4, 4, '2026-06-11 08:30:00', 'Approved', 'Meeting room booking approved.', NULL),
    (4, 5, 10, '2026-06-07 09:00:00', 'Rejected', NULL,
     'The Student Workspace is intended for individual or small-group study; student activity events with 25 participants should use a classroom or project lab.');
GO

SET IDENTITY_INSERT Booking_Approval OFF;
GO

-- ============================================================
-- Maintenance Records (4 records)
-- Covers statuses: Open, In Progress, Resolved.
-- Covers problem types: broken equipment, renovation, AC failure.
-- ============================================================
SET IDENTITY_INSERT Maintenance ON;
GO

INSERT INTO Maintenance (maintenance_id, space_code, reporter_id, assigned_staff_id, problem_description, problem_type, start_time, completion_time, status, result_note)
VALUES
    (1, 'B202', 8,  4,  'Computers in Computer Lab 2 are not booting; several monitors flickering.',     'Network Problem',  '2026-05-20 08:00:00', '2026-05-25 16:00:00', 'Resolved',    'Replaced faulty power supply units in 15 computers.'),
    (2, 'A101', 2,  4,  'Left projector lamp is dim and flickering during use.',                           'Broken Projector', '2026-06-02 10:30:00', NULL,                   'In Progress', 'Replacement lamp ordered, expected delivery 2026-06-20.'),
    (3, 'B101', 5,  10, 'Seminar Room under renovation - walls being repainted and flooring replaced.',   'Damaged Furniture', '2026-05-15 09:00:00', NULL,                   'In Progress', 'Expected completion: 2026-07-01.'),
    (4, 'C302', 2,  NULL, 'Air conditioner in Meeting Room 1 is not cooling properly.',                   'AC Failure',       '2026-06-12 14:00:00', NULL,                   'Open',        NULL);
GO

SET IDENTITY_INSERT Maintenance OFF;
GO

PRINT 'Sample data inserted successfully.';
GO
