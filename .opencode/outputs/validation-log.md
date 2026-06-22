# Validation Log - Autonomous SQL Validation Pipeline
**Target:** E:\Computer Hardware\CS486-Database-Lab\mq\outputs\05-db-definition-G08.sql
**Started:** 2026-06-22 18:00:51
**Status:** Running

## Loop Summary

| Iteration | Phase 1 (Syntax) | Phase 2 (Lint) | Errors Found |
|-----------|------------------|----------------|--------------|
2026-06-22 18:00:51 [LOOP] 
============================================
2026-06-22 18:00:52 [LOOP] ITERATION 1
2026-06-22 18:00:52 [LOOP] ============================================
2026-06-22 18:00:52 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:01:03 [PASS] Phase 1 PASSED - No syntax errors
2026-06-22 18:01:03 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:01:03 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:01:03 [FAIL] Phase 2 FAILED - 23 linting issue(s) found
2026-06-22 18:01:03 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:01:03 [LINT]   IDENTITY: Column 'facility_id' is INT NOT NULL without IDENTITY
2026-06-22 18:01:03 [LINT]   IDENTITY: Column 'requester_id' is INT NOT NULL without IDENTITY
2026-06-22 18:01:03 [LINT]   IDENTITY: Column 'booking_id' is INT NOT NULL without IDENTITY
2026-06-22 18:01:03 [LINT]   IDENTITY: Column 'staff_id' is INT NOT NULL without IDENTITY
2026-06-22 18:01:03 [LINT]   IDENTITY: Column 'reporter_id' is INT NOT NULL without IDENTITY
2026-06-22 18:01:03 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:01:03 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:03 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:03 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:01:03 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:03 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:03 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:03 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:01:03 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:01:03 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:01:03 [LINT]   SCHEMA: Table 'Space' should use dbo. prefix
2026-06-22 18:01:03 [LINT]   SCHEMA: Table 'Facility' should use dbo. prefix
2026-06-22 18:01:03 [LINT]   SCHEMA: Table 'Space_Facility' should use dbo. prefix
2026-06-22 18:01:03 [LINT]   SCHEMA: Table 'Booking' should use dbo. prefix
2026-06-22 18:01:03 [LINT]   SCHEMA: Table 'Booking_Approval' should use dbo. prefix
2026-06-22 18:01:03 [LINT]   SCHEMA: Table 'Maintenance' should use dbo. prefix
2026-06-22 18:01:04 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 1 | PASS | FAIL | 23 |

