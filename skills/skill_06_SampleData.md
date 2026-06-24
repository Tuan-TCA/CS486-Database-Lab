---
name: Sample-Data-Preparation
description: >
  Insert realistic sample data to support testing of normal operations and important
  exceptional cases. Produces a single idempotent .sql file of INSERT statements
  that covers every booking status, every user role, every space type, every
  maintenance status, and every exceptional scenario flagged in the business rules.
  Use this skill for section 06 of the Campus Space Booking project.
  Always run the Explore → Plan → Execute cycle and the Verification Loop before
  writing the result to experiments/.
---

# Skill: Sample Data Preparation

This skill governs how to produce `06-sample-data-G08.sql`. It is scoped to the
seven-table schema of the Campus Space Booking project. Read this file in full
before writing a single INSERT statement.

---

## Context Scope (load these before starting)

Read **only** these files:

1. `outputs/01-business-req-analysis-G08.md` — §7 Status Lifecycle (the flow
   diagram), §6 Business Rules (what exceptional cases must be demonstrated)
2. `outputs/03-logical-design-G08.md` — FK Constraints Summary and Referential
   Integrity Rules (insert order and nullable columns)
3. `outputs/05-db-definition-G08.sql` — the actual DDL; confirm exact column
   names, types, and CHECK constraint values before inserting
4. `evaluation/evaluation-06.md` — if it exists, read it first; it lists
   known gaps from prior rounds (e.g., missing approval records for completed
   bookings) that must be fixed in this round

YOU MUST NOT CHANGE ANYTHING INSIDE `evaluation/` or `output/`
YOUR OUTPUT MUST BE IN THE `experiments/section_06`
---

## Phase 1 — Exploration

Before planning, confirm these facts from the context files:

**INSERT dependency order (children must be inserted after parents):**
```
USER            ← no dependencies
SPACE           ← no dependencies
FACILITY        ← depends on SPACE
BOOKING_REQUEST ← depends on USER, SPACE
BOOKING_APPROVAL← depends on BOOKING_REQUEST, USER
USAGE_SESSION   ← depends on BOOKING_REQUEST, USER (×2)
MAINTENANCE_RECORD ← depends on SPACE, USER (×2)
```

**Nullable FK columns (safe to leave NULL in sample data):**
- `USAGE_SESSION.completed_by_user_id` — nullable (session may not be completed)
- `MAINTENANCE_RECORD.assigned_staff_user_id` — nullable (may be unassigned)

**The status lifecycle (every transition must appear in the data):**
```
Pending  →  Approved  →  Checked In  →  Completed
         →  Rejected                 →  No-Show
         →  Cancelled
```
Every arrow in this diagram needs at least one row in the sample data.

**Exceptional cases mandated by the business rules (§5 of AGENT.md):**
- A rejected booking with a non-null `rejection_reason` in `BOOKING_APPROVAL`
- A space with `current_status = 'Under Maintenance'` (to demonstrate the trigger blocks it)
- A space with `current_status = 'Temporarily Closed'`
- A space with `current_status = 'Retired'`
- A `MAINTENANCE_RECORD` with `assigned_staff_user_id = NULL` (unassigned)
- A `No-Show` booking that has a prior `BOOKING_APPROVAL` (Approved) — without the approval record, the no-show is an invalid lifecycle state

---

## Phase 2 — Planning

Before writing any INSERT statements, produce a **Coverage Matrix** (in your
working notes) to confirm every required scenario is mapped to a specific row:

### Required User Coverage

| user_id | role | account_status | Purpose in data |
|---|---|---|---|
| U01 | Student | Active | Normal requester |
| U02 | Lecturer | Active | Normal requester |
| U03 | Teaching Assistant | Active | Normal requester |
| U04 | Facility Staff | Active | Approver, check-in staff |
| U05 | Facility Manager | Active | Approver, oversight |
| U06 | Department Administrator | Active | Admin event requester |
| U07 | Student | Suspended | Tests suspended account edge case |

Minimum 7 users. Every role must appear. At least one non-Active account.

### Required Space Coverage

