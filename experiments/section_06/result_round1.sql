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

-- Reset identity seeds after cleanup
DBCC CHECKIDENT ('[USER]', RESEED, 0);
DBCC CHECKIDENT ('FACILITY', RESEED, 0);
DBCC CHECKIDENT ('BOOKING_REQUEST', RESEED, 0);
DBCC CHECKIDENT ('BOOKING_APPROVAL', RESEED, 0);
DBCC CHECKIDENT ('USAGE_SESSION', RESEED, 0);
DBCC CHECKIDENT ('MAINTENANCE_RECORD', RESEED, 0);
GO

-- ============================================================
-- USERS (7 records — all 6 roles + one suspended account)
-- ============================================================
-- user_id is IDENTITY(1,1) — IDs will be 1..7
SET IDENTITY_INSERT [USER] ON;

INSERT INTO [USER] (user_id, full_name, email, phone, role, department, account_status)
VALUES
    (1, 'Siriporn Chaiyasit',   'siriporn.c@university.ac.th',   '081-234-5678', 'Student',                   'Computer Science',    'Active'),
    (2, 'Dr. Apichart Wongkam', 'apichart.w@university.ac.th',   '089-876-5432', 'Lecturer',                  'Computer Science',    'Active'),
    (3, 'Natthapong Suksawat',  'natthapong.s@university.ac.th', '062-345-6789', 'Teaching Assistant',         'Computer Science',    'Active'),
    (4, 'Kannika Thongprasert', 'kannika.t@university.ac.th',    '091-456-7890', 'Facility Staff',            'Facility Management', 'Active'),
    (5, 'Wichai Rattanakul',    'wichai.r@university.ac.th',     '084-567-8901', 'Facility Manager',          'Facility Management', 'Active'),
    (6, 'Ploypailin Khamwong',  'ploypailin.k@university.ac.th', '095-678-9012', 'Department Administrator',  'Computer Science',    'Active'),
    (7, 'Thanakrit Srisuwan',   'thanakrit.s@university.ac.th',  '087-789-0123', 'Student',                   'Computer Science',    'Suspended');

SET IDENTITY_INSERT [USER] OFF;
GO

-- ============================================================
-- SPACES (8 records — all 6 types + all 5 statuses)
-- ============================================================
INSERT INTO SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES
    ('SP01', 'Classroom 101',           'Classroom',          'Engineering Building A', 1, '101',  60,  'Available',          'Available for lectures and tutorials during office hours'),
    ('SP02', 'Computer Lab 201',        'Computer Lab',       'Engineering Building A', 2, '201',  40,  'Available',          'Lab coat required; no food or drinks allowed'),
    ('SP03', 'Meeting Room 301',        'Meeting Room',       'Engineering Building B', 3, '301',  12,  'Available',          'Book at least 24 hours in advance'),
    ('SP04', 'Main Auditorium',         'Auditorium',         'Central Building',       1, 'AUD1', 500, 'Available',          'Requires Facility Manager approval for events over 200 people'),
    ('SP05', 'Project Lab 202',         'Project Lab',        'Engineering Building A', 2, '202',  30,  'Under Maintenance',  'Currently closed for electrical rewiring'),
    ('SP06', 'Conference Room 302',     'Meeting Room',       'Engineering Building B', 3, '302',  16,  'Temporarily Closed', 'Closed for furniture replacement until July 2025'),
    ('SP07', 'Old Student Workspace',   'Student Workspace',  'Library Building',       1, 'SW1',  20,  'Retired',            'Permanently decommissioned; relocated to new building'),
    ('SP08', 'Student Workspace 401',   'Student Workspace',  'Engineering Building B', 4, '401',  25,  'In Use',             'Open access for all students during library hours');
GO