### Iteration 1 - Failures
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: IDENTITY: Column 'facility_id' is INT NOT NULL without IDENTITY
- Phase2: IDENTITY: Column 'requester_id' is INT NOT NULL without IDENTITY
- Phase2: IDENTITY: Column 'booking_id' is INT NOT NULL without IDENTITY
- Phase2: IDENTITY: Column 'staff_id' is INT NOT NULL without IDENTITY
- Phase2: IDENTITY: Column 'reporter_id' is INT NOT NULL without IDENTITY
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: SCHEMA: Table 'Space' should use dbo. prefix
- Phase2: SCHEMA: Table 'Facility' should use dbo. prefix
- Phase2: SCHEMA: Table 'Space_Facility' should use dbo. prefix
- Phase2: SCHEMA: Table 'Booking' should use dbo. prefix
- Phase2: SCHEMA: Table 'Booking_Approval' should use dbo. prefix
- Phase2: SCHEMA: Table 'Maintenance' should use dbo. prefix
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:01:04 [FIX] FIX: Added IDENTITY(1,1) to column 'facility_id'
2026-06-22 18:01:04 [FIX] FIX: Added IDENTITY(1,1) to column 'requester_id'
2026-06-22 18:01:04 [FIX] FIX: Added IDENTITY(1,1) to column 'booking_id'
2026-06-22 18:01:04 [FIX] FIX: Added IDENTITY(1,1) to column 'staff_id'
2026-06-22 18:01:04 [FIX] FIX: Added IDENTITY(1,1) to column 'reporter_id'
2026-06-22 18:01:04 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:01:04 [FIX] FIX: Added dbo. prefix to table 'Space'
2026-06-22 18:01:04 [FIX] FIX: Added dbo. prefix to table 'Facility'
2026-06-22 18:01:04 [FIX] FIX: Added dbo. prefix to table 'Space_Facility'
2026-06-22 18:01:04 [FIX] FIX: Added dbo. prefix to table 'Booking'
2026-06-22 18:01:04 [FIX] FIX: Added dbo. prefix to table 'Booking_Approval'
2026-06-22 18:01:04 [FIX] FIX: Added dbo. prefix to table 'Maintenance'
2026-06-22 18:01:04 [FIX] FIXES APPLIED to E:\Computer Hardware\CS486-Database-Lab\mq\outputs\05-db-definition-G08.sql
2026-06-22 18:01:04 [LOOP] 
============================================
2026-06-22 18:01:04 [LOOP] ITERATION 2
2026-06-22 18:01:04 [LOOP] ============================================
2026-06-22 18:01:04 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:01:17 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:01:17 [ERROR]   Msg 1788, Level 16, State 1, Server d13aff839909, Line 7
2026-06-22 18:01:17 [ERROR]   Msg 1750, Level 16, State 1, Server d13aff839909, Line 7
2026-06-22 18:01:18 [ERROR]   Msg 2744, Level 16, State 2, Server d13aff839909, Line 7
2026-06-22 18:01:18 [ERROR]   Msg 2744, Level 16, State 2, Server d13aff839909, Line 7
2026-06-22 18:01:18 [ERROR]   Msg 2744, Level 16, State 2, Server d13aff839909, Line 6
2026-06-22 18:01:18 [ERROR]   Msg 208, Level 16, State 101, Server d13aff839909, Line 3
2026-06-22 18:01:18 [ERROR]   Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
2026-06-22 18:01:18 [ERROR]   Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
2026-06-22 18:01:18 [ERROR]   Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
2026-06-22 18:01:18 [ERROR]   Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
2026-06-22 18:01:18 [ERROR]   Msg 8197, Level 16, State 4, Server d13aff839909, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:01:18 [ERROR]   Msg 8197, Level 16, State 4, Server d13aff839909, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:01:18 [ERROR]   Msg 8197, Level 16, State 4, Server d13aff839909, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:01:18 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:01:18 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:01:18 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:01:18 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:01:18 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:01:18 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:18 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:18 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:01:18 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:18 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:18 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:18 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:01:18 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:01:18 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:01:18 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 2 | FAIL | FAIL | 25 |

### Iteration 2 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server d13aff839909, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server d13aff839909, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server d13aff839909, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server d13aff839909, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server d13aff839909, Line 6
- Phase1: Msg 208, Level 16, State 101, Server d13aff839909, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d13aff839909, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server d13aff839909, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server d13aff839909, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server d13aff839909, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:01:18 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:01:18 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:01:18 [LOOP] 
============================================
2026-06-22 18:01:18 [LOOP] ITERATION 3
2026-06-22 18:01:18 [LOOP] ============================================
2026-06-22 18:01:18 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:01:32 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:01:32 [ERROR]   Msg 1788, Level 16, State 1, Server b6259903a23d, Line 7
2026-06-22 18:01:32 [ERROR]   Msg 1750, Level 16, State 1, Server b6259903a23d, Line 7
2026-06-22 18:01:32 [ERROR]   Msg 2744, Level 16, State 2, Server b6259903a23d, Line 7
2026-06-22 18:01:32 [ERROR]   Msg 2744, Level 16, State 2, Server b6259903a23d, Line 7
2026-06-22 18:01:32 [ERROR]   Msg 2744, Level 16, State 2, Server b6259903a23d, Line 6
2026-06-22 18:01:32 [ERROR]   Msg 208, Level 16, State 101, Server b6259903a23d, Line 3
2026-06-22 18:01:32 [ERROR]   Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
2026-06-22 18:01:32 [ERROR]   Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
2026-06-22 18:01:32 [ERROR]   Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
2026-06-22 18:01:32 [ERROR]   Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
2026-06-22 18:01:32 [ERROR]   Msg 8197, Level 16, State 4, Server b6259903a23d, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:01:32 [ERROR]   Msg 8197, Level 16, State 4, Server b6259903a23d, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:01:32 [ERROR]   Msg 8197, Level 16, State 4, Server b6259903a23d, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:01:32 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:01:32 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:01:32 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:01:32 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:01:32 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:01:32 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:32 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:32 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:01:32 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:32 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:32 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:32 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:01:32 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:01:32 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:01:32 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 3 | FAIL | FAIL | 25 |

