# Section 02: Conceptual Database Design (ERD)

## 1. Entity-Relationship Diagram

```mermaid
erDiagram
    %% Entities and Attributes
    USER {
        string user_id PK
        string full_name
        string email UK
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
        string booking_id FK, UK
        string decided_by_user_id FK
        datetime decision_time
        string decision_note
        string rejection_reason
    }

    USAGE_SESSION {
        string session_id PK
        string booking_id FK, UK
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

## 2. Explicit Relationships Summary

| Entity A | Relationship | Entity B | Cardinality | Constraint |
|----------|-------------|----------|-------------|------------|
| USER | submits | BOOKING_REQUEST | 1:N | `user_id` FK (Mandatory) |
| SPACE | receives | BOOKING_REQUEST | 1:N | `space_code` FK (Mandatory) |
| SPACE | contains | FACILITY | 1:N | `space_code` FK (Mandatory) |
| SPACE | requires | MAINTENANCE_RECORD | 1:N | `space_code` FK (Mandatory) |
| USER | decides | BOOKING_APPROVAL | 1:N | `decided_by_user_id` FK (Mandatory) |
| USER | checks_in | USAGE_SESSION | 1:N | `checked_in_by_user_id` FK (Mandatory) |
| USER | completes | USAGE_SESSION | 1:N | `completed_by_user_id` FK (Logically Optional until completion) |
| USER | reports | MAINTENANCE_RECORD | 1:N | `reporter_user_id` FK (Mandatory) |
| USER | assigned_to | MAINTENANCE_RECORD | 1:N | `assigned_staff_user_id` FK (Logically Optional until assigned) |
| BOOKING_REQUEST | has_decision | BOOKING_APPROVAL | 1:1 | `booking_id` FK, UK (Optional / 0..1) |
| BOOKING_REQUEST | has_session | USAGE_SESSION | 1:1 | `booking_id` FK, UK (Optional / 0..1) |

## 3. Assumptions & Participation Constraints

The following participation constraints are inferred to properly map the business logic into structural ERD constraints:

1. **Nullable Foreign Keys (Optional Participation on the Many side):** 
   - `USAGE_SESSION.completed_by_user_id`: A session may not be completed immediately upon check-in. Therefore, the relationship `USER ||--o{ USAGE_SESSION : "completes"` implies that while a completed session must map to exactly one user, the foreign key itself is logically optional (0..1) until the completion event occurs.
   - `MAINTENANCE_RECORD.assigned_staff_user_id`: A maintenance record is initially reported but may not be immediately assigned. The foreign key is logically optional (0..1) until assignment.
   - For structural mapping in Mermaid, `||--o{` is used to represent the path, emphasizing that when populated, a valid target `USER` must exist.

2. **Zero-or-One Constraints (0..1) and Unique Keys (UK):**
   - As mandated by the non-negotiable business rules, a `BOOKING_REQUEST` may exist without a `BOOKING_APPROVAL` (it remains pending/cancelled) and without a `USAGE_SESSION` (it was rejected or no-show). These are explicitly modeled with the `||--o|` notation.
   - Since these are 1:0..1 relationships, their respective foreign keys (`booking_id`) inside `BOOKING_APPROVAL` and `USAGE_SESSION` have been explicitly annotated as `UK` (Unique Keys).

3. **Strict Relationship Separation:**
   - Multiple foreign keys referencing the same parent entity (e.g., `USER`) from the same child entity (e.g., `USAGE_SESSION`) are modeled as explicitly separate relationship lines to prevent conflation of distinct business actions. This guarantees all 11 relationships are distinct and traceable.
