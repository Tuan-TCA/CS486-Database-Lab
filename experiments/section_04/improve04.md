# Improve - Section 04: Database Design Validation

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 8/10  | No explicit attribute-by-attribute comparison; candidate keys for USER/SPACE not fully detailed; missing SPACE.usage_policy and SPACE.current_status validation; no discussion of participation constraints | None | Add attribute-level validation checklist; add participation constraint verification; add status value validation |
| 2     | 9/10  | Domain values for account_status, space_type, maintenance.status not fully specified — requires assumptions; cross-section check is high-level without concrete file references | None | Add guidance for handling unspecified domain values; add explicit assumption documentation rule |
| 3     | 9.5/10| Participation constraint for non-booking relationships (e.g. USER→BOOKING_APPROVAL as decider) not fully analyzed; cross-section references still generic rather than specific versioned outputs | None | Minor refinements only — skill is mature enough |

---

## Round 1

### Evaluation

Score: 8/10

Strengths

* Complete entity coverage (all 7 entities present)
* Correct relationship cardinality mapping (1:N via FK, 1:0..1 via UNIQUE FK)
* Clear structural vs operational classification of business rules
* Proper key identification (PK, candidate keys, FK)
* Explicit "why not DDL" explanations for operational rules

Issues

* ERD validation lacks attribute-by-attribute comparison — only lists entity names
* Missing validation of SPACE.current_status values (available, under_maintenance, etc.) and SPACE.usage_policy
* Missing validation of USER.role values (student, lecturer, etc.)
* No discussion of participation constraints (total vs partial)
* Candidate keys section does not justify why email and (building, room_number) are valid candidate keys
* No explicit cross-check against the ERD from section 02
* No mention of CHECK constraints for status/role domains
* Missing validation of FACILITY attributes

### Improvements

Agent Updates

* None — issues are section-specific, not globally reusable

Skill Updates

* Add explicit "Attribute-Level Validation" section requiring per-attribute verification against source documents
* Add "Status and Domain Value Validation" step — verify every ENUM-like attribute has correct permitted values
* Add "Participation Constraint Validation" — verify total vs partial participation
* Add "Cross-Section Consistency Check" step — compare against finalized outputs of sections 02 and 03
* Add checklist item: verify attribute-level correctness for every relation
* Add checklist item: verify status/domain values match project_description
* Add checklist item: verify participation constraints
* Add common mistake: "assuming entity presence alone validates ERD representation"

---

## Round 2

### Evaluation

Score: 9/10

Strengths

* Attribute-level validation performed for all 7 relations
* Participation constraints analyzed
* Domain values explicitly verified with source citations
* Cross-section consistency confirmed across sections 01-03
* Candidate keys include justification for each selection
* Operational rules have clear "why not DDL" explanations

Issues

* Some domain values noted as "not explicitly specified" without proposing default assumptions
* account_status, space_type, maintenance.status domain sets are inferred rather than traced
* Cross-section check references sections generically without comparing against specific section outputs
* Missing validation of CHECK constraints for status/role ENUM domains in SQL DDL

### Improvements

Agent Updates

* None — issues are section-specific, not globally reusable

Skill Updates

* Add rule: when domain values are not fully specified in project_description, document explicit reasonable defaults with justification
* Add rule: cross-section check must reference specific section outputs
* Add checklist item: verify that CHECK constraints exist for ENUM-like columns in SQL DDL

---

## Round 3

### Evaluation

Score: 9.5/10

Strengths

* Full attribute-level validation with source citations for every relation
* Participation constraints analyzed with schema enforcement verification
* Domain values explicitly enumerated with assumptions documented for unspecified sets
* Cross-section consistency verified against Agent.md and preceding sections
* Candidate keys include justification for each selection
* Structural vs operational constraint separation clearly maintained
* Unspecified domain values documented with reasonable defaults

Issues

* Participation constraint for USER→BOOKING_APPROVAL (decider) not analyzed — a user may optionally act as decider
* Cross-section references cite sections generically rather than specific versioned outputs (e.g. section_03/result_round3)
* Minor: TYPE column for PKs (INT vs VARCHAR) noted but not always justified

### Improvements

Agent Updates

* None — remaining issues are minor and section-specific

Skill Updates

* Minor: consider adding USER→BOOKING_APPROVAL participation constraint to methodology
* Minor: encourage referencing specific versioned outputs in cross-section checks

---

## Overall Summary

Initial weaknesses

* Validation was entity-level only, missing attribute-level detail
* No verification of domain values (status, role, booking_type)
* No participation constraint analysis
* No cross-section consistency check

Major improvements

* Round 1 → 2: Added attribute-level validation, participation constraints, domain value checks
* Round 2 → 3: Added unspecified domain defaults, CHECK constraint verification, refined cross-section checks

Final observations

* The validation skill matured from entity-level to full attribute-level with domain verification
* Cross-section consistency and structural vs operational separation are well established
* Three rounds of iteration produced progressively more rigorous validation documents
* No Agent updates were needed — all lessons were section-specific

Final score: 9.5/10

---

## Rules

Agent Updates

* None

Skill Updates

* Attribute-level validation
* Domain value validation
* Participation constraint validation
* Cross-section consistency check
