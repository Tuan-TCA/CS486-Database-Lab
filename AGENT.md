# AGENT.md

This file orients any AI agent (or teammate) working in this repository. Read it
in full before touching anything in `outputs/`. It tells you what the project is,
what has already been delivered, what rules must not be broken, how to do new work,
and how to log the improvement process.

For the _methodology_ of each design step, see `skills/`. This file is
project-specific context; `skills/` files are the reusable process.

---

## 1. Project Snapshot

| Item       | Detail                                                                             |
| ---------- | ---------------------------------------------------------------------------------- |
| Project    | Shared Campus Space Booking & Facility Management System                           |
| Client     | School of Computer Science                                                         |
| Group      | G08                                                                                |
| Assignment | Database Design Project — Phase 1                                                  |
| Domain     | Booking/approval/usage/maintenance of classrooms, labs, meeting rooms, auditoriums |

The system replaces a manual spreadsheet/email process with a relational database
enforcing "no double-booking" and "no booking of unavailable spaces" at the data level.

---

## 2. Repository Layout

```
.
├── AGENT.md                        ← you are here; read first every session
├── skills/                         ← focused skills for individual sections (experiments)
│   ├── skill_01_BR.md
│   ├── skill_02_ERD.md
│   ├── skill_03_LogicalSchema.md
│   ├── skill_04_Validation.md
│   ├── skill_05_SQL.md
│   ├── skill_06_SampleData.md
│   └── skill_07_QueryDesign.md
├── outputs/                        ← graded deliverables; one file per step
│   ├── 01-business-req-analysis-G08.md
│   ├── 02-erd-design-G08.md
│   ├── 03-logical-design-G08.md
│   └── ...
├── evaluations/                    ← evaluation reports written after each output round
│   ├── evaluation-01.md            ← section-specific evaluations
│   ├── evaluation-02.md
│   └── ...
└── experiments/                    ← improvement loop logs and round results
    ├── section_01/
    │   ├── improve01.md            ← cumulative improvement log for section 1
    │   ├── result_round1.md
    │   ├── result_round2.md
    │   └── result_round3.md
    ├── section_02/
    │   ├── improve02.md            ← cumulative improvement log for section 2
    │   ├── result_round1.md
    │   ├── result_round2.md
    │   └── result_round3.md
    └── ...
```

**Output file naming convention:** `NN-short-name-G08.md` (or `.sql`), where `NN`
is the zero-padded step number. Do not rename or renumber existing files.

---

## 3. Phase 1 Task List & Status

| #   | Step                              | Deliverable                               | Status   |
| --- | --------------------------------- | ----------------------------------------- | -------- |
| 1   | Business Requirement Analysis     | `outputs/01-business-req-analysis-G08.md` | ⏳ To Do |
| 2   | Conceptual Database Design (ERD)  | `outputs/02-erd-design-G08.md`            | ⏳ To Do |
| 3   | Logical Database Design           | `outputs/03-logical-design-G08.md`        | ⏳ To Do |
| 4   | Database Design Validation        | `outputs/04-design-validation-G08.md`     | ⏳ To Do |
| 5   | Database Implementation (SQL DDL) | `outputs/05-db-definition-G08.sql`        | ⏳ To Do |
| 6   | Sample Data Preparation           | `outputs/06-sample-data-G08.sql`          | ⏳ To Do |
| 7   | Query Design                      | `outputs/07-query-design-G08.sql`         | ⏳ To Do |

Continue from any ⏳ To Do or 🔄 Experimenting item. Never silently redesign earlier decisions — call out any discovered flaw explicitly in the deliverable or in `evaluations/`.

---

## 4. Source of Truth: Entities & Keys (do not contradict)

Table names and column names must match these **byte-for-byte** across all files:

