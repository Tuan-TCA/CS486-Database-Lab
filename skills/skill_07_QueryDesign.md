---
name: Query-Design
description: >
  Design and execute 24 meaningful SQL queries for the Campus Space Booking system that are 
  syntactically correct, business-accurate, performant, and fully documented.
  Produces a single .md file containing the business questions, target users, explanations, and T-SQL code blocks.
---

# Skill: Query Design

This skill governs how to produce `result_roundN.sql` for Section 07 (Query Design). Read this file in full before writing any queries.

---

## Context Scope
1. `doc/project_description.md`
2. `agent/Agent.md`
3. `experiments/section_03/result_round3.md` (Logical Schema)
4. `experiments/section_05/result_round3.sql` (DDL)
5. `experiments/section_06/result_round4.sql` (Sample Data)

YOU MUST READ THE `project_description.md` FIRST
USE `evaluation_07.md` FOR SCORING AND EVALUATION IN `improve07.md`
YOUR OUTPUT MUST BE IN THE `experiments/section_07` with the name `result_roundN.md` 

---

## Phase 1 — Exploration

Before planning, confirm these facts from the context files:

1. **Query Requirements:** The project requires **24 meaningful T-SQL queries** (satisfying the requirement of ~5 per student for a group).
2. **Components per Query:** Every query MUST include exactly 4 components:
   - Business Question
   - Target User(s)
   - Explanation
   - T-SQL Statement
3. **Complexity Requirements:** 
   - At least 5 queries use `GROUP BY` with aggregate functions (`COUNT`, `SUM`, `AVG`).
   - At least 3 queries use `CASE WHEN`.
   - At least 3 queries use subqueries or `NOT EXISTS`.
   - At least 2 queries use `NULLIF` (to prevent division-by-zero).
   - At least 2 queries use `DATEDIFF` or `DATEADD`.
   - At least 1 query uses `TOP X WITH TIES`.
   - At least 1 query uses a window function (`RANK()` or `DENSE_RANK()`).

---

## Phase 2 — Planning

Organize your 24 queries into these 8 specific categories (3 queries each) in your working notes before executing:

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

*Note: A "meaningful" query involves JOINs, WHERE clauses, and logic. `SELECT * FROM Table` is not acceptable.*

---

## Phase 3 — Execution

### File Structure
Produce a single `.md` file structured as follows:

```markdown
# Section 07: Query Design

*Schema Reference: Includes USER, SPACE, FACILITY, BOOKING_REQUEST, BOOKING_APPROVAL, USAGE_SESSION, MAINTENANCE_RECORD*

## Category 1: Booking Operations

### Query 1: [Short Title]
**Business Question:** [Exact question]
**Target User(s):** [Roles]
**Explanation:** [Why this is useful]
**SQL Statement:**
\```sql
SELECT ...
\```
```

### SQL Rules
- **Dialect:** Microsoft SQL Server (T-SQL). No PostgreSQL/MySQL syntax (`LIMIT`, `NOW()`, `ILIKE`).
- **Identifiers:** Use fully qualified column names (e.g., `SPACE.space_name`). Use square brackets `[USER]` for the USER table since it is a reserved word.
- **Dates:** Use `GETDATE()` for current timestamps. If comparing against static sample data, explicitly document why hardcoded dates are used or use `DATEADD` to create rolling windows relative to static dates.
- **Performance:** Explicit column list in `SELECT` (no `SELECT *`). Use `NOT EXISTS` instead of `NOT IN`. Add index recommendation comments above high-frequency queries.
- **Logic:** Division-by-zero MUST be handled with `NULLIF(denominator, 0)`.

---

## Verification Loop

**Step 1: Syntax & Execution Verification**
Mentally execute each SQL statement against the schema from Section 05.
* Do all referenced columns exist with the EXACT spelling from `Agent.md`? (e.g., `current_status`, not `status` for `SPACE`).
* Are `GROUP BY` clauses correctly including all non-aggregated `SELECT` columns?

**Step 2: The Logical Checklist & Self-Improvement**
Copy and paste this exact checklist into the `### Verification Checklist` section of your round log:

```markdown
### Verification Checklist
* [ ] Exactly 24 meaningful T-SQL queries are provided: PASS/FAIL - (Notes)
* [ ] Each query includes Business Question, Target User(s), Explanation, and SQL: PASS/FAIL - (Notes)
* [ ] T-SQL specific syntax used (TOP X WITH TIES instead of LIMIT, GETDATE() instead of NOW()): PASS/FAIL - (Notes)
* [ ] Complexity requirements met (Aggregates, CASE WHEN, Window functions, NULLIF): PASS/FAIL - (Notes)
* [ ] No hallucinated column names or tables: PASS/FAIL - (Notes)
* [ ] Division-by-zero risks mitigated with NULLIF: PASS/FAIL - (Notes)
```

---

## Common Mistakes (from prior evaluation rounds)

1. **Checklist Integrity Drop:** Removing a required syntax pattern (like `TOP X WITH TIES`) when fixing a completely different query in a later round. Always re-verify the full complexity requirements after any change!
2. **Hallucinated Columns (CRITICAL):** Using `SPACE.status` instead of `SPACE.current_status`, or `BOOKING.status` instead of `BOOKING_REQUEST.status`. Check `Agent.md` for exact column names.
3. **Using PostgreSQL/MySQL Syntax:** Using `LIMIT 10` instead of `TOP 10`. Using `NOW()` instead of `GETDATE()`.
4. **Invalid `GROUP BY`:** Writing queries like `SELECT space_code, space_name, COUNT(booking_id) FROM BOOKING_REQUEST JOIN SPACE... GROUP BY space_code`. In SQL Server, `space_name` must also be in the `GROUP BY` clause.
5. **Losing Zero-Count Entities:** Using `INNER JOIN` instead of `LEFT JOIN` when answering questions like "Find all spaces and their number of bookings" (spaces with 0 bookings disappear).
6. **Alias Hallucination:** Naming a column `occupancy_pct` when it actually calculates `booking_distribution_pct`. Aliases must accurately reflect the mathematical business meaning.

---

## Anti-Hallucination Rules

- Never reference tables or columns not in Agent.md section 3 (Source of Truth).
- Never use syntax features not supported by Microsoft SQL Server.
- Never assume existence of indexes, triggers, or views not specified.
- If calculating waiting time with no `created_at` column, explicitly document the limitation in the explanation and use `requested_start_time` as a proxy.

---

## Evolution & Lessons Integrated

**Round 1 → Round 2**
- Added strict T-SQL enforcements (banning `LIMIT` and Postgres syntax).
- Enforced `NULLIF` checking to prevent division-by-zero crashes.
- Emphasized explicit column matching (`current_status` vs `status`) to avoid DDL hallucination.

**Round 2 → Round 3**
- Instituted the `LEFT JOIN` rule for aggregations so zero-state counts do not drop.
- Added strict Temporal Anchoring rules (use `@ReportDate` declarations instead of `GETDATE()` when interacting with the statically-dated sample data from Section 06).
