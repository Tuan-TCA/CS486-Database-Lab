# Purpose

Provide a reusable methodology for validating the logical database design (relational schema) of the Campus Space Management System against the conceptual ERD, business requirements, and key constraints.

# Methodology

## Step 1: Collect Inputs

Load the following in order:
1. Project Description (`doc/project_description.md`)
2. Business Requirement Analysis (`output/01-business-req-analysis-G08.md`)
3. ERD Design (`output/02-erd-design-G08.md`)
4. Logical Database Design (`output/03-logical-design-G08.md`)

## Step 2: Validate ERD Representation

For every relation in the logical schema, verify:
- Every entity from the ERD maps to exactly one relation.
- Every attribute from the ERD appears as a column in the corresponding relation.
- Every relationship from the ERD is implemented via foreign keys.
- Cardinalities match: `1:N` → FK in the child table; `1:0..1` → UNIQUE FK.

## Step 3: Validate Business Rules

Cross-check each business rule from `01-business-req-analysis-G08.md` and `doc/project_description.md`:
- Can the rule be enforced at the schema level (PK, FK, UNIQUE, NOT NULL, CHECK)?
- If schema-level enforcement is impossible, is it explicitly documented as an application-level constraint?
- No business rule is silently ignored.
- Verify that no requirement from the original project description has been lost in translation through the business analysis and logical design steps.

## Step 4: Validate Keys

Check every relation:
- Primary key is well-chosen (stable, non-null, unique).
- Candidate keys are correctly identified.
- Foreign keys reference the correct parent table and primary key.
- UNIQUE constraints are applied on candidate keys.
- Composite keys are documented and justified.

## Step 5: Validate Relationships

- Every FK matches the cardinality from the ERD.
- `1:N` relationships always put the FK in the N-side table.
- `1:0..1` relationships use a UNIQUE FK constraint.
- Optional relationships allow NULLs where appropriate; mandatory relationships use NOT NULL.
- No extraneous FKs exist beyond what the ERD defines.
- Verify the logical schema's own relationship mapping section (Section 3 in the logical design) is self-consistent with the FK definitions in the relations.

## Step 6: Validate Constraints

- NOT NULL is applied to all PK attributes and mandatory FK attributes.
- CHECK constraints are proposed for status value sets.
- DEFAULT values are proposed where appropriate.
- Domain types match the attribute semantics (VARCHAR for codes, DATETIME for timestamps, INT for counts).
- Data type precision is reviewed for appropriateness (e.g., VARCHAR(20) for codes, VARCHAR(100) for names, TEXT for long descriptions).

## Step 7: Generate Validation Report

For each validation dimension:
- List items that PASS.
- List items that FAIL with specific reasons and references.
- Deduplicate identical issues before finalizing the gap list.
- Tag each gap with the target resolution section: `[04]` for logical documentation fixes, `[05]` for implementation constraint gaps.
- Assign a priority to each gap: `blocker`, `important`, or `nice-to-have`.
- Distinguish between:
  - **Logical documentation gaps**: missing entries in the logical schema's own constraint documentation.
  - **Implementation constraint gaps**: CHECK, DEFAULT, triggers that belong in DDL (section 05).
- If everything passes, state that the design is valid.

## Step 8: Normalization Check

For each relation, verify it satisfies 3NF (Third Normal Form):
1. The relation is in 1NF (all attributes are atomic).
2. The relation is in 2NF (no partial dependency on a composite PK — not applicable if PK is single-attribute).
3. The relation is in 3NF (no transitive dependency where a non-key attribute determines another non-key attribute).
4. If a violation is found, document the offending dependency and propose a decomposition.

# Checklist

