-- =====================================================
-- 06-sample-data-G08.sql
-- Campus Space Management System
-- Sample Data
-- Compatible with 05-db-definition-G08.sql
-- =====================================================


-- =====================================================
-- USERS
-- =====================================================

INSERT INTO USERS VALUES

('U001','Alice Nguyen','alice.nguyen@hcmus.edu.vn','0901000001','student','Computer Science','active'),
('U002','Bob Tran','bob.tran@hcmus.edu.vn','0901000002','student','Computer Science','active'),
('U003','Carol Le','carol.le@hcmus.edu.vn','0901000003','student','Software Engineering','active'),
('U004','David Pham','david.pham@hcmus.edu.vn','0901000004','lecturer','Computer Science','active'),
('U005','Emma Hoang','emma.hoang@hcmus.edu.vn','0901000005','lecturer','Data Science','active'),
('U006','Frank Vu','frank.vu@hcmus.edu.vn','0901000006','teaching_assistant','Computer Science','active'),
('U007','Grace Do','grace.do@hcmus.edu.vn','0901000007','teaching_assistant','Software Engineering','active'),
('U008','Henry Bui','henry.bui@hcmus.edu.vn','0901000008','facility_staff','Administration','active'),
('U009','Ivy Truong','ivy.truong@hcmus.edu.vn','0901000009','facility_staff','Administration','active'),
('U010','Jack Dang','jack.dang@hcmus.edu.vn','0901000010','department_administrator','Computer Science','active'),
('U011','Kevin Phan','kevin.phan@hcmus.edu.vn','0901000011','facility_manager','Administration','active'),
('U012','Linda Mai','linda.mai@hcmus.edu.vn','0901000012','student','Data Science','active'),
('U013','Minh Vo','minh.vo@hcmus.edu.vn','0901000013','student','AI','inactive'),
('U014','Nina Ly','nina.ly@hcmus.edu.vn','0901000014','lecturer','AI','active'),
('U015','Oscar Tran','oscar.tran@hcmus.edu.vn','0901000015','facility_staff','Administration','active'),
('U016','Peter Ho','peter.ho@hcmus.edu.vn','0901000016','student','Computer Science','suspended'),
('U017','Quynh Nguyen','quynh.nguyen@hcmus.edu.vn','0901000017','student','Software Engineering','active'),
('U018','Ryan Le','ryan.le@hcmus.edu.vn','0901000018','lecturer','Information Systems','active');


-- =====================================================
-- SPACE
-- =====================================================

INSERT INTO SPACE VALUES

('SP001','Classroom A101','Classroom','A',1,'101',60,'available','Teaching only'),

('SP002','Classroom A102','Classroom','A',1,'102',50,'available','Teaching only'),

('SP003','Computer Lab B201','Computer Laboratory','B',2,'201',40,'available','Authorized users only'),

('SP004','Computer Lab B202','Computer Laboratory','B',2,'202',35,'under_maintenance','Authorized users only'),

('SP005','Auditorium C301','Auditorium','C',3,'301',200,'available','Large events'),

('SP006','Meeting Room D101','Meeting Room','D',1,'101',20,'available','Meetings only'),

('SP007','Project Lab E201','Project Laboratory','E',2,'201',30,'available','Project work'),

('SP008','Student Workspace F101','Workspace','F',1,'101',25,'temporarily_closed','Student activities'),

('SP009','Old Classroom G001','Classroom','G',0,'001',40,'retired','No longer in service'),

('SP010','Seminar Room H201','Meeting Room','H',2,'201',80,'available','Seminars'),

('SP011','Classroom H202','Classroom','H',2,'202',70,'in_use','General teaching'),

('SP012','Workshop Room I101','Meeting Room','I',1,'101',45,'available','Workshops');


-- =====================================================
-- FACILITY
-- =====================================================

INSERT INTO FACILITY VALUES

('F001','SP001','Projector','4K projector'),
('F002','SP001','Whiteboard','Magnetic board'),
('F003','SP001','Microphone','Lecture microphone'),

('F004','SP002','Projector','HD projector'),
('F005','SP002','Whiteboard','Large board'),

('F006','SP003','Computer','40 PCs'),
('F007','SP003','Projector','4K projector'),
('F008','SP003','Air Conditioner','Central AC'),
('F009','SP003','Microphone','Wireless'),

('F010','SP004','Computer','35 PCs'),
('F011','SP004','Projector','HD projector'),

('F012','SP005','Projector','4K projector'),
('F013','SP005','Microphone','Conference microphones'),
('F014','SP005','Livestreaming Equipment','Streaming system'),
('F015','SP005','Air Conditioner','Central AC'),

('F016','SP006','Whiteboard','Meeting board'),
('F017','SP006','Air Conditioner','1 AC'),

('F018','SP007','Computer','20 PCs'),
('F019','SP007','Projector','Project projector'),
('F020','SP007','Whiteboard','Project board'),

('F021','SP008','Whiteboard','Student board'),

('F022','SP010','Projector','4K projector'),
('F023','SP010','Microphone','Conference microphone'),
('F024','SP010','Livestreaming Equipment','Webcam'),

('F025','SP011','Projector','HD projector'),
('F026','SP011','Whiteboard','Teaching board'),

('F027','SP012','Projector','HD projector'),
('F028','SP012','Whiteboard','Workshop board'),
('F029','SP012','Microphone','Wireless'),
('F030','SP012','Air Conditioner','Central AC');


-- =====================================================
-- BOOKING_REQUEST
-- =====================================================

INSERT INTO BOOKING_REQUEST VALUES

('B001','U004','SP001','2026-07-01 08:00','2026-07-01 10:00','Database lecture',55,'lecture','completed'),

