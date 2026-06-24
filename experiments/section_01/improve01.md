# Improve - Section 01: Business Requirement Analysis

## Round Summary

| Round | Score | Main Issues                                                                                                                                                     | Agent Updates | Skill Updates |
| ----- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ------------- |
| 1     | 8/10  | Missing dedicated Business Purpose section; several actors missing or mislabeled (Lecturer, TA, Dept Administrator); missing "university account" business rule | ...           | ...           |
| 2     | 10/10 | None                                                                                                                                                             | ...           | ...           |
| 3     | x/10  | ...                                                                                                                                                             | ...           | ...           |

---

## Round 1

### Evaluation

Score: 8/10

Strengths

- All 7 required entities are correctly identified and named.
- All attributes for every entity are present, correctly named, and match AGENT.md byte-for-byte.
- Relationships are complete and correctly described (1-to-many, optional zero-or-one).
- All 9 business rules from AGENT.md are listed.
- Status value sets are defined with proper enumerated values.
- No hallucinated entities or attributes.

Issues

- **Business Purpose (0.5/1):** No dedicated "Business Purpose" section exists. The purpose is embedded in a project overview table without a clear narrative explaining why the system is needed.
- **Actors Identification (0.5/1):** Several expected actors are missing or mislabeled. Expected: Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, Facility Manager. The document lists "Students", "Faculty/Staff" (vague grouping of Lecturers/TAs), "Facility Managers", and "Maintenance Staff", but omits Lecturer, Teaching Assistant, Facility Staff (as distinct), and Department Administrator. It also invents "System Administrators" without requirement justification.
- **Business Rules (1/2):** Missing the rule "Every user must have a university account."

### Improvements

Agent Updates

- Output formatting: Added a dedicated narrative section for "Business Purpose" rather than embedding it in an overview table.
- Naming consistency: Corrected actor identification to explicitly separate Lecturer, Teaching Assistant, Facility Staff, and Department Administrator.
- Hallucination: Removed the unprompted "System Administrators" role.

Skill Updates

- Missing edge cases/rules: Added the "Every user must have a university account" constraint to the verification checklist.
- Output formatting: Formalized the required document structure in skill_01_BR.md to guarantee the Business Purpose and Actor lists are formatted correctly in future rounds.

---

## Round 2

### Evaluation

Score: 10/10

Strengths

- **Business Purpose (1/1):** Dedicated narrative paragraph clearly explaining why the system is needed, with no invented goals.
- **Actors Identification (1/1):** All six required actors listed exactly (Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, Facility Manager); no hallucinated roles.
- **Entities Identification (2/2):** All 7 core entities present and correctly named.
- **Attributes Identification (2/2):** All attributes match AGENT.md byte-for-byte, including PK/FK/unique/candidate key annotations. No hallucinated or missing attributes.
- **Relationships and Cardinalities (2/2):** All relationships correctly represented via FK annotations. Optional 0..1 relationships clearly marked with "(unique)". No missing or incorrect relationships.
- **Business Rules (2/2):** All 10 business rules listed, including the previously missing "Every user must have a university account" as Rule 1.

Issues

- None identified.

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
