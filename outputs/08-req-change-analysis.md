
# 08-Requirement Change Analysis

## 1. Affected Entities and Attributes

Based on the transition from the Phase 1 schema to the Phase 2 operating conditions, the following entities and attributes have been modified or introduced to support the new business logic:

* **ROLES (New Entity):** Extracted from the `USERS` table into a dedicated reference table containing `role_id` (PK) and `role_name`.


* **SPACE_USAGEPOLICY (New Entity):** Created to explicitly map which roles are allowed to use specific spaces, containing `space_code` (FK) and `role_id` (FK).


* **USERS (Updated):** The `role` string attribute was replaced with a `role_id` Foreign Key linking to the new `ROLES` table.


* **SPACES (Updated):** The string `usage_policy` was removed in favor of the `SPACE_USAGEPOLICY` mapping table. Two new read-only attributes, `nums_out_of_service___[read_only]` and `nums_advisory___[read_only]`, were added to quickly track active maintenance counts.


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

* **Maintenance Impact Rule:** A space under maintenance with an `out-of-service` impact level cannot be booked for any overlapping time period. The system uses the `nums_out_of_service` count on the `SPACES` table for fast validation.


* **Maintenance Advisory Rule:** A space with an `advisory` impact level can still be booked, but the system must notify the requester of all active advisories. The user's acknowledgement of specific warnings must be recorded in the `ADVISORY_ACKNOWLEDGEMENT` table at the time of booking.


* **Maintenance Escalation:** The impact level of a maintenance record can be escalated (advisory to out-of-service) or downgraded while open. If escalated to out-of-service, the system must identify already-approved bookings that overlap the maintenance period.


* **Role-Based Usage Policy:** A user's eligibility to book a space (and potentially trigger an automatic approval) is validated by joining their `role_id` against the `SPACE_USAGEPOLICY` table.


* **Instant Booking & Unified Decision Tracking:** For selected space types, if a booking request satisfies the usage policy, it is approved automatically at submission time. All bookings, whether instantly approved or manually reviewed, generate a `BOOKING_DECISION` record to maintain a consistent audit trail.


* **Strict Non-Overlap Rule:** The system must ensure that two approved bookings cannot use the same space during overlapping time periods, regardless of whether the bookings are created through instant booking or staff approval.



---

## 4. Concurrency Conflicts Caused by Booking and Approval Operations

The introduction of instant booking combined with manual staff workflows creates high-risk concurrency conflicts.

* **The Read-Write Conflict (Race Condition):** Because users and staff may perform booking operations concurrently, multiple operations might check the availability of the same space before any single operation records its final result. Without appropriate concurrency control, conflicting overlapping bookings may be approved.


* **High-Volume Catalyst:** This conflict risk is highest at the beginning of each semester when many users submit booking requests simultaneously, causing popular spaces to receive several overlapping requests within a short time interval.


* **Trigger Count Anomalies:** High-volume concurrent updates to the `MAINTENANCE_RECORD` table could cause race conditions for the backend processes responsible for updating the `nums_out_of_service` and `nums_advisory` read-only columns on the `SPACES` table, potentially leading to inaccurate blocking mechanisms if not properly locked.



---
