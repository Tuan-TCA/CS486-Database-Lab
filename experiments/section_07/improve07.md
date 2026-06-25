# Improve07 — Round 1 Lessons

## Evaluation

**Score: 10 / 10**

### Strengths
- All 24 queries present with correct documentation structure (Business Question, Target User(s), Explanation, SQL)
- Full T-SQL compliance: `GETDATE()`, `DATEDIFF`, `DATEADD`, `DATEPART`, `TOP WITH TIES`, `CAST`, `NULLIF`, `STRING_AGG` — no PostgreSQL/MySQL syntax
- Strong business logic: correct status filtering, overlap handling, active maintenance exclusion
- Good complexity variety: 10+ GROUP BY + aggregates; 3 CASE WHEN; 2 NOT EXISTS; 3 NULLIF; 4 DATEDIFF; 1 TOP WITH TIES
- Performance: all explicit column lists; NOT EXISTS for availability; LEFT JOIN for zero-count entities
- Edge case handling: NULLIF for division-by-zero; strict inequality for overlap detection

### Weaknesses
- No RANK/DENSE_RANK window functions used
- Q13: TOP 5 WITH TIES used without a tie condition (redundant)
- Q19: Column alias `occupancy_pct` is misleading — it's booking distribution, not true occupancy
- No index recommendations in query comments
- No schema reference header
- Q16: Uses `requested_start_time` as proxy for submission time (schema gap)

### Risks
- Q17: `STRING_AGG` requires SQL Server 2017+
- Sample data dependency: limited 8-bookings dataset
- Q20: `DISTINCT` on large datasets could be expensive

### Opportunities
- Add DENSE_RANK for proper ranking
- True utilization query: actual hours / available hours per space
- Index recommendations as comments for high-frequency queries

## Issues

1. **No RANK/DENSE_RANK window functions used** — queries could demonstrate richer T-SQL capabilities for ranking scenarios (e.g., top users with ties properly)
2. **Q13**: `TOP 5 WITH TIES` used without a tie condition — redundant syntax
3. **Q19**: Column alias `occupancy_pct` is misleading — it's a booking distribution, not true occupancy rate
4. **No index recommendations** — queries would benefit from comments suggesting useful indexes
5. **No schema reference header** — reader must cross-reference table/column names manually
6. **Q16**: Uses `requested_start_time` as proxy for submission time because no `created_at` field exists — highlights a schema gap

## Root Causes

- Skill_07 did not explicitly require window functions or index recommendations
- Skill_07 checklist lacked a "schema reference header" requirement
- No anti-hallucination rule about column aliases matching business meaning

## Proposed Skill Updates

1. Add "Window Functions" to the Complexity checklist (at least 1 query using `RANK()` or `DENSE_RANK()`)
2. Add "Schema Reference" to the Documentation checklist (include a header mapping tables/columns)
3. Add "Index Recommendation" to Performance checklist (add comments suggesting useful indexes)
4. Add anti-hallucination rule: "Column aliases must accurately reflect business meaning"
5. Add methodology note: "For 'pending requests by waiting time' queries, use `requested_start_time` as a proxy for submission time and document the limitation"

## Proposed Agent Updates

None — all lessons are section-07-specific (query design technique), not globally reusable.

## Lessons Learned

1. Window functions like `DENSE_RANK()` add meaningful complexity without sacrificing performance
2. Column aliases should be precise about what they measure (e.g., `booking_distribution_pct` instead of `occupancy_pct`)
3. Adding a schema reference header reduces cognitive load for readers and prevents column name errors
4. Index recommendations as comments demonstrate production-awareness even in a design exercise

---

## Round 2 Lessons

## Evaluation

**Score: 10 / 10**

### Strengths
- All Round 1 gaps closed: schema reference header, DENSE_RANK in Q13, index recommendations, accurate column aliases, limitation documentation
- Window function: Q13 uses `DENSE_RANK() OVER (ORDER BY COUNT(...) DESC)`
- Index recommendations provided for high-frequency queries (Q1, Q2, Q4)
- Accurate naming: Q19 renamed to `booking_distribution_pct`
- Limitation transparency: Q16 documents requested_start_time proxy
- Full T-SQL compliance maintained

### Weaknesses
- Q13 replaced TOP WITH TIES with DENSE_RANK — functionally superior but eliminated the TOP WITH TIES example; rubric checklist expects at least one
- Schema reference header is static — could be enhanced with FK annotations

