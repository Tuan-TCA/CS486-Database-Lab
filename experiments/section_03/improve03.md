# Improve - Section 03: Logical Database Design

## Round Summary

| Round | Score | Main Issues                                                            | Agent Updates | Skill Updates |
| ----- | ----- | ---------------------------------------------------------------------- | ------------- | ------------- |
| 1     | 9/10  | Missing SPACE(building, room_number) candidate key / UNIQUE constraint | ...           | ...           |
| 2     | 10/10 | None (all round 1 issues resolved)                                     | ...           | ...           |
| 3     | x/10  | ...                                                                    | ...           | ...           |

---

## Round 1

### Evaluation

Score: 9/10

Strengths

- **Relations (2/2):** All 7 required relations (USER, SPACE, FACILITY, BOOKING_REQUEST, BOOKING_APPROVAL, USAGE_SESSION, MAINTENANCE_RECORD) are present. No unnecessary relations invented.
- **Attributes (2/2):** All attributes match AGENT.md byte-for-byte. Data types are appropriate. No hallucinated or missing attributes. Attribute placement is correct.
- **Foreign Keys (2/2):** All 11 expected foreign keys are correctly identified and placed in the appropriate child relations. Referential integrity summary is comprehensive.
- **Business rule enforcement documented:** All 10 business rules have explicit enforcement mechanisms, distinguishing between schema-level (CHECK, UNIQUE, NOT NULL) and application-layer enforcement.

Issues

- **Primary Keys and Candidate Keys (1.5/2):** Missing `SPACE(building, room_number)` as a candidate key. The rubric expects (building, room_number) to be recognized as a unique business identifier for spaces. The candidate keys table only lists `space_code` for SPACE.
- **Key Constraints (1.5/2):** Missing `UNIQUE (building, room_number)` constraint on SPACE. The existing UNIQUE constraints (USER.email, BOOKING_APPROVAL.booking_id, USAGE_SESSION.booking_id) are all correctly specified.

### Improvements

Agent Updates

- Reasoning process: Expanded candidate key analysis to evaluate multi-attribute combinations (composite keys), specifically recognizing that a physical location requires a combination of building and room_number to guarantee uniqueness.

Skill Updates

- Missing keys: Added a strict verification check to skill_03_LogicalSchema.md to ensure SPACE(building, room_number) is documented as a candidate key.
- Missing edge cases: Added a verification check to ensure composite candidate keys are correctly mapped to UNIQUE constraints in the schema enforcement section.

---

## Round 2

### Evaluation

Score: 10/10

Strengths

- **Relations (2/2):** All 7 required relations present. No unnecessary relations.
- **Attributes (2/2):** All attributes match AGENT.md byte-for-byte. Data types, nullability, and descriptions are appropriately specified in the data dictionary.
- **Primary Keys and Candidate Keys (2/2):** All PKs correctly defined. All expected candidate keys identified, including the previously missing `SPACE(building, room_number)` composite key. 1:0..1 relationships properly converted using UNIQUE FKs.
- **Foreign Keys (2/2):** All 11 expected foreign keys correctly placed in appropriate child relations with correct parent references.
- **Key Constraints (2/2):** NOT NULL, UNIQUE (USER.email, SPACE(building, room_number), BOOKING_APPROVAL.booking_id, USAGE_SESSION.booking_id), and CHECK constraints are correctly identified and consistent with business requirements.

Issues

- None identified. All round 1 issues resolved.

---

## Round 3

### Evaluation

Score: x/10

Strengths

- ...

Issues

- ...

### Improvements

Agent Updates

- ...

Skill Updates

- ...

---

## Overall Summary

Initial weaknesses

- ...

Major improvements

- ...

Final observations

- ...

Final score: x/10

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
