---
name: Database-Implementation
description: >
  Implement the relational database schema using SQL DDL (CREATE TABLE, PRIMARY KEY,
  FOREIGN KEY, UNIQUE, CHECK, DEFAULT, triggers) based on the logical design and
  validation deliverables. Produces a single idempotent .sql file that can be run
  from scratch. Use this skill for section 05 of the Campus Space Booking project.
  Always run the Explore → Plan → Execute cycle and the Verification Loop before
  writing the result to experiments/.
---

# Skill: Database Implementation (SQL DDL)

This skill governs how to produce `result_roundN.sql`. It is scoped to
this project's schema — seven tables, three business-rule triggers, and a set of
filtered indexes. Read this file in full before writing a single line of SQL.

---

## Context Scope (load these before starting)

Read **only** these files — loading more wastes context with no accuracy gain:

1. `doc/project_description.md`
2. `experiments/section_01/result_round3.md`
3. `experiments/section_02/result_round3.md`
4. `experiments/section_03/result_round3.md`
5. `experiments/section_04/result_round3.md`
6. `evaluation/evaluation_05.md`
7. `prompts/`

YOU MUST READ THE `project_description.md` FIRST
USE `evaluation_05.md` FOR SCORING AND EVALUATION IN `improve05.md`
YOU MUST NOT CHANGE ANYTHING INSIDE `evaluation/` or `output/`
YOUR OUTPUT MUST BE IN THE `experiments/section_05` with the name `result_roundN.sql` 
Do not load `experiments/section_02/result_round1.md` for DDL work — the logical design (03) is the
direct source; the ERD is already abstracted away.

---

## Phase 1 — Exploration

Before planning, explicitly confirm these facts by reading the context files:

**Table names (must match exactly):**
`USER`, `SPACE`, `FACILITY`, `BOOKING_REQUEST`, `BOOKING_APPROVAL`,
`USAGE_SESSION`, `MAINTENANCE_RECORD`

**FK dependency order (parents must be created first):**
`USER` and `SPACE` have no FK dependencies → create them first.
`FACILITY` depends on `SPACE`.
`BOOKING_REQUEST` depends on `USER` and `SPACE`.
`BOOKING_APPROVAL` depends on `BOOKING_REQUEST` and `USER`.
`USAGE_SESSION` depends on `BOOKING_REQUEST` and `USER` (×2).
`MAINTENANCE_RECORD` depends on `SPACE` and `USER` (×2).

**Status value sets (copy verbatim into CHECK constraints — do not invent new values):**

| Column | Allowed Values |
|---|---|
| USER.role | 'Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager' |
| USER.account_status | 'Active', 'Inactive', 'Suspended' |
| SPACE.space_type | 'Auditorium', 'Classroom', 'Computer Lab', 'Project Lab', 'Meeting Room', 'Student Workspace' |
| SPACE.current_status | 'Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired' |
| BOOKING_REQUEST.booking_type | 'Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event' |
| BOOKING_REQUEST.status | 'Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-Show' |
| MAINTENANCE_RECORD.status | 'Open', 'In Progress', 'Resolved', 'Closed' |

**Gaps that need triggers (from validation step 4):**
- Overlapping approved bookings — cross-row check; needs `AFTER INSERT, UPDATE` trigger on `BOOKING_REQUEST`
- Space unavailability — needs `AFTER INSERT, UPDATE` trigger on `BOOKING_REQUEST`, but **only for Pending/Approved status transitions** (not historical updates)
- Rejection reason required — cross-column conditional; needs `AFTER INSERT, UPDATE` trigger on `BOOKING_APPROVAL`

**FK ON DELETE actions (from `03-logical-design-G08.md`):**

| FK | Action |
|---|---|
| BOOKING_REQUEST.user_id → USER | RESTRICT |
| BOOKING_REQUEST.space_code → SPACE | RESTRICT |
| BOOKING_APPROVAL.booking_id → BOOKING_REQUEST | CASCADE |
| BOOKING_APPROVAL.decided_by_user_id → USER | RESTRICT |
| USAGE_SESSION.booking_id → BOOKING_REQUEST | CASCADE |
| USAGE_SESSION.checked_in_by_user_id → USER | RESTRICT |
| USAGE_SESSION.completed_by_user_id → USER | RESTRICT |
| FACILITY.space_code → SPACE | CASCADE |
| MAINTENANCE_RECORD.space_code → SPACE | RESTRICT |
| MAINTENANCE_RECORD.reporter_user_id → USER | RESTRICT |
| MAINTENANCE_RECORD.assigned_staff_user_id → USER | SET NULL |

