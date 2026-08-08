
## ER Diagram (Mermaid)
```mermaid
erDiagram

USERS {
    string user_id PK
    string full_name
    string email
    string phone_number
    int role_id FK
    string department
    string account_status
}

ROLES { 
        int role_id PK
        string role_name
    }

SPACES {
    string space_code PK
    string space_name
    string space_type
    string building
    int floor
    string room_number
    int capacity
    string current_status
    int nums_out_of_service___[read_only]
    int nums_advisory___[read_only]
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
    string status___[read_only]
}

BOOKING_DECISION {
    string decision_id PK
    string booking_id FK
    boolean is_approved 
    string decided_by FK
    datetime decision_time
    string decision_reason
}

USAGE_SESSION {
    string session_id PK
    string decision_id FK
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
    string impact_level
}

ADVISORY_ACKNOWLEDGEMENT {
        string booking_id FK
        string maintenance_id FK
        datetime acknowledged_at
    }
SPACE_USAGEPOLICY {
        string space_code FK
        int role_id FK  
    }


%% Relationships

ROLES ||--o{ USERS : assigned_to

SPACES ||--o{ FACILITY : contains

USERS ||--o{ BOOKING_REQUEST : submits

SPACES ||--o{ BOOKING_REQUEST : receives

ROLES ||--o{ SPACE_USAGEPOLICY : allowed_in

SPACES||--o{ SPACE_USAGEPOLICY: has

BOOKING_REQUEST ||--o| BOOKING_DECISION : requires

USERS ||--o{ BOOKING_DECISION : decide_by_staff_or_machine

BOOKING_DECISION ||--o| USAGE_SESSION : creates

USERS ||--o{ USAGE_SESSION : checks_in_by_staff

USERS ||--o{ USAGE_SESSION : completes_by_staff

SPACES ||--o{ MAINTENANCE_RECORD : has

USERS ||--o{ MAINTENANCE_RECORD : reports

USERS ||--o{ MAINTENANCE_RECORD : assigned_to_staff

BOOKING_REQUEST ||--o{ ADVISORY_ACKNOWLEDGEMENT : has
MAINTENANCE_RECORD ||--o{ ADVISORY_ACKNOWLEDGEMENT : acknowledged_in

ROLES ||--o{ USERS : assigned_to
ROLES ||--o{ SPACE_USAGEPOLICY : allowed_in
```


### Design Notes

| ID | Constraint | Purpose |
|----|------------|---------|
| **A1** | `SPACE_USAGEPOLICY (space_code, role_id)` is a **composite primary key**. | Prevent duplicate role permissions for the same space. |
| **A2** | `ADVISORY_ACKNOWLEDGEMENT (booking_id, maintenance_id)` is a **composite primary key**. | Prevent duplicate acknowledgements for the same booking and maintenance record. |
| **A3** | `BOOKING_DECISION.booking_id` is **UNIQUE**. | Ensure each booking request has at most one approval/rejection decision. |
| **A4** | `USAGE_SESSION.decision_id` is **UNIQUE**. | Ensure each approved booking creates at most one usage session. |
| **A5** | `BOOKING_REQUEST.status` is **system-maintained (read-only)**. | Status is updated automatically by business rules and workflow. |
| **A6** | `SPACES.nums_out_of_service` and `SPACES.nums_advisory` are **derived attributes** maintained automatically from active maintenance records. |