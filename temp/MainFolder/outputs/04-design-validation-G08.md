# Database Design Validation

## 1. Validation Objective

This document evaluates whether the relational schema correctly represents the ERD, satisfies the business requirements, and applies appropriate keys, relationships, and integrity constraints.

The validation is performed based on three criteria:

1. Consistency between the ERD and relational schema.
2. Compliance with business rules.
3. Correct usage of keys, relationships, and constraints.

---

## 2. ERD and Relational Schema Consistency

The relational schema was compared against the ERD to ensure every entity and relationship was correctly transformed.

### Entity Mapping Validation

| ERD Entity | Relation | Validation |
|------------|----------|------------|
| User | User | ✓ |
| Space | Space | ✓ |
| Facility | Facility | ✓ |
| Booking_Request | Booking_Request | ✓ |
| Booking_Approval | Booking_Approval | ✓ |
| Usage_Session | Usage_Session | ✓ |
| Maintenance_Record | Maintenance_Record | ✓ |

Result:

- All entities defined in the ERD are represented in the relational schema.
- No entity was omitted during the transformation process.
- No redundant relation was introduced.

---

## 3. Business Rule Validation

The relational schema was evaluated against the business requirements.

| Business Rule | Implementation | Validation |
|---------------|---------------|------------|
| Every booking request belongs to one user | FK user_id in Booking_Request | ✓ |
| Every booking request belongs to one space | FK space_code in Booking_Request | ✓ |
| One booking may have one approval record | UNIQUE FK booking_id in Booking_Approval | ✓ |
| One booking may have one usage session | UNIQUE FK booking_id in Usage_Session | ✓ |
| A maintenance record belongs to one space | FK space_code in Maintenance_Record | ✓ |
| Historical records must be preserved | No cascading delete | ✓ |
| Prevent overlapping approved bookings | Requires trigger/application logic | ⚠ |
| Prevent booking unavailable spaces | Requires trigger/application logic | ⚠ |

Observations:

- Most business rules are enforced using relational constraints.
- Temporal constraints cannot be fully enforced using standard relational schema alone.

---

## 4. Key Validation

### Primary Keys

| Relation | Primary Key | Validation |
|----------|-------------|------------|
| User | user_id | ✓ |
| Space | space_code | ✓ |
| Facility | facility_id | ✓ |
| Booking_Request | booking_id | ✓ |
| Booking_Approval | approval_id | ✓ |
| Usage_Session | session_id | ✓ |
| Maintenance_Record | maintenance_id | ✓ |

### Candidate Keys

| Relation | Candidate Key | Validation |
|----------|---------------|------------|
| User | email | ✓ |
| Space | (building, room_number) | ✓ |

Result:

- Every relation has a stable primary key.
- Candidate keys are meaningful and prevent duplicate data.

---

## 5. Relationship Validation

| Relationship | Expected Cardinality | Implementation | Validation |
|--------------|--------------------|----------------|------------|
| User → Booking_Request | 1:N | FK user_id | ✓ |
| Space → Booking_Request | 1:N | FK space_code | ✓ |
| Booking_Request → Booking_Approval | 1:0..1 | UNIQUE FK booking_id | ✓ |
| Booking_Request → Usage_Session | 1:0..1 | UNIQUE FK booking_id | ✓ |
| Space → Maintenance_Record | 1:N | FK space_code | ✓ |

Result:

- Cardinalities from the ERD are preserved.
- Foreign keys correctly enforce relationships.

---

## 6. Constraint Validation

### Implemented Constraints

✓ Primary Key

✓ Foreign Key

✓ UNIQUE

✓ NOT NULL

✓ CHECK

✓ DEFAULT

### Constraints Requiring Additional Logic

The following rules cannot be fully enforced using standard SQL constraints:

1. The same space cannot have two approved bookings with overlapping time periods.

2. Spaces under maintenance, temporarily closed, or retired cannot be booked.

These rules should be implemented using database triggers, stored procedures, or application-level validation.

---

## 7. Limitations and Future Improvements

The current design satisfies most structural requirements but has limitations regarding temporal business rules.

Future improvements:

- Add triggers to detect overlapping bookings.
- Add triggers to prevent booking unavailable spaces.
- Add stored procedures to automate approval workflows.

---

## 8. Conclusion

The relational schema successfully represents the ERD and satisfies most business requirements.

The design uses appropriate primary keys, candidate keys, foreign keys, and integrity constraints while preserving all required relationships.

Complex temporal rules require additional implementation beyond standard relational constraints.