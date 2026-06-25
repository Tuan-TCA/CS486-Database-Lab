# skill_07_QueryDesign.md

## Purpose

Guide the generation of 24 T-SQL queries for the Campus Space Booking system that are syntactically correct, business-accurate, performant, and fully documented. Each query must translate a real business question into executable Microsoft SQL Server (T-SQL) code.

---

## Methodology

### Query Categories (24 queries total)

Organize 24 queries into 8 categories (3 queries each):

| # | Category | Focus |
|---|----------|-------|
| 1-3 | **Booking Operations** | Pending/approved/upcoming bookings |
| 4-6 | **Availability & Conflicts** | Free spaces, overlap detection, non-conflicting slots |
| 7-9 | **Usage & Check-in** | Checked-in sessions, completed sessions, no-shows |
| 10-12 | **Maintenance** | Active maintenance, resolved history, spaces blocked by maintenance |
| 13-15 | **User Activity** | Most active users, user booking history, user role-based queries |
| 16-18 | **Approval Tracking** | Pending approvals, rejection reasons, approval/rejection ratios |
| 19-21 | **Aggregations & Reports** | Occupancy rates, utilization metrics, peak usage times |
| 22-24 | **Advanced Analytics** | Facility usage patterns, booking trends, comparative analysis |

### Checklist Integrity Rule

When applying improvements between rounds, verify that no existing checklist requirement was accidentally removed. In particular:
- If adding `DENSE_RANK()`, ensure `TOP X WITH TIES` is still present in at least one other query
- If fixing one query, do not delete another query's distinguishing syntax feature

### Per-Query Structure

Every query MUST include exactly 4 components in this order:

```
-- Business Question: <question>
-- Target User(s): <user role(s)>
-- Explanation: <why useful>
<SQL statement>
```

---

## Checklist

### Documentation
- [ ] All 24 queries present with sequential numbering
- [ ] Each query has Business Question, Target User(s), Explanation
- [ ] Target users match the question (e.g., Facility Manager for maintenance queries)
- [ ] Explanations describe real business value
- [ ] Schema reference header included at the top of the file listing all table/columns used

### T-SQL Syntax
- [ ] Uses `GETDATE()` for current timestamps (NOT `NOW()`)
- [ ] Uses `DATEDIFF` / `DATEADD` for temporal math
- [ ] Uses `TOP X WITH TIES` for ranking (NOT `LIMIT`)
- [ ] Uses `CAST` for type conversions where needed
- [ ] No PostgreSQL/MySQL syntax (`LIMIT`, `NOW()`, `ILIKE`, `SERIAL`)
- [ ] Table/column names match the DDL exactly

### Business Logic
- [ ] Correct status filtering (`'Approved'`, `'Rejected'`, `'Completed'`, `'No-Show'`, `'Checked In'`, `'Cancelled'`, `'Pending'`)
- [ ] Upcoming queries filter `requested_start_time > GETDATE()`
- [ ] Past queries filter `requested_end_time < GETDATE()`
- [ ] Active maintenance excludes `'Resolved'` and `'Closed'` statuses
- [ ] Bookable spaces exclude `'Under Maintenance'`, `'Temporarily Closed'`, `'Retired'`
- [ ] `LEFT JOIN` used when entities with zero counts must appear
- [ ] Division-by-zero handled with `NULLIF`

### Complexity
- [ ] At least 5 queries use `GROUP BY` with aggregate functions (`COUNT`, `SUM`, `AVG`)
- [ ] At least 3 queries use `CASE WHEN` for conditional logic
- [ ] At least 3 queries use subqueries or `NOT EXISTS`
- [ ] At least 2 queries use `NULLIF` to prevent division-by-zero errors
- [ ] At least 2 queries use `DATEDIFF` or `DATEADD`
- [ ] At least 1 query uses `TOP X WITH TIES`
- [ ] At least 1 query uses a window function (`RANK()` or `DENSE_RANK()`)

