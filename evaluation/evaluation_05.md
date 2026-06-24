# evaluation_05.md

# Evaluation Rubric - Section 05: Database Implementation (SQL DDL)

Total Score: 10 points

This rubric evaluates whether the SQL DDL correctly implements the relational schema and business requirements.

Evaluation must compare against:

- Original project requirements
- ERD
- Logical database design

This section emphasizes technical correctness over document formatting.

---

# 1. Table Definitions (1.5 points)

Evaluate whether:

- All required tables are created.
- Table names are consistent.
- Table structures match the logical design.
- No unnecessary tables are added.

Expected tables:

- USER (or USERS if consistently used)
- SPACE
- FACILITY
- BOOKING_REQUEST
- BOOKING_APPROVAL
- USAGE_SESSION
- MAINTENANCE_RECORD

Common mistakes:

- Missing tables
- Unsupported tables
- Inconsistent naming

Scoring:

- 1.5 = Complete and accurate
- 1.0 = Minor issues
- 0.5 = Multiple minor issues
- 0.0 = Major issues

---

# 2. Data Types (1 point)

Evaluate whether:

- Appropriate data types are used.
- Attribute sizes are reasonable.
- Temporal attributes use DATETIME/TIMESTAMP appropriately.
- Numeric attributes use INT appropriately.
- Text attributes use VARCHAR/TEXT appropriately.

Examples:

Good:

- phone_number VARCHAR(20)
- capacity INT
- requested_start_time DATETIME
- usage_policy TEXT

Common mistakes:

- INT for phone numbers
- VARCHAR for timestamps
- Using TEXT for every attribute

Scoring:

- 1.0 = Complete and appropriate
- 0.5 = Minor issues
- 0.0 = Major issues

---

# 3. Primary Keys and Foreign Keys (2 points)

Evaluate whether:

- Every table has exactly one primary key.
- Foreign keys correctly implement relationships.
- Parent-child references are correct.
- Referential integrity is preserved.

Examples:

- FACILITY.space_code → SPACE(space_code)
- BOOKING_REQUEST.user_id → USER(user_id)
- BOOKING_APPROVAL.booking_id → BOOKING_REQUEST(booking_id)

Common mistakes:

- Missing FK constraints
- Incorrect references
- Wrong parent tables

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 4. Constraints and Integrity Rules (2.5 points)

Evaluate whether structural constraints are implemented correctly.

Check for:

PRIMARY KEY

FOREIGN KEY

UNIQUE

NOT NULL

CHECK

Examples:

- UNIQUE(email)
- UNIQUE(building, room_number)
- UNIQUE(booking_id)
- CHECK(requested_end_time > requested_start_time)
- CHECK(capacity > 0)

Common mistakes:

- Missing UNIQUE constraints
- Missing NOT NULL constraints
- Missing CHECK constraints
- Contradicting business requirements

Scoring:

- 2.5 = Complete and accurate
- 2.0 = Minor issues
- 1.0 = Multiple issues
- 0.0 = Major issues

---

# 5. Business Rule Implementation (2 points)

Evaluate whether business rules are implemented directly in SQL whenever possible.

Examples of implementable rules:

- requested_end_time > requested_start_time
- actual_end_time >= actual_start_time
- capacity > 0
- At most one approval per booking
- At most one usage session per booking
- Rejected bookings should have a rejection reason

Examples of rules that usually require triggers or application logic:

- Prevent overlapping approved bookings
- Prevent booking unavailable spaces
- Restrict approval permissions by role
- Restrict check-in permissions by role
- Restrict completion permissions by role

Do NOT penalize rules that cannot realistically be implemented using standard DDL if they are explicitly documented.

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions
- 0.0 = Major omissions

---

# 6. SQL Quality and Technical Correctness (1 point)

Evaluate whether:

- SQL syntax is valid.
- Table creation order is correct.
- Parent tables are created before child tables.
- Naming conventions are consistent.
- The implementation is maintainable.

Examples:

Good:

- USER before BOOKING_REQUEST
- SPACE before FACILITY

Common mistakes:

- Creating child tables first
- Duplicate constraints
- Inconsistent naming

Scoring:

- 1.0 = Complete and accurate
- 0.5 = Minor issues
- 0.0 = Major issues

---

# Technical Evaluation Checklist

Tables

□ USER / USERS

□ SPACE

□ FACILITY

□ BOOKING_REQUEST

□ BOOKING_APPROVAL

□ USAGE_SESSION

□ MAINTENANCE_RECORD

Primary Keys

□ Every table has exactly one PK

Foreign Keys

□ All FK references are correct

Unique Constraints

□ USER.email

□ SPACE(building, room_number)

□ BOOKING_APPROVAL.booking_id

□ USAGE_SESSION.booking_id

Checks

□ requested_end_time > requested_start_time

□ actual_end_time >= actual_start_time

□ capacity > 0

□ expected_participants > 0

□ floor >= 0 (if applicable)

Business Rules

□ One approval per booking

□ One usage session per booking

□ Rejected bookings contain rejection reasons (if implemented)

Execution Order

□ Parent tables before child tables

---

# General Evaluation Principles

1. Use this rubric for every experiment round.

2. Compare generated outputs against:

- Original project requirements
- ERD
- Logical database design

3. Technical correctness is more important than formatting.

4. Penalize incorrect SQL more heavily than missing comments.

5. Penalize broken referential integrity heavily.

6. Penalize contradictions with business requirements heavily.

7. Additional design decisions must be justified.

8. Small formatting inconsistencies should not significantly reduce the score.

---

# Suggested Evaluation Template

Score: __ / 10

## Strengths

- ...
- ...

## Issues

- ...
- ...

## Recommended Improvements

### Agent Improvements

- ...

### Skill Improvements

- ...

## Overall Observation

...