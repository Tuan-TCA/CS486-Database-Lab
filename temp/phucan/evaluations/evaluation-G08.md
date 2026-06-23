# Phase 1 Evaluation — G08
*Campus Space Booking & Facility Management System*

---

## Overall Verdict

Strong submission. The redesign relative to the earlier draft shows real improvement — the M:N junction table for Space_Facility is architecturally correct, the three-trigger approach to cross-row business rule enforcement is well-executed, and the sample data coverage is genuinely comprehensive. The deliverables are also internally consistent in naming, which is where many groups lose marks.

There are **two bugs that must be fixed before submission** (one in the DDL trigger, one in a query), **one ERD gap**, and **two sample data holes**. Everything else is a minor improvement, not a blocker.

---

## Severity Classification Used

| Label | Meaning |
|---|---|
| 🔴 Critical | Incorrect, would lose marks, must fix |
| 🟡 Significant | Gap or weakness a grader will notice |
| 🟢 Minor | Polish issue or edge case |
| ✅ Strength | Notably good — worth keeping |

---

## 01 — Business Requirement Analysis

**Overall: Good. Clear improvement from the original.**

✅ Status lifecycle diagram (the `Pending → Approved → Checked In → Completed` flowchart) is an excellent addition not required by the rubric — it pre-answers questions a grader might ask about the `status` field.

✅ `Space_Facility` is correctly identified as a separate entity in the Core Entities table, which correctly anticipates the M:N relationship that must become a junction table.

✅ The Assumptions section is honest and well-placed — documenting that overlap prevention requires a trigger rather than a declarative constraint is exactly the kind of self-awareness graders reward.

✅ Open Questions section is a nice professional touch.

---

🟡 **Business Rule 2 ambiguity.** The rule states "A space can only be booked if its status is `Available` or `In Use`." The source requirement says spaces "under maintenance, closed, or retired cannot be booked" — which by exclusion implies `Available` is bookable and `In Use` might be. But `In Use` means someone is actively in the room right now. This is defensible (time-based conflict detection prevents same-slot double-booking regardless), but the rule as written could confuse a reader. Consider clarifying: *"A space with status `Under Maintenance`, `Temporarily Closed`, or `Retired` cannot receive new booking requests."* This directly mirrors the source text.

