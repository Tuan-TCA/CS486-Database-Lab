# Improve - Section 02: Conceptual Database Design (ERD)

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | -----------| 1     | 8.5/10 | Hallucinated data types (string, int) in Mermaid ERD | None | Forbid data types in ERD attributes; strictly use name + PK/FK |
| 2     | 9.0/10 | Missing Unique Key (UK) annotations for 1:1 relationships; missing text mapping of the 11 relationships | None | Require UK annotation for unique FKs; require explicit 11-relationship table |
| 3     | 9.5/10 | Missing Candidate Key constraint on USER.email | None | Require UK/CK annotation for candidate keys |

---

## Round 1

### Evaluation

Score: 8.5/10

Strengths

- All 7 entities correctly modeled with 11 distinct relationships.
- Participation constraints are explicitly documented.
- Clean separation of multiple FKs (like `USAGE_SESSION` check-in and complete).
- Mermaid diagram properly structured.

Issues

- **Hallucinated data types:** The ERD introduces data types like `string`, `int`, `datetime`. `Agent.md` does not specify data types, only attribute names and PK/FK markers. This violates the anti-hallucination rule.

### Improvements

Agent Updates

- None

Skill Updates

- **Forbid Data Types:** Update the skill to explicitly forbid adding data types (e.g., `string`, `int`) to the Mermaid ERD entity definitions. Only use the attribute name and structural markers (`PK`, `FK`).

---

## Round 2

### Evaluation

Score: 9.0/10

Strengths

- Hallucinated data types removed. The attributes now match `Agent.md` byte-for-byte.

Issues

- **Missing UK annotations:** `Agent.md` specifies that `booking_id` in `BOOKING_APPROVAL` and `USAGE_SESSION` is `unique` (FK -> BOOKING_REQUEST, unique). The ERD attribute list should reflect this `UK` (Unique Key) constraint alongside `FK`.
- **Missing Explicit Relationship Table:** While the Mermaid diagram is correct, the document lacks a tabular summary of the 11 relationships for quick reference and traceability.

### Improvements

Agent Updates

- None

Skill Updates

- **Add UK Annotations:** Update the skill to require annotating unique foreign keys as `FK, UK` in the Mermaid diagram to properly represent 1:1 structural constraints.
- **Add Relationship Table:** Update the skill to require a dedicated Markdown table summarizing the 11 relationships (Entity A, Relationship, Entity B, Cardinality) beneath the ERD.

---

## Round 3

### Evaluation

Score: 9.5/10

Strengths

- ERD is well-aligned with `Agent.md`, containing no hallucinated data types.
- 1:1 constraints explicitly marked with `UK` annotations.
- Full traceability provided via the explicit relationship table and participation assumptions.

Issues

- **Missing Candidate Key Constraint:** `Agent.md` explicitly lists `email` under `USER` as `(candidate key)`. The current ERD fails to map this constraint, listing `email` without any key annotations (like `UK` or `CK`). This leads to a loss of data integrity requirements in the Conceptual Design phase.

### Improvements

Agent Updates

- None

Skill Updates

- **Require Candidate Key Annotations:** Update the skill to explicitly require that any attribute marked as `(candidate key)` in `Agent.md` must be annotated as `UK` (Unique Key) or `CK` in the Mermaid ERD attribute list.

---

## Overall Summary

Initial weaknesses

- Hallucinated data types in the ERD diagram.
- Lack of explicit Unique Key constraints and a traceable relationship table.

Major improvements

- Stripped all assumed data types to strictly adhere to `Agent.md`.
- Added `UK` annotations for 1:1 mappings and Candidate Keys.
- Introduced a tabular relationship summary for better requirement traceability.

Final observations

- Strictly relying on `Agent.md` means avoiding the temptation to "flesh out" the ERD with standard SQL data types before the physical design phase, while simultaneously ensuring we don't accidentally drop subtle constraints like Candidate Keys.

Final score: 9.5/10

---

## Rules

Agent Updates

- Hallucination
- Requirement traceability
- Naming consistency
- Output formatting
- Reasoning process
- Verification behavior

Skill Updates

- Missing entities
- Missing relationships
- Missing cardinalities
- Missing participation constraints
- Missing keys
- Incorrect SQL
- Missing edge cases
