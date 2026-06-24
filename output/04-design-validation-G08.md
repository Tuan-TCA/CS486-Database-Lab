# Database Design Validation

This document evaluates whether the relational schema correctly represents the ERD, satisfies the business requirements, and uses appropriate keys, relationships, and constraints.

---

# 1. Validation of ERD Representation

The relational schema correctly represents all entities, attributes, and relationships defined in the ERD.

## Entity Validation

All seven entities from the ERD are preserved in the relational schema.

- USERS
- SPACES
- FACILITY
- BOOKING_REQUEST
- BOOKING_APPROVAL
- USAGE_SESSION
- MAINTENANCE_RECORD

No entities were added or removed during the conversion process.

## Attribute Validation

All attributes identified during the business requirement analysis are preserved in their corresponding relations.

Examples:

- USERS stores university account information.
- SPACES stores information about physical spaces.
- BOOKING_REQUEST stores reservation information.
- BOOKING_APPROVAL stores approval decisions.
- USAGE_SESSION stores check-in and completion information.
- MAINTENANCE_RECORD stores maintenance activities.

## Relationship Validation

All ERD relationships are implemented using foreign keys.

| Relationship | Cardinality | Relational Implementation |
|--------------|-------------|--------------------------|
| USERS → BOOKING_REQUEST | 1:N | user_id FK in BOOKING_REQUEST |
| SPACES → BOOKING_REQUEST | 1:N | space_code FK in BOOKING_REQUEST |
| SPACES → FACILITY | 1:N | space_code FK in FACILITY |
| BOOKING_REQUEST → BOOKING_APPROVAL | 1:0..1 | UNIQUE booking_id FK |
| USERS → BOOKING_APPROVAL | 1:N | decided_by_user_id FK |
| BOOKING_REQUEST → USAGE_SESSION | 1:0..1 | UNIQUE booking_id FK |
| USERS → USAGE_SESSION (check-in) | 1:N | checked_in_by_user_id FK |
| USERS → USAGE_SESSION (completion) | 1:N | completed_by_user_id FK |
| SPACES → MAINTENANCE_RECORD | 1:N | space_code FK |
| USERS → MAINTENANCE_RECORD (reporter) | 1:N | reporter_user_id FK |
| USERS → MAINTENANCE_RECORD (assigned staff) | 1:N | assigned_staff_user_id FK |

### Conclusion

The relational schema correctly represents the ERD.

---

# 2. Validation of Business Requirements

The database design structurally supports the business requirements by separating structural constraints from operational business logic.

## Business Requirements Supported by the Relational Schema and SQL DDL

The following requirements are directly represented in the relational schema and SQL DDL constraints.

| Business Requirement | Implementation |
|---------------------|----------------|
| Every user must have a university account | USERS relation with a primary key and required attributes |
| Every booking request belongs to one user | FK user_id in BOOKING_REQUEST |
| Every booking request belongs to one space | FK space_code in BOOKING_REQUEST |
| Every facility belongs to one space | FK space_code in FACILITY |
| Every maintenance record belongs to one space | FK space_code in MAINTENANCE_RECORD |
| Every maintenance record has a reporter and an assigned staff member | FK reporter_user_id and assigned_staff_user_id |
| Approval records store decision information | BOOKING_APPROVAL relation |
| Usage sessions store check-in and completion information | USAGE_SESSION relation |
| Historical booking and maintenance records can be preserved | Separate entities support historical data storage |
| Booking end time must be later than booking start time | CHECK constraint |

## Business Requirements Requiring Additional Implementation

Some requirements cannot be enforced using SQL DDL alone because they require comparisons across multiple rows, multiple tables, or dynamic system states.

| Business Requirement | Why DDL Alone Is Not Sufficient | Suggested Solution |
|---------------------|--------------------------------|-------------------|
| Prevent overlapping approved bookings for the same space | Requires comparing a new booking against existing bookings | SQL trigger or application logic |
| Prevent booking spaces with status under_maintenance, temporarily_closed, or retired | Requires checking current_status in another table | SQL trigger or application logic |
| Prevent booking spaces with active maintenance records | Requires checking active records in MAINTENANCE_RECORD | SQL trigger or application logic |
| Ensure Facility Staff or Facility Managers can approve bookings | Requires checking the role of another user | SQL trigger or application logic |
| Ensure only approved bookings can create usage sessions | Requires checking booking status before creating a session | SQL trigger or application logic |

