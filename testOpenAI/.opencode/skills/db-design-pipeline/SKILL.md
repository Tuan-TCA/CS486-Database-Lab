---
name: db-design-pipeline
description: Analyze business requirements and produce conceptual ERD, logical database design, and DDL documents step by step.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform business requirements into a database design.

## Workflow Order
Always follow this order:

1. Analyze business requirements.
2. Produce conceptual ERD using Crow's Foot notation.
3. Convert ERD to logical relational schema.
4. Validate the database design.
5. Implement using SQL DDL (Microsoft SQL Server).
6. Prepare sample data.
7. Design meaningful SQL queries.

Do not jump directly to DDL. The documents from the prior steps should be followed in the later steps.

## DBMS
Use Microsoft SQL Server unless the user specifies another DBMS.

## Design Rules
- Record assumptions explicitly.
- Record open questions explicitly.
- Preserve traceability from requirement → entity → relationship → table → constraint.
- Use Mermaid `erDiagram` for ERD.
- Do not silently invent business rules.

## Required output files
Create or update the following files in `outputs/`:

1. `01-business-req-analysis-G<GroupNumber>.md`
2. `02-erd-design-G<GroupNumber>.md`
3. `03-logical-design-G<GroupNumber>.md`
4. `04-design-validation-G<GroupNumber>.md`
5. `05-db-definition-G<GroupNumber>.sql`
6. `06-sample-data-G<GroupNumber>.sql`
7. `07-query-design-G<GroupNumber>.sql`
