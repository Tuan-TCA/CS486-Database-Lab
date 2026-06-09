cat > .opencode/skills/db-design-pipeline/SKILL.md <<'EOF'
---
name: db-design-pipeline
description: Analyze business requirements and produce conceptual ERD, logical database design, and DDL documents step by step.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform business requirements into a database design.

## Important behavior

Before assuming anything, inspect the project:

1. Run `ls -la`.
2. Locate requirement files under `req/`, `docs/`, or files passed by the user.
3. Read the relevant requirement files fully before designing.
4. If the requirement is incomplete, continue with explicit assumptions, but also create an unresolved questions section.

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

1. `01-business-req-analysis-G08.md`
2. `02-erd-design-G08.md`
3. `03-logical-design-G08.md`
4. `04-design-validation-G08.md`
5. `05-db-definition-G08.sql`
6. `06-sample-data-G08.sql`
7. `07-query-design-G08.sql`

Do not skip any Markdown file.

---

# Step 1: Business Requirement Analysis

Save to:

`outputs/01-business-requirement-analysis.md`

The document must include:

<!-- YOUR SKILL DESCRIPTION HERE -->

# Step 2: Conceptual Design / ERD

The ERD should be based on the document from the prior step: Step 1: Business Requirement Analysis.

Save to:

`outputs/02-conceptual-design-erd.md`

The document must include:

<!-- YOUR SKILL DESCRIPTION HERE -->
