# Improve - Section 05: Database Implementation (SQL DDL)

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 7.5/10 | Missing UNIQUE constraints on 1:1 relationships; `trg_CheckSpaceAvailability` not scoped to active statuses, blocking historical updates | None | Add strict mandate for `UNIQUE` on `booking_id` in child tables; explicitly define trigger scope (`status IN ('Pending', 'Approved')`) |
| 2     | 8.8/10 | Incorrect `ON DELETE RESTRICT` on `assigned_staff_user_id` instead of `SET NULL`; Overlapping booking trigger incorrectly blocking on 'Completed' bookings | None | Add explicit `ON DELETE` mapping table to skill; explicitly define logic for `trg_PreventOverlappingBooking` to ignore historical states |
| 3     | 9.3/10 | Flawed CHECK constraint logic allowing end times without start times; transactional order vulnerability on rejection trigger; missing `SPACE` trigger for maintenance | None | Add strict chronological `IS NOT NULL` chaining; mandate moving rejection trigger to parent entity (`BOOKING_REQUEST`); mandate `SPACE` trigger |

---

## Round 1

### Evaluation

Score: 7.5/10

Strengths

- All 7 tables generated in correct dependency order (`USER` and `SPACE` first).
- `CHECK` constraints accurately enforce the domain value enumerations.
- Syntax is valid T-SQL; script is fully idempotent (drops tables before creating).

Issues

- **Missing UNIQUE Constraints:** Failed to include `UNIQUE (booking_id)` on `BOOKING_APPROVAL` and `USAGE_SESSION`. Without this, the 1:1 cardinality is completely broken at the physical layer, allowing multiple approvals for one booking.
- **Trigger Scope Bug:** `trg_CheckSpaceAvailability` correctly rolls back bookings for spaces that are 'Under Maintenance'. However, it fires on ALL updates. If a staff member adds a note to a 'Completed' booking from last year, and the space is currently 'Under Maintenance', the trigger rolls back the update. The trigger MUST be scoped to only fire when `status IN ('Pending', 'Approved')`.

### Improvements

Agent Updates

- None

Skill Updates

- **Require UNIQUE constraints:** Explicitly mandate that the 1:1 FKs (`booking_id`) on child tables must have `UNIQUE` constraints.
- **Define Trigger Scopes:** Add a strict scoping rule to the skill for `trg_CheckSpaceAvailability` to ensure it only validates against active state transitions.

---

## Round 2

### Evaluation

Score: 8.8/10

Strengths

- `UNIQUE` constraints successfully added to 1:1 foreign keys.
- `trg_CheckSpaceAvailability` properly scopes out historical rows.

Issues

- **Incorrect Referential Action:** `MAINTENANCE_RECORD.assigned_staff_user_id` was set to `ON DELETE RESTRICT`. Logical design and standard practice dictate this should be `SET NULL`, otherwise deleting a staff user account becomes impossible while they are assigned to old records.
- **Overlapping Booking Trigger Bug:** `trg_PreventOverlappingBooking` includes 'Completed' bookings in the *inserted* side check. This prevents historically logging a completed booking if it happens to overlap with another historical record (e.g., during a retroactive data sync).

### Improvements

Agent Updates

- None

Skill Updates

- **Explicit ON DELETE Mappings:** Add a complete mapping table to the skill defining the exact `ON DELETE` action for every single foreign key, preventing default `RESTRICT` assumptions.
- **Define Overlap Logic:** Add explicit pseudo-code logic to the skill for `trg_PreventOverlappingBooking`, ensuring that 'Completed' bookings are strictly ignored on the inserted side.
- **Add Verification Checklist:** Add a copy-pasteable Verification Checklist for the agent to explicitly sign off on these specific edge cases.

---

## Round 3

### Evaluation

Score: 9.3/10

Strengths

- Flawless SQL Server syntax.
- `SET NULL` correctly applied to `assigned_staff_user_id`.
- Filtered indexes accurately implemented.

Issues

- **Flawed CHECK Constraint Logic (Sneaky Bug):** The `CHK_SessionTime` constraint for `USAGE_SESSION` was written as `(actual_end_time IS NULL OR actual_start_time IS NULL OR actual_end_time >= actual_start_time)`. Because of the `OR`, if `actual_start_time` is NULL, the expression evaluates to TRUE, allowing `actual_end_time` to be populated without a start time! This allows a session to be completed without ever starting.
- **Transactional Ordering Vulnerability (Sneaky Bug):** `trg_RequireRejectionReason` was attached to `BOOKING_APPROVAL`, relying on a JOIN to `BOOKING_REQUEST.status`. If an application inserts the approval record *before* updating the request status to 'Rejected' (standard transaction flow), the trigger sees a 'Pending' status and bypasses validation. The trigger MUST be moved to `BOOKING_REQUEST`.
- **Missing Trigger on Parent Entity (Space):** While bookings are blocked if a space is under maintenance (`trg_CheckSpaceAvailability`), nothing prevents a `SPACE` from being updated to 'Under Maintenance' while it has active, approved bookings. This leaves a massive data integrity loophole.

### Improvements

Agent Updates

- None

Skill Updates

- **Strict Chronological Chaining:** Mandate that if an end time is provided, the start time MUST NOT be null via `CHECK (actual_end_time IS NULL OR (actual_start_time IS NOT NULL AND actual_end_time >= actual_start_time))`.
- **Move Rejection Trigger:** Mandate that `trg_RequireRejectionReason` resides on `BOOKING_REQUEST` to catch state changes safely regardless of transaction insert order.
- **Require SPACE Trigger:** Add a requirement for `trg_PreventMaintenanceWithActiveBookings` on the `SPACE` table to prevent status changes that orphan approved bookings.

---

## Overall Summary

Initial weaknesses

- Relied on generic SQL generation which missed edge-case trigger scopes (historical updates) and dropped 1:1 uniqueness guarantees.

Major improvements

- Iteratively hardened the skill to include exact logic pseudo-code for the complex triggers, an absolute map of `ON DELETE` referential actions.
- Uncovered and fixed highly complex transaction-ordering vulnerabilities and boolean logic flaws in `CHECK` constraints that would have caused silent data corruption.

Final observations

- Perfecting a Logical Schema in SQL requires anticipating the behavior of the application layer. Triggers must be placed on the table where the *state change* occurs (e.g., `BOOKING_REQUEST`), not just where the data lives, to avoid race conditions.

Final score: 9.3/10
