# Skill 05: Database Implementation (SQL DDL) (Round 3 Snapshot)

*This snapshot reflects updates after the Round 2 evaluation. It matches the final, fully evolved state of `skill_05_SQL.md`.*

# Purpose
Implement the relational database schema using SQL DDL based on the logical design. Produces a single idempotent `.sql` file.

# Context Scope
- `doc/project_description.md`
- `experiments/section_03/result_round3.md` (Logical Schema)

# Methodology
1. **Dependency Order & Idempotency:** Drop and recreate tables in dependency order.
2. **Table Creation & UNIQUE:** Define tables. `UNIQUE` on `booking_id` in child tables is mandatory.
3. **Foreign Keys (ON DELETE Explicit Map):** You must apply these exact rules:
   - `assigned_staff_user_id` -> `SET NULL`
   - `BOOKING_APPROVAL.booking_id` -> `CASCADE`
   - `USAGE_SESSION.booking_id` -> `CASCADE`
   - `FACILITY.space_code` -> `CASCADE`
   - All others -> `RESTRICT`
4. **Triggers (Explicit Logic):**
   - **trg_PreventOverlappingBooking:** `status IN ('Approved', 'Checked In')`. Do NOT include 'Completed' in the *inserted* side check.
   - **trg_CheckSpaceAvailability:** Scope ONLY to `status IN ('Pending', 'Approved')`.
   - **trg_RequireRejectionReason:** Must reside on `BOOKING_REQUEST` to prevent transaction-order bypass.
   - **trg_PreventMaintenanceWithActiveBookings:** Must reside on `SPACE` to prevent orphaning approved bookings.
5. **Indexes:** Create filtered indexes for hot paths (e.g. active bookings).

# Verification Checklist
* [ ] UNIQUE on BOOKING_APPROVAL (1:1 cardinality): PASS/FAIL - (Notes)
* [ ] UNIQUE on USAGE_SESSION (1:1 cardinality): PASS/FAIL - (Notes)
* [ ] trg_CheckSpaceAvailability scoped to Pending/Approved only: PASS/FAIL - (Notes)
* [ ] trg_PreventOverlappingBooking ignores self (b.booking_id <> i.booking_id) and historical inserts: PASS/FAIL - (Notes)
* [ ] ON DELETE actions match skill map perfectly (`SET NULL` on assigned staff): PASS/FAIL - (Notes)
