# Improve - Section 07: Query Design

## Round Summary

| Round | Score | Main Findings | Agent Updates | Skill Updates | Future Opportunities |
| ----- | ----- | ----------- | ------------- | ------------- | -------------------- |
| 1     | 7.2/10 | Postgres syntax hallucination (`LIMIT`); Column name hallucination (`status` vs `current_status`); Missing division-by-zero handling. | None | Add strict T-SQL guardrails; mandate explicit column mapping checks; mandate `NULLIF` for division. | Enforce complex SQL constructs earlier. |
| 2     | 8.5/10 | Used `INNER JOIN` causing zero-count entities to disappear; still lacked temporal context for the sample data execution. | None | Mandate `LEFT JOIN` for aggregations; add "Checklist Integrity Rule" to prevent regressions. | Better temporal anchoring. |
| 3     | 10/10 | Flawless 24-query T-SQL execution with window functions, safe aggregations, and data-aware temporal anchoring (`@ReportDate`). | None | Mandate relative date anchoring or explicitly documented static date variables for sample data querying. | None |

---

## Round 1

### Evaluation

Score: 7.2/10

Strengths

- Successfully generated 24 queries across all 8 required categories.
- Documented Business Questions, Target Users, and Explanations for all 24 queries.

Issues

- **Postgres Syntax Hallucination:** Used `LIMIT 3` in Query 8 instead of T-SQL's `TOP 3 WITH TIES`.
- **Column Hallucination:** Used `SPACE.status` instead of `SPACE.current_status` in Query 4 and Query 6, causing execution failure against the DDL.
- **Division-by-Zero Risk:** Query 14 and Query 20 performed raw division without `NULLIF()`, which crashes if zero entities exist.

### Improvements

Agent Updates
- None

Skill Updates
- **Anti-Hallucination Guardrails:** Explicitly list `current_status` vs `status` in common mistakes. 
- **T-SQL Enforcements:** Add strict prohibition of MySQL/PostgreSQL syntax (`LIMIT`).
- **NULLIF Mandate:** Add explicit checklist requirement for division safety.

---

## Round 2

### Evaluation

Score: 8.5/10

Strengths

- All syntax errors fixed (T-SQL compliant). Column names accurately mapped.
- `NULLIF` implemented successfully.

Issues

- **Data Loss via INNER JOIN:** Query 13 (User Booking History) used `INNER JOIN`, completely dropping users who had exactly 0 bookings. Business reports usually require seeing zeroes.
- **Temporal Disconnect:** Query 1 filtered via `requested_start_time > GETDATE()`. Because the sample data is statically rooted in June/July 2026, running this query today returns zero rows.

### Improvements

Agent Updates
- None

Skill Updates
- **Aggregation Joins:** Add rule: `LEFT JOIN` used when entities with zero counts must appear.
- **Temporal Anchoring:** Require the use of explicit `DECLARE @ReportDate` or data-anchored timestamps when querying static sample sets to ensure reproducibility.

---

## Round 3

### Evaluation

Score: 10/10

Strengths

- Perfect execution of all 24 T-SQL queries.
- Zero division-by-zero risks (`NULLIF` utilized).
- `LEFT JOIN` correctly applied, returning accurate zero-state entities.
- Advanced analytics successfully implement `RANK() OVER()` and `PARTITION BY`.
- All queries simulate execution as of `'2026-06-30 20:00:00'` to perfectly align with the Section 06 sample data.

Issues
- None.

### Improvements

Agent Updates
- None

Skill Updates
- None

---

Final score: 10/10 (Achieved in Round 3)
