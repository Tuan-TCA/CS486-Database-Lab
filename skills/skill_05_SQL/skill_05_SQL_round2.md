# Skill 05: Database Implementation (SQL DDL) (Round 2 Snapshot)

*This snapshot reflects updates after the Round 1 evaluation, explicitly addressing 1:1 constraints and trigger scopes.*

# Purpose
Implement the relational database schema using SQL DDL (CREATE TABLE, PRIMARY KEY, FOREIGN KEY, CHECK, triggers) based on the logical design. Produces a single idempotent `.sql` file that can be run from scratch.

# Context Scope
- `doc/project_description.md`
- `experiments/section_03/result_round3.md` (Logical Schema)

# Methodology
1. **Dependency Order:** Define tables in dependency order (`USER` and `SPACE` first).
2. **Idempotency:** Drop tables before creating them.
3. **Table Creation:** Define columns, `PRIMARY KEY`, and `FOREIGN KEY` constraints exactly matching Section 03.
4. **UNIQUE Constraints (CRITICAL):** The `UNIQUE` constraint on `BOOKING_APPROVAL.booking_id` and `USAGE_SESSION.booking_id` is mandatory to enforce the 1:1 cardinality.
5. **CHECK Constraints:** Translate domain values into explicit `CHECK` constraints.
6. **Triggers:** Write `AFTER INSERT, UPDATE` triggers to enforce business logic:
   - **trg_CheckSpaceAvailability (CRITICAL SCOPE):** Must be scoped ONLY to `status IN ('Pending', 'Approved')`. If not scoped, it will illegally block updates to historical/completed bookings.
   - **trg_PreventOverlappingBooking:** Prevent overlapping time periods for approved bookings.
   - **trg_RequireRejectionReason:** Enforce presence of notes on rejection.

# Verification
1. Mentally execute and validate the SQL DDL statements to ensure they are valid T-SQL.
2. Verify that 1:1 Foreign Keys possess `UNIQUE` constraints.
3. Verify that `trg_CheckSpaceAvailability` has the correct `status` scope.