---

## Phase 2 — Planning

Before writing any SQL, write out a plan in this format (in your working notes,
not in the output file):

```
TABLE CREATION ORDER:
1. USER
2. SPACE
3. FACILITY
4. BOOKING_REQUEST
5. BOOKING_APPROVAL
6. USAGE_SESSION
7. MAINTENANCE_RECORD

TRIGGERS TO WRITE:
- trg_PreventOverlappingBooking (on BOOKING_REQUEST, AFTER INSERT/UPDATE)
- trg_CheckSpaceAvailability    (on BOOKING_REQUEST, AFTER INSERT/UPDATE)
- trg_RequireRejectionReason    (on BOOKING_APPROVAL, AFTER INSERT/UPDATE)

INDEXES TO CREATE:
- IX_BookingRequest_Space_Time  (filtered: status IN active set)
- IX_BookingRequest_User
- IX_BookingApproval_Decider
- IX_Maintenance_Space

DECISIONS / ASSUMPTIONS:
- [List any value or type decision not fully specified in the logical design]
```

The human must be able to read this plan and confirm the approach is correct
before execution begins.

---

## Phase 3 — Execution

### File structure

Produce a single `.sql` file with this section order, each clearly separated
by a header comment block:

```sql
-- ============================================================
-- DATABASE CREATION (idempotent: drop and recreate)
-- ============================================================

-- ============================================================
-- TABLE: <name>
-- <one-sentence description of what this table stores>
-- ============================================================

-- ... (one block per table, in dependency order)

-- ============================================================
-- INDEXES
-- ============================================================

-- ============================================================
-- TRIGGERS
-- ============================================================
```

### Table DDL rules

- Use `IDENTITY(1,1)` for surrogate integer PKs. For natural-key PKs (e.g.,
  `space_code VARCHAR`), do not use IDENTITY.
- Every `CHECK` constraint must use the exact value set from the Exploration table
  above — do not add or remove values without flagging it as an assumption.
- Every `NOT NULL` / `NULL` decision must match the `03-logical-design-G08.md`
  Constraints column.
- `DEFAULT` values: apply `DEFAULT GETDATE()` to submission/decision timestamps,
  `DEFAULT 'Pending'` to `BOOKING_REQUEST.status`, `DEFAULT 'Active'` to
  `USER.account_status`, `DEFAULT 'Available'` to `SPACE.current_status`,
  `DEFAULT 'Open'` to `MAINTENANCE_RECORD.status`.
- The `UNIQUE` constraint on `BOOKING_APPROVAL.booking_id` is mandatory — it
  enforces the 1:1 relationship between booking and its approval record.
- The `UNIQUE` constraint on `USAGE_SESSION.booking_id` is mandatory — same reason.

### Trigger rules

**trg_PreventOverlappingBooking**

```
Fires: AFTER INSERT, UPDATE on BOOKING_REQUEST
Logic:
  For each row in `inserted` where status IN ('Approved', 'Checked In'):
    Check if any OTHER row in BOOKING_REQUEST exists where:
      - same space_code
      - different booking_id
      - status IN ('Approved', 'Checked In', 'Completed')
      - time ranges overlap: inserted.requested_start < existing.requested_end
                         AND inserted.requested_end > existing.requested_start
  If such a row exists: RAISERROR and ROLLBACK.
```

Do not include 'Completed' in the **inserted** side check — completed bookings
are historical and should not block new approvals. Only include 'Completed' on the
**existing** side if required by policy (i.e., if a completed booking's time slot
is still considered blocked).

**trg_CheckSpaceAvailability** ← CRITICAL SCOPING RULE

```
Fires: AFTER INSERT, UPDATE on BOOKING_REQUEST
Logic:
  For each row in `inserted` where status IN ('Pending', 'Approved'):
    Check if Space.current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
  If so: RAISERROR and ROLLBACK.
```

**The `status IN ('Pending', 'Approved')` scope is non-negotiable.** Without it,
the trigger will roll back any UPDATE to a historical completed booking (e.g.,
adding usage_notes) if the space has since gone under maintenance. This is the
most common bug in prior rounds.

**trg_RequireRejectionReason**

```
Fires: AFTER INSERT, UPDATE on BOOKING_REQUEST
Logic:
  For each row in `inserted` where status = 'Rejected':
    Check if a corresponding record exists in BOOKING_APPROVAL where rejection_reason IS NULL OR empty
  If so: RAISERROR and ROLLBACK.
```
*(Moved from BOOKING_APPROVAL to BOOKING_REQUEST to prevent transaction-ordering bypass vulnerabilities).*

