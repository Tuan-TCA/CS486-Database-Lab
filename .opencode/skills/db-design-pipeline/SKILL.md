## cat > .opencode/skills/db-design-pipeline/SKILL.md <<'EOF'

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

## Required output files

Create or update the following files:

1. `outputs/01-business-req-analysis-G08.md`
2. `outputs/02-erd-design-G08.md`
3. `outputs/03-logical-design-G08.md`
4. `outputs/04-design-validation-G08.md`
5. `outputs/05-db-definition-G08.sql`
6. `outputs/06-sample-data-G08.sql`
7. `outputs/07-query-design-G08.sql`

Do not skip any Markdown file.

---

# Step 1: Business Requirement Analysis

Save to:

`outputs/01-business-req-analysis-G01.md`

The document must include:

<!-- YOUR SKILL DESCRIPTION HERE -->

# Step 2: Conceptual Design / ERD

The ERD should be based on the document from the prior step: Step 1: Business Requirement Analysis.

Save to:

`outputs/02-erd-design-G08.md`

The document must include:

<!-- YOUR SKILL DESCRIPTION HERE -->

<!-- SIMILARLY FOR FOLLOWING STEPS -->
