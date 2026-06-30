# Skill 03: Logical Schema Design (Round 3 Snapshot)

# Purpose
To generate a comprehensive, normalized Relational Logical Schema for the Campus Space Management System that translates the Conceptual ERD into strict relational database constructs, fully capturing table-level constraints and referential integrity.

# Methodology
1. **Source of Truth Extraction:** Read `Agent.md` and the final result of Section 02 to extract the exact list of entities, attributes, and relationships. Refer to Section 01 results to retrieve explicit Domain Value Enumerations.
2. **Table Definition:** For every entity in the ERD, define a corresponding relational table.
3. **Column Definition:** Map every attribute to a column. Assign appropriate standard SQL data types (e.g., `VARCHAR`, `INT`, `TIMESTAMP`).
4. **Primary and Foreign Keys:** Explicitly define `PRIMARY KEY` and `FOREIGN KEY` constraints. **CRITICAL: All Foreign Keys MUST explicitly define `ON DELETE RESTRICT` to satisfy the "No hard deletes" requirement (Rule 10).**
5. **Unique Constraints:** Any attribute marked with `UK` in the Section 02 ERD must be translated into `UNIQUE` constraints.
6. **Domain Constraints:** Translate the enumerated domain values into explicit `CHECK` constraints.
7. **Business Rule Constraints:** Add a dedicated "Table-Level Constraints" section. Enforce time validity (e.g., `requested_end_time > requested_start_time` per Rule 4) via `CHECK` constraints, and explicitly document when multi-row validations (like Rule 1 overlapping bookings) require Triggers or Application logic.
8. **Nullability Constraints:** Define `NOT NULL` for required fields. Fields that are logically optional should remain nullable.
9. **Assumption Documentation:** Explicitly state structural inferences in an Assumptions block.

# Verification Procedure
Before finalizing the Logical Schema result:
1. Cross-check every table and column name against `Agent.md`.
2. Cross-check the Unique Constraints against the `UK` markings in Section 02.
3. Cross-check the `CHECK` constraints against the defined Domain Enumerations and Rule 4 (Time validity).
4. Verify that all Foreign Keys declare `ON DELETE RESTRICT`.
5. Verify that multi-row constraints (Rule 1) are explicitly documented as requiring Triggers.
6. Verify that no new attributes or tables were invented.
