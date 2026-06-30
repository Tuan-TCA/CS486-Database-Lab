# Section 02: Conceptual Database Design (ERD)

## 1. Entity-Relationship Diagram

```mermaid
erDiagram
    %% Entities and Attributes
    USER {
        string user_id PK
        string full_name
        string email
        string phone
        string role
        string department
        string account_status
    }

    SPACE {
        string space_code PK
        string space_name
        string space_type
        string building
        string floor
        string room_number
        int capacity
        string current_status
        string usage_policy
    }

    FACILITY {
        string facility_id PK
        string space_code FK
        string facility_name
        string description
    }

    BOOKING_REQUEST {
        string booking_id PK
        string user_id FK
        string space_code FK
        datetime requested_start_time
        datetime requested_end_time
        string purpose
        int expected_participants
        string booking_type
        string status
    }

    BOOKING_APPROVAL {
        string approval_id PK
        string booking_id FK
        string decided_by_user_id FK
        datetime decision_time
        string decision_note
        string rejection_reason
    }

    USAGE_SESSION {
        string session_id PK
        string booking_id FK
        datetime actual_start_time
        datetime actual_end_time
        string checked_in_by_user_id FK
        string completed_by_user_id FK
        string initial_condition
        string final_condition
        string usage_notes
    }

    MAINTENANCE_RECORD {
        string maintenance_id PK
        string space_code FK
        string reporter_user_id FK
        string assigned_staff_user_id FK
        string problem_description
        datetime start_time
        datetime completion_time
        string status
        string result_note
    }

    %% Relationships and Cardinalities
    USER ||--o{ BOOKING_REQUEST : "submits"
    SPACE ||--o{ BOOKING_REQUEST : "receives"
    SPACE ||--o{ FACILITY : "contains"
    SPACE ||--o{ MAINTENANCE_RECORD : "requires"
    USER ||--o{ BOOKING_APPROVAL : "decides"
    USER ||--o{ USAGE_SESSION : "checks_in"
    USER ||--o{ USAGE_SESSION : "completes"
    USER ||--o{ MAINTENANCE_RECORD : "reports"
    USER ||--o{ MAINTENANCE_RECORD : "assigned_to"
    BOOKING_REQUEST ||--o| BOOKING_APPROVAL : "has_decision"
    BOOKING_REQUEST ||--o| USAGE_SESSION : "has_session"
```

## 2. Assumptions & Participation Constraints

The following participation constraints are inferred to properly map the business logic into structural ERD constraints:

1. **Nullable Foreign Keys (Optional Participation on the Many side):** 
   - `USAGE_SESSION.completed_by_user_id`: A session may not be completed immediately upon check-in. Therefore, the relationship `USER ||--o{ USAGE_SESSION : "completes"` implies that while a completed session must map to exactly one user, the foreign key itself is logically optional (0..1) until the completion event occurs.
   - `MAINTENANCE_RECORD.assigned_staff_user_id`: A maintenance record is initially reported but may not be immediately assigned. The foreign key is logically optional (0..1) until assignment.
   - For simplicity and standard structural mapping in Mermaid, the `||--o{` notation is used to represent the relationship path, emphasizing that a valid target `USER` must exist when the field is populated.

2. **Zero-or-One Constraints (0..1):**
   - As mandated by the non-negotiable business rules, a `BOOKING_REQUEST` may exist without a `BOOKING_APPROVAL` (it remains pending/cancelled) and without a `USAGE_SESSION` (it was rejected or no-show). These are explicitly modeled with the `||--o|` notation to enforce the strict zero-or-one constraint on the dependent entities.

3. **Strict Relationship Separation:**
   - Multiple foreign keys referencing the same parent entity (e.g., `USER`) from the same child entity (e.g., `USAGE_SESSION`) are modeled as explicitly separate relationship lines to prevent conflation of distinct business actions (checking in vs. completing). There are exactly 11 relationships modeled.