### Iteration 3 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server b6259903a23d, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server b6259903a23d, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server b6259903a23d, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server b6259903a23d, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server b6259903a23d, Line 6
- Phase1: Msg 208, Level 16, State 101, Server b6259903a23d, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server b6259903a23d, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server b6259903a23d, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server b6259903a23d, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server b6259903a23d, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:01:32 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:01:32 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:01:32 [LOOP] 
============================================
2026-06-22 18:01:32 [LOOP] ITERATION 4
2026-06-22 18:01:32 [LOOP] ============================================
2026-06-22 18:01:32 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:01:45 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:01:45 [ERROR]   Msg 1788, Level 16, State 1, Server d84a312b91b0, Line 7
2026-06-22 18:01:45 [ERROR]   Msg 1750, Level 16, State 1, Server d84a312b91b0, Line 7
2026-06-22 18:01:45 [ERROR]   Msg 2744, Level 16, State 2, Server d84a312b91b0, Line 7
2026-06-22 18:01:45 [ERROR]   Msg 2744, Level 16, State 2, Server d84a312b91b0, Line 7
2026-06-22 18:01:45 [ERROR]   Msg 2744, Level 16, State 2, Server d84a312b91b0, Line 6
2026-06-22 18:01:45 [ERROR]   Msg 208, Level 16, State 101, Server d84a312b91b0, Line 3
2026-06-22 18:01:45 [ERROR]   Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
2026-06-22 18:01:45 [ERROR]   Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
2026-06-22 18:01:45 [ERROR]   Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
2026-06-22 18:01:45 [ERROR]   Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
2026-06-22 18:01:45 [ERROR]   Msg 8197, Level 16, State 4, Server d84a312b91b0, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:01:45 [ERROR]   Msg 8197, Level 16, State 4, Server d84a312b91b0, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:01:46 [ERROR]   Msg 8197, Level 16, State 4, Server d84a312b91b0, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:01:46 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:01:46 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:01:46 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:01:46 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:01:46 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:01:46 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:46 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:46 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:01:46 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:46 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:46 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:01:46 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:01:46 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:01:46 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:01:46 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 4 | FAIL | FAIL | 25 |

### Iteration 4 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server d84a312b91b0, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server d84a312b91b0, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server d84a312b91b0, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server d84a312b91b0, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server d84a312b91b0, Line 6
- Phase1: Msg 208, Level 16, State 101, Server d84a312b91b0, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server d84a312b91b0, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server d84a312b91b0, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server d84a312b91b0, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server d84a312b91b0, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:01:46 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:01:46 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:01:46 [LOOP] 
============================================
2026-06-22 18:01:46 [LOOP] ITERATION 5
2026-06-22 18:01:46 [LOOP] ============================================
2026-06-22 18:01:46 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:01:59 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:01:59 [ERROR]   Msg 1788, Level 16, State 1, Server a9086e6beef1, Line 7
2026-06-22 18:02:00 [ERROR]   Msg 1750, Level 16, State 1, Server a9086e6beef1, Line 7
2026-06-22 18:02:00 [ERROR]   Msg 2744, Level 16, State 2, Server a9086e6beef1, Line 7
2026-06-22 18:02:00 [ERROR]   Msg 2744, Level 16, State 2, Server a9086e6beef1, Line 7
2026-06-22 18:02:00 [ERROR]   Msg 2744, Level 16, State 2, Server a9086e6beef1, Line 6
2026-06-22 18:02:00 [ERROR]   Msg 208, Level 16, State 101, Server a9086e6beef1, Line 3
2026-06-22 18:02:00 [ERROR]   Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
2026-06-22 18:02:00 [ERROR]   Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
2026-06-22 18:02:00 [ERROR]   Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
2026-06-22 18:02:00 [ERROR]   Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
2026-06-22 18:02:00 [ERROR]   Msg 8197, Level 16, State 4, Server a9086e6beef1, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:02:00 [ERROR]   Msg 8197, Level 16, State 4, Server a9086e6beef1, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:02:00 [ERROR]   Msg 8197, Level 16, State 4, Server a9086e6beef1, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:02:00 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:02:00 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:02:00 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:02:00 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:02:00 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:02:00 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:00 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:00 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:02:00 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:00 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:00 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:00 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:02:00 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:02:00 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:02:00 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 5 | FAIL | FAIL | 25 |

