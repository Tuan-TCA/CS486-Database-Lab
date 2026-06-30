# Improve - Section 06: Sample Data Preparation

## Round Summary

| Round | Score | Main Findings | Agent Updates | Skill Updates | Future Opportunities |
| ----- | ----- | ----------- | ------------- | ------------- | -------------------- |
| 1     | 7.5/10 | Missed NO-SHOW approval requirement; Stale dates breaking Query 5; Missed facilities for closed spaces. | None | Mandate concrete dates within the recent past month; mandate facilities for closed spaces. | Ensure dynamic querying doesn't hard-fail on static data. |
| 2     | 8.8/10 | Fixed dates and facilities, but retained NO-SHOW lifecycle error. | None | Add explicit warning that NO-SHOW requires a prior Approved status. | Catch lifecycle logic errors earlier. |
| 3     | 9/10 | Missed 'In Use'/'Closed' statuses; temporal collisions between maintenance and bookings; stale future states (past-due pending); zombie sessions. | None | Mandate state synchronization (Checked In = In Use); mandate temporal realism (Pending/Approved must be in future); prevent maintenance/booking overlaps. | Implement time-shifting scripts or dynamic GETDATE() offsets for sample data. |
| 4     | 10/10 | Perfect implementation covering all edge cases, rules, lifecycles, and temporal realism correctly. | None | None | None |

---

## Round 1

### Evaluation

Score: 7.5/10

Strengths

- The `DELETE` statements are correctly ordered in reverse FK dependency, and `INSERT` statements follow the correct forward dependency order.
- All required coverage matrices (Booking Statuses, User Roles, Space Statuses) are successfully represented in the data.
- The data uses realistic descriptions for facility equipment, rejection reasons, and maintenance notes.

Issues

- **Missing `decision` Column:** The `INSERT INTO BOOKING_APPROVAL` statement completely omits the `decision` column in both the column list and the values. (Note: Evaluator hallucinated this based on an older conceptual draft, but the lack of approval for the No-Show booking *is* a real lifecycle violation).
- **Stale Date Values:** The script uses dates from 2023 instead of 2026. This violates the instruction to "Use dates in the most recent past month" and will cause Query 5 (which filters for the previous calendar month) to return empty results.
- **Missing Facilities for Closed/Retired Spaces:** While SP05 (Under Maintenance) has facilities, SP06 (Temporarily Closed) and SP07 (Retired) have no facility records. 

### Improvements

Agent Updates

- None

Skill Updates

- **Date Stability:** Add a strict rule to use concrete dates in the most recent past month (e.g. 2026) to prevent reporting queries from breaking.
- **Facility Coverage:** Add a rule that even spaces that are 'Under Maintenance', 'Temporarily Closed', or 'Retired' must have `FACILITY` records. A closed room does not lose its physical assets.

---

## Round 2

### Evaluation

Score: 8.8/10

Strengths

- Dates successfully shifted to 2026 to support Query 5.
- `FACILITY` records added for closed/retired spaces (SP06, SP07).

Issues

- **Lifecycle Violation (No-Show):** The No-Show booking (Booking 8) still does not have a corresponding `BOOKING_APPROVAL` record. A No-Show can only logically occur if a booking was first approved.

### Improvements

Agent Updates

- None

Skill Updates

- **Lifecycle Validity:** Add a critical rule emphasizing that a `No-Show` booking can ONLY occur if there is a corresponding `BOOKING_APPROVAL` with an 'Approved' decision.

---

## Round 3

### Evaluation

Score: 9/10

Strengths

- Strict reverse-order `DELETE` and forward-order `INSERT`.
- All edge cases, including suspended users (to test app-layer logic), no-shows with valid prior approvals, and closed spaces with facilities, are represented.

Issues

- **Missing Domain Values (Sneaky Bug):** The data failed to include the `In Use` status for any `SPACE`, and failed to include the `Closed` status for any `MAINTENANCE_RECORD`.
- **State Inconsistency (Sneaky Bug):** SP02 has an active, in-progress 'Checked In' session (Booking 3), but the space status is incorrectly listed as 'Available' instead of 'In Use'.
- **Temporal Collision (Sneaky Bug):** Booking 1 (Completed) occurred exactly during the window of Maintenance 1 (SP01, 2026-05-01 10:00 to 2026-05-02 10:00). Logically, a completed student activity cannot take place in a room that is actively under maintenance.
- **Stale Future States & Zombie Sessions (Sneaky Bug):** Relative to the current system date (June 30, 2026), Bookings 4 (Approved) and 5 (Pending) are scheduled for June 15 and June 20—they are past-due. Additionally, Booking 3 has been 'Checked In' without checking out for 29 days.

### Improvements

Agent Updates

- None

Skill Updates

- **State Synchronization:** Add a rule that if a booking is 'Checked In', the corresponding space MUST be 'In Use'.
- **Temporal Realism:** Add a rule that 'Pending' and 'Approved' bookings must be scheduled in the *future* relative to the execution date, while 'Completed' and 'Rejected' must be in the past.
- **Collision Prevention:** Add a rule to manually verify that maintenance record timeframes do not logically overlap with completed booking timeframes in the sample data.

---

## Round 4

### Evaluation

Score: 10/10

Strengths

- Flawless sample data generation with absolute logical, temporal, and relational consistency.
- All 5 Space statuses and 4 Maintenance statuses are fully represented.
- Active 'Checked In' sessions are properly mirrored by 'In Use' space statuses.
- Future states (Pending/Approved) are correctly time-shifted to July 2026, avoiding past-due anomalies.
- Maintenance windows are cleanly separated from completed booking windows.

Issues

- None.

### Improvements

Agent Updates

- None

Skill Updates

- None

---

## Overall Summary

Initial weaknesses

- The sample data generation correctly handled basic referential integrity but struggled with implicit lifecycle dependencies (e.g., No-Show requiring an Approval) and physical reality (closed spaces still have facilities).

Major improvements

- Iteratively hardened the skill to include strict rules around lifecycle validity and time-bound data mapping to support future queries.

Final score: 10/10 (Achieved in Round 4)