### Performance
- [ ] Explicit column list in `SELECT` (avoid `SELECT *`)
- [ ] Filters use indexed columns (`space_code`, `status`, `user_id`, `booking_id`)
- [ ] Availability queries use `NOT EXISTS` instead of `NOT IN`
- [ ] No unnecessary joins (only join tables actually referenced in SELECT/WHERE)
- [ ] Overlap detection uses efficient range comparison
- [ ] Index recommendations included as comments for high-frequency queries (e.g., composite indexes on filtered columns)

---

## Verification Procedure

1. **Syntax check**: Verify every query compiles against the DDL schema
2. **Run against sample data**: Execute against section 06 sample data
3. **Business check**: Does the WHERE clause correctly isolate the intended records?
4. **Edge case check**: What happens when there are zero records? No-shows? All spaces under maintenance?
5. **Performance check**: Would this query scan unnecessary tables or columns?
6. **Regression check**: After applying any fix from ImproveXX, re-verify the full checklist — ensure no existing requirement was accidentally removed

---

## Common Mistakes

1. Using `LIMIT` instead of `TOP X WITH TIES`
2. Using `NOW()` instead of `GETDATE()`
3. Using `INNER JOIN` when `LEFT JOIN` is needed (losing zero-count entities)
4. Forgetting to exclude `cancelled`/`rejected` bookings from active usage queries
5. Not handling division-by-zero (use `NULLIF(denominator, 0)`)
6. Using `SELECT *` in aggregation/reporting queries
7. Missing `WHERE` filters on status for maintenance records (include/exclude resolved)
8. Incorrect overlap detection (using `>=` when `>` is needed or vice versa)
9. Removing a required syntax pattern (e.g., TOP WITH TIES) when fixing a different query issue — always re-check the full checklist after any change

---

## Consistency Rules

- Table names: `[USER]`, `SPACE`, `FACILITY`, `BOOKING_REQUEST`, `BOOKING_APPROVAL`, `USAGE_SESSION`, `MAINTENANCE_RECORD`
- Status values: `'Pending'`, `'Approved'`, `'Rejected'`, `'Cancelled'`, `'Checked In'`, `'Completed'`, `'No-Show'`
- Space statuses: `'Available'`, `'In Use'`, `'Under Maintenance'`, `'Temporarily Closed'`, `'Retired'`
- Maintenance statuses: `'Open'`, `'In Progress'`, `'Resolved'`, `'Closed'`
- Use square brackets `[USER]` for the USER table (reserved word)
- All DATETIME comparisons use `GETDATE()` as baseline

---

## Anti-Hallucination Rules

- Never reference tables or columns not in Agent.md section 3 (Source of Truth)
- Never use syntax features not supported by Microsoft SQL Server
- Never assume existence of indexes, triggers, or views not specified
- Never invent business rules beyond what project_description and Agent define
- If uncertain about a column name, use Agent.md section 3 as the authoritative source
- Cross-check all FK column names against Agent.md relationship definitions
- Column aliases must accurately reflect the business meaning (e.g., use `booking_distribution_pct` not `occupancy_pct` if not measuring true occupancy)
- When calculating waiting time with no `created_at` column, document the limitation and use `requested_start_time` as proxy

---

## Lessons Integrated

### Round 1 → Round 2

- Added schema reference header requirement to Documentation checklist
- Added window functions requirement (`RANK()` / `DENSE_RANK()`) to Complexity checklist
- Added index recommendation requirement to Performance checklist
- Added anti-hallucination rule: column aliases must accurately reflect business meaning
- Added anti-hallucination rule: document limitations when using proxy columns for missing fields

### Round 2 → Round 3

- Added Checklist Integrity Rule to Methodology: fixing one issue must not remove another required feature
- Added common mistake #9: removing a required syntax pattern when fixing a different query
- Added regression check step to Verification Procedure (step 6)
- Reinforced: maintain TOP WITH TIES coverage alongside window functions