### Iteration 5 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server a9086e6beef1, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server a9086e6beef1, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server a9086e6beef1, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server a9086e6beef1, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server a9086e6beef1, Line 6
- Phase1: Msg 208, Level 16, State 101, Server a9086e6beef1, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server a9086e6beef1, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server a9086e6beef1, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server a9086e6beef1, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server a9086e6beef1, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:02:00 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:02:00 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:02:00 [LOOP] 
============================================
2026-06-22 18:02:00 [LOOP] ITERATION 6
2026-06-22 18:02:00 [LOOP] ============================================
2026-06-22 18:02:00 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:02:13 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:02:13 [ERROR]   Msg 1788, Level 16, State 1, Server 89f55d274140, Line 7
2026-06-22 18:02:13 [ERROR]   Msg 1750, Level 16, State 1, Server 89f55d274140, Line 7
2026-06-22 18:02:13 [ERROR]   Msg 2744, Level 16, State 2, Server 89f55d274140, Line 7
2026-06-22 18:02:13 [ERROR]   Msg 2744, Level 16, State 2, Server 89f55d274140, Line 7
2026-06-22 18:02:13 [ERROR]   Msg 2744, Level 16, State 2, Server 89f55d274140, Line 6
2026-06-22 18:02:13 [ERROR]   Msg 208, Level 16, State 101, Server 89f55d274140, Line 3
2026-06-22 18:02:13 [ERROR]   Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
2026-06-22 18:02:13 [ERROR]   Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
2026-06-22 18:02:13 [ERROR]   Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
2026-06-22 18:02:13 [ERROR]   Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
2026-06-22 18:02:13 [ERROR]   Msg 8197, Level 16, State 4, Server 89f55d274140, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:02:13 [ERROR]   Msg 8197, Level 16, State 4, Server 89f55d274140, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:02:13 [ERROR]   Msg 8197, Level 16, State 4, Server 89f55d274140, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:02:13 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:02:13 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:02:13 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:02:13 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:02:13 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:02:13 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:13 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:13 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:02:13 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:13 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:13 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:13 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:02:13 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:02:13 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:02:13 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 6 | FAIL | FAIL | 25 |

### Iteration 6 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server 89f55d274140, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server 89f55d274140, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 89f55d274140, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 89f55d274140, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 89f55d274140, Line 6
- Phase1: Msg 208, Level 16, State 101, Server 89f55d274140, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 89f55d274140, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server 89f55d274140, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server 89f55d274140, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server 89f55d274140, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:02:14 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:02:14 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:02:14 [LOOP] 
============================================
2026-06-22 18:02:14 [LOOP] ITERATION 7
2026-06-22 18:02:14 [LOOP] ============================================
2026-06-22 18:02:14 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:02:27 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:02:27 [ERROR]   Msg 1788, Level 16, State 1, Server 03d7a9e0ad99, Line 7
2026-06-22 18:02:27 [ERROR]   Msg 1750, Level 16, State 1, Server 03d7a9e0ad99, Line 7
2026-06-22 18:02:27 [ERROR]   Msg 2744, Level 16, State 2, Server 03d7a9e0ad99, Line 7
2026-06-22 18:02:27 [ERROR]   Msg 2744, Level 16, State 2, Server 03d7a9e0ad99, Line 7
2026-06-22 18:02:27 [ERROR]   Msg 2744, Level 16, State 2, Server 03d7a9e0ad99, Line 6
2026-06-22 18:02:27 [ERROR]   Msg 208, Level 16, State 101, Server 03d7a9e0ad99, Line 3
2026-06-22 18:02:27 [ERROR]   Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
2026-06-22 18:02:27 [ERROR]   Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
2026-06-22 18:02:27 [ERROR]   Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
2026-06-22 18:02:27 [ERROR]   Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
2026-06-22 18:02:27 [ERROR]   Msg 8197, Level 16, State 4, Server 03d7a9e0ad99, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:02:27 [ERROR]   Msg 8197, Level 16, State 4, Server 03d7a9e0ad99, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:02:27 [ERROR]   Msg 8197, Level 16, State 4, Server 03d7a9e0ad99, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:02:27 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:02:27 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:02:27 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:02:27 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:02:27 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:02:27 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:27 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:27 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:02:27 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:27 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:27 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:27 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:02:27 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:02:27 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:02:27 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 7 | FAIL | FAIL | 25 |

