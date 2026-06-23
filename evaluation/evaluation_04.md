# evaluation_04.md

# Evaluation Rubric - Section 04: Database Design Validation

Total Score: 10 points

This rubric evaluates whether the validation document correctly analyzes and justifies the quality of the relational database design.

Evaluation must compare against:

- The original project requirements
- The ERD
- The logical database design

This section evaluates the quality of the validation process itself, not the database design alone.

---

# 1. Validation of ERD Representation (2 points)

Evaluate whether the document verifies:

- All ERD entities are represented in the relational schema.
- Attributes are preserved correctly.
- Relationships are preserved correctly.
- Cardinalities are preserved correctly.
- The validation provides explicit justification.

Examples:

Good:

- "BOOKING_REQUEST → BOOKING_APPROVAL (1:0..1) is implemented using a UNIQUE foreign key."

Poor:

- "The ERD is correct."

Scoring:

- 2.0 = Complete and well justified
- 1.0 = Partially justified
- 0.0 = Missing or incorrect

---

# 2. Validation of Business Rules (2 points)

Evaluate whether the document verifies:

- Which business rules are directly supported.
- Which business rules require additional implementation.
- Why certain rules cannot be enforced structurally.
- Appropriate solutions are proposed.

Examples of operational rules:

- Prevent overlapping bookings
- Restrict unavailable spaces
- Restrict active maintenance spaces
- Restrict unauthorized approvals
- Restrict invalid usage sessions

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# 3. Validation of Keys (2 points)

Evaluate whether the document verifies:

- Primary keys
- Candidate keys
- Foreign keys
- Uniqueness requirements
- Referential integrity

Examples:

- USER.email
- SPACE(building, room_number)
- BOOKING_APPROVAL.booking_id
- USAGE_SESSION.booking_id

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 4. Validation of Relationships (2 points)

Evaluate whether the document verifies:

- One-to-many relationships
- One-to-zero-or-one relationships
- Relationship implementation methods
- Consistency with the ERD

Examples:

Correct:

- USER → BOOKING_REQUEST
- SPACE → BOOKING_REQUEST
- BOOKING_REQUEST → BOOKING_APPROVAL

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 5. Validation of Constraints (2 points)

Evaluate whether the document verifies:

- PRIMARY KEY usage
- FOREIGN KEY usage
- UNIQUE usage
- NOT NULL usage
- CHECK usage
- Constraints requiring triggers or application logic

Examples:

Structural constraints:

- email UNIQUE
- booking_id UNIQUE
- requested_end_time > requested_start_time

Operational constraints:

- Prevent overlapping bookings
- Restrict unavailable spaces
- Restrict unauthorized approvals

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# General Evaluation Principles

1. Use this rubric for every experiment round.

2. Compare generated outputs only against:

- Original project requirements
- ERD
- Logical database design

3. Validation quality is more important than document length.

4. Explanations and justifications are more important than simply listing items.

5. Distinguish structural constraints from operational business rules.

6. Penalize unsupported claims.

7. Small formatting issues should not significantly reduce the score.

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