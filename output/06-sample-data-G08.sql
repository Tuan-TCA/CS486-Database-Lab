-- =====================================================
-- 06-sample-data-G08.sql
-- Campus Space Management System
-- Sample Data Preparation
-- PART 1/2
--
-- TABLES:
-- USERS
-- SPACES
-- FACILITY
-- BOOKING_REQUEST
-- BOOKING_APPROVAL
-- =====================================================


-- =====================================================
-- USERS
-- =====================================================

INSERT INTO USERS VALUES

('U001','Nguyen Van An','nguyenvanan@hcmus.edu.vn','0901000001','student','Computer Science','active'),

('U002','Tran Minh Khoa','tranminhkhoa@hcmus.edu.vn','0901000002','student','Computer Science','active'),

('U003','Le Quoc Bao','lequocbao@hcmus.edu.vn','0901000003','student','Software Engineering','active'),

('U004','Pham Gia Huy','phamgiahuy@hcmus.edu.vn','0901000004','student','Data Science','active'),

('U005','Vo Thanh Dat','vothanhdat@hcmus.edu.vn','0901000005','student','Artificial Intelligence','active'),

('U006','Dang Duc Long','dangduclong@hcmus.edu.vn','0901000006','student','Information Systems','active'),

('U007','Hoang Minh Duc','hoangminhduc@hcmus.edu.vn','0901000007','student','Cybersecurity','inactive'),

('U008','Bui Tuan Kiet','buituankiet@hcmus.edu.vn','0901000008','student','Computer Science','suspended'),

('U009','Nguyen Thi Thu Ha','nguyenthithuha@hcmus.edu.vn','0901000009','lecturer','Computer Science','active'),

('U010','Tran Thi My Linh','tranthimylinh@hcmus.edu.vn','0901000010','lecturer','Data Science','active'),

('U011','Le Thanh Tung','lethanhtung@hcmus.edu.vn','0901000011','lecturer','Artificial Intelligence','active'),

('U012','Pham Ngoc Anh','phamngocanh@hcmus.edu.vn','0901000012','lecturer','Information Systems','active'),

('U013','Vo Minh Chau','vominhchau@hcmus.edu.vn','0901000013','lecturer','Software Engineering','active'),

('U014','Nguyen Quang Hieu','nguyenquanghieu@hcmus.edu.vn','0901000014','teaching_assistant','Computer Science','active'),

('U015','Tran Gia Bao','trangiabao@hcmus.edu.vn','0901000015','teaching_assistant','Software Engineering','active'),

('U016','Le Hoang Nam','lehoangnam@hcmus.edu.vn','0901000016','teaching_assistant','Data Science','active'),

('U017','Pham Tuan Anh','phamtuananh@hcmus.edu.vn','0901000017','facility_staff','Administration','active'),

('U018','Dang Thanh Son','dangthanhson@hcmus.edu.vn','0901000018','facility_staff','Administration','active'),

('U019','Nguyen Thi Kim Ngan','nguyenthikimngan@hcmus.edu.vn','0901000019','department_administrator','Computer Science','active'),

('U020','Tran Van Hung','tranvanhung@hcmus.edu.vn','0901000020','facility_manager','Administration','active');



-- =====================================================
-- SPACES
-- =====================================================

INSERT INTO SPACES VALUES

('SP001','classroom_a101','classroom','A',1,'101',60,'available','general_teaching'),

('SP002','classroom_a102','classroom','A',1,'102',50,'available','general_teaching'),

('SP003','classroom_b101','classroom','B',1,'101',70,'available','general_teaching'),

('SP004','computer_lab_b201','computer_laboratory','B',2,'201',40,'available','authorized_users_only'),

('SP005','computer_lab_b202','computer_laboratory','B',2,'202',35,'under_maintenance','authorized_users_only'),

('SP006','computer_lab_c201','computer_laboratory','C',2,'201',45,'available','authorized_users_only'),

('SP007','meeting_room_d101','meeting_room','D',1,'101',20,'available','meetings_only'),

('SP008','meeting_room_d102','meeting_room','D',1,'102',25,'temporarily_closed','meetings_only'),

('SP009','project_lab_e201','project_laboratory','E',2,'201',30,'available','project_work'),

('SP010','project_lab_f201','project_laboratory','F',2,'201',35,'temporarily_closed','project_work'),

('SP011','auditorium_g301','auditorium','G',3,'301',200,'available','large_events'),

('SP012','workspace_h101','workspace','H',1,'101',25,'retired','student_workspace');



