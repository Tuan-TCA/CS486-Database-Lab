# Skill 02: Conceptual Database Design (ERD)

# Purpose
To generate a comprehensive and accurate Entity-Relationship Diagram (ERD) for the Campus Space Management System that visually models all entities, attributes, relationships, cardinalities, and participation constraints, strictly adhering to the established source of truth without hallucinating database-level data types.

# Methodology
1. **Source of Truth Extraction:** Read `Agent.md` and the final result of Section 01 (`result_round3.md`) to extract the exact list of entities, attributes, relationships, and cardinalities.
2. **Mermaid Diagram Generation:** Use Mermaid JS `erDiagram` syntax to construct the ERD. 
3. **Entity Definition:** Define all 7 entities exactly as named in `Agent.md`.
4. **Attribute Listing:** List all attributes under each entity in the Mermaid diagram. Annotate Primary Keys (`PK`) and Foreign Keys (`FK`). If an attribute is marked as `unique` or `candidate key` in `Agent.md`, annotate it as `UK` (Unique Key). Do NOT include data types (e.g., `string`, `int`).
5. **Relationship Mapping:** Map every relationship explicitly listed in Section 3.5 of `result_round3.md`.
6. **Participation Constraints:** Determine and visualize mandatory vs. optional participation constraints based on the business rules (e.g., `BOOKING_APPROVAL` is optional for a `BOOKING_REQUEST` (0..1)).
7. **Diagram Clarity:** Keep the diagram clean and well-structured to avoid overlapping relationship lines where possible.
8. **Explicit Relationship Table:** Create a dedicated Markdown table summarizing all 11 relationships (Entity A, Relationship, Entity B, Cardinality) beneath the ERD.
9. **Assumption Documentation:** If any participation constraint is inferred rather than explicitly stated, document it beneath the diagram in an Assumptions list.

# Checklist
- [ ] Are all 7 entities included in the ERD?
- [ ] Do entity and attribute names match `Agent.md` byte-for-byte?
- [ ] Are all hallucinated data types (string, int, etc.) removed from the ERD attributes?
- [ ] Are Primary Keys (PK) and Foreign Keys (FK) properly annotated in the ERD?
- [ ] Are unique foreign keys (e.g., in `BOOKING_APPROVAL` and `USAGE_SESSION`) marked with `UK`?
- [ ] Are there exactly 11 distinct relationships modeled, both in the ERD and in a dedicated Markdown table?
- [ ] Are distinct foreign keys pointing to the same entity modeled as separate, distinct relationship lines?
- [ ] Are cardinalities (1:N, 1:1) accurately represented using Mermaid syntax?
- [ ] Are participation constraints (mandatory vs. optional) accurately represented?
- [ ] Are inferred constraints documented in an Assumptions section?

# Verification Procedure
Before finalizing the ERD result:
1. Cross-check every entity and attribute in the Mermaid diagram against `Agent.md` Section 3. Verify no data types exist.
2. Cross-check every relationship in the Mermaid diagram against `result_round3.md` Section 3.5.
3. Count the relationships in the ERD and the Relationship Table to ensure there are exactly 11.
4. Verify that the Mermaid syntax compiles correctly and uses the proper symbols for cardinalities (`\|\|--o{` or `\|\|--o\|`).
5. If inconsistencies are found, STOP, fix the diagram, and re-verify.

# Common Mistakes
- **Conflating multiple relationships:** Merging two distinct foreign keys into a single relationship line.
- **Hallucinating Data Types:** Adding `varchar`, `string`, `int`, or `datetime` to the ERD attributes. `Agent.md` doesn't define these for the Conceptual design.
- **Missing UK annotations:** Forgetting to mark the 1:1 foreign keys as Unique Keys (`UK`).
- **Incorrect Mermaid Syntax:** Using invalid characters or unsupported attribute annotations in Mermaid.
- **Missing Participation Indicators:** Failing to show that a `BOOKING_APPROVAL` is optional (0..1) rather than mandatory (1..1).

# Consistency Rules
- Entity names must be UPPERCASE (e.g., `USER`, `SPACE`).
- Attribute names must be snake_case, matching `Agent.md` exactly.
- Relationship labels in Mermaid should briefly describe the action/role.
- Never introduce synonyms for entities or attributes.

# Anti-Hallucination Rules
- Do NOT add any entities not present in `Agent.md`.
- Do NOT add any attributes not present in `Agent.md`.
- Do NOT add any data types to the ERD.
- Do NOT add any relationships not present in `result_round3.md` Section 3.5.

# Lessons Integrated
- **Round 1 (improve02):** Explicit relationships and cardinalities are crucial and must not be conflated.
- **Round 1 (improve02):** We must not modify the schema defined in `Agent.md` or hallucinate data types. ERD should only show attribute names and constraints (`PK`, `FK`).
- **Round 2 (improve02):** Added `UK` annotations for 1:1 relationships, and a dedicated Relationship summary table for traceability.
