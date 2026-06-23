# evaluation_03.md

# Evaluation Rubric - Section 03: Logical Database Design

Total Score: 10 points

This rubric evaluates whether the generated logical database design correctly converts the ERD into a relational schema.

Evaluation must always compare against the original project requirements and the conceptual ERD.

---

# 1. Relations (2 points)

Evaluate whether:

- All required relations are present.
- Relations correctly correspond to ERD entities.
- No unnecessary relations are invented.

Expected relations:

- USER
- SPACE
- FACILITY
- BOOKING_REQUEST
- BOOKING_APPROVAL
- USAGE_SESSION
- MAINTENANCE_RECORD

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# 2. Attributes (2 points)

Evaluate whether:

- Attributes are correctly assigned to their relations.
- Required attributes are not missing.
- Attributes are consistent with the ERD.
- Additional attributes are justified.
- No duplicated attributes exist.

Common issues:

- Missing attributes
- Hallucinated attributes
- Incorrect attribute placement

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# 3. Primary Keys and Candidate Keys (2 points)

Evaluate whether:

- Every relation has an appropriate primary key.
- Candidate keys are correctly identified.
- Unique business identifiers are recognized.
- Optional 1:0..1 relationships are properly converted.

Examples:

Correct candidate keys:

- USER.email
- SPACE(building, room_number)
- BOOKING_APPROVAL.booking_id
- USAGE_SESSION.booking_id

Common mistakes:

- Missing candidate keys
- Declaring non-unique attributes as candidate keys
- Missing UNIQUE constraints for 1:0..1 mappings

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 4. Foreign Keys (2 points)

Evaluate whether:

- Foreign keys correctly represent ERD relationships.
- Foreign keys reference the correct parent relation.
- Foreign keys are placed in the appropriate child relation.

Expected foreign keys include:

- FACILITY.space_code
- BOOKING_REQUEST.user_id
- BOOKING_REQUEST.space_code
- BOOKING_APPROVAL.booking_id
- BOOKING_APPROVAL.decided_by_user_id
- USAGE_SESSION.booking_id
- USAGE_SESSION.checked_in_by_user_id
- USAGE_SESSION.completed_by_user_id
- MAINTENANCE_RECORD.space_code
- MAINTENANCE_RECORD.reporter_user_id
- MAINTENANCE_RECORD.assigned_staff_user_id

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 5. Key Constraints (2 points)

Evaluate whether:

- NOT NULL constraints are correctly identified.
- UNIQUE constraints are correctly identified.
- 1:0..1 relationships are enforced appropriately.
- Constraints are consistent with business requirements.

Examples:

Correct:

- USER.email is UNIQUE
- SPACE(building, room_number) is UNIQUE
- BOOKING_APPROVAL.booking_id is UNIQUE
- USAGE_SESSION.booking_id is UNIQUE

Common mistakes:

- Missing UNIQUE constraints
- Overusing NOT NULL constraints
- Contradicting business requirements

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# General Evaluation Principles

1. Use this rubric for every experiment round.

2. Compare generated outputs only against the original project requirements and ERD.

3. Penalize hallucinated relations, attributes, and keys.

4. Penalize missing business requirements more heavily than formatting issues.

5. Logical correctness is more important than presentation style.

6. Additional design decisions must be explicitly justified.

7. Business rules that cannot be fully represented in a relational schema should not be penalized if documented separately.

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