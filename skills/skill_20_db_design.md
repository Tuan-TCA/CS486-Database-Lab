# Skill 20: Database Design Report Section

## 1. Purpose

Generate the LaTeX content for **Section 2: Database Design** of the group report (`report/src/20_db_design.tex`). This section synthesizes the outputs from Sections 01–03 (Business Requirement Analysis, Conceptual ERD, Logical Schema) and Section 04 (Validation) into a cohesive, professionally formatted academic report chapter (~5 pages).

---

## 2. Context Scope

Load the following files in order before writing:

1. `doc/project_description.md` — Original project requirements
2. `agent/Agent.md` — Global project knowledge (Sections 3–6)
3. `output/01-business-req-analysis-G08.md` — Business Requirement Analysis output
4. `output/02-erd-design-G08.md` — Conceptual Database Design (ERD) output
5. `output/03-logical-design-G08.md` — Logical Database Design output
6. `evaluation/evaluation_01.md` — Business Requirement rubric
7. `evaluation/evaluation_02.md` — ERD rubric
8. `evaluation/evaluation_03.md` — Logical Design rubric
9. `report/report-structure` — Report structure guide
10. `report/main.tex` — Main report template (for package/command awareness)

---

## 3. Target File

```
report/src/20_db_design.tex
```

This file is `\input`'ed by `report/main.tex`. It must NOT contain `\documentclass`, `\begin{document}`, or `\end{document}`.

---

## 4. Required Document Structure

The output must be a LaTeX file with the following hierarchical structure matching the report-structure guide:

### 4.1 Section Header

```latex
\section{Database Design}
```

### 4.2 Subsection: Business Requirement Analysis (§2.1)

```latex
\subsection{Business Requirement Analysis}
```

Content:

- **Business Purpose** (`\subsubsection{Business Purpose}`): A concise narrative paragraph (NOT a table) explaining:
  - What the system does (manage campus space booking, approval, usage, and maintenance)
  - Why it is needed (replace manual spreadsheet/email process)
  - Core objectives (fair allocation, prevent conflicts, preserve history)
  - Source: `output/01-business-req-analysis-G08.md` Section 1

- **Actors** (`\subsubsection{Actors}`): A `tabularx` table with columns: Role, Description. Exactly 6 actors:
  - Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, Facility Manager
  - Source: `output/01-business-req-analysis-G08.md` Section 2

- **Core Entities** (`\subsubsection{Core Entities}`): A `tabularx` table summarizing all 7 entities with columns: Entity Name, Description, Key Attributes.
  - Entities: User, Space, Facility, Booking\_Request, Booking\_Approval, Usage\_Session, Maintenance\_Record
  - Source: `output/01-business-req-analysis-G08.md` Section 3

- **Business Rules** (`\subsubsection{Business Rules}`): An `enumerate` list of all 10 business rules from `Agent.md` Section 4 and the output file.
  - Source: `output/01-business-req-analysis-G08.md` Section "Business Rules" + `Agent.md` Section 4

- **Requirement Summary Table** (`\subsubsection{Requirement Summary}`): A `tabularx` table mapping each major requirement to how the database supports it. Columns: Requirement, Database Support.

### 4.3 Subsection: Conceptual Database Design (§2.2)

```latex
\subsection{Conceptual Database Design}
```

Content:

- **Entity Relationship Diagram** (`\subsubsection{Entity Relationship Diagram}`):
  - Reference an ERD image if available, OR describe that the ERD was generated using Mermaid notation
  - Briefly explain the diagram structure
  - If an ERD image exists in `report/img/`, use `\includegraphics`. Otherwise, note that the full ERD is provided in the project deliverables and provide a textual summary.

- **Design Decisions** (`\subsubsection{Design Decisions}`): Narrative paragraphs explaining key design choices:
  - Entity identification rationale (why 7 entities, not more or fewer)
  - Relationship design (why certain relationships exist)
  - Cardinality decisions (why 1:0..1 for Booking\_Approval and Usage\_Session)
  - Participation constraints (total vs. partial)
  - Source: `output/02-erd-design-G08.md`