-- ============================================================
-- FACILITIES (10 records — equipment for various spaces,
-- including unavailable spaces per common mistake #6)
-- ============================================================
SET IDENTITY_INSERT FACILITY ON;

INSERT INTO FACILITY (facility_id, space_code, facility_name, description)
VALUES
    (1,  'SP01', 'Projector',                'Epson EB-X51 ceiling-mounted projector'),
    (2,  'SP01', 'Whiteboard',               'Wall-mounted 2.4m x 1.2m magnetic whiteboard'),
    (3,  'SP02', 'Desktop Computers',        '40 Dell OptiPlex 7010 workstations with monitors'),
    (4,  'SP02', 'Projector',                'BenQ MW560 short-throw projector'),
    (5,  'SP03', 'Video Conference System',  'Logitech Rally Plus conference camera and speakerphone'),
    (6,  'SP04', 'Microphone System',        '4-channel wireless microphone system with lapel mics'),
    (7,  'SP04', 'Livestreaming Equipment',  'PTZ camera and encoder for live event broadcast'),
    (8,  'SP05', 'Desktop Computers',        '30 HP EliteDesk 800 G9 workstations'),
    (9,  'SP05', 'Projector',                'ViewSonic PA700S classroom projector'),
    (10, 'SP08', 'Air Conditioner',          'Daikin split-type 24000 BTU cooling unit');

SET IDENTITY_INSERT FACILITY OFF;
GO

-- ============================================================
-- BOOKING REQUESTS (8 records — all 7 statuses covered)
--
-- Note on dates:
--   Past bookings (Completed, Rejected, No-Show): May–June 2025
--   Current booking (Checked In): June 2025
--   Future bookings (Approved, Pending): July 2025
--   Cancelled booking: submitted June 2025, for July 2025
--
-- The trg_CheckSpaceAvailability trigger blocks inserts for
-- spaces with status IN ('Under Maintenance','Temporarily Closed','Retired')
-- when booking status is 'Pending' or 'Approved'. To safely insert
-- historical/test bookings, we insert with 'Completed'/'Rejected'/etc.
-- status values that bypass the trigger scope.
-- ============================================================
SET IDENTITY_INSERT BOOKING_REQUEST ON;

-- BK01: Completed — happy path end-to-end (Classroom, Lecture)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (1, 2, 'SP01', '2025-06-02 09:00:00', '2025-06-02 12:00:00', 'CS101 Introduction to Programming — Week 1 lecture', 55, 'Lecture', 'Completed');

-- BK02: Completed — second completed booking, same space different time slot
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (2, 2, 'SP01', '2025-06-03 13:00:00', '2025-06-03 16:00:00', 'CS101 Introduction to Programming — Week 1 lab session', 55, 'Lecture', 'Completed');

-- BK03: Checked In — in-progress session (Computer Lab, Workshop)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (3, 3, 'SP02', '2025-06-25 09:00:00', '2025-06-25 12:00:00', 'Python data analysis workshop for TA training', 25, 'Workshop', 'Checked In');

-- BK04: Approved — future booking awaiting check-in (Auditorium, Seminar)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (4, 6, 'SP04', '2025-07-15 13:00:00', '2025-07-15 17:00:00', 'Annual Computer Science Department seminar on AI trends', 200, 'Seminar', 'Approved');

-- BK05: Pending — awaiting approval (Meeting Room, Meeting)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (5, 1, 'SP03', '2025-07-10 14:00:00', '2025-07-10 16:00:00', 'Senior project team weekly meeting with advisor', 6, 'Meeting', 'Pending');

-- BK06: Rejected — with rejection reason (Meeting Room, Student Activity)
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (6, 1, 'SP03', '2025-06-05 10:00:00', '2025-06-05 12:00:00', 'Student club social gathering and planning session', 10, 'Student Activity', 'Rejected');

-- BK07: Cancelled — user cancelled before any decision
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (7, 1, 'SP03', '2025-07-20 09:00:00', '2025-07-20 11:00:00', 'Student study group session — cancelled by requester', 8, 'Student Activity', 'Cancelled');

-- BK08: No-Show — was approved but requester never showed up
INSERT INTO BOOKING_REQUEST (booking_id, user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
VALUES (8, 6, 'SP01', '2025-06-09 09:00:00', '2025-06-09 11:00:00', 'Administrative review meeting with department heads', 15, 'Administrative Event', 'No-Show');

SET IDENTITY_INSERT BOOKING_REQUEST OFF;
GO

-- ============================================================
-- BOOKING APPROVALS (5 records — covers Approved + Rejected)
--
-- Required approvals:
--   BK01 (Completed)  → Approved
--   BK02 (Completed)  → Approved
--   BK03 (Checked In) → Approved
--   BK04 (Approved)   → Approved
--   BK06 (Rejected)   → Rejected with reason
--   BK08 (No-Show)    → Approved (MUST have approval per lifecycle)
--
-- Not needed:
--   BK05 (Pending)    → No approval yet
--   BK07 (Cancelled)  → No approval needed
-- ============================================================
SET IDENTITY_INSERT BOOKING_APPROVAL ON;

INSERT INTO BOOKING_APPROVAL (approval_id, booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason)
VALUES
    (1, 1, 5, '2025-05-28 14:30:00', 'Approved for regular weekly lecture schedule',                            NULL),
    (2, 2, 5, '2025-05-28 14:35:00', 'Approved as part of CS101 lab sessions — same weekly block',              NULL),
    (3, 3, 4, '2025-06-20 10:00:00', 'Approved for TA training workshop — computer lab confirmed available',    NULL),
    (4, 4, 5, '2025-07-01 09:00:00', 'Approved for annual department seminar — auditorium reserved',            NULL),
    (5, 6, 4, '2025-06-04 16:00:00', 'Booking rejected',                                                        'The meeting room is reserved for faculty use on Thursday mornings. Student activities should use the Student Workspace instead.'),
    (6, 8, 5, '2025-06-05 11:00:00', 'Approved for administrative review meeting',                              NULL);

SET IDENTITY_INSERT BOOKING_APPROVAL OFF;
GO

-- ============================================================
-- USAGE SESSIONS (3 records — Completed + Checked In)
--
-- BK01 (Completed): full check-in + check-out, all fields populated
-- BK02 (Completed): full check-in + check-out, all fields populated
-- BK03 (Checked In): check-in only, actual_end_time = NULL,
--                     completed_by_user_id = NULL, final_condition = NULL
-- ============================================================
SET IDENTITY_INSERT USAGE_SESSION ON;

INSERT INTO USAGE_SESSION (session_id, booking_id, actual_start_time, actual_end_time, checked_in_by_user_id, completed_by_user_id, initial_condition, final_condition, usage_notes)
VALUES
    (1, 1, '2025-06-02 08:55:00', '2025-06-02 11:50:00', 4, 4,
        'Room clean and ready; projector and whiteboard functional',
        'Room left in good condition; whiteboard cleaned',
        'Lecture ran smoothly. 52 out of 55 expected students attended.'),

    (2, 2, '2025-06-03 13:05:00', '2025-06-03 15:55:00', 4, 4,
        'Room clean; all equipment operational',
        'Room left tidy; minor chalk dust on front desks',
        'Lab session completed successfully. Students worked on Python exercises.'),

    (3, 3, '2025-06-25 09:10:00', NULL, 4, NULL,
        'Computer lab set up for workshop; 25 workstations powered on',
        NULL,
        NULL);

SET IDENTITY_INSERT USAGE_SESSION OFF;
GO

-- ============================================================
-- MAINTENANCE RECORDS (4 records — all 4 statuses covered)
--
-- M01: Resolved — completed repair for Project Lab (SP05)
-- M02: In Progress — active maintenance on Project Lab (SP05)
-- M03: Open — unassigned issue (assigned_staff_user_id = NULL)
-- M04: Closed — archived maintenance record
-- ============================================================
SET IDENTITY_INSERT MAINTENANCE_RECORD ON;

INSERT INTO MAINTENANCE_RECORD (maintenance_id, space_code, reporter_user_id, assigned_staff_user_id, problem_description, start_time, completion_time, status, result_note)
VALUES
    (1, 'SP05', 3, 4,
        'Multiple power outlets on the east wall are non-functional, affecting 8 workstations',
        '2025-05-20 08:30:00', '2025-05-25 16:00:00',
        'Resolved',
        'Electrician replaced faulty wiring in 6 outlets. All workstations tested and operational.'),

    (2, 'SP05', 4, 4,
        'Ceiling-mounted projector displays intermittent color distortion and overheating warning',
        '2025-06-15 10:00:00', NULL,
        'In Progress',
        NULL),

    (3, 'SP06', 2, NULL,
        'Three office chairs have broken casters and armrests; furniture replacement requested',
        '2025-06-18 14:00:00', NULL,
        'Open',
        NULL),

    (4, 'SP01', 4, 4,
        'Whiteboard surface scratched and difficult to erase cleanly',
        '2025-04-10 09:00:00', '2025-04-15 12:00:00',
        'Closed',
        'Whiteboard resurfaced with new laminate coating. Confirmed clean erasure.');

SET IDENTITY_INSERT MAINTENANCE_RECORD OFF;
GO