-- =====================================================
-- FACILITY
-- =====================================================

INSERT INTO FACILITY VALUES

('F001','SP001','projector','4k_projector'),
('F002','SP001','whiteboard','magnetic_board'),
('F003','SP001','microphone','lecture_microphone'),

('F004','SP002','projector','hd_projector'),
('F005','SP002','whiteboard','large_whiteboard'),
('F006','SP002','air_conditioner','central_ac'),

('F007','SP003','projector','4k_projector'),
('F008','SP003','whiteboard','large_whiteboard'),

('F009','SP004','computer','40_workstations'),
('F010','SP004','projector','4k_projector'),
('F011','SP004','air_conditioner','central_ac'),
('F012','SP004','printer','network_printer'),

('F013','SP005','computer','35_workstations'),
('F014','SP005','projector','hd_projector'),
('F015','SP005','air_conditioner','central_ac'),

('F016','SP006','computer','45_workstations'),
('F017','SP006','projector','4k_projector'),
('F018','SP006','printer','network_printer'),

('F019','SP007','whiteboard','meeting_board'),
('F020','SP007','speaker','conference_speaker'),

('F021','SP008','whiteboard','meeting_board'),
('F022','SP008','speaker','conference_speaker'),

('F023','SP009','computer','20_workstations'),
('F024','SP009','projector','project_projector'),
('F025','SP009','whiteboard','project_board'),

('F026','SP010','computer','25_workstations'),
('F027','SP010','projector','project_projector'),

('F028','SP011','projector','4k_projector'),
('F029','SP011','microphone','conference_microphone'),
('F030','SP011','livestreaming_equipment','streaming_system'),
('F031','SP011','speaker','auditorium_speaker'),

('F032','SP012','whiteboard','student_board');



-- =====================================================
-- BOOKING_REQUEST
-- =====================================================

INSERT INTO BOOKING_REQUEST VALUES

('B001','U009','SP001','2026-01-05 08:00','2026-01-05 10:00','database systems lecture',55,'lecture','completed'),

('B002','U010','SP011','2026-01-08 13:00','2026-01-08 16:00','data science seminar',180,'seminar','completed'),

('B003','U014','SP004','2026-01-12 08:00','2026-01-12 12:00','python workshop',35,'workshop','completed'),

('B004','U011','SP007','2026-01-15 09:00','2026-01-15 11:00','ai research meeting',15,'meeting','completed'),

('B005','U009','SP002','2026-01-19 08:00','2026-01-19 11:00','computer architecture examination',45,'examination','completed'),

('B006','U013','SP009','2026-03-03 18:00','2026-03-03 20:00','student club activity',22,'student_activity','completed'),

('B007','U012','SP011','2026-03-06 13:00','2026-03-06 16:00','information systems seminar',170,'seminar','completed'),

('B008','U015','SP009','2026-03-10 08:00','2026-03-10 12:00','capstone workshop',25,'workshop','completed'),

('B009','U019','SP007','2026-03-13 09:00','2026-03-13 11:00','department planning meeting',18,'administrative_event','completed'),

('B010','U011','SP001','2026-03-18 08:00','2026-03-18 10:00','machine learning lecture',58,'lecture','completed'),

('B011','U010','SP011','2026-05-05 13:00','2026-05-05 16:00','big data symposium',190,'seminar','completed'),

('B012','U004','SP007','2026-05-08 15:00','2026-05-08 17:00','student project meeting',12,'meeting','no_show'),

('B013','U009','SP003','2026-05-12 08:00','2026-05-12 10:00','operating systems lecture',65,'lecture','completed'),

('B014','U011','SP002','2026-05-15 08:00','2026-05-15 11:00','deep learning examination',50,'examination','completed'),

('B015','U019','SP007','2026-05-20 09:00','2026-05-20 11:00','academic planning meeting',16,'administrative_event','completed'),

('B016','U009','SP001','2026-07-02 08:00','2026-07-02 10:00','advanced database lecture',55,'lecture','approved'),

('B017','U010','SP011','2026-07-03 13:00','2026-07-03 17:00','ai conference',190,'seminar','checked_in'),

('B018','U014','SP006','2026-07-04 08:00','2026-07-04 12:00','backend workshop',40,'workshop','approved'),

('B019','U001','SP007','2026-07-05 09:00','2026-07-05 11:00','student project discussion',10,'meeting','pending'),

('B020','U002','SP009','2026-07-06 18:00','2026-07-06 20:00','student association activity',22,'student_activity','approved'),