- **Relationship Summary** (`\subsubsection{Relationship Summary}`): A `tabularx` table with columns: Relationship, Cardinality, Description. List all 11 relationships.
  - Source: `output/02-erd-design-G08.md` Cardinalities table

### 4.4 Subsection: Logical Database Design (§2.3)

```latex
\subsection{Logical Database Design}
```

Content:

- **Relational Schema** (`\subsubsection{Relational Schema}`): Present the schema for all 7 relations using `lstlisting` blocks (language=text or SQL). For each relation, show:
  - Relation name
  - Attributes with data types
  - Source: `output/03-logical-design-G08.md` Section 2

- **Relation Summary** (`\subsubsection{Relation Summary}`): A `tabularx` table with columns: Relation, Primary Key, Foreign Keys, Candidate Keys.
  - Source: `output/03-logical-design-G08.md` Section 1

- **Key Analysis** (`\subsubsection{Key Analysis}`):
  - Primary keys: brief paragraph or list
  - Candidate keys: highlight USER.email, SPACE(building, room\_number), BOOKING\_APPROVAL.booking\_id, USAGE\_SESSION.booking\_id
  - Foreign keys: a `tabularx` table listing all 11 FKs with columns: Child Relation, FK Attribute, Parent Relation
  - Source: `output/03-logical-design-G08.md` Sections for each relation

- **Normalization** (`\subsubsection{Normalization}`): Brief explanation confirming that all relations satisfy:
  - 1NF: All attributes are atomic
  - 2NF: No partial dependencies (all PKs are single-attribute)
  - 3NF: No transitive dependencies among non-key attributes

### 4.5 Subsection: Database Validation (§2.4)

```latex
\subsection{Database Validation}
```

Content:

- **Requirement Traceability** (`\subsubsection{Requirement Traceability}`): A `tabularx` table mapping each business requirement to the corresponding database component(s). Columns: Business Requirement, Database Component.

- **Constraint Analysis** (`\subsubsection{Constraint Analysis}`): A `tabularx` table showing how each business rule is enforced. Columns: Business Rule, Schema Constraint, Additional Enforcement.
  - Distinguish between schema-level enforcement (PK, FK, UNIQUE, NOT NULL, CHECK) and application-level enforcement (triggers, application logic)

- **Design Limitations** (`\subsubsection{Design Limitations}`): Brief discussion of:
  - Constraints requiring triggers (e.g., overlapping booking prevention)
  - Constraints requiring application logic (e.g., checking space status before booking)
  - Source: `output/03-logical-design-G08.md` Section 4

---

## 5. LaTeX Formatting Rules

### 5.1 Package Awareness

The following packages are already loaded in `main.tex` — use them freely:

- `tabularx` — for flexible-width tables
- `array` — for column formatting
- `float` — for `[H]` placement
- `listings` / `lstlisting` — for code blocks
- `tcolorbox` — for highlighted boxes (use `gitbox` environment if needed)
- `enumitem` — for customized lists
- `hyperref` — for links
- `caption` — table captions (note: `\captionsetup[table]{labelformat=empty}`)

### 5.2 Table Convention

Use `tabularx` with `\textwidth` for all tables:

```latex
\begin{table}[H]
\centering
\caption{Table Title}
\begin{tabularx}{\textwidth}{|l|X|}
\hline
\textbf{Column 1} & \textbf{Column 2} \\
\hline
Data & Data \\
\hline
\end{tabularx}
\end{table}
```

### 5.3 Code Blocks

Use `lstlisting` for schema definitions:

```latex
\begin{lstlisting}[language=SQL, caption=Relation Name]
RELATION_NAME(
    attribute1 TYPE,
    attribute2 TYPE
)
\end{lstlisting}
```

### 5.4 Naming Conventions

- Entity/Table names: use `\texttt{UPPER\_SNAKE\_CASE}` (e.g., `\texttt{BOOKING\_REQUEST}`)
- Attribute/Column names: use `\texttt{lower\_snake\_case}` (e.g., `\texttt{user\_id}`)
- Escape underscores in text mode: `\_`
- In `lstlisting` environments, underscores do NOT need escaping

