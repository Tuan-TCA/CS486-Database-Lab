# Skill 05: Database Implementation (SQL DDL) (Round 1 Baseline Snapshot)

# Purpose
Implement the relational database schema using SQL DDL (CREATE TABLE, PRIMARY KEY, FOREIGN KEY, CHECK, triggers) based on the logical design. Produces a single idempotent `.sql` file that can be run from scratch.

# Context Scope
- `doc/project_description.md`
- `experiments/section_03/result_round3.md` (Logical Schema)

# Methodology
1. **Dependency Order:** Define tables in dependency order (`USER` and `SPACE` first).
2. **Idempotency:** Drop tables before creating them.
3. **Table Creation:** Define columns, `PRIMARY KEY`, and `FOREIGN KEY` constraints exactly matching Section 03.
4. **CHECK Constraints:** Translate domain values into explicit `CHECK` constraints.
5. **Triggers:** Write `AFTER INSERT, UPDATE` triggers to enforce:
   - No overlapping approved bookings (Rule 1).
   - Space unavailability blocking bookings (Rule 2/3).
   - Require rejection reasons.
6. **Indexes:** Add indexes on Foreign Keys.

# Verification
1. Mentally execute and validate the SQL DDL statements to ensure they are valid T-SQL.
2. Ensure parent tables are created before child tables.
3. Ensure no missing commas or syntax errors.