### Iteration 7 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server 03d7a9e0ad99, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server 03d7a9e0ad99, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 03d7a9e0ad99, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 03d7a9e0ad99, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 03d7a9e0ad99, Line 6
- Phase1: Msg 208, Level 16, State 101, Server 03d7a9e0ad99, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 03d7a9e0ad99, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server 03d7a9e0ad99, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server 03d7a9e0ad99, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server 03d7a9e0ad99, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:02:27 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:02:27 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:02:27 [LOOP] 
============================================
2026-06-22 18:02:27 [LOOP] ITERATION 8
2026-06-22 18:02:27 [LOOP] ============================================
2026-06-22 18:02:27 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:02:40 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:02:40 [ERROR]   Msg 1788, Level 16, State 1, Server f87a885449e7, Line 7
2026-06-22 18:02:40 [ERROR]   Msg 1750, Level 16, State 1, Server f87a885449e7, Line 7
2026-06-22 18:02:40 [ERROR]   Msg 2744, Level 16, State 2, Server f87a885449e7, Line 7
2026-06-22 18:02:40 [ERROR]   Msg 2744, Level 16, State 2, Server f87a885449e7, Line 7
2026-06-22 18:02:40 [ERROR]   Msg 2744, Level 16, State 2, Server f87a885449e7, Line 6
2026-06-22 18:02:40 [ERROR]   Msg 208, Level 16, State 101, Server f87a885449e7, Line 3
2026-06-22 18:02:40 [ERROR]   Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
2026-06-22 18:02:40 [ERROR]   Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
2026-06-22 18:02:40 [ERROR]   Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
2026-06-22 18:02:40 [ERROR]   Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
2026-06-22 18:02:40 [ERROR]   Msg 8197, Level 16, State 4, Server f87a885449e7, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:02:40 [ERROR]   Msg 8197, Level 16, State 4, Server f87a885449e7, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:02:40 [ERROR]   Msg 8197, Level 16, State 4, Server f87a885449e7, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:02:40 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:02:41 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:02:41 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:02:41 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:02:41 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:02:41 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:41 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:41 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:02:41 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:41 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:41 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:41 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:02:41 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:02:41 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:02:41 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 8 | FAIL | FAIL | 25 |

### Iteration 8 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server f87a885449e7, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server f87a885449e7, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server f87a885449e7, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server f87a885449e7, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server f87a885449e7, Line 6
- Phase1: Msg 208, Level 16, State 101, Server f87a885449e7, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server f87a885449e7, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server f87a885449e7, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server f87a885449e7, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server f87a885449e7, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:02:41 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:02:41 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:02:41 [LOOP] 
============================================
2026-06-22 18:02:41 [LOOP] ITERATION 9
2026-06-22 18:02:41 [LOOP] ============================================
2026-06-22 18:02:41 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:02:52 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:02:52 [ERROR]   Msg 1788, Level 16, State 1, Server ba8bae8ed1bf, Line 7
2026-06-22 18:02:52 [ERROR]   Msg 1750, Level 16, State 1, Server ba8bae8ed1bf, Line 7
2026-06-22 18:02:52 [ERROR]   Msg 2744, Level 16, State 2, Server ba8bae8ed1bf, Line 7
2026-06-22 18:02:52 [ERROR]   Msg 2744, Level 16, State 2, Server ba8bae8ed1bf, Line 7
2026-06-22 18:02:52 [ERROR]   Msg 2744, Level 16, State 2, Server ba8bae8ed1bf, Line 6
2026-06-22 18:02:52 [ERROR]   Msg 208, Level 16, State 101, Server ba8bae8ed1bf, Line 3
2026-06-22 18:02:52 [ERROR]   Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
2026-06-22 18:02:52 [ERROR]   Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
2026-06-22 18:02:52 [ERROR]   Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
2026-06-22 18:02:52 [ERROR]   Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
2026-06-22 18:02:52 [ERROR]   Msg 8197, Level 16, State 4, Server ba8bae8ed1bf, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:02:52 [ERROR]   Msg 8197, Level 16, State 4, Server ba8bae8ed1bf, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:02:52 [ERROR]   Msg 8197, Level 16, State 4, Server ba8bae8ed1bf, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:02:52 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:02:52 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:02:52 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:02:52 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:02:52 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:02:52 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:52 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:52 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:02:52 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:52 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:52 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:02:52 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:02:52 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:02:52 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:02:52 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 9 | FAIL | FAIL | 25 |