| space_code | space_type | current_status | Purpose in data |
|---|---|---|---|
| SP01 | Classroom | Available | Normal bookings |
| SP02 | Computer Lab | Available | Normal bookings |
| SP03 | Meeting Room | Available | Normal bookings |
| SP04 | Auditorium | Available | Large event booking |
| SP05 | Project Lab | Under Maintenance | Tests maintenance trigger |
| SP06 | Meeting Room | Temporarily Closed | Tests closed-space rule |
| SP07 | Student Workspace | Retired | Tests retired-space rule |

Minimum 7 spaces. Every space type and every status value must appear.

### Required Booking Coverage

| booking_id | status | Has BOOKING_APPROVAL? | Has USAGE_SESSION? | Tests |
|---|---|---|---|---|
| BK01 | Completed | Yes (Approved) | Yes (full check-in + check-out) | Happy path end-to-end |
| BK02 | Completed | Yes (Approved) | Yes (full check-in + check-out) | Second completed booking (same space, different slot) |
| BK03 | Checked In | Yes (Approved) | Yes (check-in only, no check-out yet) | In-progress session |
| BK04 | Approved | Yes (Approved) | No | Future booking awaiting check-in |
| BK05 | Pending | No | No | Awaiting approval decision |
| BK06 | Rejected | Yes (Rejected, with rejection_reason) | No | Rejection rule |
| BK07 | Cancelled | No | No | User-cancelled before decision |
| BK08 | No-Show | Yes (Approved) | No | No-show — MUST have prior approval |

Minimum 8 bookings. Every status must appear. **BK08 (No-Show) must have an
approval record** — a no-show can only occur if the booking was previously approved.

### Required Maintenance Coverage

| maintenance_id | status | assigned_staff_user_id | Tests |
|---|---|---|---|
| M01 | Resolved | U04 (assigned) | Full cycle, resolved issue |
| M02 | In Progress | U04 (assigned) | Active maintenance |
| M03 | Open | NULL (unassigned) | Unassigned issue edge case |

Minimum 3 maintenance records. All 4 statuses (Open, In Progress, Resolved,
Closed) should appear; at minimum Open, In Progress, and Resolved.

---

## Phase 3 — Execution

### File structure

Produce a single `.sql` file with this section order:

```sql
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
DELETE FROM USER;
GO

-- ============================================================
-- USERS (N records — all roles + one suspended account)
-- ============================================================
INSERT INTO [USER] (...) VALUES (...);
GO

-- ============================================================
-- SPACES (N records — all types + all statuses)
-- ============================================================

-- ============================================================
-- FACILITIES (N records)
-- ============================================================

-- ============================================================
-- BOOKING REQUESTS (N records — all statuses covered)
-- ============================================================

-- ============================================================
-- BOOKING APPROVALS (N records — Approved + Rejected decisions)
-- ============================================================

-- ============================================================
-- USAGE SESSIONS (N records — Completed + Checked In)
-- ============================================================

-- ============================================================
-- MAINTENANCE RECORDS (N records — all statuses covered)
-- ============================================================
```

### INSERT rules

**Idempotency:** Always begin with DELETE statements in reverse FK order (as shown
above) so the file can be re-run during testing without errors.

**Explicit values for all NOT NULL columns:** Do not rely on DEFAULT values in
sample data — provide every value explicitly so the data is self-documenting and
readable without looking at the DDL.

**Date and time values:** Use concrete dates, not `GETDATE()`, in sample data.
This makes the data stable across test runs. Use dates in the recent past for
historical bookings (Completed, Rejected) and dates in the near future for
upcoming bookings (Approved, Pending).

**Booking ↔ Approval consistency:** For every booking with status in
`{Approved, Checked In, Completed, No-Show}`, there must be a corresponding
`BOOKING_APPROVAL` row with `decision = 'Approved'`. Without it, the booking
is in an impossible lifecycle state.

**Booking ↔ UsageSession consistency:** For every booking with status in
`{Checked In, Completed}`, there must be a corresponding `USAGE_SESSION` row.
- `Checked In`: `actual_start_time` present, `actual_end_time` NULL,
  `completed_by_user_id` NULL, `final_condition` NULL
- `Completed`: all session columns populated

