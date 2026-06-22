# Database Design Validation — G08

**Sources:** `project_description.md` and `req/business-requirement.md`

## 1. Correctness of ERD Representation

Every business concept from the requirements maps to an entity in the ERD:

| Requirement (from both sources) | Entity/Attribute | Covered |
|--------------------------------|------------------|---------|
| University account user info (ID, name, email, phone, role, department, status) | User | Yes |
| Bookable spaces (code, name, type, building, floor, room, capacity, status, policy) | Space | Yes |
| Facilities (projector, whiteboard, microphone, computer, livestreaming, AC) | Facility, Space_Facility | Yes |
| Booking requests (space, start, end, purpose, participants) | Booking | Yes |
| Booking status lifecycle (pending → ... → no-show) | Booking.status | Yes |
| Conflict prevention (no overlapping approved bookings) | Business rule (application/trigger) | Yes |
| Approval/rejection by staff | Booking_Approval | Yes |
| Check-in (actual start, staff, initial condition) | Booking (actual_start_time, checkin_staff_id, initial_condition) | Yes |
| Check-out (actual end, final condition, usage notes) | Booking (actual_end_time, final_condition, usage_notes) | Yes |
| Maintenance records (space, reporter, assigned, description, times, status, result) | Maintenance | Yes |
| Historical record keeping | All entities (no physical deletes) | Yes |
| Staff views (booking history, upcoming, maintenance, no-shows) | Queries (07) | Yes |

## 2. Business Rules Satisfaction

| Rule | Enforcement Mechanism |
|------|----------------------|
| User must have active account | `account_status` CHECK constraint; application logic checks for 'Active' before booking |
| Space only bookable if available | Application checks `current_status` before INSERT; FK ensures space exists |
| No overlapping approved bookings | Application-level check or trigger on `(space_code, requested_start, requested_end)` where status IN ('Approved','Checked In','Completed') |
| Booking must be approved/rejected by staff | Booking_Approval table with FK to User; staff role validated at application layer |
| Rejection reason required if rejected | Application enforces `rejection_reason IS NOT NULL` when `decision = 'Rejected'`; can be reinforced via trigger |
| Space under maintenance/closed/retired cannot be booked | Application checks `current_status` before INSERT |
| Check-in records actual start, staff, condition | Columns on Booking table |
| Check-out records actual end, condition, notes | Columns on Booking table |
| Historical records preserved | No DELETE operations on historical data; all rows retained with status tracking |
| Staff can view booking history, upcoming, maintenance, no-shows | Supported via SQL queries (output 07) |

## 3. Normalization

All tables satisfy 3NF (Third Normal Form):

| Table | 1NF | 2NF | 3NF | Notes |
|-------|-----|-----|-----|-------|
| User | Yes | Yes | Yes | All non-key attributes depend on user_id |
| Space | Yes | Yes | Yes | All non-key attributes depend on space_code |
| Facility | Yes | Yes | Yes | All non-key attributes depend on facility_id |
| Space_Facility | Yes | Yes | Yes | Composite PK; no partial/transitive dependencies |
| Booking | Yes | Yes | Yes | All non-key attributes depend on booking_id |
| Booking_Approval | Yes | Yes | Yes | All non-key attributes depend on approval_id; booking_id is AK |
| Maintenance | Yes | Yes | Yes | All non-key attributes depend on maintenance_id |

No denormalization was necessary. All repeating groups, partial dependencies, and transitive dependencies have been eliminated.

## 4. Key Constraints

- Every table has a primary key (either single-column IDENTITY or natural/composite key).
- Foreign keys are properly defined referencing parent tables with appropriate ON DELETE actions (RESTRICT, CASCADE, SET NULL).
- Candidate keys (User.email, Facility.facility_name, Booking_Approval.booking_id) have UNIQUE constraints.
- Composite PK (space_code, facility_id) correctly models the M:N relationship in Space_Facility.

## 5. Data Integrity

- CHECK constraints enforce domain values for all enumerated attributes (role, space_type, current_status, purpose, status, decision, maintenance status, account_status).
- NOT NULL constraints on all essential attributes.
- DEFAULT values (booking_time = GETDATE(), status = 'Pending', etc.) reduce nullable columns in new rows.
- FK constraints ensure referential integrity; no orphaned records.
- `CHECK (requested_end > requested_start)` prevents impossible time ranges.
- `CHECK (capacity > 0)`, `CHECK (expected_participants > 0)`, `CHECK (quantity > 0)` enforce positive numeric values.

## 6. Traceability Matrix

| Requirement | Trace |
|-------------|-------|
| User info (ID, name, email, phone, role, dept, status) | `project_description.md:15-32`, `business-requirement.md:10` → User |
| Space info (code, name, type, building, floor, room, capacity, status, policy) | `project_description.md:34-52`, `business-requirement.md:11` → Space |
| Facilities list per space | `project_description.md:54-63`, `business-requirement.md:12` → Facility, Space_Facility |
| Booking request fields | `project_description.md:65-81`, `business-requirement.md:13` → Booking |
| Booking status lifecycle | `project_description.md:83-91`, `business-requirement.md:14` → Booking.status |
| Overlap prevention | `project_description.md:93-94`, `business-requirement.md:14` → Application rule |
| Unavailable space prevention | `project_description.md:95`, `business-requirement.md:14` → Application rule |
| Approval/rejection by staff | `project_description.md:96-103`, `business-requirement.md:15` → Booking_Approval |
| Check-in process | `project_description.md:104-108`, `business-requirement.md:16` → Booking (check-in fields) |
| Check-out process | `project_description.md:110-114`, `business-requirement.md:16` → Booking (check-out fields) |
| Maintenance management | `project_description.md:116-136`, `business-requirement.md:17` → Maintenance |
| Historical records | `project_description.md:137`, `business-requirement.md:18` → All tables |
| Staff view capabilities | `project_description.md:138-143`, `business-requirement.md:18` → Queries in 07 |

## 7. Limitations and Risks

| Limitation | Description | Mitigation |
|------------|-------------|------------|
| Overlap detection | SQL Server has no native exclusion constraint; overlapping time ranges cannot be enforced declaratively. | Use a filtered index + application check or an AFTER INSERT/UPDATE trigger. |
| Rejection reason enforcement | CHECK constraint cannot reference another column in the same row in standard SQL Server. | Enforce via trigger or application logic. |
| No separate audit log | Historical tracking relies on row retention in existing tables rather than a dedicated audit table. | Acceptable for scope; can add audit table in future. |
| Indexing for large datasets | The index on `(space_code, requested_start, requested_end)` with filtered WHERE status IN (...) needs periodic maintenance. | Covered by the filtered index in DDL; monitor fragmentation. |
| Check-in by unauthorized staff | `checkin_staff_id` FK allows any user, not just facility staff. | Enforce role check at application layer. |