- **USER** (user_id PK, full_name, email candidate key, phone, role, department [Optional], account_status)
- **SPACE** (space_code PK, space_name, space_type, building candidate key, floor, room_number candidate key, capacity, current_status, usage_policy)
- **FACILITY** (facility_id PK, space_code FK→SPACE, facility_name, description)
- **BOOKING_REQUEST** (booking_id PK, user_id FK→USER, space_code FK→SPACE, requested_start_time, requested_end_time, purpose, expected_participants, booking_type, status)
- **BOOKING_APPROVAL** (approval_id PK, booking_id FK→BOOKING_REQUEST unique, decided_by_user_id FK→USER, decision_time, decision_note, rejection_reason)
- **USAGE_SESSION** (session_id PK, booking_id FK→BOOKING_REQUEST unique, actual_start_time, actual_end_time, checked_in_by_user_id FK→USER, completed_by_user_id FK→USER, initial_condition, final_condition, usage_notes, session_status)
- **MAINTENANCE_RECORD** (maintenance_id PK, space_code FK→SPACE, reporter_user_id FK→USER, assigned_staff_user_id FK→USER, problem_description, start_time, completion_time, status, result_note)

---

## 5. Non-Negotiable Business Rules

Every output must respect these. Steps 5–7 must enforce or demonstrate them:

1. A space cannot have two **approved** bookings with overlapping time periods.
2. A space with `current_status` in `{under_maintenance, temporarily_closed, retired}` cannot be booked.
3. A space with an **active** maintenance record cannot be booked.
4. `requested_end_time` must be strictly greater than `requested_start_time`.
5. `BOOKING_APPROVAL` and `USAGE_SESSION` are each optional (zero-or-one) per `BOOKING_REQUEST`.
6. Rejected bookings must retain a `rejection_reason`.
7. Check-in records: actual_start_time, checked_in_by_user_id, initial_condition.
8. Completion records: actual_end_time, completed_by_user_id, final_condition, usage_notes.
9. No hard deletes — all history is preserved via status fields.
10. Every user must have a university account.
11. A user is not strictly required to belong to an academic department (e.g., administrative roles).
12. A space may contain zero or more facilities, but a facility must belong to exactly one space.
13. BOOKING_REQUEST statuses are strictly for the approval lifecycle (e.g., pending, approved, rejected, cancelled). Usage lifecycle statuses (e.g., checked_in, completed, no-show) belong exclusively to the USAGE_SESSION entity.
14. ID generation standards (e.g., prefixes like 'USR-', 'SPC-') must be explicitly defined and explained in the Logical Database Design output.
15. The combination of building and room_number must be unique for every space to prevent physical duplicates in the system.

---

## 6. Established Conventions (keep consistent)

- Status value sets must match `outputs/01-business-req-analysis-G08.md` exactly — no new values.
- Markdown tables for dictionaries; Mermaid `erDiagram` for the ER diagram only.
- **Bold** = PK, _italic_ = FK in any schema notation in prose.
- Do not invent requirements; state every assumption explicitly inside the deliverable.
- Standardized System Actors: Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, Facility Manager. Do not invent new roles (e.g., System Administrators) unless explicitly requested.

---

## 7. Agent Workflow: Explore, Plan, Execute

Every time this agent begins a task — whether producing a first-round output or
improving an existing one — it must follow these phases in strict order.
**Do not skip to execution.**

### Phase 0 — Skill Retrieval (or Creation)

The methodology for every step is decoupled from this master file and stored in
the `skills/` directory (e.g., `skills/skill_05_SQL.md`).

- If the skill file for your current section **exists**, read it fully. It will
  dictate your context scope, planning format, and verification checklist.
- If the skill file **does not exist**, your _very first task_ is to write it.
  Do not begin the actual step until the methodology is formalized as a reusable
  skill document and approved by the human.

### Phase 1 — Exploration

Consult your active `skills/` file to see exactly which `outputs/` or
`evaluations/` files you are allowed to load into context.

- Do not load the entire repository.
- Read the permitted files and explicitly state out loud (in a comment block at
  the top of your working notes) what you found: confirmed entities, rules, or
  open gaps identified in prior evaluations.

### Phase 2 — Planning

