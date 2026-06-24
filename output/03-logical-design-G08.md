# 03-logical-design-G08

# Logical Database Design

This document converts the ERD into a relational schema by defining relations, attributes, primary keys, foreign keys, candidate keys, and key constraints.

---

# 1. Relational Schema Summary

| Relation | Primary Key | Foreign Key(s) | Candidate Key(s) |
|----------|-------------|----------------|------------------|
| USERS | user_id | - | user_id, email |
| SPACES | space_code | - | space_code, (building, room_number) |
| FACILITY | facility_id | space_code | facility_id |
| BOOKING_REQUEST | booking_id | user_id, space_code | booking_id |
| BOOKING_APPROVAL | approval_id | booking_id, decided_by_user_id | approval_id, booking_id |
| USAGE_SESSION | session_id | booking_id, checked_in_by_user_id, completed_by_user_id | session_id, booking_id |
| MAINTENANCE_RECORD | maintenance_id | space_code, reporter_user_id, assigned_staff_user_id | maintenance_id |

---

# 2. Relations

## USERS

```text
USERS(
    user_id VARCHAR(20),
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(20),
    role VARCHAR(50),
    department VARCHAR(100),
    account_status VARCHAR(30)
)
```

### Primary Key

- user_id

### Candidate Keys

- user_id
- email

### Foreign Keys

- None

### Key Constraints

- user_id is UNIQUE and NOT NULL
- email is UNIQUE and NOT NULL

---

## SPACES

```text
SPACES(
    space_code VARCHAR(20),
    space_name VARCHAR(100),
    space_type VARCHAR(50),
    building VARCHAR(50),
    floor INT,
    room_number VARCHAR(20),
    capacity INT,
    current_status VARCHAR(30),
    usage_policy TEXT
)
```

### Primary Key

- space_code

### Candidate Keys

- space_code
- (building, room_number)

### Foreign Keys

- None

### Key Constraints

- space_code is UNIQUE and NOT NULL
- (building, room_number) must be UNIQUE

---

## FACILITY

```text
FACILITY(
    facility_id VARCHAR(20),
    space_code VARCHAR(20),
    facility_name VARCHAR(100),
    description TEXT
)
```

### Primary Key

- facility_id

### Candidate Keys

- facility_id

### Foreign Keys

- space_code → SPACES(space_code)

### Key Constraints

- facility_id is UNIQUE and NOT NULL
- space_code is NOT NULL

---

## BOOKING_REQUEST

```text
BOOKING_REQUEST(
    booking_id VARCHAR(20),
    user_id VARCHAR(20),
    space_code VARCHAR(20),
    requested_start_time DATETIME,
    requested_end_time DATETIME,
    purpose TEXT,
    expected_participants INT,
    booking_type VARCHAR(50),
    status VARCHAR(30)
)
```

### Primary Key

- booking_id

### Candidate Keys

- booking_id

### Foreign Keys

- user_id → USERS(user_id)
- space_code → SPACES(space_code)

### Key Constraints

- booking_id is UNIQUE and NOT NULL
- user_id is NOT NULL
- space_code is NOT NULL

---

## BOOKING_APPROVAL

```text
BOOKING_APPROVAL(
    approval_id VARCHAR(20),
    booking_id VARCHAR(20),
    decided_by_user_id VARCHAR(20),
    decision_time DATETIME,
    decision_note TEXT,
    rejection_reason TEXT
)
```

### Primary Key

- approval_id

### Candidate Keys

- approval_id
- booking_id

### Foreign Keys

- booking_id → BOOKING_REQUEST(booking_id)
- decided_by_user_id → USERS(user_id)

### Key Constraints

- approval_id is UNIQUE and NOT NULL
- booking_id is UNIQUE and NOT NULL
- decided_by_user_id is NOT NULL

Note:

- booking_id is UNIQUE because one booking request can have at most one approval record (1:0..1).

---

## USAGE_SESSION

```text
USAGE_SESSION(
    session_id VARCHAR(20),
    booking_id VARCHAR(20),
    actual_start_time DATETIME,
    actual_end_time DATETIME,
    checked_in_by_user_id VARCHAR(20),
    completed_by_user_id VARCHAR(20),
    initial_condition TEXT,
    final_condition TEXT,
    usage_notes TEXT
)
```

### Primary Key

- session_id

### Candidate Keys

- session_id
- booking_id

### Foreign Keys

- booking_id → BOOKING_REQUEST(booking_id)
- checked_in_by_user_id → USERS(user_id)
- completed_by_user_id → USERS(user_id)

### Key Constraints

- session_id is UNIQUE and NOT NULL
- booking_id is UNIQUE and NOT NULL
- checked_in_by_user_id is NOT NULL

Note:

- booking_id is UNIQUE because one booking request can create at most one usage session (1:0..1).

---

## MAINTENANCE_RECORD

```text
MAINTENANCE_RECORD(
    maintenance_id VARCHAR(20),
    space_code VARCHAR(20),
    reporter_user_id VARCHAR(20),
    assigned_staff_user_id VARCHAR(20),
    problem_description TEXT,
    start_time DATETIME,
    completion_time DATETIME,
    status VARCHAR(30),
    result_note TEXT
)
```

### Primary Key

- maintenance_id

### Candidate Keys

- maintenance_id

### Foreign Keys

- space_code → SPACES(space_code)
- reporter_user_id → USERS(user_id)
- assigned_staff_user_id → USERS(user_id)

### Key Constraints

- maintenance_id is UNIQUE and NOT NULL
- space_code is NOT NULL
- reporter_user_id is NOT NULL
- assigned_staff_user_id is NOT NULL

---

# 3. Relationship Mapping

| Relationship | Cardinality | Implementation |
|--------------|-------------|----------------|
| USERS → BOOKING_REQUEST | 1:N | FK user_id in BOOKING_REQUEST |
| SPACES → BOOKING_REQUEST | 1:N | FK space_code in BOOKING_REQUEST |
| SPACES → FACILITY | 1:N | FK space_code in FACILITY |
| BOOKING_REQUEST → BOOKING_APPROVAL | 1:0..1 | UNIQUE FK booking_id |
| USERS → BOOKING_APPROVAL | 1:N | FK decided_by_user_id |
| BOOKING_REQUEST → USAGE_SESSION | 1:0..1 | UNIQUE FK booking_id |
| USERS → USAGE_SESSION (check-in) | 1:N | FK checked_in_by_user_id |
| USERS → USAGE_SESSION (completion) | 1:N | FK completed_by_user_id |
| SPACES → MAINTENANCE_RECORD | 1:N | FK space_code |
| USERS → MAINTENANCE_RECORD (reporter) | 1:N | FK reporter_user_id |
| USERS → MAINTENANCE_RECORD (assigned staff) | 1:N | FK assigned_staff_user_id |

---

# 4. Additional Business Constraints

The following constraints cannot be fully represented in the relational schema and will be enforced during database implementation:

- Prevent overlapping approved bookings for the same space.
- Prevent booking a space with status `under_maintenance`, `temporarily_closed`, or `retired`.
- Prevent booking a space with an active maintenance record.
- Preserve historical booking and maintenance records.