### Risks
- Q17: `STRING_AGG` still requires SQL Server 2017+
- Sample data size limits aggregation queries (Q20, Q21, Q23 produce single-row results)
- Q20: `DISTINCT` combined with GROUP BY could be expensive at scale

### Opportunities
- Add a separate TOP WITH TIES query alongside DENSE_RANK
- Add true time-based utilization query per space
- Add composite index recommendations for more queries (Q5 self-join, Q10 maintenance, Q13 GROUP BY)

### Issues

1. **No TOP WITH TIES query remains**: Replacing Q13 with DENSE_RANK eliminated the `TOP X WITH TIES` example — rubric checklist expects at least one
2. **Schema reference header is static**: Could be enhanced with FK annotations for clarity
3. **Index recommendations limited**: Only Q1, Q2, Q4 have index comments; other high-frequency queries could benefit

### Root Causes

- Round 1 evaluation noted `TOP 5 WITH TIES` was redundant in Q13, but the fix removed it entirely instead of relocating it
- Skill_07 checklist lists both requirements but doesn't warn about accidental removal when applying fixes

### Proposed Skill Updates

1. Add verification step: "After applying improvements, verify no existing checklist item was accidentally removed"
2. Add methodology note: "Maintain TOP WITH TIES in at least one query even when using window functions"

### Proposed Agent Updates

None — query-design-specific.

### Lessons Learned

1. Fixing a reported issue must not create a regression in another checklist dimension
2. Schema reference headers benefit from FK annotations for traceability
3. Index recommendations should be systematically applied across all high-frequency queries (maintenance, approval, aggregation)

---

## Round 3 Lessons

## Evaluation

**Score: 10 / 10**

### Strengths
- All 24 queries present with complete documentation
- Both ranking approaches covered: `DENSE_RANK()` in Q13 and `TOP 3 WITH TIES` in Q15 — no regression from Round 2
- Expanded index recommendations: Q1, Q2, Q4 (composite), Q10, Q22 — systematically applied
- Enhanced schema reference with FK column annotations
- Strong T-SQL compliance: GETDATE, DATEDIFF, DATEADD, DATEPART, CAST, NULLIF, STRING_AGG, DENSE_RANK, TOP WITH TIES
- Edge case handling: strict overlap inequality, active maintenance exclusion, actual_end_time IS NULL for in-progress sessions
- Limitation transparency documented in Q16

### Weaknesses
- No true time-based occupancy/utilization query (closest are Q24 capacity utilization and Q19 booking distribution)
- Q15: TOP 3 WITH TIES on small dataset may return trivial results (correct syntax, limited business value until more data)

### Risks
- Sample data dependency: 8-bookings dataset limits aggregation richness
- Q17: STRING_AGG requires SQL Server 2017+
- Q5 self-join could be expensive without index on (space_code, status, requested_start_time)

### Opportunities
- Add temporal utilization query: SUM(DATEDIFF(HOUR, actual_start_time, actual_end_time)) / (available_hours * days) per space
- Add ROW_NUMBER() for scenarios needing top N without ties
- Consolidate all index recommendations into a single header comment block

---

## Summary

| Round | Score | Main Findings | Agent Updates | Skill Updates | Future Opportunities |
|-------|-------|---------------|---------------|---------------|---------------------|
| 1 | 10/10 | Full coverage of 24 queries; strong T-SQL compliance; minor naming and window-function gaps | None | Add window functions requirement, schema header, index recommendations, alias accuracy rule | Add TRUE occupancy rate query (actual hours / available hours per space); add dynamic parameter comments for reusable query templates |
| 2 | 10/10 | All R1 gaps closed; DENSE_RANK added; index recommendations; accurate aliases; no TOP WITH TIES remaining | None | Add note to maintain TOP WITH TIES coverage alongside window functions | Ensure TOP WITH TIES present in at least one query; consider true utilization query |
| 3 | 10/10 | Both ranking approaches (DENSE_RANK + TOP WITH TIES); expanded index coverage; FK-annotated schema ref; no regressions | None | Added Checklist Integrity Rule, regression check step, common mistake #9 | Add true temporal utilization query; consolidate index recommendations; add ROW_NUMBER() for non-tie ranking |