### Iteration 9 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server ba8bae8ed1bf, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server ba8bae8ed1bf, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server ba8bae8ed1bf, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server ba8bae8ed1bf, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server ba8bae8ed1bf, Line 6
- Phase1: Msg 208, Level 16, State 101, Server ba8bae8ed1bf, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server ba8bae8ed1bf, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server ba8bae8ed1bf, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server ba8bae8ed1bf, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server ba8bae8ed1bf, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:02:52 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:02:52 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:02:52 [LOOP] 
============================================
2026-06-22 18:02:52 [LOOP] ITERATION 10
2026-06-22 18:02:52 [LOOP] ============================================
2026-06-22 18:02:52 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:03:06 [FAIL] Phase 1 FAILED - 13 error(s) found
2026-06-22 18:03:06 [ERROR]   Msg 1788, Level 16, State 1, Server 9ff2cd3c1a78, Line 7
2026-06-22 18:03:06 [ERROR]   Msg 1750, Level 16, State 1, Server 9ff2cd3c1a78, Line 7
2026-06-22 18:03:06 [ERROR]   Msg 2744, Level 16, State 2, Server 9ff2cd3c1a78, Line 7
2026-06-22 18:03:06 [ERROR]   Msg 2744, Level 16, State 2, Server 9ff2cd3c1a78, Line 7
2026-06-22 18:03:06 [ERROR]   Msg 2744, Level 16, State 2, Server 9ff2cd3c1a78, Line 6
2026-06-22 18:03:06 [ERROR]   Msg 208, Level 16, State 101, Server 9ff2cd3c1a78, Line 3
2026-06-22 18:03:06 [ERROR]   Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
2026-06-22 18:03:06 [ERROR]   Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
2026-06-22 18:03:06 [ERROR]   Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
2026-06-22 18:03:06 [ERROR]   Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
2026-06-22 18:03:06 [ERROR]   Msg 8197, Level 16, State 4, Server 9ff2cd3c1a78, Procedure trg_PreventOverlappingBooking, Line 8
2026-06-22 18:03:06 [ERROR]   Msg 8197, Level 16, State 4, Server 9ff2cd3c1a78, Procedure trg_CheckSpaceAvailability, Line 3
2026-06-22 18:03:06 [ERROR]   Msg 8197, Level 16, State 4, Server 9ff2cd3c1a78, Procedure trg_RequireRejectionReason, Line 3
2026-06-22 18:03:06 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:03:06 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - ensure this is intentional
2026-06-22 18:03:06 [FAIL] Phase 2 FAILED - 12 linting issue(s) found
2026-06-22 18:03:06 [LINT]   MISMATCH: 10 FK constraints but 5 REFERENCES clauses
2026-06-22 18:03:06 [LINT]   INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
2026-06-22 18:03:06 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:03:06 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:03:06 [LINT]   INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
2026-06-22 18:03:06 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:03:06 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:03:06 [LINT]   INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
2026-06-22 18:03:06 [LINT]   CHECK: 12 inline CHECK constraint(s) without explicit name
2026-06-22 18:03:06 [LINT]   DATETIME2: 8 DATETIME2 column(s) without explicit precision
2026-06-22 18:03:06 [LINT]   INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
2026-06-22 18:03:06 [LINT]   NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
| 10 | FAIL | FAIL | 25 |