**trg_PreventMaintenanceWithActiveBookings**

```
Fires: AFTER UPDATE on SPACE
Logic:
  For each row in `inserted` where current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired'):
    Check if any BOOKING_REQUEST exists for that space_code with status IN ('Approved', 'Checked In')
  If so: RAISERROR and ROLLBACK.
```

### Index rules

- Create a **filtered** index on `BOOKING_REQUEST(space_code, requested_start_time, requested_end_time)`
  with `WHERE status IN ('Approved', 'Checked In')` — this is the hot path for
  the overlap trigger and should not include historical rows.
- Create a plain index on `BOOKING_REQUEST(user_id)` for history queries.
- Create a plain index on `BOOKING_APPROVAL(decided_by_user_id)` for staff reports.
- Create a plain index on `MAINTENANCE_RECORD(space_code)` for space status queries.

---

## Verification Loop

Before writing the result to `experiments/section_05/result_roundN.sql`, you must mathematically and syntactically prove the script works. 

**Step 1: Syntax & Architectural Verification**
You must mentally execute and validate your SQL DDL statements to ensure they are valid T-SQL and follow database design best practices. Check explicitly for:
* **Dependency Order:** Ensure parent tables (like `USER` and `SPACE`) are created *before* the child tables that reference them.
* **Syntax Errors:** Verify there are no missing commas, unbalanced parentheses, or omitted `GO` statements. Ensure all data types are valid SQL Server types.
* **Constraint Integrity:** Verify all `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, and `CHECK` constraints are properly formatted and attached to the correct tables.
* **Architectural Best Practices:** Ensure indexes are created for performance, particularly on foreign key columns and fields heavily used in WHERE clauses.

* **IF FAIL:** Fix the `.sql` file and retry Step 1.
* **IF PASS:** Proceed to Step 2.

**Step 2: The Logical Checklist & Self-Improvement**
Once the script passes the syntax and architectural checks, verify these final business-logic constraints. You **MUST** record these results in your `experiments/section_05/improve05.md` file using the exact format defined in `improve_structure.md`. 

Copy and paste this exact checklist into the `### Verification Checklist` section of your round log:

```markdown
### Verification Checklist
* [ ] CHECK value sets match outputs/01: PASS/FAIL - (Notes)
* [ ] UNIQUE on BOOKING_APPROVAL (1:1 cardinality): PASS/FAIL - (Notes)
* [ ] UNIQUE on USAGE_SESSION (1:1 cardinality): PASS/FAIL - (Notes)
* [ ] trg_CheckSpaceAvailability scoped to Pending/Approved only: PASS/FAIL - (Notes)
* [ ] trg_PreventOverlappingBooking ignores self (b.booking_id <> i.booking_id): PASS/FAIL - (Notes)
* [ ] ON DELETE actions match outputs/03 perfectly: PASS/FAIL - (Notes)
* [ ] No status value casing drift: PASS/FAIL - (Notes)

---

## Common Mistakes (from prior evaluation rounds)

These are the bugs most likely to be introduced. Check for each explicitly:

1. **Trigger fires on historical rows** — `trg_CheckSpaceAvailability` without
   the `status IN ('Pending','Approved')` scope will block updates to completed
   bookings in currently-unavailable spaces. Always scope the trigger.

2. **Status values drift between files** — If the DDL uses `'checked_in'`
   (lowercase) but the business analysis specifies `'Checked In'` (title case),
   sample data INSERTs and query WHERE clauses will silently fail. Use the exact
   strings from `outputs/01-*`.

3. **Missing UNIQUE on the 1:1 FK** — Without `UNIQUE (booking_id)` on
   `BOOKING_APPROVAL`, two approval records can be inserted for the same booking,
   breaking the 1:1 cardinality. Always add this constraint.

4. **ON DELETE RESTRICT instead of SET NULL for assigned_staff** —
   `MAINTENANCE_RECORD.assigned_staff_user_id` should be `SET NULL` on delete,
   not `RESTRICT`, so that deleting a user account doesn't block maintenance
   record deletion. Match the logical design exactly.

5. **Table name casing inconsistency** — SQL Server is case-insensitive for
   identifiers by default, but the convention is `PascalCase` for table names
   (e.g., `BookingRequest` vs `BOOKING_REQUEST`). Pick one form and use it in
   every file. The logical design uses `UPPER_SNAKE_CASE`; match it.
