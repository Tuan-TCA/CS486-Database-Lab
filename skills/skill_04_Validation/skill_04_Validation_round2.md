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
- Cardinalities match:
  - `1:N` → FK in the child table.
  - `1:0..1` → UNIQUE FK.

## Step 3: Validate Business Rules

Cross-check each business rule from `01-business-req-analysis-G08.md`:

- Can the rule be enforced at the schema level (PK, FK, UNIQUE, NOT NULL, CHECK)?
- If schema-level enforcement is impossible, is it explicitly documented as an application-level constraint?
- No business rule is silently ignored.

## Step 4: Validate Keys

Check every relation:

- Primary key is well-chosen.
- Candidate keys are correctly identified.
- Foreign keys reference the correct parent table.
- UNIQUE constraints are applied on candidate keys.
- Composite keys are documented.

## Step 5: Validate Relationships

- Every FK matches the cardinality from the ERD.
- `1:N` relationships always put the FK in the N-side table.
- `1:0..1` relationships use a UNIQUE FK constraint.
- Optional relationships allow NULLs where appropriate.
- Mandatory relationships use NOT NULL.
- No extraneous FKs exist beyond what the ERD defines.
- Verify the logical schema's relationship mapping section is self-consistent with the FK definitions.

## Step 6: Validate Constraints

- NOT NULL is applied to all PK attributes and mandatory FK attributes.
- CHECK constraints are proposed for status value sets.
- DEFAULT values are proposed where appropriate.
- Domain types match the attribute semantics.

## Step 7: Generate Validation Report

For each validation dimension:

- List PASS items.
- List FAIL items with explanations.
- Deduplicate identical issues before finalizing.
- Tag each gap with the target resolution section:
  - `[04]` Logical documentation
  - `[05]` Implementation
- Distinguish between
  - Logical documentation gaps
  - Implementation constraint gaps
- If everything passes, state that the design is valid.

## Step 8: Normalization Check

For every relation:

1. Verify 1NF.
2. Verify 2NF.
3. Verify 3NF.
4. If a violation exists, explain the dependency and propose decomposition.

# Checklist

- [ ] All ERD entities are represented.
- [ ] All ERD attributes are mapped correctly.
- [ ] All ERD relationships are implemented.
- [ ] Cardinality `1:N` is correct.
- [ ] Cardinality `1:0..1` uses UNIQUE FK.
- [ ] Every business rule is enforced or documented.
- [ ] Primary keys are correct.
- [ ] Candidate keys use UNIQUE constraints.
- [ ] Foreign key references are correct.
- [ ] NOT NULL matches mandatory participation.
- [ ] FK nullability matches optionality.
- [ ] Status value sets are documented.
- [ ] No extra attributes beyond the ERD.
- [ ] Naming follows AGENT.md conventions.
- [ ] All relations satisfy 3NF.
- [ ] Relationship mapping section is self-consistent.
- [ ] Each gap is tagged with `[04]` or `[05]`.
- [ ] Duplicate gaps are removed.

# Verification Procedure

1. Compare ERD entities with relation list.
2. Compare ERD attributes with relation attributes.
3. Trace every ERD relationship to its FK.
4. Walk through every business rule and classify it as:
   - Schema-Enforced
   - Documented Gap
   - Missing
5. Verify PKs, CKs, and FKs.
6. Review the "Additional Business Constraints" section.
7. Perform a 3NF review for every relation.
8. Remove duplicate gaps.
9. Assign ownership `[04]` or `[05]`.
10. Produce the final validation report.

# Common Mistakes

- Adding attributes not present in the ERD.
- Missing entities.
- Incorrect FK references.
- Missing UNIQUE on `1:0..1` relationships.
- Incorrect FK nullability.
- Claiming application rules are schema-enforced.
- Mixing naming conventions.
- Ignoring candidate keys.
- Missing normalization analysis.
- Reporting duplicate gaps.
- Confusing logical documentation gaps with implementation gaps.
- Forgetting to validate the relationship mapping section.

# Consistency Rules

- Table names must match AGENT.md.
- Column names must match AGENT.md.
- Data types should be consistent across relations.
- Status values must match the Business Requirement Analysis.
- FK names should match referenced PK names where possible.

# Anti-Hallucination Rules

- Do not invent entities, attributes, relationships, or business rules.
- Mark unverifiable items as **UNVERIFIED**.
- Do not claim schema-level enforcement for application-level logic.
- Report inconsistencies rather than silently correcting them.

# Lessons Integrated

- Round 1: Added normalization check (3NF).
- Round 1: Tag each gap with `[04]` or `[05]`.
- Round 1: Deduplicate gap list.
- Round 1: Validate the logical schema's relationship mapping section.
- Round 1: Distinguish logical documentation gaps from implementation constraint gaps.