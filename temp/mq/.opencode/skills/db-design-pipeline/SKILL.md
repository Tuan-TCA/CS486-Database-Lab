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

Create or update the following files exactly as named:

1. `outputs/01-business-req-analysis-G08.md`
2. `outputs/02-erd-design-G08.md`
3. `outputs/03-logical-design-G08.md`
4. `outputs/04-design-validation-G08.md`
5. `outputs/05-db-definition-G08.sql`
6. `outputs/06-sample-data-G08.sql`
7. `outputs/07-query-design-G08.sql`

Do not skip any file. Do not invent business rules.

---

# Step 1: Business Requirement Analysis

Save to: `outputs/01-business-req-analysis-G08.md`
Instructions: Analyze the requirements to identify the business purpose, actors, entities, attributes, relationships, cardinalities, and business rules.

# Step 2: Conceptual Database Design

Save to: `outputs/02-erd-design-G08.md`
Instructions: Design an ERD showing the main entities, attributes, relationships, cardinalities, and participation constraints. Use Mermaid `erDiagram` notation.

# Step 3: Logical Database Design

Save to: `outputs/03-logical-design-G08.md`
Instructions: Convert the ERD into a relational schema with relations, attributes, primary keys, foreign keys, candidate keys, and key constraints.

# Step 4: Database Design Validation

Save to: `outputs/04-design-validation-G08.md`
Instructions: Evaluate whether the relational schema correctly represents the ERD, satisfies the business rules, and uses appropriate keys, relationships, and constraints.

# Step 5: Database Implementation

Save to: `outputs/05-db-definition-G08.sql`
Instructions: Implement the database using SQL DDL with tables, keys, constraints, checks, and default values where appropriate. Use Microsoft SQL Server syntax unless otherwise specified.

# Step 6: Sample Data Preparation

Save to: `outputs/06-sample-data-G08.sql`
Instructions: Insert realistic sample data to support testing of normal operations and important exceptional cases. CRITICAL: The generated SQL script must be idempotent. You must include commands to clear existing data from the tables (e.g., DELETE FROM TableName;) in the correct order to respect foreign key constraints before running your INSERT statements. This ensures the script can be run multiple times safely without duplicating data.

# Step 7: Query Design

Save to: `outputs/07-query-design-G08.sql`
Instructions: Design and execute at least 5 meaningful SQL queries that answer business questions in the given context. For each query, include the business question, target user(s), a short explanation of its usefulness, and the SQL statement.