('B021','U011','SP003','2026-07-07 08:00','2026-07-07 11:00','software engineering examination',60,'examination','checked_in'),

('B022','U019','SP007','2026-07-08 09:00','2026-07-08 11:00','faculty meeting',18,'administrative_event','approved'),

('B023','U005','SP009','2026-07-09 15:00','2026-07-09 17:00','startup meeting',15,'meeting','cancelled'),

('B024','U010','SP011','2026-07-10 09:00','2026-07-10 12:00','deep learning seminar',170,'seminar','rejected'),

('B025','U014','SP004','2026-07-11 13:00','2026-07-11 17:00','advanced python workshop',35,'workshop','rejected'),

('B026','U009','SP002','2026-09-03 08:00','2026-09-03 10:00','computer networks lecture',45,'lecture','approved'),

('B027','U011','SP011','2026-09-05 13:00','2026-09-05 17:00','ai summit',190,'seminar','approved'),

('B028','U003','SP007','2026-09-09 18:00','2026-09-09 20:00','student club meeting',15,'student_activity','pending'),

('B029','U019','SP007','2026-11-06 10:00','2026-11-06 12:00','budget planning meeting',15,'administrative_event','approved'),

('B030','U004','SP009','2026-11-12 15:00','2026-11-12 17:00','graduation project meeting',12,'meeting','no_show');



-- =====================================================
-- BOOKING_APPROVAL
-- =====================================================

INSERT INTO BOOKING_APPROVAL VALUES

('A001','B001','U017','2025-12-28 09:00','approved',NULL),

('A002','B002','U020','2026-01-02 10:00','approved',NULL),

('A003','B003','U017','2026-01-05 08:00','approved',NULL),

('A004','B004','U018','2026-01-08 09:00','approved',NULL),

('A005','B005','U020','2026-01-10 08:00','approved',NULL),

('A006','B006','U018','2026-02-25 09:00','approved',NULL),

('A007','B007','U020','2026-02-27 10:00','approved',NULL),

('A008','B008','U017','2026-03-01 09:00','approved',NULL),

('A009','B009','U018','2026-03-05 10:00','approved',NULL),

('A010','B010','U020','2026-03-10 09:00','approved',NULL),

('A011','B011','U020','2026-04-25 10:00','approved',NULL),

('A012','B012','U017','2026-04-28 09:00','approved',NULL),

('A013','B013','U018','2026-05-01 08:00','approved',NULL),

('A014','B014','U020','2026-05-03 10:00','approved',NULL),

('A015','B015','U018','2026-05-05 08:00','approved',NULL),

('A016','B016','U017','2026-06-25 09:00','approved',NULL),

('A017','B017','U020','2026-06-26 10:00','approved',NULL),

('A018','B018','U018','2026-06-27 09:00','approved',NULL),

('A019','B020','U017','2026-06-28 09:00','approved',NULL),

('A020','B021','U020','2026-06-29 10:00','approved',NULL),

('A021','B022','U018','2026-06-30 09:00','approved',NULL),

('A022','B024','U020','2026-07-01 09:00','capacity_exceeded','capacity_exceeded'),

('A023','B025','U017','2026-07-02 09:00','equipment_unavailable','equipment_unavailable'),

('A024','B026','U018','2026-08-25 10:00','approved',NULL);


-- =====================================================
-- USAGE_SESSION
-- =====================================================

INSERT INTO USAGE_SESSION VALUES

('S001','B001',
'2026-01-05 07:55',
'2026-01-05 10:05',
'U017',
'U017',
'good_condition',
'good_condition',
'lecture_completed'),

('S002','B002',
'2026-01-08 12:55',
'2026-01-08 16:05',
'U018',
'U018',
'good_condition',
'good_condition',
'seminar_completed'),

('S003','B003',
'2026-01-12 07:55',
'2026-01-12 12:05',
'U017',
'U017',
'good_condition',
'good_condition',
'workshop_completed'),

('S004','B004',
'2026-01-15 08:55',
'2026-01-15 11:00',
'U018',
'U018',
'good_condition',
'good_condition',
'meeting_completed'),

('S005','B005',
'2026-01-19 07:55',
'2026-01-19 11:05',
'U017',
'U017',
'good_condition',
'good_condition',
'examination_completed'),

('S006','B006',
'2026-03-03 17:55',
'2026-03-03 20:00',
'U018',
'U018',
'good_condition',
'good_condition',
'student_activity_completed'),

