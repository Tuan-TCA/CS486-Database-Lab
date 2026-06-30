# Section 02: Conceptual Database Design (ERD)

## 1. Entity-Relationship Diagram

```mermaid
erDiagram
    %% Entities and Attributes
    USER {
        user_id PK
        full_name
        email
        phone
        role
        department
        account_status
    }

    SPACE {
        space_code PK
        space_name
        space_type
        building
        floor
        room_number
        capacity
        current_status
        usage_policy
    }

    FACILITY {
        facility_id PK
        space_code FK
        facility_name
        description
    }

    BOOKING_REQUEST {
        booking_id PK
        user_id FK
        space_code FK
        requested_start_time
        requested_end_time
        purpose
        expected_participants
        booking_type
        status
    }

    BOOKING_APPROVAL {
        approval_id PK
        booking_id FK
        decided_by_user_id FK
        decision_time
        decision_note
        rejection_reason
    }

    USAGE_SESSION {
        session_id PK
        booking_id FK
        actual_start_time
        actual_end_time
        checked_in_by_user_id FK
        completed_by_user_id FK
        initial_condition
        final_condition
        usage_notes
    }

    MAINTENANCE_RECORD {
        maintenance_id PK
        space_code FK
        reporter_user_id FK
        assigned_staff_user_id FK
        problem_description
        start_time
        completion_time
        status
        result_note
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

2. **Zero-or-One Constraints (0..1):**
   - As mandated by the non-negotiable business rules, a `BOOKING_REQUEST` may exist without a `BOOKING_APPROVAL` (it remains pending/cancelled) and without a `USAGE_SESSION` (it was rejected or no-show). These are explicitly modeled with the `||--o|` notation.

3. **Strict Relationship Separation:**
   - Multiple foreign keys referencing the same parent entity (e.g., `USER`) from the same child entity (e.g., `USAGE_SESSION`) are modeled as explicitly separate relationship lines to prevent conflation of distinct business actions.
