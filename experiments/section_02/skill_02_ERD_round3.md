# Skill 02: Conceptual Database Design (ERD) (Round 3 Snapshot)

# Purpose
To generate a comprehensive and accurate Entity-Relationship Diagram (ERD) for the Campus Space Management System that visually models all entities, attributes, relationships, cardinalities, and participation constraints, strictly adhering to the established source of truth without hallucinating database-level data types.

# Methodology
1. **Source of Truth Extraction:** Read `Agent.md` and the final result of Section 01 (`result_round3.md`) to extract the exact list of entities, attributes, relationships, and cardinalities.
2. **Mermaid Diagram Generation:** Use Mermaid JS `erDiagram` syntax to construct the ERD. 
3. **Entity Definition:** Define all 7 entities exactly as named in `Agent.md`.
4. **Attribute Listing:** List all attributes under each entity in the Mermaid diagram. Annotate Primary Keys (`PK`) and Foreign Keys (`FK`). If an attribute is marked as `unique` or `candidate key` in `Agent.md`, annotate it as `UK` (Unique Key). Do NOT include data types (e.g., `string`, `int`).
5. **Relationship Mapping:** Map every relationship explicitly listed in Section 3.5 of `result_round3.md`.
6. **Participation Constraints:** Determine and visualize mandatory vs. optional participation constraints based on the business rules.
7. **Diagram Clarity:** Keep the diagram clean and well-structured to avoid overlapping relationship lines where possible.
8. **Explicit Relationship Table:** Create a dedicated Markdown table summarizing all 11 relationships (Entity A, Relationship, Entity B, Cardinality) beneath the ERD.
9. **Assumption Documentation:** If any participation constraint is inferred rather than explicitly stated, document it beneath the diagram in an Assumptions list.

# Verification Procedure
Before finalizing the ERD result:
1. Cross-check every entity and attribute in the Mermaid diagram against `Agent.md` Section 3. Verify no data types exist.
2. Cross-check every relationship in the Mermaid diagram against `result_round3.md` Section 3.5.
3. Count the relationships in the ERD and the Relationship Table to ensure there are exactly 11.
4. Verify that `UK` annotations are successfully applied to all candidate keys and 1:1 foreign keys defined in the source of truth.
5. Verify that the Mermaid syntax compiles correctly.
6. If inconsistencies are found, STOP, fix the diagram, and re-verify.