('S007','B007',
'2026-03-06 12:55',
'2026-03-06 16:05',
'U017',
'U017',
'good_condition',
'good_condition',
'seminar_completed'),

('S008','B008',
'2026-03-10 07:55',
'2026-03-10 12:05',
'U018',
'U018',
'good_condition',
'good_condition',
'workshop_completed'),

('S009','B009',
'2026-03-13 08:55',
'2026-03-13 11:00',
'U017',
'U017',
'good_condition',
'good_condition',
'administration_completed'),

('S010','B010',
'2026-03-18 07:55',
'2026-03-18 10:05',
'U018',
'U018',
'good_condition',
'good_condition',
'lecture_completed'),

('S011','B011',
'2026-05-05 12:55',
'2026-05-05 16:05',
'U017',
'U017',
'good_condition',
'good_condition',
'seminar_completed'),

('S012','B013',
'2026-05-12 07:55',
'2026-05-12 10:05',
'U018',
'U018',
'good_condition',
'good_condition',
'lecture_completed'),

('S013','B014',
'2026-05-15 07:55',
'2026-05-15 11:05',
'U017',
'U017',
'good_condition',
'good_condition',
'examination_completed'),

('S014','B015',
'2026-05-20 08:55',
'2026-05-20 11:00',
'U018',
'U018',
'good_condition',
'good_condition',
'administration_completed'),

('S015','B017',
'2026-07-03 12:55',
NULL,
'U017',
NULL,
'good_condition',
NULL,
'event_in_progress'),

('S016','B021',
'2026-07-07 07:55',
NULL,
'U018',
NULL,
'good_condition',
NULL,
'exam_in_progress');



-- =====================================================
-- MAINTENANCE_RECORD
-- =====================================================

INSERT INTO MAINTENANCE_RECORD VALUES

('M001',
'SP005',
'U017',
'U018',
'broken_projector',
'2026-06-15 08:00',
NULL,
'in_progress',
NULL),

('M002',
'SP005',
'U018',
'U017',
'network_issue',
'2026-06-16 09:00',
NULL,
'pending',
NULL),

('M003',
'SP008',
'U017',
'U018',
'cleaning_issue',
'2026-06-10 08:00',
'2026-06-10 11:00',
'completed',
'room_cleaned'),

('M004',
'SP009',
'U003',
'U017',
'damaged_furniture',
'2026-05-20 09:00',
'2026-05-20 14:00',
'completed',
'chair_replaced'),

('M005',
'SP004',
'U014',
'U018',
'air_conditioner_failure',
'2026-04-25 10:00',
'2026-04-25 17:00',
'completed',
'ac_repaired'),

('M006',
'SP011',
'U010',
'U018',
'microphone_issue',
'2026-03-15 08:00',
'2026-03-15 09:00',
'completed',
'microphone_replaced'),

('M007',
'SP001',
'U009',
'U017',
'broken_projector',
'2026-05-29 14:00',
'2026-05-29 15:00',
'completed',
'projector_calibrated'),

('M008',
'SP011',
'U011',
'U018',
'camera_issue',
'2026-06-30 08:00',
NULL,
'in_progress',
NULL),

('M009',
'SP006',
'U016',
'U017',
'network_issue',
'2026-06-18 09:00',
'2026-06-18 10:00',
'completed',
'network_restored'),

('M010',
'SP010',
'U015',
'U018',
'power_outage',
'2026-06-25 09:00',
NULL,
'cancelled',
'building_closed'),

('M011',
'SP012',
'U004',
'U017',
'damaged_furniture',
'2026-05-01 08:00',
NULL,
'cancelled',
'building_retired'),

('M012',
'SP003',
'U009',
'U018',
'microphone_issue',
'2026-06-05 10:00',
'2026-06-05 11:00',
'completed',
'microphone_replaced');



-- =====================================================
-- DATASET NOTES
-- =====================================================

/*

This dataset supports:

1. Upcoming Bookings

2. Spaces Under Maintenance

3. No-show Bookings

4. Rejected Bookings With Reasons

5. Space Utilization Ranking

6. Maintenance Workload

7. Booking History

8. Most Active Users

9. Space Usage By Building

10. Booking Statistics By Activity Type

11. Check-in and Completion Performance

12. Facility Availability

Exceptional cases:

- inactive account
- suspended account

- under_maintenance space
- temporarily_closed space
- retired space

- pending booking
- cancelled booking
- rejected booking
- checked_in booking
- no_show booking

- ongoing sessions

- pending maintenance
- in_progress maintenance
- cancelled maintenance

*/