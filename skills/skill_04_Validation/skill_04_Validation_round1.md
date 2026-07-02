# skill_04_round1.md

# Purpose

Provide a reusable methodology for validating the logical database design (relational schema) of the Campus Space Management System against the conceptual ERD and business requirements.

# Methodology

## Step 1: Collect Inputs

Load:

1. Project Description
2. Business Requirement Analysis
3. ERD Design
4. Logical Database Design

---

## Step 2: Validate ERD Representation

Verify:

- Every ERD entity maps to exactly one relation.
- Every ERD attribute appears in the corresponding relation.
- Every ERD relationship is implemented via foreign keys.
- Cardinalities are correctly represented.

---

## Step 3: Validate Business Rules

Cross-check business rules.

Determine whether each rule is

- Schema-enforced
- Application-level
- Missing

---

## Step 4: Validate Keys

Verify

- PK
- Candidate Keys
- FK
- UNIQUE

---

## Step 5: Validate Relationships

Verify

- FK placement
- Cardinalities
- Optional vs mandatory participation
- No unnecessary FK

---

## Step 6: Validate Constraints

Review

- NOT NULL
- CHECK
- DEFAULT
- Domain types

---

## Step 7: Generate Validation Report

Produce

- PASS
- FAIL
- Overall assessment

# Checklist

...

# Common Mistakes

...

# Consistency Rules

...

# Anti-Hallucination Rules

...
