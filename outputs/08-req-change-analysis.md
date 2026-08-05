# 08-Requirement Change Analysis

## 1. Affected Entities and Attributes

Based on the transition from the Phase 1 schema to the Phase 2 operating conditions, the following entities and attributes have been modified or introduced to support the new business logic:

* **ROLES (New Entity):** Extracted from the `USERS` table into a dedicated reference table containing `role_id` (PK) and `role_name`.

* **SPACE_USAGEPOLICY (New Entity):** Created to explicitly map which roles are allowed to use specific spaces, containing `space_code` (FK) and `role_id` (FK).

* **USERS (Updated):** The `role` string attribute was replaced with a `role_id` Foreign Key linking to the new `ROLES` table.

* **SPACES (Updated):** The string `usage_policy` was removed in favor of the `SPACE_USAGEPOLICY` mapping table.

* **BOOKING_DECISION (Replaces BOOKING_APPROVAL):** Renamed to reflect that decisions can now be made automatically by the system. It includes a new boolean `is_approved`, renames the deciding user to `decided_by` (FK), and consolidates notes into a single `decision_reason` attribute.

* **MAINTENANCE_RECORD (Updated):** Added an `impact_level` attribute to distinguish between `out-of-service` and `advisory` issues.

* **ADVISORY_ACKNOWLEDGEMENT (New Entity):** A mapping table to link a `booking_id` (FK) to a specific `maintenance_id` (FK) along with an `acknowledged_at` timestamp.

* **USAGE_SESSION (Updated):** Now references `decision_id` (FK) rather than `booking_id` directly, ensuring a session can only stem from a formalized approval decision.

---

## 2. Affected Relationships

The structural changes introduce the following new relationships to the database:

* **ROLES and USERS:** A 1:N relationship (`assigned_to`) linking roles to users.

* **ROLES and SPACE_USAGEPOLICY:** A 1:N relationship (`allowed_in`) connecting roles to the space usage rules.

* **SPACES and SPACE_USAGEPOLICY:** A 1:N relationship (`has`) tying spaces to their specific role-based policies.

* **BOOKING_REQUEST and BOOKING_DECISION:** A 1:0..1 relationship (`requires`) where a request demands a formal decision record.

* **USERS and BOOKING_DECISION:** A 1:N relationship (`decide_by_staff_machine`), showing that a decision can be tied to a staff member or a system/machine ID for instant bookings.

* **BOOKING_REQUEST and ADVISORY_ACKNOWLEDGEMENT:** A 1:N relationship (`has`) where one request can acknowledge multiple warnings.

* **MAINTENANCE_RECORD and ADVISORY_ACKNOWLEDGEMENT:** A 1:N relationship (`acknowledged_in`) where one maintenance warning can be acknowledged by multiple overlapping bookings.

---

## 3. Updated Business Rules

* **Maintenance Impact Rule:** A space under maintenance with an `out-of-service` impact level cannot be booked for any overlapping time period.

* **Maintenance Advisory Rule:** A space with an `advisory` impact level can still be booked, but the system must notify the requester of all active advisories. The user's acknowledgement of specific warnings must be recorded in the `ADVISORY_ACKNOWLEDGEMENT` table at the time of booking.

* **Maintenance Escalation:** The impact level of a maintenance record can be escalated (advisory to out-of-service) or downgraded while open. If escalated to out-of-service, the system must identify already-approved bookings that overlap the maintenance period.

* **Role-Based Usage Policy:** A user's eligibility to book a space (and potentially trigger an automatic approval) is validated by joining their `role_id` against the `SPACE_USAGEPOLICY` table.

* **Instant Booking & Unified Decision Tracking:** For selected space types, booking requests that satisfy the applicable usage policy are approved automatically at submission time. Every booking that reaches a final decision, whether through automatic approval or manual review, generates a `BOOKING_DECISION` record to ensure a consistent audit trail.

* **Strict Non-Overlap Rule:** The system must ensure that two approved bookings cannot use the same space during overlapping time periods, regardless of whether the bookings are created through instant booking or staff approval.

---

## 4. Concurrency Conflicts Caused by Booking and Approval Operations

The introduction of instant booking, automated approval, and concurrent staff operations increases the likelihood of transaction conflicts. Multiple users, facility staff, and backend processes may simultaneously access or modify the same booking or space. Without proper concurrency control, these concurrent operations may violate business rules or produce inconsistent system states.

### 4.1 Concurrent Booking Requests

Multiple users may submit booking requests for the same space and overlapping time period simultaneously. If each transaction checks availability before any competing transaction commits, all requests may observe the space as available and proceed to approval.

This race condition is most likely to occur during peak periods, particularly at the beginning of each semester, when many users compete for popular spaces within a short period of time.

Without appropriate locking or transaction isolation, conflicting overlapping bookings may be approved.

---

### 4.2 Concurrent Maintenance Updates

Booking operations may execute concurrently with maintenance updates on the same space. While one transaction is validating availability, another may create, modify, complete, or change the impact level of a maintenance record.

Without proper synchronization, a booking may be approved even though the space has just become unavailable due to maintenance, or a maintenance operation may incorrectly affect bookings that are being processed concurrently.

---

### 4.3 Concurrent Approval Workflows

Booking decisions may be processed simultaneously by different approval workflows.

These conflicts include:

- **Human ↔ Human:** multiple staff members process the same booking or competing bookings concurrently.
- **Human ↔ Machine:** a staff member manually processes a booking while the automatic approval engine is evaluating the same request.
- **Machine ↔ Machine:** multiple backend processes execute automatic booking or approval operations on the same space at the same time.

Without concurrency control, bookings may receive conflicting decisions, inconsistent approval metadata, or violate the booking policies defined by the system.