### 5.5 Cross-References

- Do not use `\label` / `\ref` unless coordinated with other sections
- Use descriptive table captions
- Number subsections follow the document's `\setcounter{secnumdepth}{4}` setting

---

## 6. Execution Strategy

### 6.1 Source of Truth

- All entity names, attribute names, and relationships MUST match `Agent.md` Section 3 exactly
- All business rules MUST match `Agent.md` Section 4 exactly
- Status values and enumerations MUST match the output files exactly
- Do NOT invent requirements, entities, attributes, or relationships

### 6.2 Content Synthesis

- Do NOT copy-paste raw markdown from the output files
- Rephrase and restructure content for a formal academic report tone
- Consolidate information — avoid repeating the same facts across subsections
- Use tables for structured data, prose for explanations and design rationale
- Keep the section concise (~5 pages when compiled to PDF)

### 6.3 Anti-Hallucination

- Do NOT add entities, attributes, or business rules not present in the source files
- Do NOT invent design decisions not documented in the output files
- If something is ambiguous, flag it with a LaTeX comment `% TODO: verify`
- Use only the 7 defined entities: USER, SPACE, FACILITY, BOOKING\_REQUEST, BOOKING\_APPROVAL, USAGE\_SESSION, MAINTENANCE\_RECORD

---

## 7. Verification Checklist

Before finalizing `report/src/20_db_design.tex`, verify:

- [ ] File does NOT contain `\documentclass`, `\begin{document}`, or `\end{document}`
- [ ] Top-level section is `\section{Database Design}`
- [ ] Four subsections exist: 2.1 Business Requirement Analysis, 2.2 Conceptual Database Design, 2.3 Logical Database Design, 2.4 Database Validation
- [ ] Business Purpose is a narrative paragraph (NOT a table)
- [ ] Exactly 6 actors are listed: Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, Facility Manager
- [ ] Exactly 7 entities are listed: User, Space, Facility, Booking\_Request, Booking\_Approval, Usage\_Session, Maintenance\_Record
- [ ] All 10+ business rules from Agent.md Section 4 are present
- [ ] All 11 relationships from the ERD are included in the Relationship Summary
- [ ] All 11 foreign keys are listed in the Key Analysis
- [ ] Candidate keys include: USER.email, SPACE(building, room\_number), BOOKING\_APPROVAL.booking\_id, USAGE\_SESSION.booking\_id
- [ ] Cardinalities for Booking\_Approval and Usage\_Session are 1:0..1 (NOT 1:N)
- [ ] Normalization section confirms 1NF, 2NF, 3NF compliance
- [ ] Validation subsection covers requirement traceability, constraint analysis, and design limitations
- [ ] All table/entity/attribute names match Agent.md byte-for-byte
- [ ] All underscores in text mode are escaped as `\_`
- [ ] All tables use `tabularx` with `\textwidth`
- [ ] LaTeX compiles without errors when included via `\input{src/20_db_design.tex}`

---

## 8. Page Budget Guide

Target approximately 5 pages in the compiled PDF:

| Subsection | Target Pages |
|---|---|
| 2.1 Business Requirement Analysis | ~1.5 pages |
| 2.2 Conceptual Database Design | ~1 page |
| 2.3 Logical Database Design | ~1.5 pages |
| 2.4 Database Validation | ~1 page |

Use dense tables and concise prose to stay within the budget. Avoid unnecessary whitespace or overly verbose explanations.

---

## 9. Common Mistakes to Avoid

- Writing `\documentclass` or `\begin{document}` in a sub-file
- Using `tabular` instead of `tabularx` (causes overflow)
- Forgetting to escape underscores in entity/attribute names outside code blocks
- Using 1:N cardinality for Booking\_Approval or Usage\_Session (must be 1:0..1)
- Adding a "System Administrator" actor (hallucination — not in requirements)
- Omitting the normalization discussion
- Listing only a subset of foreign keys
- Writing overly long prose that exceeds the 5-page budget
- Using inconsistent naming between subsections
- Placing the ERD description in the Business Requirements subsection instead of the Conceptual Design subsection
