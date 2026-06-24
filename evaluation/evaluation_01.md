# evaluation_01.md

# Evaluation Rubric - Section 01: Business Requirement Analysis

Total Score: 10 points

This rubric evaluates whether the generated Business Requirement Analysis correctly extracts information from the original project description.

Evaluation must always compare against the project requirements.

---

# 1. Business Purpose (1 point)

Evaluate whether:

- The business purpose accurately summarizes the overall objective of the system.
- The purpose explains why the system is needed.
- The purpose reflects the original requirements.
- The purpose does not invent additional goals.

Scoring:

- 1.0 = Complete and accurate
- 0.5 = Partially complete
- 0.0 = Missing or incorrect

---

# 2. Actors Identification (1 point)

Evaluate whether:

- All required actors are identified.
- Actor responsibilities are correctly described.
- No unnecessary actors are invented.

Expected actors:

- Student
- Lecturer
- Teaching Assistant
- Facility Staff
- Department Administrator
- Facility Manager

Scoring:

- 1.0 = Complete and accurate
- 0.5 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# 3. Entities Identification (2 points)

Evaluate whether:

- All major entities are identified.
- Entities are derived from the requirements.
- No unnecessary entities are added.

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

# 4. Attributes Identification (2 points)

Evaluate whether:

- Attributes are extracted correctly.
- Required attributes are not missing.
- No hallucinated attributes are added.
- Additional attributes are justified by the requirements.

Examples of common issues:

- Missing required attributes.
- Adding unsupported attributes.
- Duplicating information already represented elsewhere.

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions/errors
- 0.0 = Major omissions/errors

---

# 5. Relationships and Cardinalities (2 points)

Evaluate whether:

- Relationships are correctly identified.
- Cardinalities are correct.
- Relationships follow business logic.
- Optional relationships are represented correctly (e.g. 1:0..1).

Examples:

Correct:

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

# 6. Business Rules (2 points)

Evaluate whether critical business rules are identified.

Important rules include:

- Every user must have a university account.
- No overlapping approved bookings.
- Unavailable spaces cannot be booked.
- End time must be later than start time.
- Approval information must be recorded.
- Usage session information must be recorded.
- Maintenance blocks booking.
- Historical records must be preserved.

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor omissions
- 0.0 = Major omissions

---

# General Evaluation Principles

1. Use this rubric for every experiment round.

2. Compare generated outputs only against the original project requirements.

3. Penalize hallucinated information.

4. Penalize missing business requirements more heavily than formatting issues.

5. Small formatting inconsistencies should not significantly reduce the score.

6. Requirement extraction is more important than additional design decisions.

7. Additional assumptions must be explicitly justified by the requirements.

---

# Suggested Evaluation Template

Score: \_\_ / 10

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

