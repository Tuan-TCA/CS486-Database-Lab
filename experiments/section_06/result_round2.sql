-- ============================================================
-- SAMPLE DATA — G08 (Round 2)
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

INSERT INTO [USER] (full_name, email, phone, role, department, account_status) VALUES
('Alice Student', 'alice@edu.com', '123', 'Student', 'CS', 'Active'),
('Bob Lecturer', 'bob@edu.com', '123', 'Lecturer', 'CS', 'Active'),
('Charlie TA', 'charlie@edu.com', '123', 'Teaching Assistant', 'CS', 'Active'),
('Dave Staff', 'dave@edu.com', '123', 'Facility Staff', 'Facilities', 'Active'),
('Eve Manager', 'eve@edu.com', '123', 'Facility Manager', 'Facilities', 'Active'),
('Frank Admin', 'frank@edu.com', '123', 'Department Administrator', 'Admin', 'Active'),
('Grace Suspended', 'grace@edu.com', '123', 'Student', 'Math', 'Suspended');
GO

INSERT INTO SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status) VALUES
('SP01', 'Room A', 'Classroom', 'B1', 1, '101', 30, 'Available'),
('SP02', 'Lab A', 'Computer Laboratory', 'B1', 1, '102', 30, 'Available'),
('SP03', 'Meet A', 'Meeting Room', 'B1', 2, '201', 10, 'Available'),
('SP04', 'Aud A', 'Auditorium', 'B2', 1, '101', 200, 'Available'),
('SP05', 'Proj A', 'Project Laboratory', 'B2', 2, '201', 20, 'Under Maintenance'),
('SP06', 'Meet B', 'Meeting Room', 'B2', 2, '202', 10, 'Temporarily Closed'),
('SP07', 'Study A', 'Student Workspace', 'B3', 1, '101', 50, 'Retired');
GO

INSERT INTO FACILITY (space_code, facility_name, description) VALUES
('SP01', 'Projector', 'Standard 1080p'),
('SP02', 'PCs', '30 Desktop PCs'),
('SP05', '3D Printer', 'Needs nozzle replacement'),
('SP06', 'Conference Phone', 'Polycom'),
('SP07', 'Desks', 'Individual study carrels');
GO

INSERT INTO BOOKING_REQUEST (user_id, space_code, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status) VALUES
(1, 'SP01', '2026-05-01 10:00:00', '2026-05-01 12:00:00', 'Study', 5, 'Student Activity', 'Completed'),
(2, 'SP01', '2026-05-02 10:00:00', '2026-05-02 12:00:00', 'Lecture', 30, 'Lecture', 'Completed'),
(3, 'SP02', '2026-06-01 10:00:00', '2026-06-01 12:00:00', 'Workshop', 20, 'Workshop', 'Checked In'),
(4, 'SP03', '2026-06-15 10:00:00', '2026-06-15 12:00:00', 'Meeting', 5, 'Meeting', 'Approved'),
(1, 'SP04', '2026-06-20 10:00:00', '2026-06-20 12:00:00', 'Event', 100, 'Student Activity', 'Pending'),
(2, 'SP01', '2026-05-15 10:00:00', '2026-05-15 12:00:00', 'Review', 10, 'Seminar', 'Rejected'),
(1, 'SP01', '2026-05-10 10:00:00', '2026-05-10 12:00:00', 'Study', 2, 'Student Activity', 'Cancelled'),
(2, 'SP01', '2026-05-20 10:00:00', '2026-05-20 12:00:00', 'Lecture', 30, 'Lecture', 'No-show');
GO

INSERT INTO BOOKING_APPROVAL (booking_id, decided_by_user_id, decision_time, decision_note, rejection_reason) VALUES
(1, 5, '2026-04-25 10:00:00', 'Approved', NULL),
(2, 5, '2026-04-25 10:00:00', 'Approved', NULL),
(3, 5, '2026-05-25 10:00:00', 'Approved', NULL),
(4, 5, '2026-06-05 10:00:00', 'Approved', NULL),
(6, 5, '2026-05-10 10:00:00', 'Rejected', 'Conflict with department meeting'); 
-- BUG: Still missing approval for No-show (Booking 8).
-- Wait, the No-show missing approval is an explicit edge case failure.
GO

INSERT INTO USAGE_SESSION (booking_id, actual_start_time, actual_end_time, checked_in_by_user_id, completed_by_user_id, initial_condition, final_condition, usage_notes) VALUES
(1, '2026-05-01 09:55:00', '2026-05-01 12:05:00', 4, 4, 'Good', 'Good', 'No issues'),
(2, '2026-05-02 09:50:00', '2026-05-02 12:10:00', 4, 4, 'Good', 'Good', 'No issues'),
(3, '2026-06-01 09:55:00', NULL, 4, NULL, 'Good', NULL, NULL);
GO

INSERT INTO MAINTENANCE_RECORD (space_code, reporter_user_id, assigned_staff_user_id, problem_description, start_time, completion_time, status, result_note) VALUES
('SP01', 4, 4, 'Broken chair', '2026-05-01 10:00:00', '2026-05-02 10:00:00', 'Resolved', 'Fixed'),
('SP05', 4, 4, 'AC leaking', '2026-06-01 10:00:00', NULL, 'In Progress', NULL),
('SP06', 4, NULL, 'Door lock jammed', '2026-06-05 10:00:00', NULL, 'Open', NULL);
GO
