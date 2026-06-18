# 02-erd-design-G08.md

# Conceptual Database Design (ER Diagram)

## ER Diagram (Mermaid)

```mermaid
erDiagram

USER {
    string user_id PK
    string full_name
    string email
    string phone_number
    string role
    string department
    string account_status
}

SPACE {
    string space_code PK
    string space_name
    string space_type
    string building
    int floor
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


%% Relationships

SPACE ||--o{ FACILITY : contains

USER ||--o{ BOOKING_REQUEST : submits

SPACE ||--o{ BOOKING_REQUEST : receives

BOOKING_REQUEST ||--|| BOOKING_APPROVAL : has

USER ||--o{ BOOKING_APPROVAL : performs

BOOKING_REQUEST ||--|| USAGE_SESSION : creates

USER ||--o{ USAGE_SESSION : checks_in

USER ||--o{ USAGE_SESSION : completes

SPACE ||--o{ MAINTENANCE_RECORD : has

USER ||--o{ MAINTENANCE_RECORD : reports

USER ||--o{ MAINTENANCE_RECORD : assigned_to

```

# Relationship Summary

| Relationship                          | Cardinality |
| ------------------------------------- | ----------- |
| Space contains Facility               | 1 : N       |
| User submits Booking_Request          | 1 : N       |
| Space receives Booking_Request        | 1 : N       |
| Booking_Request has Booking_Approval  | 1 : 1       |
| User performs Booking_Approval        | 1 : N       |
| Booking_Request creates Usage_Session | 1 : 1       |
| User checks in Usage_Session          | 1 : N       |
| User completes Usage_Session          | 1 : N       |
| Space has Maintenance_Record          | 1 : N       |
| User reports Maintenance_Record       | 1 : N       |
| User assigned to Maintenance_Record   | 1 : N       |

# Participation Constraints

## Total Participation

- Every Booking_Request must be submitted by one User.
- Every Booking_Request must belong to one Space.

- Every Booking_Approval must belong to one Booking_Request.
- Every Booking_Approval must be performed by one User.

- Every Usage_Session must belong to one Booking_Request.
- Every Usage_Session must be checked in by one User.
- Every Usage_Session must be completed by one User.

- Every Maintenance_Record must belong to one Space.
- Every Maintenance_Record must be reported by one User.
- Every Maintenance_Record must be assigned to one User.

- Every Facility must belong to one Space.

---

## Partial Participation

### User

- A User may have zero or many Booking_Requests.
- A User may have zero or many Booking_Approvals.
- A User may have zero or many Usage_Sessions (as check-in staff).
- A User may have zero or many Usage_Sessions (as completion staff).
- A User may have zero or many Maintenance_Records (as reporter).
- A User may have zero or many Maintenance_Records (as assigned staff).

### Space

- A Space may have zero or many Facilities.
- A Space may have zero or many Booking_Requests.
- A Space may have zero or many Maintenance_Records.

### Booking_Request

- A Booking_Request may have zero or one Booking_Approval.
- A Booking_Request may create zero or one Usage_Session.

# Notes

This ERD follows the business analysis and business rules defined in Phase 1 requirements.