### Iteration 10 - Failures
- Phase1: Msg 1788, Level 16, State 1, Server 9ff2cd3c1a78, Line 7
- Phase1: Msg 1750, Level 16, State 1, Server 9ff2cd3c1a78, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 9ff2cd3c1a78, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 9ff2cd3c1a78, Line 7
- Phase1: Msg 2744, Level 16, State 2, Server 9ff2cd3c1a78, Line 6
- Phase1: Msg 208, Level 16, State 101, Server 9ff2cd3c1a78, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
- Phase1: Msg 1088, Level 16, State 12, Server 9ff2cd3c1a78, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server 9ff2cd3c1a78, Procedure trg_PreventOverlappingBooking, Line 8
- Phase1: Msg 8197, Level 16, State 4, Server 9ff2cd3c1a78, Procedure trg_CheckSpaceAvailability, Line 3
- Phase1: Msg 8197, Level 16, State 4, Server 9ff2cd3c1a78, Procedure trg_RequireRejectionReason, Line 3
- Phase2: MISMATCH: 10 FK constraints but 5 REFERENCES clauses
- Phase2: INDEX: Missing index on FK column referencing facility_id (pattern IX_*_facility)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing booking_id (pattern IX_*_booking)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: INDEX: Missing index on FK column referencing user_id (pattern IX_*_user)
- Phase2: CHECK: 12 inline CHECK constraint(s) without explicit name
- Phase2: DATETIME2: 8 DATETIME2 column(s) without explicit precision
- Phase2: INDEX: 'IX_BookingApproval_Staff' should follow IX_{Table}_{Purpose} naming
- Phase2: NVARCHAR(MAX): 9 column(s) use NVARCHAR(MAX) - consider specific length limits
2026-06-22 18:03:06 [INFO] INFO: Inline CHECK constraints without names - adding CK_ names would break existing SQL; manual review recommended
2026-06-22 18:03:06 [INFO] No auto-fixable issues found (or all issues require manual review)
2026-06-22 18:03:06 [ERROR] MAX ITERATIONS (10) REACHED
2026-06-22 18:03:07 [DONE] Pipeline finished at 2026-06-22 18:03:07
2026-06-22 18:04:17 [LOOP] 
============================================
2026-06-22 18:04:17 [LOOP] ITERATION 1
2026-06-22 18:04:17 [LOOP] ============================================
2026-06-22 18:04:18 [PHASE1] === PHASE 1: Docker SQL Server Syntax Check ===
2026-06-22 18:04:30 [PASS] Phase 1 PASSED - No syntax errors
2026-06-22 18:04:30 [PHASE2] === PHASE 2: Architectural Linting ===
2026-06-22 18:04:30 [WARN] WARNING: 2 FK(s) use ON DELETE CASCADE - verify intentional
2026-06-22 18:04:30 [FAIL] Phase 2 FAILED - 7 linting issue(s) found
2026-06-22 18:04:30 [LINT]   DATA TYPE: 9 columns use NVARCHAR(MAX) - prefer specific lengths
2026-06-22 18:04:30 [LINT]   INDEX: 'IX_Booking_Space_Time' is filtered (WHERE clause) - ensure query patterns justify this
2026-06-22 18:04:30 [LINT]   DATA TYPE: 8 DATETIME2 column(s) without explicit precision (e.g. DATETIME2(0))
2026-06-22 18:04:30 [LINT]   INDEX: FK column 'facility_id' may benefit from an index
2026-06-22 18:04:30 [LINT]   INDEX: FK column 'checkin_staff_id' may benefit from an index
2026-06-22 18:04:30 [LINT]   INDEX: FK column 'booking_id' may benefit from an index
2026-06-22 18:04:30 [LINT]   INDEX: FK column 'reporter_id' may benefit from an index
| 1 | PASS | FAIL | 7 |

### Iteration 1 - Failures
- Phase2: DATA TYPE: 9 columns use NVARCHAR(MAX) - prefer specific lengths
- Phase2: INDEX: 'IX_Booking_Space_Time' is filtered (WHERE clause) - ensure query patterns justify this
- Phase2: DATA TYPE: 8 DATETIME2 column(s) without explicit precision (e.g. DATETIME2(0))
- Phase2: INDEX: FK column 'facility_id' may benefit from an index
- Phase2: INDEX: FK column 'checkin_staff_id' may benefit from an index
- Phase2: INDEX: FK column 'booking_id' may benefit from an index
- Phase2: INDEX: FK column 'reporter_id' may benefit from an index
2026-06-22 18:04:30 [PASS] PHASE 1 PASSED - Syntax valid. Phase 2 lint issues are recommendations.

## Final Summary

**Phase 1:** PASS — Zero syntax errors
**Phase 2:** FAIL — 7 lint recommendation(s)

### Lint Recommendations (non-blocking)
- DATA TYPE: 9 columns use NVARCHAR(MAX) - prefer specific lengths
 - INDEX: 'IX_Booking_Space_Time' is filtered (WHERE clause) - ensure query patterns justify this
 - DATA TYPE: 8 DATETIME2 column(s) without explicit precision (e.g. DATETIME2(0))
 - INDEX: FK column 'facility_id' may benefit from an index
 - INDEX: FK column 'checkin_staff_id' may benefit from an index
 - INDEX: FK column 'booking_id' may benefit from an index
 - INDEX: FK column 'reporter_id' may benefit from an index

2026-06-22 18:04:30 [DONE] Pipeline finished at 2026-06-22 18:04:30
