# AGENTS.md — CS486 Project G08

## General Configuration

- Group: G08
- DBMS: Microsoft SQL Server
- Root directory: C:\Users\Tuan TCA\OneDrive\Tai_Lieu\2ndYear\Tin\CS486_Database\Project-Midterm\testOpenAI
- LLM Model(s): TBD — update after selection

## Project Workflow

Always follow this order:

1. Business Requirement Analysis
2. Conceptual Design (ERD)
3. Logical Design
4. Design Validation
5. Database Implementation (DDL)
6. Sample Data
7. Query Design

## Output Location

All generated artifacts go into the `outputs/` folder.

## Design Conventions

- Use Mermaid `erDiagram` for ERD (Crow's Foot notation)
- Use Microsoft SQL Server T-SQL syntax
- Preserve traceability: requirement → entity → relationship → table → constraint
- Record assumptions and open questions explicitly
- Do not silently invent business rules
