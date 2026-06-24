# Database Design Deliverables Evaluation (mq/outputs)

Based on a thorough review of the provided instructions (`AGENT.md` and `SKILL.md`) and the deliverables in the `mq/outputs` folder, here is the evaluation. The outputs severely violate the non-negotiable project constraints locked in by earlier steps, specifically those detailed in `AGENT.md`.

## 🚨 Major Violations (`AGENT.md` Consistency)

The single biggest grading risk mentioned in `SKILL.md` is **inconsistency between steps**, and unfortunately, these outputs fail this fundamentally by silently redesigning the database.

1. **Entity and Table Naming (`AGENT.md` §4)**
   * **Rule:** "Any new deliverable... must use exactly these table and column names — no renaming, no re-pluralizing, no casing changes."
   * **Violation:** The deliverables changed the casing and names of almost all entities. 
     * `USER` became `[User]`
     * `SPACE` became `Space`
     * `FACILITY` became `Facility` (and a new `Space_Facility` table was invented)
     * `BOOKING_REQUEST` became `Booking`
     * `MAINTENANCE_RECORD` became `Maintenance`
     * **Critical failure:** `USAGE_SESSION` was completely dropped as an entity. Its attributes were flattened into the `Booking` table.

2. **Column and Foreign Key Naming (`AGENT.md` §4 & §5.7)**
   * **Rule:** Must use the exact locked-in keys.
   * **Violation:** `decided_by_user_id` was renamed to `staff_id` in `Booking_Approval`. For check-in/check-out fields, `checked_in_by_user_id` was renamed to `checkin_staff_id`, and `completed_by_user_id` was completely omitted.

3. **ID Data Types (`AGENT.md` §6)**
   * **Rule:** "IDs are opaque `VARCHAR` strings (e.g., `user_id`, `booking_id`), not auto-increment integers — keep this in the DDL."
   * **Violation:** In `05-db-definition-G08.sql`, all ID columns are implemented as `INT NOT NULL IDENTITY(1,1)` instead of `VARCHAR`. The sample data uses integers (1, 2, 3) instead of the required human-readable strings (e.g., 'U001', 'BK001').

4. **Status Field Vocabularies (`AGENT.md` §6)**
   * **Rule:** Must tighten these using exact value sets named in the business analysis (e.g., `pending`, `approved`, `checked_in`, etc.).
   * **Violation:** The `CHECK` constraints in the DDL used Title Case with spaces (e.g., `'Checked In'`, `'No-Show'`) instead of the exact specified snake_case values (`'checked_in'`, `'no_show'`).

## 📝 Step-by-Step Deliverable Evaluation (`SKILL.md` Methodology)

### `04-design-validation-G08.md`
* **Fail:** Did not flag the massive schema drift (dropped tables, renamed columns, changed ID types) between Step 3 and Step 5. 
* **Pass:** Followed the general spirit of evaluating business rules and normalization, noting that overlapping bookings require a trigger rather than a plain `CHECK` constraint.

### `05-db-definition-G08.sql`
* **Fail:** Failed the naming, casing, data type, and entity preservation rules (as detailed above). 
* **Pass:** Successfully implemented all logical rules, referential integrity (`ON DELETE CASCADE`, etc.), and added the necessary `AFTER INSERT, UPDATE` triggers to enforce complex business constraints like overlap prevention and status-dependent booking blocks.

### `06-sample-data-G08.sql`
* **Fail:** Used integer IDs instead of the mandated human-readable `VARCHAR` IDs (e.g., `U001`).
* **Pass:** The data itself is realistic and covers all the required exceptional cases (rejected bookings with reasons, overlapping constraints, maintenance). It is also idempotent and safely cleans up before inserting.

### `07-query-design-G08.sql`
* **Fail:** Relies on the incorrectly named tables and columns.
* **Pass:** The formatting is perfect. It strictly follows `SKILL.md`'s required template structure: Title, Business Question, Target User, Explanation, and SQL. The queries are business-relevant, varying in complexity (JOINs, GROUP BYs, date filtering).

## Summary
While the SQL written in Steps 5, 6, and 7 is technically sound, robust, and correctly formatted, it **fails the assignment** because it ignores the established baseline schema in `AGENT.md`. To fix this, the deliverables must be rewritten to match the exact `UPPER_SNAKE_CASE` table names, `VARCHAR` keys, and the exact entity structure (including restoring `USAGE_SESSION` as its own table) dictated by the prior steps.
