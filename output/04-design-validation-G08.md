# Database Design Validation

This document evaluates whether the relational schema correctly represents the ERD, satisfies the business rules, and uses appropriate keys, relationships, and constraints.

---

# 1. Validation of ERD Representation

The relational schema correctly represents the entities, attributes, and relationships defined in the ERD.

## Entity Validation

All seven entities from the ERD are preserved in the relational schema:

* USER
* SPACE
* FACILITY
* BOOKING_REQUEST
* BOOKING_APPROVAL
* USAGE_SESSION
* MAINTENANCE_RECORD

No entities were added or removed during the conversion from the ERD to the relational schema.

## Attribute Validation

All attributes identified in the ERD are preserved in their corresponding relations.

Examples:

* USER stores account information.
* SPACE stores information about physical spaces.
* BOOKING_REQUEST stores reservation information.
* USAGE_SESSION stores check-in and completion information.
* MAINTENANCE_RECORD stores maintenance activities.

## Relationship Validation

All ERD relationships are correctly implemented using foreign keys.

| Relationship                               | Cardinality | Relational Implementation        |
| ------------------------------------------ | ----------- | -------------------------------- |
| USER → BOOKING_REQUEST                     | 1:N         | user_id FK in BOOKING_REQUEST    |
| SPACE → BOOKING_REQUEST                    | 1:N         | space_code FK in BOOKING_REQUEST |
| SPACE → FACILITY                           | 1:N         | space_code FK in FACILITY        |
| BOOKING_REQUEST → BOOKING_APPROVAL         | 1:0..1      | UNIQUE booking_id FK             |
| USER → BOOKING_APPROVAL                    | 1:N         | decided_by_user_id FK            |
| BOOKING_REQUEST → USAGE_SESSION            | 1:0..1      | UNIQUE booking_id FK             |
| USER → USAGE_SESSION (check-in)            | 1:N         | checked_in_by_user_id FK         |
| USER → USAGE_SESSION (completion)          | 1:N         | completed_by_user_id FK          |
| SPACE → MAINTENANCE_RECORD                 | 1:N         | space_code FK                    |
| USER → MAINTENANCE_RECORD (reporter)       | 1:N         | reporter_user_id FK              |
| USER → MAINTENANCE_RECORD (assigned staff) | 1:N         | assigned_staff_user_id FK        |

### Conclusion

The relational schema correctly represents the ERD.

---

# 2. Validation of Business Rules

The database design satisfies most business rules specified in the requirements.

## Business Rules Directly Represented

The following rules are directly supported by the schema:

* Every user must have a university account.
* Every booking request belongs to one user.
* Every booking request belongs to one space.
* Every facility belongs to one space.
* Every maintenance record belongs to one space.
* Every maintenance record has a reporter and an assigned staff member.
* Approval records store decision information.
* Usage sessions store check-in and completion information.
* Historical records of bookings and maintenance activities are preserved.

## Business Rules Requiring Additional Implementation

The following rules cannot be fully represented by the relational schema alone and must be enforced during database implementation:

* Prevent overlapping approved bookings for the same space.
* Prevent booking spaces with status `under_maintenance`, `temporarily_closed`, or `retired`.
* Prevent booking spaces with active maintenance records.
* Ensure `requested_end_time > requested_start_time`.

These rules will be implemented using SQL constraints, triggers, or application logic.

### Conclusion

The design satisfies the business requirements while delegating complex business logic to the implementation stage.

---

# 3. Validation of Keys

The design uses appropriate primary keys, foreign keys, and candidate keys.

## Primary Keys

Every relation has a single, stable, and unique primary key.

| Relation           | Primary Key    |
| ------------------ | -------------- |
| USER               | user_id        |
| SPACE              | space_code     |
| FACILITY           | facility_id    |
| BOOKING_REQUEST    | booking_id     |
| BOOKING_APPROVAL   | approval_id    |
| USAGE_SESSION      | session_id     |
| MAINTENANCE_RECORD | maintenance_id |

These keys are concise, stable, and suitable for referencing from other relations.

## Candidate Keys

Additional candidate keys are used where appropriate.

| Relation         | Candidate Key(s)                    |
| ---------------- | ----------------------------------- |
| USER             | user_id, email                      |
| SPACE            | space_code, (building, room_number) |
| BOOKING_APPROVAL | approval_id, booking_id             |
| USAGE_SESSION    | session_id, booking_id              |

The remaining candidate keys support uniqueness requirements without being selected as primary keys.

## Foreign Keys

All relationships between entities are implemented using foreign keys to preserve referential integrity.

### Conclusion

The design uses appropriate keys and maintains data consistency.

---

# 4. Validation of Relationships

The relationship implementation is consistent with the ERD and business requirements.

## One-to-Many Relationships

The following relationships are correctly implemented using foreign keys:

* USER → BOOKING_REQUEST
* SPACE → BOOKING_REQUEST
* SPACE → FACILITY
* USER → BOOKING_APPROVAL
* USER → USAGE_SESSION
* SPACE → MAINTENANCE_RECORD
* USER → MAINTENANCE_RECORD

## One-to-Zero-or-One Relationships

The following relationships are implemented using UNIQUE foreign keys:

* BOOKING_REQUEST → BOOKING_APPROVAL
* BOOKING_REQUEST → USAGE_SESSION

Using UNIQUE constraints on booking_id ensures that each booking request can have at most one approval record and at most one usage session.

### Conclusion

The relationships are correctly modeled and consistent with the business requirements.

---

# 5. Validation of Constraints

The design uses appropriate constraints to maintain data integrity.

## Key Constraints

The following constraints are applied:

* PRIMARY KEY
* FOREIGN KEY
* UNIQUE
* NOT NULL

Examples:

* email is UNIQUE in USER.
* (building, room_number) is UNIQUE in SPACE.
* booking_id is UNIQUE in BOOKING_APPROVAL.
* booking_id is UNIQUE in USAGE_SESSION.

## Additional Constraints

Some constraints will be implemented during the SQL implementation phase.

Examples:

* Prevent overlapping bookings.
* Restrict booking unavailable spaces.
* Validate booking time ranges.

### Conclusion

The design applies appropriate constraints and reserves complex business logic for implementation.

---

# Overall Evaluation

The database design successfully converts the business requirements into a consistent ERD and relational schema.

Strengths:

* Correctly represents all entities and relationships.
* Uses appropriate primary, foreign, and candidate keys.
* Preserves referential integrity.
* Supports historical data preservation.
* Clearly separates structural constraints from business logic.

Limitations:

* Some business rules cannot be represented solely by a relational schema and require SQL constraints, triggers, or application logic during implementation.

Overall, the design is consistent with the requirements and is suitable for implementation in the next phase.