**Rejection reason is mandatory:** For any `BOOKING_APPROVAL` row where
`decision = 'Rejected'`, `rejection_reason` must be a non-empty, meaningful string
(not just `'Rejected'` — explain the actual reason as a real facility manager would).

**Use readable IDs:** If IDs are VARCHAR (not IDENTITY integers), use human-readable
values like `'U001'`, `'SP001'`, `'BK001'` so sample data and query results are
easy to read during grading.

---

## Verification Loop

Before writing the result to `experiments/section_06/result_roundN.sql`, you must syntactically and logically prove the sample data works.

**Step 1: Syntax & Constraint Verification**
You must mentally execute and validate your INSERT statements to ensure they do not violate the DDL constraints built in Section 5. Check explicitly for:
* **Foreign Key Violations:** Ensure every referenced `user_id`, `space_code`, or `booking_id` exists in the parent table *before* it is referenced in a child table.
* **CHECK Constraint Violations:** Ensure all inserted statuses match the exact permitted values defined in the DDL.
* **Data Type & Size Violations:** Ensure strings fit within their `VARCHAR` limits and date formats are valid SQL strings.
* **Syntax Errors:** Verify there are no missing commas, unbalanced quotes, or omitted `GO` statements.

* **IF FAIL:** Fix the data and retry Step 1.
* **IF PASS:** Proceed to Step 2.

**Step 2: The Logical Checklist & Self-Improvement**
Once the script passes the syntax and constraint checks, verify these final business-logic constraints. You **MUST** record these results in your `experiments/section_06/improve06.md` file using the exact format defined in `improve_structure.md`. 

Copy and paste this exact checklist into the `### Verification Checklist` section of your round log:

```markdown
### Verification Checklist
* [ ] All 7 booking statuses are represented: PASS/FAIL - (Notes)
* [ ] All 6 user roles are represented: PASS/FAIL - (Notes)
* [ ] All 5 space statuses are represented: PASS/FAIL - (Notes)
* [ ] BK_NoShow has a prior Approved BOOKING_APPROVAL: PASS/FAIL - (Notes)
* [ ] All Completed bookings have a matching USAGE_SESSION: PASS/FAIL - (Notes)
* [ ] Checked In bookings have actual_end_time IS NULL: PASS/FAIL - (Notes)
* [ ] Rejected booking has a non-empty rejection_reason: PASS/FAIL - (Notes)
* [ ] DELETE statements are in strict reverse FK order: PASS/FAIL - (Notes)
* [ ] INSERT statements are in strict FK dependency order: PASS/FAIL - (Notes)
---

## Common Mistakes (from prior evaluation rounds)

1. **No-Show booking has no approval record** — A `No-Show` status can only be
   reached via the Approved state. Every No-Show booking must have a corresponding
   `BOOKING_APPROVAL` row with `decision = 'Approved'`. Without it, the lifecycle
   is invalid and queries that join bookings to approvals will miss the row.

2. **Completed booking has no approval record** — Same issue. Completed bookings
   must have gone through Approved → Checked In → Completed. An approval record
   is required.

3. **USAGE_SESSION.actual_end_time populated for a Checked In booking** — A booking
   that is `Checked In` is still in progress; `actual_end_time` should be NULL.
   Only `Completed` bookings have both times populated.

4. **Date values that make Query 5 return nothing** — Query 5 (monthly utilization)
   filters for the previous calendar month. If all completed booking dates are from
   six months ago, Query 5 returns no rows. Use dates in the most recent past month.

5. **Rejection reason is a placeholder** — `rejection_reason = 'Rejected'` or
   `rejection_reason = 'N/A'` fails the grader's eye test. Use a real reason that
   mirrors what a facility manager would actually write.

6. **Missing FACILITY rows for spaces under maintenance** — Even unavailable spaces
   still have physical facilities (the projector didn't disappear because the room
   is being repainted). Include facility rows for unavailable spaces.

7. **Suspended user makes a booking** — If a suspended user (e.g., U07) has a
   booking in the sample data, it demonstrates the system *doesn't* enforce the
   account status rule at the data layer (which is correct — it's enforced at the
   application layer). Make sure this is intentional and documented in the file
   as a comment, or avoid it if the grader might see it as an oversight.
