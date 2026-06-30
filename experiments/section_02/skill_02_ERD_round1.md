# Skill 02: Conceptual Database Design (ERD) (Round 1 Baseline Snapshot)

# Purpose
To generate a comprehensive and accurate Entity-Relationship Diagram (ERD) for the Campus Space Management System that visually models all entities, attributes, relationships, cardinalities, and participation constraints, strictly adhering to the established source of truth.

# Methodology
1. **Source of Truth Extraction:** Read `Agent.md` and the final result of Section 01 (`result_round3.md`) to extract the exact list of entities, attributes, relationships, and cardinalities.
2. **Mermaid Diagram Generation:** Use Mermaid JS `erDiagram` syntax to construct the ERD. 
3. **Entity Definition:** Define all 7 entities (`USER`, `SPACE`, `FACILITY`, `BOOKING_REQUEST`, `BOOKING_APPROVAL`, `USAGE_SESSION`, `MAINTENANCE_RECORD`) exactly as named in `Agent.md`.
4. **Attribute Listing:** List all attributes under each entity in the Mermaid diagram, annotating Primary Keys (PK) and Foreign Keys (FK).
5. **Relationship Mapping:** Map every relationship explicitly listed in Section 3.5 of `result_round3.md`.
6. **Participation Constraints:** Determine and visualize mandatory vs. optional participation constraints based on the business rules.
7. **Diagram Clarity:** Keep the diagram clean and well-structured.
8. **Assumption Documentation:** If any participation constraint is inferred rather than explicitly stated, document it beneath the diagram in an Assumptions list.

# Verification Procedure
Before finalizing the ERD result:
1. Cross-check every entity and attribute in the Mermaid diagram against `Agent.md` Section 3.
2. Cross-check every relationship in the Mermaid diagram against `result_round3.md` Section 3.5. Count them to ensure there are exactly 11 relationships.
3. Verify that the Mermaid syntax compiles correctly.
4. If inconsistencies are found, STOP, fix the diagram, and re-verify.