## Why These Requirements Cannot Be Enforced by DDL Alone

SQL DDL constraints are limited to structural validation.

DDL can enforce:

- PRIMARY KEY
- FOREIGN KEY
- UNIQUE
- NOT NULL
- CHECK constraints within a row

However, DDL cannot:

- Compare a new row against existing rows.
- Read values from another table inside a CHECK constraint.
- Validate role-based permissions.
- Enforce dynamic operational rules.

These requirements would require SQL triggers or application-level implementation in a complete production system.

### Conclusion

The database design structurally supports all business requirements while recognizing that some operational rules require mechanisms beyond SQL DDL.

---

# 3. Validation of Keys

The design uses appropriate primary keys, foreign keys, and candidate keys.

## Primary Keys

Every relation has a stable and unique primary key.

| Relation | Primary Key |
|----------|-------------|
| USERS | user_id |
| SPACES | space_code |
| FACILITY | facility_id |
| BOOKING_REQUEST | booking_id |
| BOOKING_APPROVAL | approval_id |
| USAGE_SESSION | session_id |
| MAINTENANCE_RECORD | maintenance_id |

These keys are concise, stable, and suitable for referencing.

## Candidate Keys

Additional candidate keys are defined where appropriate.

| Relation | Candidate Key(s) |
|----------|-----------------|
| USERS | user_id, email |
| SPACES | space_code, (building, room_number) |
| BOOKING_APPROVAL | approval_id, booking_id |
| USAGE_SESSION | session_id, booking_id |

These candidate keys satisfy uniqueness requirements without being selected as primary keys.

## Foreign Keys

All relationships are implemented using foreign keys to preserve referential integrity.

### Conclusion

The design uses appropriate keys and maintains data consistency.

---

# 4. Validation of Relationships

The relationship implementation is consistent with both the ERD and the business requirements.

## One-to-Many Relationships

The following relationships are correctly implemented:

- USERS → BOOKING_REQUEST
- SPACES → BOOKING_REQUEST
- SPACES → FACILITY
- USERS → BOOKING_APPROVAL
- USERS → USAGE_SESSION
- SPACES → MAINTENANCE_RECORD
- USERS → MAINTENANCE_RECORD

## One-to-Zero-or-One Relationships

The following relationships are implemented using UNIQUE foreign keys:

- BOOKING_REQUEST → BOOKING_APPROVAL
- BOOKING_REQUEST → USAGE_SESSION

Using UNIQUE constraints on booking_id guarantees that each booking request can have at most one approval record and at most one usage session.

### Conclusion

The relationships are correctly modeled.

---

# 5. Validation of Constraints

The design uses appropriate constraints to maintain data integrity.

## Constraints Used

The following constraints are applied:

- PRIMARY KEY
- FOREIGN KEY
- UNIQUE
- NOT NULL
- CHECK

Examples:

- email is UNIQUE in USERS.
- (building, room_number) is UNIQUE in SPACES.
- booking_id is UNIQUE in BOOKING_APPROVAL.
- booking_id is UNIQUE in USAGE_SESSION.
- requested_end_time > requested_start_time.

## Constraints Requiring Additional Mechanisms

The following constraints require triggers or application logic:

- Prevent overlapping bookings.
- Restrict booking unavailable spaces.
- Restrict booking spaces under active maintenance.
- Restrict unauthorized users from approving bookings.
- Restrict creating usage sessions for unapproved bookings.

### Conclusion

The design appropriately separates structural constraints from operational business logic.

---

# Overall Evaluation

The database design successfully converts the business requirements into a consistent ERD and relational schema.

Strengths:

- Correctly represents all entities and relationships.
- Uses appropriate primary, foreign, and candidate keys.
- Preserves referential integrity.
- Supports historical data storage.
- Distinguishes between DDL constraints and operational business rules.

Limitations:

- Some business requirements cannot be enforced solely by relational schema definitions and require triggers or application-level implementation.

Overall, the design is consistent with the requirements and is suitable for SQL implementation.