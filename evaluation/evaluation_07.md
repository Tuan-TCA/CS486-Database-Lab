# evaluation_07.md

# Evaluation Rubric - Section 07: Query Design

Total Score: 10 points

This rubric evaluates whether the generated SQL queries are syntactically accurate, highly performant, and fully aligned with the defined business requirements of the system.

Evaluation must compare against:

- Original business requirement documentation
- ERD and Logical database design
- SQL DDL implementation (Section 05)
- Microsoft SQL Server (T-SQL) syntax standards

This section emphasizes the ability to translate human business questions into performant, accurate, and readable database queries.

---

# 1. Requirement Fulfillment & Documentation (2 points)

Evaluate whether the query set meets the strict structural requirements defined in the project template.

Expected components for EVERY query:

- Business Question
- Target User(s)
- Short Explanation Of Why The Query Is Useful
- SQL Statement

Evaluate whether:

- All 24 required queries are present.
- The documentation comments correctly precede the SQL block.
- The targeted users make sense for the business question being asked.

Scoring:

- 2.0 = Complete, all 24 queries are fully documented and functional
- 1.0 = Minor missing documentation or incomplete explanations
- 0.0 = Major sections missing or queries fail to follow the comment structure

---

# 2. Syntactic Correctness & T-SQL Compliance (2 points)

Evaluate whether the SQL code is error-free and natively follows Microsoft SQL Server conventions.

Check for:

- Correct usage of T-SQL specific temporal functions (`GETDATE()`, `DATEDIFF`).
- Proper grouping and selection logic (`TOP 1 WITH TIES` instead of `LIMIT`).
- Correct syntax for filtering and casting (`CAST`, `NULLIF`).
- Valid join conditions (avoiding accidental Cartesian products/cross-joins).

Common mistakes:

- Using PostgreSQL or MySQL syntax (e.g., `LIMIT`, `NOW()`).
- Syntax errors that prevent compilation.
- Referencing tables or columns that do not exist in the DDL.

Scoring:

- 2.0 = Perfect syntax, no execution errors, strictly T-SQL
- 1.0 = Minor syntax warnings or generic SQL usage instead of optimized T-SQL
- 0.0 = Queries fail to compile or major syntax errors present

---

# 3. Business Logic & Filtering Accuracy (2 points)

Evaluate whether the SQL mathematically and logically solves the actual business problem described.

Check for:

- Status filtering: Does the query correctly exclude `cancelled` or `rejected` bookings when calculating active usage?
- Temporal logic: Do "upcoming" queries properly check `> GETDATE()`? Do "past" queries check `< GETDATE()`?
- Edge cases: Does the query properly account for spaces under maintenance or no-shows?

Common mistakes:

- Pulling all records when only 'approved' records were requested.
- Mathematical errors in occupancy or no-show rate calculations.
- Using `INNER JOIN` when a `LEFT JOIN` is required (e.g., finding spaces with *zero* bookings).

Scoring:

- 2.0 = Directly and accurately solves the business problems
- 1.0 = Loosely related or contains minor filtering bugs
- 0.0 = Fails to provide meaningful or accurate insights

---

# 4. Complexity & Aggregation Coverage (2 points)

Evaluate whether the agent demonstrated a robust range of relational database capabilities appropriate for a management system.

Check for:

- Aggregations: Proper use of `COUNT`, `SUM`, `AVG`, and `GROUP BY`.
- Conditional Logic: Usage of `CASE WHEN` statements for pivot-style metrics.
- Subqueries/EXISTS: Usage of nested queries or `NOT EXISTS` to find availability.
- Advanced capabilities: Handling division by zero errors using `NULLIF`.

Scoring:

- 2.0 = High variety (Aggregations, conditional logic, temporal math, subqueries)
- 1.0 = Mostly basic `SELECT *` statements with simple `WHERE` clauses
- 0.0 = Inadequate complexity for a business intelligence or operational system

---

# 5. Performance & Query Optimization (2 points)

Evaluate whether queries are written to minimize Optimizer Cost and resource consumption.

Check for:

- Explicit column selection (e.g., `SELECT space_name, capacity` instead of `SELECT *` where possible).
- Efficient filtering (using indexed columns like `space_code` or `status`).
- Avoiding unnecessary joins.
- Optimized availability checking (using `NOT EXISTS` rather than heavy `NOT IN` subqueries).

Scoring:

- 2.0 = Highly optimized, minimal data scanning
- 1.0 = Sub-optimal query structure that functions but is inefficient
- 0.0 = Queries likely to cause severe performance degradation on large datasets (e.g., forced full table scans)

---

# Technical Evaluation Checklist

**Documentation & Structure**
□ All 24 queries exist.
□ Business Question, Target User(s), and Useful Explanations are present.

**T-SQL Syntax**
□ Uses `GETDATE()` for current timestamps.
□ Uses `DATEDIFF` or `DATEADD` for temporal math.
□ Uses `TOP X` (or `TOP X WITH TIES`) for ranking queries.

**Relational Logic**
□ Proper use of `LEFT JOIN` to identify entities with zero activity (e.g., spaces with no bookings).
□ Correct status filtering (`approved`, `rejected`, `completed`, `no_show`).
□ Handles mathematical division by zero securely (e.g., `NULLIF`).

**Performance**
□ Overlap detection / In-progress logic is efficiently written.
□ Avoids `SELECT *` on large reporting aggregations.

---

# General Evaluation Principles

1. Use this rubric for every experiment round.

2. Compare generated outputs against:
- Original project requirements
- ERD
- Logical database design
- SQL DDL implementation

3. Accuracy is paramount. A query that runs fast but returns wrong business data is a failure.

4. Penalize PostgreSQL/MySQL syntax heavily, as the target engine is SQL Server.

5. Penalize incorrect JOIN types heavily (e.g., missing records due to an `INNER JOIN` instead of a `LEFT JOIN`).

6. Reward optimized queries that explicitly handle edge cases (like division by zero).

7. Minor formatting or indentation inconsistencies should not significantly reduce the score.

---

# Suggested Evaluation Template

Score: __ / 10

## Strengths

- ...
- ...

## Issues

- ...
- ...

## Recommended Improvements

### Query Refinements

- ...

### Performance Optimizations

- ...

## Overall Observation

...