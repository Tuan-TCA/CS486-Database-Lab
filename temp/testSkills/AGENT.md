# AGENT.md

This file orients any AI agent (or teammate) working in this repository. Read this
before touching anything in `outputs/`. It explains what the project is, what has
already been delivered, what rules must not be broken, and what to do next.

For the *methodology* (how to actually perform each design step, with formatting
conventions), see `SKILL.md`. This file is project-specific context; `SKILL.md` is
the reusable process.

---

## 1. Project Snapshot

| Item | Detail |
|---|---|
| Project | Shared Campus Space Booking & Facility Management System |
| Client | School of Computer Science |
| Group | G08 |
| Assignment | Database Design Project — Phase 1 |
| Domain | Booking/approval/usage/maintenance of classrooms, labs, meeting rooms, auditoriums |

The system replaces a manual, spreadsheet/email-based room-booking process with a
relational database that handles booking requests, approvals, check-in/check-out
usage sessions, maintenance tracking, and historical reporting — while enforcing
"no double-booking" and "no booking of unavailable spaces" at the data level.

## 2. Repository Layout

```
.
├── AGENT.md          ← you are here
├── SKILL.md           ← reusable database-design methodology/checklist
└── outputs/            ← all graded deliverables go here, one file per step
    ├── 01-business-req-analysis-G08.md
    ├── 02-erd-design-G08.md
    └── 03-logical-design-G08.md
```

**File naming convention** (must be preserved for every future deliverable):
`NN-short-name-G08.md`, where `NN` is the two-digit step number from the Phase 1
task list below, zero-padded, and `G08` is the group ID. Do not rename or
renumber existing files — later steps append to this sequence, they don't
reshuffle it.

## 3. Phase 1 Task List & Status

The assignment defines seven steps. Status of each, against this repo:

| # | Step | Deliverable file | Status |
|---|---|---|---|
| 1 | Business Requirement Analysis | `outputs/01-business-req-analysis-G08.md` | ✅ Done |
| 2 | Conceptual Database Design (ERD) | `outputs/02-erd-design-G08.md` | ✅ Done |
| 3 | Logical Database Design | `outputs/03-logical-design-G08.md` | ✅ Done |
| 4 | Database Design Validation | `outputs/04-design-validation-G08.md` | ⏳ Not started |
| 5 | Database Implementation (SQL DDL) | `outputs/05-implementation-ddl-G08.sql` (+ `.md` writeup) | ⏳ Not started |
| 6 | Sample Data Preparation | `outputs/06-sample-data-G08.sql` (+ `.md` writeup) | ⏳ Not started |
| 7 | Query Design (≥5 queries) | `outputs/07-queries-G08.md` | ⏳ Not started |

When picking up this project, continue from the first ⏳ item, in order. Each
later step must stay consistent with the entities, attributes, keys, and business
rules already locked in by steps 1–3 — do not silently redesign the schema.
If a flaw is found in the existing design (e.g., during Step 4 validation), call
it out explicitly and document the fix; don't change it silently.

## 4. Source of Truth: Entities & Keys (do not contradict)

Seven entities, carried consistently across all three completed deliverables:

`USER`, `SPACE`, `FACILITY`, `BOOKING_REQUEST`, `BOOKING_APPROVAL`,
`USAGE_SESSION`, `MAINTENANCE_RECORD`.

Primary/foreign keys (from `03-logical-design-G08.md`):

- **USER**(user_id PK, ..., email *candidate key*)
- **SPACE**(space_code PK, ..., building+room_number *composite candidate key*)
- **FACILITY**(facility_id PK, space_code FK→SPACE)
- **BOOKING_REQUEST**(booking_id PK, user_id FK→USER, space_code FK→SPACE)
- **BOOKING_APPROVAL**(approval_id PK, booking_id FK→BOOKING_REQUEST *unique*, decided_by_user_id FK→USER)
- **USAGE_SESSION**(session_id PK, booking_id FK→BOOKING_REQUEST *unique*, checked_in_by_user_id FK→USER, completed_by_user_id FK→USER)
- **MAINTENANCE_RECORD**(maintenance_id PK, space_code FK→SPACE, reporter_user_id FK→USER, assigned_staff_user_id FK→USER)

Any new deliverable (DDL, sample data, queries) must use exactly these table and
column names — no renaming, no re-pluralizing, no casing changes.

## 5. Non-Negotiable Business Rules

These rules were derived from the Facility Manager's requirements and must be
enforced (via constraints in Step 5, and respected by sample data in Step 6 and
queries in Step 7):

1. A space cannot have two **approved** bookings with overlapping time periods.
2. A space with `current_status` in `{under_maintenance, temporarily_closed, retired}` cannot be booked.
3. A space with an active `MAINTENANCE_RECORD` cannot be booked.
4. `requested_end_time` must be strictly greater than `requested_start_time`.
5. `BOOKING_APPROVAL` and `USAGE_SESSION` are each optional 1:1 with `BOOKING_REQUEST` (zero-or-one) — a booking may exist without an approval (e.g., still pending) and without a usage session (e.g., not yet checked in, or rejected).
6. Rejected bookings must retain a `rejection_reason`.
7. Check-in must record actual_start_time, checked_in_by_user_id, initial_condition; completion must record actual_end_time, completed_by_user_id, final_condition, usage_notes.
8. All booking and maintenance history must be preserved (no hard deletes — design should favor status fields over row removal).

When Step 4 (validation) is performed, check the schema in `03-logical-design-G08.md`
against this list item by item and flag any gap (e.g., the current schema has no
explicit mechanism preventing overlapping approved bookings beyond application
logic — this is a known open question worth flagging in validation).

## 6. Conventions Already Established (keep consistent)

- IDs are opaque `VARCHAR` strings (e.g., `user_id`, `booking_id`), not auto-increment integers — keep this in the DDL.
- Status fields (`account_status`, `current_status`, booking `status`, maintenance `status`) are free-text `VARCHAR` in the logical design; Step 5 should tighten these into `CHECK` constraints or enums using the exact value sets named in the business analysis (e.g., booking status: pending, approved, rejected, cancelled, checked_in, completed, no_show).
- Markdown tables are used for data dictionaries; Mermaid `erDiagram` syntax is used for the ER diagram.
- PK = **bold**, FK = *italic* in the relational schema notation (see `03-logical-design-G08.md` §1).

## 7. How to Continue This Project

1. Read `SKILL.md` for the methodology and formatting conventions to follow for every remaining step.
2. Re-read `outputs/01` through `outputs/03` in full before starting Step 4 — don't rely on this summary alone, it's a pointer, not a replacement.
3. Produce each remaining deliverable as its own file under `outputs/`, following the naming convention in §2.
4. Keep entity/attribute/key names byte-for-byte consistent with §4.
5. Cross-check every new deliverable against the business rules in §5.
6. Do not invent new business requirements; if something is ambiguous, note the assumption explicitly inside the deliverable rather than silently guessing.
