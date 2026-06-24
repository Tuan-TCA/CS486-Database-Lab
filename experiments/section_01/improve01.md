# Improve - Section 01: Business Requirement Analysis

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 8/10  | Missing dedicated Business Purpose section; several actors missing or mislabeled (Lecturer, TA, Dept Administrator); missing "university account" business rule | ...           | ...           |
| 2     | x/10  | ...         | ...           | ...           |
| 3     | x/10  | ...         | ...           | ...           |

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

- (To be filled after round evaluation)

Skill Updates

- (To be filled after round evaluation)

---

## Round 2

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