('B002','U005','SP005','2026-07-02 13:00','2026-07-02 16:00','AI seminar',180,'seminar','approved'),

('B003','U001','SP006','2026-07-03 09:00','2026-07-03 11:00','Student project meeting',10,'meeting','pending'),

('B004','U006','SP003','2026-07-04 08:00','2026-07-04 12:00','Python workshop',35,'workshop','approved'),

('B005','U002','SP010','2026-07-05 18:00','2026-07-05 20:00','Club event',60,'student_activity','approved'),

('B006','U004','SP002','2026-07-06 07:00','2026-07-06 10:00','Operating Systems lecture',45,'lecture','checked_in'),

('B007','U005','SP005','2026-07-07 09:00','2026-07-07 12:00','Faculty meeting',100,'meeting','rejected'),

('B008','U012','SP007','2026-07-08 13:00','2026-07-08 17:00','Capstone project',20,'student_activity','approved'),

('B009','U014','SP010','2026-07-09 14:00','2026-07-09 16:00','AI workshop',70,'workshop','approved'),

('B010','U003','SP006','2026-07-10 09:00','2026-07-10 11:00','Research meeting',15,'meeting','cancelled'),

('B011','U004','SP001','2026-07-11 08:00','2026-07-11 10:00','Algorithms lecture',55,'lecture','approved'),

('B012','U005','SP005','2026-07-12 09:00','2026-07-12 17:00','Department seminar',190,'seminar','approved'),

('B013','U001','SP006','2026-07-13 10:00','2026-07-13 11:00','Group meeting',8,'meeting','no_show'),

('B014','U006','SP003','2026-07-14 08:00','2026-07-14 10:00','Tutorial session',30,'lecture','completed'),

('B015','U014','SP010','2026-07-15 14:00','2026-07-15 17:00','ML seminar',75,'seminar','pending'),

('B016','U018','SP012','2026-07-16 09:00','2026-07-16 12:00','Data workshop',40,'workshop','approved'),

('B017','U017','SP006','2026-07-17 15:00','2026-07-17 17:00','Student meeting',15,'meeting','approved'),

('B018','U004','SP011','2026-07-18 08:00','2026-07-18 10:00','Computer Networks',65,'lecture','approved');


-- =====================================================
-- BOOKING_APPROVAL
-- =====================================================

INSERT INTO BOOKING_APPROVAL VALUES

('A001','B001','U008','2026-06-25 09:00','Approved',NULL),

('A002','B002','U011','2026-06-26 10:00','Approved',NULL),

('A003','B004','U008','2026-06-28 08:00','Approved',NULL),

('A004','B005','U009','2026-06-29 11:00','Approved',NULL),

('A005','B006','U008','2026-06-30 09:00','Approved',NULL),

('A006','B007','U011','2026-06-30 10:00','Rejected','Room unavailable'),

('A007','B008','U008','2026-07-01 09:00','Approved',NULL),

('A008','B009','U011','2026-07-01 13:00','Approved',NULL),

('A009','B011','U008','2026-07-02 08:00','Approved',NULL),

('A010','B012','U011','2026-07-02 10:00','Approved',NULL),

('A011','B014','U008','2026-07-03 10:00','Approved',NULL),

('A012','B016','U009','2026-07-04 10:00','Approved',NULL),

('A013','B017','U008','2026-07-05 08:00','Approved',NULL),

('A014','B018','U011','2026-07-06 09:00','Approved',NULL);


-- =====================================================
-- USAGE_SESSION
-- =====================================================

INSERT INTO USAGE_SESSION VALUES

('S001','B001','2026-07-01 07:55','2026-07-01 10:05','U008','U008',
'Good condition',
'Good condition',
'Lecture completed'),

('S002','B006','2026-07-06 06:55',NULL,'U009',NULL,
'Good condition',
NULL,
NULL),

('S003','B014','2026-07-14 07:55','2026-07-14 10:00','U008','U008',
'All equipment working',
'Good condition',
'Completed successfully');


-- =====================================================
-- MAINTENANCE_RECORD
-- =====================================================

INSERT INTO MAINTENANCE_RECORD VALUES

('M001','SP004','U008','U015',
'Broken projector',
'2026-06-20 08:00',
NULL,
'in_progress',
NULL),

('M002','SP004','U009','U015',
'Network issue',
'2026-06-21 10:00',
NULL,
'pending',
NULL),

('M003','SP008','U008','U015',
'Cleaning issue',
'2026-06-15 09:00',
'2026-06-16 12:00',
'completed',
'Room cleaned'),

('M004','SP007','U012','U015',
'Broken chair',
'2026-06-18 11:00',
'2026-06-18 15:00',
'completed',
'Chair replaced'),

('M005','SP003','U006','U008',
'Air conditioner malfunction',
'2026-06-25 09:00',
'2026-06-25 17:00',
'completed',
'AC repaired'),

('M006','SP005','U004','U009',
'Microphone battery issue',
'2026-06-27 08:00',
'2026-06-27 09:00',
'completed',
'Battery replaced'),

('M007','SP001','U004','U008',
'Projector calibration issue',
'2026-06-29 14:00',
'2026-06-29 15:00',
'completed',
'Calibrated'),

('M008','SP010','U014','U015',
'Camera not working',
'2026-06-30 08:00',
NULL,
'in_progress',
NULL),

('M009','SP011','U018','U009',
'Whiteboard damaged',
'2026-07-01 10:00',
'2026-07-01 14:00',
'completed',
'Whiteboard replaced'),

('M010','SP012','U018','U015',
'Microphone issue',
'2026-07-02 11:00',
NULL,
'pending',
NULL);
