# AGENTS.md — CS486 Project G08

## General Configuration

- **Group:** G08
- **DBMS:** Microsoft SQL Server
- **LLM Model(s):** TBD — update after selection

## Project Workflow

Always follow this order. Do not jump directly to DDL. Prior steps must inform later steps:

1. Business Requirement Analysis
2. Conceptual Design (ERD)
3. Logical Design
4. Design Validation
5. Database Implementation (DDL)
6. Sample Data Preparation
7. Query Design

## Required Outputs

All generated artifacts must be saved to the `outputs/` folder exactly as named:

- `outputs/01-business-req-analysis-G08.md`
- `outputs/02-erd-design-G08.md`
- `outputs/03-logical-design-G08.md`
- `outputs/04-design-validation-G08.md`
- `outputs/05-db-definition-G08.sql`
- `outputs/06-sample-data-G08.sql`
- `outputs/07-query-design-G08.sql`

## Design Conventions & Constraints

- **ERD:** Use Mermaid `erDiagram` with Crow's Foot notation.
- **SQL:** Use Microsoft SQL Server T-SQL syntax.
- **Traceability:** Preserve explicit traceability: requirement → entity → relationship → table → constraint.
- **Assumptions:** Record assumptions and open questions explicitly in the documents.
- **Strict Adherence:** Do not silently invent business rules, features, or tables not present in the requirements.