Write a short plan _before_ producing the output, formatted exactly as requested
by your active skill file. The plan must be human-reviewable. A reviewer should
be able to say "yes, that approach is correct" or "no, change X" before any code
or content is written.

### Phase 3 — Execution

Apply the plan. Follow the relevant skill file for formatting conventions, edge
case handling, and technical rules. Do not deviate from the plan without noting
the change.

---

## 8. Verification Loops

The single most effective way to ensure correct output is to run a local
verification after every execution. Because every deliverable is fundamentally
different, **the specific verification checklist is located at the bottom of
each `skills/` file.**

After generating your output, you must:

1. Open the checklist in the relevant `skill_NN.md` file.
2. Mentally (or actually) run every check against your proposed output.
3. Mark each check as PASS or FAIL in your `experiments/section_N/improveN.md` log.

If any check fails: you must fix the issue before writing the final result to
`experiments/section_N/result_roundN.md` (or `.sql`). Do not write a result
file that you know is broken.

## 9. Improvement Logging Protocol

This section defines how the agent records its work across improvement rounds.

### What triggers a new round

A new round begins when:

- An evaluation file (`evaluations/evaluation-NN.md`) is placed by the human, OR
- The agent's own verification loop (§8) finds issues that require a fix.

### Where to log

Every round of work on section N must be logged in
`experiments/section_N/improveN.md`. This file is **cumulative** — never
overwrite it. Each round appends a new dated entry.

### What to log per round

```
# Improve - Section XX: <Section Name>

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | x/10  | ...         | ...           | ...           |
| 2     | x/10  | ...         | ...           | ...           |
| 3     | x/10  | ...         | ...           | ...           |

---

## Round 1

### Evaluation

Score: x/10

Strengths

* ...

Issues

* ...

### Improvements

Agent Updates

* ...

Skill Updates

* ...

---

## Round 2

### Evaluation

Score: x/10

Strengths

* ...

Issues

* ...

### Improvements

Agent Updates

* ...

Skill Updates

* ...

---

## Round 3

### Evaluation

Score: x/10

Strengths

* ...

Issues

* ...

### Improvements

Agent Updates

* ...

Skill Updates

* ...

---

## Overall Summary

Initial weaknesses

* ...

Major improvements

* ...

Final observations

* ...

Final score: x/10

---

## Rules

Agent Updates

* Hallucination
* Requirement traceability
* Naming consistency
* Output formatting
* Reasoning process
* Verification behavior

Skill Updates

* Missing entities
* Missing relationships
* Missing cardinalities
* Missing participation constraints
* Missing keys
* Incorrect SQL
* Missing edge cases

```

### Round result files

The actual SQL (or Markdown) output from each round is saved as
`experiments/section_N/result_roundN.md` (or `.sql`). The `improve` log is
the _reasoning_; the `result` file is the _artifact_. Both are required.

### When to promote a result to `outputs/`

Only promote a round's result to `outputs/` (replacing the previous version)
when the verification loop in §8 passes all checks AND the human confirms.
Never self-promote without human sign-off.

---

## 10. Context Scope Per Step

Do not load the entire repo into context on every step. Load only what is needed:

| Step                        | Files to read                                                    |
| --------------------------- | ---------------------------------------------------------------- |
| 1 — Business Requirements   | Initial project prompt/brief, `evaluations/evaluation-01.md`     |
| 2 — Conceptual Design (ERD) | `01-*`, `evaluations/evaluation-02.md`                           |
| 3 — Logical Design          | `01-*`, `02-*`, `evaluations/evaluation-03.md`                   |
| 4 — Design Validation       | `01-*`, `03-*`, `evaluations/evaluation-04.md`                   |
| 5 — DDL                     | `01-*`, `03-*`, `04-*`, `evaluations/evaluation-05.md`           |
| 6 — Sample Data             | `01-*`, `03-*`, `05-*` (the DDL), `evaluations/evaluation-06.md` |
| 7 — Queries                 | `01-*`, `03-*`, `05-*`, `06-*`, `evaluations/evaluation-07.md`   |

Loading more than this costs context window with no accuracy benefit.