- [ ] All ERD entities are represented as relations.
- [ ] All ERD attributes are present in the correct relation.
- [ ] All ERD relationships are implemented with correct FKs.
- [ ] Cardinality `1:N` is correctly implemented.
- [ ] Cardinality `1:0..1` is correctly implemented (UNIQUE FK).
- [ ] Every business rule is either enforced or documented as a gap.
- [ ] Primary keys are stable and meaningful.
- [ ] Candidate keys have UNIQUE constraints.
- [ ] Foreign key references are correct (table + column).
- [ ] NOT NULL is correct for all mandatory attributes.
- [ ] FK nullability matches optionality from ERD.
- [ ] Status value sets are documented.
- [ ] No extraneous attributes beyond ERD.
- [ ] Data types are appropriate for each attribute.
- [ ] Naming follows AGENT.md conventions (UPPER_SNAKE for tables, lower_snake for columns).
- [ ] All relations satisfy 3NF (no transitive dependencies).
- [ ] Each gap is tagged with a target resolution section ([04] or [05]).
- [ ] Gap list is deduplicated before finalization.
- [ ] Logical schema's relationship mapping section is self-consistent.
- [ ] Project description requirements are cross-checked against the validation.
- [ ] Data type precision is reviewed for each attribute.
- [ ] Each gap has a priority rating (blocker / important / nice-to-have).

# Verification Procedure

1. Print the ERD entity list and check off each entity against the logical schema's relation list. If any entity is missing → FAIL.
2. For each relation, list its attributes and compare against the corresponding ERD entity attributes. Any missing or extra attribute → FAIL.
3. Trace every relationship from the ERD to the logical schema. Verify FK placement and constraints.
4. Walk through every business rule from `01-business-req-analysis-G08.md` section "Business Rules" and AGENT.md section 5. Mark each as: Schema-Enforced, Documented-Gap, or Missing.
5. Verify PKs, CKs, and FKs using the logical schema's own key declarations.
6. Read the logical schema's "Additional Business Constraints" section and confirm that documented gaps are complete and accurate.
7. For each relation, check 3NF: identify the PK, list all non-key attributes, verify no non-key attribute depends on another non-key attribute.
8. Cross-check the project description directly against the logical schema for any requirements that may have been lost in the business analysis or logical design steps.
9. Review data type precision for each attribute — flag overly narrow or overly wide types.
10. Before writing the final gap list, scan for duplicate entries and merge them. Tag each remaining gap with its resolution section and assign a priority.

# Common Mistakes

- Adding attributes to a relation that do not appear in the ERD (hallucination).
- Omitting an entity from the ERD in the logical schema.
- Using incorrect FK references (wrong parent table or wrong column).
- Forgetting UNIQUE constraint on `1:0..1` FK columns.
- Leaving FK columns nullable when the ERD requires total participation.
- Claiming a business rule is schema-enforced when it actually requires application logic.
- Mixing naming conventions between output files.
- Ignoring candidate keys other than the PK.
- Missing normalization analysis (transitive dependencies undetected).
- Reporting the same gap multiple times under different headings.
- Confusing logical documentation gaps with implementation constraint gaps.
- Forgetting to check the logical schema's relationship mapping section for self-consistency.
- Not cross-checking against the project description directly.
- Using inconsistent or inappropriate data type precision (e.g., VARCHAR(255) for short codes).
- Omitting priority ratings from the gap table.

# Consistency Rules

- Table names must match AGENT.md section 4 exactly (byte-for-byte).
- Column names must match AGENT.md section 4 exactly.
- Data type choices must be consistent across all relations.
- Status values must be consistent with `01-business-req-analysis-G08.md`.
- FK column names should match the referenced PK column name where unambiguous, or use a qualifying prefix.

# Anti-Hallucination Rules

- If an attribute, entity, relationship, or business rule is not present in the injected inputs, do not invent it.
- If a constraint cannot be verified against the inputs, mark it as UNVERIFIED rather than assuming correctness.
- Do not claim schema-level enforcement for a business rule that requires triggers, procedures, or application logic unless explicitly designed.
- If an inconsistency between files is found, report it. Do not silently normalize it.

# Lessons Integrated

- Round 1: Added normalization check (Step 8) to detect transitive dependencies.
- Round 1: Gaps must be tagged with target resolution section ([04] or [05]).
- Round 1: Gap list must be deduplicated before finalization.
- Round 1: Logical schema's relationship mapping section must be verified for self-consistency.
- Round 1: Clear distinction between logical documentation gaps (fix in 04) and implementation constraint gaps (defer to 05).
- Round 2: Added project description cross-check to Step 3 for requirement traceability.
- Round 2: Added data type precision review to Step 6.
- Round 2: Added priority column (blocker / important / nice-to-have) to gap summary.
