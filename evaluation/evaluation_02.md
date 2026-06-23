# evaluation_02.md

# Evaluation Rubric - Section 02: Conceptual Database Design (ERD)

Total Score: 10 points

This rubric evaluates whether the generated ERD correctly models the business requirements.

Evaluation must always compare against the original project requirements.

---

# 1. Main Entities (2 points)

Evaluate whether:

- All required entities are included.
- No important entities are missing.
- No unnecessary entities are invented.

Expected entities:

- User
- Space
- Facility
- Booking_Request
- Booking_Approval
- Usage_Session
- Maintenance_Record

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# 2. Attributes (2 points)

Evaluate whether:

- Attributes are correctly assigned to their entities.
- Required attributes are not missing.
- Attributes are derived from the requirements.
- Additional attributes are justified.
- No duplicated attributes exist.

Examples of common issues:

- Missing attributes
- Hallucinated attributes
- Incorrect attribute placement

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# 3. Relationships (2 points)

Evaluate whether:

- Relationships correctly represent business requirements.
- Relationships connect the appropriate entities.
- Relationship names are meaningful.
- No unnecessary relationships are added.

Examples:

Correct relationships include:

- Space contains Facility
- User submits Booking_Request
- Space receives Booking_Request
- Booking_Request has Booking_Approval
- Booking_Request creates Usage_Session
- Space has Maintenance_Record

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 4. Cardinalities (2 points)

Evaluate whether:

- Cardinalities are correct.
- Optional relationships are represented correctly.
- Business logic is preserved.

Examples:

Correct:

- Space → Facility = 1:N
- Booking_Request → Booking_Approval = 1:0..1
- Booking_Request → Usage_Session = 1:0..1

Common mistakes:

- Using 1:N instead of 1:0..1
- Reversing cardinalities
- Making optional relationships mandatory

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 5. Participation Constraints (2 points)

Evaluate whether:

- Total participation is identified correctly.
- Partial participation is identified correctly.
- Participation constraints are consistent with business requirements.
- Optional relationships are represented correctly.

Examples:

Total participation:

- Facility → Space
- Booking_Request → User
- Booking_Request → Space
- Booking_Approval → Booking_Request
- Usage_Session → Booking_Request
- Maintenance_Record → Space

Partial participation:

- User → Booking_Request
- User → Booking_Approval
- Space → Maintenance_Record
- Booking_Request → Booking_Approval
- Booking_Request → Usage_Session

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# General Evaluation Principles

1. Use this rubric for every experiment round.

2. Compare generated outputs only against the original project requirements.

3. Penalize hallucinated entities, attributes, and relationships.

4. Penalize missing business requirements more heavily than formatting issues.

5. Small Mermaid syntax or diagram formatting issues should not significantly reduce the score.

6. Conceptual correctness is more important than diagram appearance.

7. Additional assumptions must be explicitly justified by the requirements.

8. Business rules that cannot be fully represented in an ERD should not be penalized if documented separately.

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