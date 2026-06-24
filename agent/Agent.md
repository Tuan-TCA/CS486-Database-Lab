# AGENT.md

This file stores global reusable knowledge for this project.

Read this file before performing any task.

This file does NOT define workflow execution, experiment logic, or approvals.

Those responsibilities belong to the prompt framework.

---

# 1. Project Snapshot

| Item | Detail |
|------|--------|
| Project | Shared Campus Space Booking & Facility Management System |
| Client | School of Computer Science |
| Group | G08 |
| Assignment | Database Design Project - Phase 1 |
| Domain | Booking, approval, usage, and maintenance of shared campus spaces |

The system replaces a manual spreadsheet and email process with a relational database that enforces business constraints at the data level.

---

# 2. Knowledge Hierarchy

Project Description

↓

AGENT.md

↓

skill_xx.md

↓

result_roundX

AGENT provides global reusable knowledge.

skill_xx provides section-specific methodology.

Results are benchmarks only.

---

# 3. Source of Truth

Unless explicitly changed by the human, these names must remain identical across all sections.

## USER

- user_id (PK)
- full_name
- email (candidate key)
- phone
- role
- department
- account_status

## SPACE

- space_code (PK)
- space_name
- space_type
- building
- floor
- room_number
- capacity
- current_status
- usage_policy

## FACILITY

- facility_id (PK)
- space_code (FK → SPACE)
- facility_name
- description

## BOOKING_REQUEST

- booking_id (PK)
- user_id (FK → USER)
- space_code (FK → SPACE)
- requested_start_time
- requested_end_time
- purpose
- expected_participants
- booking_type
- status

## BOOKING_APPROVAL

- approval_id (PK)
- booking_id (FK → BOOKING_REQUEST, unique)
- decided_by_user_id (FK → USER)
- decision_time
- decision_note
- rejection_reason

## USAGE_SESSION

- session_id (PK)
- booking_id (FK → BOOKING_REQUEST, unique)
- actual_start_time
- actual_end_time
- checked_in_by_user_id (FK → USER)
- completed_by_user_id (FK → USER)
- initial_condition
- final_condition
- usage_notes

## MAINTENANCE_RECORD

- maintenance_id (PK)
- space_code (FK → SPACE)
- reporter_user_id (FK → USER)
- assigned_staff_user_id (FK → USER)
- problem_description
- start_time
- completion_time
- status
- result_note

---

# 4. Non-Negotiable Business Rules

Every section must respect these rules.

1. A space cannot have two approved bookings with overlapping time periods.

2. Spaces with status:

- under_maintenance
- temporarily_closed
- retired

cannot be booked.

3. Spaces with active maintenance records cannot be booked.

4. requested_end_time must be greater than requested_start_time.

5. BOOKING_APPROVAL is optional and at most one per BOOKING_REQUEST.

6. USAGE_SESSION is optional and at most one per BOOKING_REQUEST.

7. Rejected bookings must preserve rejection_reason.

8. Check-in records must preserve:

- actual_start_time
- checked_in_by_user_id
- initial_condition

9. Completion records must preserve:

- actual_end_time
- completed_by_user_id
- final_condition
- usage_notes

10. Historical data must be preserved.

Do not use hard deletes.

---

# 5. Global Consistency Rules

Maintain consistency across all sections.

Always keep consistent:

- entity names
- attribute names
- relationship names
- status names
- SQL naming
- documentation terminology

Do not introduce synonyms.

Do not invent requirements.

If assumptions are necessary, explicitly state them.

---

# 6. Verification Behavior

Before finalizing any draft, verify:

- requirement coverage
- naming consistency
- relationship consistency
- business rule consistency
- documentation consistency

If inconsistencies are found:

STOP

Report them.

Do not silently change previous decisions.

---

# 7. Agent Maintenance Rules

AGENT stores global reusable knowledge.

Only store lessons that:

- apply across multiple sections
- are reusable in future tasks

Do NOT store section-specific lessons.

Do NOT:

- rewrite AGENT
- replace AGENT
- clear AGENT

Only append new knowledge.

If modification is necessary:

STOP

Warn the user.

Explain the risks.

Wait AC Agent.