🟢 Business Rule 8 ("Check-out/completion records actual end time, final condition, and usage notes") omits who performed the completion. The original source says "facility staff can complete the booking" — by parallel construction with check-in (which explicitly records the staff member's identity), the completion staff should also be captured. The decision to omit this was made and carried through consistently, so it's not an inconsistency error, but it is an interpretation gap worth noting.

🟢 The actors table lists "TA" but the role CHECK constraint in the DDL (Step 5) also uses `'TA'`. This is consistent ✅, but the full form "Teaching Assistant" appears in the actors section header. Settle on one form throughout the text body.

---

## 02 — Conceptual ERD Design

**Overall: Solid. The M:N junction table is the right call. One missing relationship line.**

✅ `Space_Facility` correctly modelled as a junction entity with its own `quantity` attribute, and the diagram shows both parent relationships (`Space ||--o{ Space_Facility` and `Facility ||--o{ Space_Facility`). Many groups get this wrong by embedding facility info directly in Space.

✅ `Booking ||--o| Booking_Approval : "has"` — the `o|` (zero-or-one) notation on the Booking_Approval side correctly reflects that a booking may have no approval yet (e.g., still Pending). Good precision.

✅ Domain Value Sets table is an excellent addition — listing allowed values per attribute here means any CHECK constraint drift in the DDL will be immediately visible.

✅ Participation Constraints table is thorough; notably, `assigned_staff_id` in Maintenance is correctly listed as Optional ("issue may not yet be assigned").

---

🔴 **Missing relationship line for `checkin_staff_id`.** The `Booking` entity includes `checkin_staff_id FK` as an attribute, which references `User(user_id)`. But there is no relationship line in the diagram connecting `User` and `Booking` for the check-in role — the only `User → Booking` line is `"submits"` (for the requester). The ERD rule is: *every FK-bearing entity must have a corresponding relationship line for each FK*. A grader checking the ERD against the logical schema will spot this.

**Fix:** Add a line such as:
```
User ||--o{ Booking : "checks_in"
```
And add the corresponding row to the Relationship Summary and Participation Constraints tables.

🟢 Entity names use `PascalCase` (`User`, `Space`, `Booking`, etc.) in the Mermaid diagram, where the convention in SKILL.md specifies `UPPER_SNAKE_CASE`. This is a stylistic inconsistency (both are readable), but the Logical Design (Step 3) uses title-case table names (`User`, `Space`) which then carry into the DDL. As long as Steps 2, 3, and 5 are self-consistent (they are), this is not a grading risk — just noting it.

---

## 03 — Logical Database Design

**Overall: Excellent. The strongest deliverable in the set.**

✅ Candidate Keys table explicitly lists all alternate keys including the composite `(space_code, facility_id)` in `Space_Facility`. This is often glossed over.

✅ FK Constraints Summary table is a genuinely useful addition beyond what the rubric requires — it lists every FK with both parent and child table in one place.

✅ Referential Integrity Rules table with explicit ON DELETE actions (`RESTRICT`, `CASCADE`, `SET NULL`) is professional quality and maps directly to the DDL. Notably, `User → Maintenance (assigned)` uses `SET NULL` which is the correct choice since an unassigned maintenance record is still valid.

✅ The `UNIQUE` constraint on `Booking_Approval.booking_id` and `booking_id` listed as both FK and Candidate Key is correct — this is exactly how a 1:1 optional relationship should be enforced.

---

🟡 **`checkin_staff_id` documented but the "checks_in" relationship is absent from the ERD** (carried forward from the 02 issue). In the FK Constraints Summary, `checkin_staff_id → User(user_id)` is correctly listed and documented. The gap is upstream in the ERD.

🟢 The `Booking` table absorbs what was previously `USAGE_SESSION` (from the original design), resulting in 7 nullable columns (`actual_start_time`, `checkin_staff_id`, `initial_condition`, `actual_end_time`, `final_condition`, `usage_notes`). This is a deliberate denormalization and is in 3NF (all non-key attributes depend on `booking_id`), so it passes normalization. The trade-off is that the Booking table becomes "wide" with many NULLs for rows that haven't been checked in yet. This is noted in Step 4's normalization table as acceptable, which is the correct way to handle deliberate denormalization.

---

## 04 — Database Design Validation

**Overall: Good structure. Two gaps in coverage.**

✅ Traceability Matrix (Section 6) with source file line number references (`project_description.md:15-32`) is strong evidence of methodical validation.

✅ Limitations section honestly flags `checkin_staff_id FK allows any user, not just facility staff` as an application-layer concern.

✅ The overlap detection and rejection reason enforcement are both correctly identified as requiring triggers rather than declarative constraints — and both triggers actually appear in Step 5.

✅ Filtered index on `Booking (space_code, requested_start, requested_end) WHERE status IN (...)` is mentioned in the validation as a performance consideration, then implemented. Good traceability.

---

🟡 **The missing ERD relationship for `checkin_staff_id` is not flagged.** Section 1 (ERD Correctness) marks check-in fields as "Yes / Covered" but does not note that there is no relationship line in the ERD for the `User → Booking (checks_in)` link. The validation's job is to find exactly this kind of gap.

🟡 **Section 3 Normalization lists `Space_Facility` but Section 1 ERD Coverage does not mention it as its own row.** The ERD coverage table groups it under `"Facilities list per space | Facility, Space_Facility | Yes"`. This is fine but slightly ambiguous — a dedicated row for `Space_Facility` (with composite PK, M:N justification) would make the coverage explicit.

🟢 Section 2 Business Rule for "Booking must be approved/rejected by a staff member" is listed as "Booking_Approval table with FK to User; staff role validated at application layer." This is accurate but the validation could also note that the DDL does not enforce that the `staff_id` in `Booking_Approval` belongs to a user with a staff/manager role — it's pure application-layer logic.

---

## 05 — Database Implementation (SQL DDL)

**Overall: Professional quality. One trigger bug that must be fixed.**

✅ Table creation order is correct (parents before children): `User` → `Space` → `Facility` → `Space_Facility` → `Booking` → `Booking_Approval` → `Maintenance`.

✅ All `CHECK` constraint value sets match the domain value tables in Steps 1–2 verbatim. No status value drift.

✅ `DEFAULT GETDATE()` on `booking_time`, `decision_time`, and `start_time` is correctly applied where the requirement implies automatic timestamping.

✅ `UNIQUE (booking_id)` on `Booking_Approval` enforces the 1:1 relationship correctly.

✅ Filtered index `WHERE status IN ('Approved','Checked In','Completed')` on `Booking(space_code, requested_start, requested_end)` is smart — avoids indexing Pending/Rejected/Cancelled rows for the overlap detection hot path.

✅ `trg_RequireRejectionReason` correctly solves the cross-column validation problem (`CHECK` constraints in SQL Server cannot reference other columns in the same row for conditional logic).

---

🔴 **`trg_CheckSpaceAvailability` fires on ALL `UPDATE` operations, including updates to historical bookings.**

The trigger fires whenever any row in `Booking` is inserted or updated. If space `B202` is currently `'Under Maintenance'` and a staff member tries to update `usage_notes` on booking #1 (a historical completed booking that happened when B202 was available), the trigger will roll back that update. Similarly, if a grader runs `UPDATE Booking SET usage_notes = '...' WHERE booking_id = 8` during testing with B202 under maintenance, an unexpected rollback occurs.

**Fix:** Restrict the trigger to only fire when the booking is transitioning to an active/pending state:

```sql
CREATE TRIGGER trg_CheckSpaceAvailability
ON Booking
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Only block new/active bookings, not historical updates
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Space s ON i.space_code = s.space_code
        WHERE s.current_status IN ('Under Maintenance', 'Temporarily Closed', 'Retired')
          AND i.status IN ('Pending', 'Approved')  -- only check active/new bookings
    )
    BEGIN
        RAISERROR('Cannot book this space: it is currently unavailable.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
```

🟡 **No trigger or mechanism to sync `Booking.status` with `Booking_Approval.decision`.** When an approval row is inserted with `decision = 'Approved'`, the parent `Booking.status` is still `'Pending'` until the application explicitly updates it. If someone runs Query 6 (pending bookings) immediately after inserting an approval record (before the app updates the booking status), they will see a booking that has been approved but still appears pending. A trigger on `Booking_Approval` that automatically updates `Booking.status` would make the schema self-consistent:

```sql
CREATE TRIGGER trg_SyncBookingStatus
ON Booking_Approval
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE b
    SET b.status = i.decision  -- 'Approved' or 'Rejected'
    FROM Booking b
    INNER JOIN inserted i ON b.booking_id = i.booking_id;
END;
```

This is not strictly required (application-layer sync is standard practice), but it's a weakness a grader might probe.

🟢 The overlap trigger includes `'Completed'` bookings in its conflict check:
```sql
AND b.status IN ('Approved', 'Checked In', 'Completed')
```
Completed bookings are historical — they ran successfully, so their time slots are in the past. Including them in overlap detection is logically safe (no future booking will overlap a past completed slot), but it is conceptually odd. Consider whether the intent is actually `('Approved', 'Checked In')` for active blocking.

🟢 `Space_Facility` uses `ON DELETE CASCADE` from both parents. This means deleting a `Facility` record removes it from all spaces silently. Whether this is desirable (vs. `RESTRICT` + application-managed removal) is a policy question, but it should be documented as a deliberate choice.

---

## 06 — Sample Data

**Overall: Broad coverage. Two approval record gaps.**

✅ All 7 booking statuses are represented (Pending, Approved, Checked In, Completed, Rejected, Cancelled, No-Show).

✅ All 6 user roles are represented, plus an edge case: a Suspended account (user_id=9, Ivy Vo).

✅ All 5 space statuses are represented (Available, Under Maintenance, Temporarily Closed, Retired, and In Use is implied by the Checked In booking).

✅ Booking #5 (Rejected) correctly has a rejection reason in its approval record — this directly tests `trg_RequireRejectionReason`.

✅ Maintenance records cover all 4 statuses (Open, In Progress, Resolved, Closed is absent but would be trivial to add).

✅ Idempotent `DELETE` in reverse FK order before inserts — safe to run repeatedly during testing.

✅ `IDENTITY_INSERT ON/OFF` used correctly around explicit ID inserts.

---

🟡 **Booking #7 (No-Show) has no `Booking_Approval` record.** A booking can only reach `No-Show` status if it was previously `Approved` (otherwise the requester would never have had reason to show up). The sample data has no approval for booking #7, leaving it in an inconsistent lifecycle state. Add:

```sql
INSERT INTO Booking_Approval (approval_id, booking_id, staff_id, decision_time, decision, decision_note, rejection_reason)
VALUES (5, 7, 4, '2026-06-01 17:00:00', 'Approved', 'Approved for student workspace session.', NULL);
```

🟡 **Booking #8 (Completed) has no `Booking_Approval` record.** A completed booking should have gone through approval before check-in. Add:

```sql
INSERT INTO Booking_Approval (approval_id, booking_id, staff_id, decision_time, decision, decision_note, rejection_reason)
VALUES (6, 8, 5, '2026-05-29 08:00:00', 'Approved', 'Standard lecture booking approved.', NULL);
```

🟢 An overlapping booking test case (inserting a second booking for the same space and time as an Approved booking) would be a strong addition to demonstrate `trg_PreventOverlappingBooking` catching the conflict. For example, booking a second slot for `A102` during `2026-06-01 08:00–10:00` while booking #1 is Completed. The trigger should block it. This isn't required by the rubric but would demonstrate the trigger works in practice.

---

## 07 — Query Design

**Overall: 7 queries is good (exceeds the minimum of 5). One query has a runtime bug.**

✅ Good variety: date-range filter (Q1, Q3), aggregation with `GROUP BY` (Q5, Q7), multi-table `JOIN` (Q2, Q4, Q7), `STRING_AGG` for readable output (Q7), `DATEDIFF` for elapsed time (Q6).

✅ Each query has a clearly stated business question, target user, and rationale in comments — exactly the format required.

✅ Query 4 uses `LEFT JOIN Booking_Approval` correctly — bookings without approval records (Pending, Cancelled) still appear in the history.

✅ Query 6 (pending bookings with `hours_since_submission`) is directly actionable — staff can sort by time waiting and prioritize old requests.

---

🔴 **Query 5 crashes in January.** The date calculation:

```sql
AND b.actual_start_time >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()) - 1, 1)
```

When `GETDATE()` falls in January, `MONTH(GETDATE()) - 1 = 0`. `DATEFROMPARTS` treats month `0` as invalid and throws a runtime error. The query works 11 months of the year but will crash every January.

**Fix:**
```sql
AND b.actual_start_time >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
AND b.actual_start_time <  DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
```

`DATEADD(MONTH, -1, ...)` handles the year rollover (December → November, January → December of the prior year) correctly.

🟡 **Query 2 has a logic gap.** The query uses an `INNER JOIN` between `Space` and `Maintenance`, then the `WHERE` clause is:
```sql
WHERE s.current_status = 'Under Maintenance'
  OR m.status IN ('Open', 'In Progress')
```
Because the join is `INNER`, a space with `current_status = 'Under Maintenance'` but all maintenance records in `Resolved`/`Closed` status would appear (the INNER JOIN matches, but the OR condition evaluates `m.status IN ('Open', 'In Progress')` as false — but `s.current_status = 'Under Maintenance'` as true, so it still shows). This case is actually fine. However, a space with `current_status = 'Under Maintenance'` and **no maintenance records at all** would be missed entirely because the INNER JOIN produces no rows for it. Change to `LEFT JOIN` to catch that edge case.

🟢 **Query 1 returns 0 rows against the sample data.** Space `A101` has no upcoming Approved/Checked In bookings in the sample set (booking #3 for A101 is Pending, not Approved). This isn't wrong, but during demo or grading, a query that returns no rows can appear broken. Consider either adjusting the sample data to include an approved future booking for A101, or parameterizing Query 1 to use a space that has upcoming data.

🟢 **`actual_end_time` can be NULL** in completed bookings if the checkout step was skipped in data entry. Query 5 uses `SUM(DATEDIFF(HOUR, b.actual_start_time, b.actual_end_time))` — if any completed booking has a NULL `actual_end_time`, `DATEDIFF` returns NULL and that booking contributes nothing to the total. A `NULLIF` guard or filtering `AND b.actual_end_time IS NOT NULL` would make the query more robust.

---

## Consolidated Fix List (Priority Order)

| # | Severity | File | Issue | Action |
|---|---|---|---|---|
| 1 | 🔴 Critical | `05-db-definition-G08.sql` | `trg_CheckSpaceAvailability` blocks updates to historical bookings in unavailable spaces | Add `AND i.status IN ('Pending', 'Approved')` to the trigger's WHERE clause |
| 2 | 🔴 Critical | `07-query-design-G08.sql` | Query 5 crashes every January (`MONTH - 1 = 0`) | Replace with `DATEADD(MONTH, -1, DATEFROMPARTS(...))` |
| 3 | 🔴 Critical | `02-erd-design-G08.md` | No relationship line for `checkin_staff_id` FK | Add `User \|\|--o{ Booking : "checks_in"` and update the summary + participation tables |
| 4 | 🟡 Significant | `06-sample-data-G08.sql` | Booking #7 (No-Show) has no approval record | Add approval #5 for booking_id=7 |
| 5 | 🟡 Significant | `06-sample-data-G08.sql` | Booking #8 (Completed) has no approval record | Add approval #6 for booking_id=8 |
| 6 | 🟡 Significant | `07-query-design-G08.sql` | Query 2 INNER JOIN misses spaces with status 'Under Maintenance' but no maintenance records | Change `JOIN Maintenance` to `LEFT JOIN Maintenance` |
| 7 | 🟡 Significant | `04-design-validation-G08.md` | ERD gap for `checkin_staff_id` not flagged in Section 1 | Add a row noting the missing relationship line |
| 8 | 🟢 Minor | `05-db-definition-G08.sql` | No trigger to sync `Booking.status` after approval inserted | Add `trg_SyncBookingStatus` or document as application-layer responsibility |
| 9 | 🟢 Minor | `07-query-design-G08.sql` | Query 1 returns 0 rows against the sample data | Add an approved future A101 booking to sample data |
| 10 | 🟢 Minor | `01-business-req-analysis-G08.md` | Business Rule 2 wording allows "In Use" bookings — clarify intent | Rephrase to match source text ("cannot be booked if status is...") |

---

## What's Working Well (Do Not Change)

- The **three-trigger architecture** (`trg_PreventOverlappingBooking`, `trg_CheckSpaceAvailability`, `trg_RequireRejectionReason`) is the right approach for SQL Server business rule enforcement and shows understanding of cross-row constraint limitations.
- The **filtered index** on Booking with `WHERE status IN (...)` is a performance decision that goes beyond coursework minimums.
- The **Referential Integrity table** in the logical design (with ON DELETE actions) is professional quality.
- The **Domain Value Sets table** in the ERD keeps status vocabularies visible and traceable.
- The **status lifecycle flowchart** in the BRA is an excellent clarifying addition.
- **Sample data idempotency** (DELETE in reverse FK order + IDENTITY_INSERT) means the script can be run repeatedly without errors.
- **Cross-deliverable naming consistency** — entity names, column names, and status values match between all 7 files. This is where most groups lose marks silently.
