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

This skill governs how to produce `05-db-definition-G08.sql`. It is scoped to
this project's schema — seven tables, three business-rule triggers, and a set of
filtered indexes. Read this file in full before writing a single line of SQL.

---

## Context Scope (load these before starting)

Read **only** these files — loading more wastes context with no accuracy gain:

1. `outputs/01-business-req-analysis-G08.md` — §6 Business Rules, §4 Attributes
   (for exact status value sets used in CHECK constraints)
2. `outputs/03-logical-design-G08.md` — Table definitions, FK Constraints Summary,
   Referential Integrity Rules (ON DELETE actions)
3. `outputs/04-design-validation-G08.md` — §7 Limitations (flags which rules need
   triggers vs. CHECK constraints) and §5 Data Integrity
4. `evaluations/evaluation-05.md` — if it exists, read it first; it lists known
   issues from prior rounds that must be fixed in this round

Do not load `02-erd-design-G08.md` for DDL work — the logical design (03) is the
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
Fires: AFTER INSERT, UPDATE on BOOKING_APPROVAL
Logic:
  For each row in `inserted` where decision = 'Rejected':
    Check if rejection_reason IS NULL OR LTRIM(RTRIM(rejection_reason)) = ''
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

Run these checks **before** writing the result to `experiments/section_05/result_roundN.sql`.
Mark each as PASS or FAIL in your `improve05.md` log entry.

| Check | How to verify |
|---|---|
| Table creation order | Trace every FK: does its parent table appear earlier in the file? |
| CHECK value sets | Compare each CHECK list against the Exploration table above, value by value |
| UNIQUE on BOOKING_APPROVAL.booking_id | Confirm the constraint is present and correctly named |
| UNIQUE on USAGE_SESSION.booking_id | Confirm the constraint is present |
| trg_CheckSpaceAvailability scope | Confirm `i.status IN ('Pending','Approved')` is in the WHERE clause |
| trg_PreventOverlappingBooking | Confirm `b.booking_id <> i.booking_id` exclusion is present |
| trg_RequireRejectionReason | Confirm empty string is also rejected (not just NULL) |
| ON DELETE actions | Compare each FK's ON DELETE against the Exploration table |
| Idempotent drop/create block | Confirm the file begins with a DROP DATABASE IF EXISTS + CREATE DATABASE block |
| No status value drift | Confirm no new status values were introduced that don't appear in `01-*` |

**All 10 checks must PASS before writing the result file.** If any fail, fix and
re-run the checks. Log what failed, what was fixed, and the final check result in
`experiments/section_05/improve05.md`.

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
