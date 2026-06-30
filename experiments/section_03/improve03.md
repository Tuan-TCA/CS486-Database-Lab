# Improve - Section 03: Logical Schema Design

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 8.0/10 | Missing referential integrity constraints enforcing "No hard deletes" (Rule 10) | None | Mandate `ON DELETE RESTRICT` for all Foreign Keys |
| 2     | 9.0/10 | Missing table-level check constraints for time validity (`end_time > start_time`) and overlap logic | None | Mandate documentation of complex table-level constraints (CHECK for time logic, Triggers for overlaps) |
| 3     | 9.8/10 | Minor formatting polish needed | None | None |

---

## Round 1

### Evaluation

Score: 8.0/10

Strengths

- Correctly mapped all 7 entities to tables.
- Accurately applied `UNIQUE` constraints to `USER.email`, `BOOKING_APPROVAL.booking_id`, and `USAGE_SESSION.booking_id`.
- Domain enumerations successfully translated into `CHECK` constraints (e.g., Space Statuses, Booking Statuses).

Issues

- **Missing Referential Integrity:** While Foreign Keys were mapped, their referential actions (e.g., `ON DELETE`, `ON UPDATE`) were omitted. Given `Agent.md`'s strict Rule 10 ("No hard deletes. All history is preserved"), the Logical Schema MUST explicitly declare `ON DELETE RESTRICT` (or similar) on all Foreign Keys to prevent cascading deletions that would violate the audit trail requirement.

### Improvements

Agent Updates

- None

Skill Updates

- **Require ON DELETE RESTRICT:** Update the Logical Schema skill to explicitly require `ON DELETE RESTRICT` for all Foreign Keys to structurally enforce the "No hard deletes" business rule.

---

## Round 2

### Evaluation

Score: 9.0/10

Strengths

- All Foreign Keys now strictly enforce `ON DELETE RESTRICT`.

Issues

- **Missing Business Rule Constraints:** While domain enumerations were mapped to CHECK constraints, other explicit business rules were ignored in the Logical Schema. Specifically, Rule 4 (`requested_end_time > requested_start_time`) can and should be a table-level `CHECK` constraint. Additionally, Rule 1 (No overlapping approved bookings) should be explicitly noted as requiring a trigger or application-level lock, since standard relational schema cannot easily enforce it natively.

### Improvements

Agent Updates

- None

Skill Updates

- **Require Complex Constraints Section:** Update the skill to require a dedicated "Table-Level Constraints" section. This must enforce explicit `CHECK` constraints for logic like `end_time > start_time` and specify when Triggers/Application logic are required for multi-row validations (like overlapping bookings).

---

## Round 3

### Evaluation

Score: 9.8/10

Strengths

- Complete and robust relational schema.
- `ON DELETE RESTRICT` actively enforces Rule 10.
- Table-level constraints perfectly capture the time validity rules.
- Triggers for overlapping bookings are explicitly designated.

Issues

- None.

### Improvements

Agent Updates

- None

Skill Updates

- None

---

## Overall Summary

Initial weaknesses

- Failed to structurally enforce the "no hard deletes" policy via Foreign Key referential actions.
- Missed the translation of time-based business rules into table-level constraints.

Major improvements

- Integrated `ON DELETE RESTRICT` across all FKs.
- Added a dedicated section for Table-Level `CHECK` constraints and Trigger requirements to fully satisfy `Agent.md` rules.

Final observations

- A Logical Schema is not just a translation of ERD boxes; it must actively incorporate the non-negotiable business rules into relational database mechanics wherever possible.

Final score: 9.8/10
