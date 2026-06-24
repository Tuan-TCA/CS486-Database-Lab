# evaluation_06.md

# Evaluation Rubric - Section 06: Sample Data Preparation

Total Score: 10 points

This rubric evaluates whether the sample data is realistic, consistent, and sufficiently comprehensive to test the database system.

Evaluation must compare against:

- Original project requirements
- ERD
- Logical database design
- SQL DDL implementation

This section emphasizes data quality and test coverage rather than data quantity.

---

# 1. Data Coverage (2 points)

Evaluate whether sample data is provided for all required tables.

Expected tables:

- USERS
- SPACE
- FACILITY
- BOOKING_REQUEST
- BOOKING_APPROVAL
- USAGE_SESSION
- MAINTENANCE_RECORD

Evaluate whether:

- Every table contains data.
- The amount of data is sufficient for testing.
- No table is left empty without justification.

Scoring:

- 2.0 = Complete and sufficient
- 1.0 = Minor omissions
- 0.0 = Major omissions

---

# 2. Referential Integrity (2 points)

Evaluate whether inserted data satisfies all foreign key relationships.

Examples:

- FACILITY.space_code references an existing SPACE.
- BOOKING_REQUEST.user_id references an existing USERS.
- BOOKING_APPROVAL.booking_id references an existing BOOKING_REQUEST.
- USAGE_SESSION.booking_id references an existing BOOKING_REQUEST.
- MAINTENANCE_RECORD.reporter_user_id references an existing USERS.

Common mistakes:

- Referencing non-existent IDs.
- Inserting child records before parent records.
- Inconsistent relationships.

Scoring:

- 2.0 = Complete and accurate
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 3. Realism and Business Consistency (2 points)

Evaluate whether the sample data is realistic.

Check for:

Users

- Realistic names
- Appropriate roles
- Valid departments

Spaces

- Realistic buildings
- Appropriate room numbers
- Reasonable capacities

Bookings

- Realistic schedules
- Reasonable participant counts
- Appropriate purposes

Maintenance

- Realistic maintenance problems

Common mistakes:

- Random placeholder values
- Unrealistic timestamps
- Inconsistent statuses

Scoring:

- 2.0 = Realistic and consistent
- 1.0 = Minor issues
- 0.0 = Major issues

---

# 4. Normal Operations Coverage (2 points)

Evaluate whether the data supports normal system operations.

Examples:

- Different user roles exist.
- Multiple spaces exist.
- Spaces have facilities.
- Bookings are created.
- Approvals exist.
- Usage sessions exist.
- Maintenance records exist.

The data should support everyday scenarios.

Scoring:

- 2.0 = Complete coverage
- 1.0 = Partial coverage
- 0.0 = Major omissions

---

# 5. Important Exceptional Cases Coverage (2 points)

Evaluate whether important edge cases are represented.

Examples:

Booking cases:

- Pending booking
- Approved booking
- Rejected booking
- Cancelled booking
- No-show booking

Space cases:

- Under maintenance
- Temporarily closed
- Retired

Maintenance cases:

- Active maintenance
- Completed maintenance

Optional relationship cases:

- Booking without approval
- Booking without usage session

Evaluate whether the sample data can be used to test business rules.

Scoring:

- 2.0 = Complete coverage
- 1.0 = Partial coverage
- 0.0 = Major omissions

---

# Technical Evaluation Checklist

USERS

□ Multiple roles exist

SPACE

□ Multiple space types exist

□ Multiple statuses exist

FACILITY

□ Multiple facility types exist

BOOKING_REQUEST

□ Pending booking exists

□ Approved booking exists

□ Rejected booking exists

□ Cancelled booking exists

□ No-show booking exists

BOOKING_APPROVAL

□ Approved decisions exist

□ Rejected decisions exist

USAGE_SESSION

□ At least one completed session exists

□ At least one booking without a usage session exists

MAINTENANCE_RECORD

□ Active maintenance exists

□ Completed maintenance exists

Optional Relationship Coverage

□ Booking without approval

□ Booking without usage session

---

# General Evaluation Principles

1. Use this rubric for every experiment round.

2. Compare generated outputs against:

- Original project requirements
- ERD
- Logical database design
- SQL DDL implementation

3. Data quality is more important than data quantity.

4. Penalize inconsistent data heavily.

5. Penalize broken referential integrity heavily.

6. Reward data that can effectively test business rules.

7. Do not reward inserting large amounts of repetitive data.

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