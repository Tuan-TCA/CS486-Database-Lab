# 15 – Index Tuning Report

**Project:** Campus Space Management System
**Group:** G08
**Database:** `campus_space_management`
**DBMS:** Microsoft SQL Server 2022
**Compatibility level:** 160

## 1. Objective and Scope

This experiment evaluates indexing and query tuning for the four workloads required by the project:

1. **Booking conflict check**
2. **Room finder** — Query 03
3. **Selected reporting query 1** — Query 01: total approved booking hours per space
4. **Selected reporting query 2** — Query 02: approved booking distribution by weekday and hour

The two reporting queries were selected only from the permitted Query 01–04 range. Query 03 is already used as the required room finder, so Queries 01 and 02 were selected as the two reporting workloads.

The objective is to compare **execution plans, logical reads, and execution times before and after indexing** without changing the semantics of the original queries.

---

## 2. Test Methodology

The same generated database was used for the before and after index tests.

Relevant table sizes were:

| Table                |    Rows |
| -------------------- | ------: |
| `BOOKING_REQUEST`    | 100,030 |
| `BOOKING_DECISION`   |  98,025 |
| `MAINTENANCE_RECORD` |     782 |
| `FACILITY`           |     182 |
| `SPACES`             |      62 |
| `SPACE_TYPE`         |       6 |

The test procedure was:

1. Remove previous experimental tuning indexes.
2. Update statistics using `FULLSCAN`.
3. Execute the four target workloads once as warm-up.
4. Recompile the benchmark procedures.
5. Execute each workload five measured times.
6. Capture:
   - logical reads;
   - physical reads;
   - CPU time;
   - elapsed time;
   - execution-plan access operators.
7. Repeat the complete baseline test three times.
8. Create the candidate indexes.
9. Repeat the same benchmark three times after indexing.

The reported post-index values below are the mean of the three complete after-index runs. SQL Server DMV elapsed time is used as the primary execution-time metric. Wall-clock measurements were also collected but are more susceptible to timer granularity and operating-system scheduling.

---

## 3. Baseline Performance

Before tuning, the target tables had only their primary-key and unique-constraint indexes.

The baseline averages were:

| Target                 | Avg. logical reads | Avg. CPU time (ms) | Avg. elapsed time (ms) |
| ---------------------- | -----------------: | -----------------: | ---------------------: |
| Booking conflict check |              55.00 |               0.31 |                   0.31 |
| Room finder — Q03      |          35,152.20 |             787.48 |                 787.54 |
| Report Q01             |           2,760.00 |              42.28 |                  42.31 |
| Report Q02             |           2,677.00 |              41.35 |                  41.38 |

The room finder was the dominant bottleneck, requiring more than 35,000 logical reads and approximately 788 ms per execution.

### 3.1 Baseline execution-plan observations

The principal access operators were:

| Target           | Important baseline operators                                                                                   |
| ---------------- | -------------------------------------------------------------------------------------------------------------- |
| Booking conflict | `BOOKING_REQUEST`: Clustered Index Scan; `BOOKING_DECISION`: booking-id seek followed by clustered lookup      |
| Room finder Q03  | Clustered Index Scans on `BOOKING_REQUEST`, `FACILITY`, and `MAINTENANCE_RECORD`; booking-decision seek/lookup |
| Report Q01       | Clustered Index Scan on both `BOOKING_REQUEST` and `BOOKING_DECISION`                                          |
| Report Q02       | Clustered Index Scan on both `BOOKING_REQUEST` and `BOOKING_DECISION`                                          |

The repeated scans of the two large booking tables were the main indexing opportunity.

---

## 4. Index Design

Six workload-specific indexes were evaluated.

### 4.1 Booking conflict and room-finder overlap lookup

```sql
CREATE NONCLUSTERED INDEX IX_G08_BR_Space_Start
ON dbo.BOOKING_REQUEST
(
    space_code,
    start_time
)
INCLUDE
(
    end_time,
    status
);
```

The booking overlap condition is based on:

```sql
space_code = ...
AND start_time < @RequestedEnd
AND end_time > @RequestedStart
```

`space_code` is an equality predicate, so it is the first key. `start_time` is the range key. `end_time` and `status` are included so the remaining overlap and cancellation predicates can be evaluated from the nonclustered index.

This index directly supports both the booking conflict check and the booking-conflict portion of the room finder.

---

### 4.2 Query 01 semester-range access

```sql
CREATE NONCLUSTERED INDEX IX_G08_BR_Start
ON dbo.BOOKING_REQUEST
(
    start_time
)
INCLUDE
(
    space_code,
    end_time,
    status
);
```

Query 01 restricts bookings to a semester using `start_time`. Making `start_time` the leading key lets SQL Server perform a range seek instead of scanning all booking requests.

This index also serves as a narrower covering access path for parts of Query 02.

---

### 4.3 Approved-booking join access

```sql
CREATE NONCLUSTERED INDEX IX_G08_BD_Approved_Booking
ON dbo.BOOKING_DECISION
(
    booking_id
)
WHERE is_approved = 1;
```

The tuned workloads repeatedly join a booking to an approved booking decision.

A filtered index is appropriate because:

- only rows with `is_approved = 1` are stored;
- `booking_id` remains the join/seek key;
- the optimizer can avoid the additional clustered lookup previously required to verify `is_approved`.

---

### 4.4 Query 02 decision-time range

```sql
CREATE NONCLUSTERED INDEX IX_G08_BD_Approved_DecisionTime
ON dbo.BOOKING_DECISION
(
    decision_time
)
INCLUDE
(
    booking_id
)
WHERE is_approved = 1;
```

Query 02 filters approved decisions by semester:

```sql
bd.is_approved = 1
AND bd.decision_time >= @SemesterStart
AND bd.decision_time < @SemesterEnd
```

The filtered index restricts the structure to approved decisions, while `decision_time` provides a direct range-seek key.

`booking_id` is included to support the join to `BOOKING_REQUEST`.

The `DATEPART(HOUR, decision_time)` predicate remains a residual predicate because the function is applied to the indexed column. No computed-column redesign was introduced because the experiment was limited to index tuning.

---

### 4.5 Room-finder facilities

```sql
CREATE NONCLUSTERED INDEX IX_G08_Facility_Space_Name
ON dbo.FACILITY
(
    space_code,
    facility_name
);
```

The room finder correlates each candidate space with its required facilities. The composite key permits direct lookup by space and facility name.

---

### 4.6 Room-finder maintenance conflicts

```sql
CREATE NONCLUSTERED INDEX IX_G08_Maint_Space_Impact_Status_Start
ON dbo.MAINTENANCE_RECORD
(
    space_code,
    impact_level,
    status,
    start_time
)
INCLUDE
(
    end_time
);
```

The room finder tests both advisory and out-of-service maintenance. Its predicates contain equality conditions on `space_code`, `impact_level`, and `status`, followed by a time-range test on `start_time`.

This key order allows the equality predicates to narrow the search before applying the time range.

---

## 5. Before-and-After Performance

The following post-index values are averaged across the three complete after-index runs.

| Target                 | Reads before | Reads after | Read reduction | Elapsed before (ms) | Elapsed after (ms) | Time reduction |
| ---------------------- | -----------: | ----------: | -------------: | ------------------: | -----------------: | -------------: |
| Booking conflict check |        55.00 |       14.00 |     **74.55%** |                0.31 |               0.08 |     **73.12%** |
| Room finder — Q03      |    35,152.20 |      953.40 |     **97.29%** |              787.54 |              15.42 |     **98.04%** |
| Report Q01             |     2,760.00 |      641.00 |     **76.78%** |               42.31 |              28.73 |     **32.10%** |
| Report Q02             |     2,677.00 |      829.00 |     **69.03%** |               41.38 |              31.03 |     **25.00%** |

All four target workloads improved after indexing.

The largest improvement occurred in the room finder, whose average elapsed time decreased from approximately **787.54 ms to 15.42 ms**.

---

## 6. Execution-Plan Comparison

### 6.1 Booking Conflict Check

#### Before indexing

```text
BOOKING_REQUEST
└── Clustered Index Scan

BOOKING_DECISION
├── Index Seek on existing UNIQUE(booking_id)
└── Clustered lookup to test is_approved
```

The optimizer had no suitable `BOOKING_REQUEST` index for the combination of `space_code` and time overlap, so it scanned the booking table.

#### After indexing

```text
BOOKING_REQUEST
└── Index Seek: IX_G08_BR_Space_Start

BOOKING_DECISION
└── Index Seek: IX_G08_BD_Approved_Booking
```

The new access path can seek by `space_code` and the `start_time` upper bound, then evaluate `end_time` and `status` from the included columns.

#### Effect

- Logical reads: **55 → 14**
- Reduction: **74.55%**
- Elapsed time: **0.31 ms → 0.08 ms**
- Reduction: **73.12%**

The execution plan therefore changed from a table-wide booking scan to selective nonclustered index seeks.

Because this operation is already sub-millisecond, wall-clock timings are sensitive to timer resolution; logical reads, DMV elapsed time, and the scan-to-seek transition provide stronger evidence of improvement.

---

### 6.2 Room Finder — Query 03

#### Before indexing

The room finder contained several correlated lookups and produced the following important operators:

```text
SPACES
└── Clustered Index Scan

FACILITY
└── Clustered Index Scan

BOOKING_REQUEST
└── Clustered Index Scan

BOOKING_DECISION
├── Index Seek
└── Clustered lookup

MAINTENANCE_RECORD
├── Clustered Index Scan
└── Clustered Index Scan
```

The repeated scans inside the room-availability conditions caused very high I/O and CPU cost.

#### After indexing

```text
SPACES
└── Clustered Index Scan

FACILITY
└── Index Seek: IX_G08_Facility_Space_Name

BOOKING_REQUEST
└── Index Seek: IX_G08_BR_Space_Start

BOOKING_DECISION
└── Index Seek: IX_G08_BD_Approved_Booking

MAINTENANCE_RECORD
├── Index Seek: IX_G08_Maint_Space_Impact_Status_Start
└── Index Seek: IX_G08_Maint_Space_Impact_Status_Start
```

The important large/repeated accesses changed from scans to seeks.

The scan of `SPACES` was intentionally left unchanged because the table contains only **62 rows**. A scan over this small relation is inexpensive, and adding another index solely to eliminate it would create unnecessary maintenance overhead.

#### Effect

- Logical reads: **35,152.20 → 953.40**
- Reduction: **97.29%**
- Elapsed time: **787.54 ms → 15.42 ms**
- Reduction: **98.04%**

This is the strongest improvement in the experiment.

---

### 6.3 Reporting Query 01

Query 01 computes total approved booking hours per space during a semester.

#### Before indexing

```text
BOOKING_REQUEST
└── Clustered Index Scan

BOOKING_DECISION
└── Clustered Index Scan
```

Both large booking relations were scanned.

#### After indexing

```text
BOOKING_REQUEST
└── Index Seek: IX_G08_BR_Start

BOOKING_DECISION
└── Index Scan: IX_G08_BD_Approved_Booking
```

`IX_G08_BR_Start` permits a direct range seek into the semester.

The optimizer still scans the filtered approved-decision index, but this structure is narrower than the clustered `BOOKING_DECISION` table and contains only approved rows. A scan is reasonable because Query 01 processes a large number of approved decisions for aggregation.

#### Effect

- Logical reads: **2,760 → 641**
- Reduction: **76.78%**
- Elapsed time: **42.31 ms → 28.73 ms**
- Reduction: **32.10%**

The logical-read reduction is larger than the elapsed-time reduction because the query must still join and aggregate a substantial number of qualifying rows.

---

### 6.4 Reporting Query 02

Query 02 reports approved booking decisions grouped by weekday and decision hour within the semester.

#### Before indexing

```text
BOOKING_DECISION
└── Clustered Index Scan

BOOKING_REQUEST
└── Clustered Index Scan
```

The optimizer scanned both large booking tables.

#### After indexing

```text
BOOKING_DECISION
└── Index Seek: IX_G08_BD_Approved_DecisionTime

BOOKING_REQUEST
└── Index Scan: IX_G08_BR_Start
```

The most important improvement is on `BOOKING_DECISION`: SQL Server now performs a range seek on the approved-only `decision_time` index.

`BOOKING_REQUEST` remains an index scan because Query 02 does not filter by `BOOKING_REQUEST.start_time`; it mainly needs `booking_id` and `status`. SQL Server nevertheless chooses the narrower `IX_G08_BR_Start` structure instead of the wider clustered table.

The query still applies:

```sql
DATEPART(HOUR, bd.decision_time)
```

as a residual expression. Therefore, indexing can reduce the semester search cost but cannot convert the hour expression into a direct seek without a schema change such as an indexed computed column.

#### Effect

- Logical reads: **2,677 → 829**
- Reduction: **69.03%**
- Elapsed time: **41.38 ms → 31.03 ms**
- Reduction: **25.00%**

The result demonstrates a meaningful reduction in I/O even though the aggregation and `DATEPART` computation still consume CPU.

---

## 7. Index Usage Validation

Post-index usage counters confirmed that the new indexes were selected by SQL Server during the measured workload.

Typical usage per complete benchmark run was:

| Index                                    |     Measured usage |
| ---------------------------------------- | -----------------: |
| `IX_G08_BD_Approved_Booking`             | 12 seeks + 6 scans |
| `IX_G08_BD_Approved_DecisionTime`        |            6 seeks |
| `IX_G08_BR_Space_Start`                  |           12 seeks |
| `IX_G08_BR_Start`                        |  6 seeks + 6 scans |
| `IX_G08_Facility_Space_Name`             |            6 seeks |
| `IX_G08_Maint_Space_Impact_Status_Start` |           12 seeks |

Thus, all six indexes contributed to at least one of the required workloads.

---

## 8. Remaining Missing-Index Recommendation

After tuning, SQL Server still produced one missing-index heuristic:

```sql
CREATE INDEX ... ON dbo.BOOKING_REQUEST(status);
```

This recommendation was **not adopted**.

For Query 02, `status` is used as:

```sql
br.status <> 'cancelled'
```

The post-index plan estimates approximately **93,029 qualifying rows out of 100,030 booking requests**, so the condition is not selective. A standalone `status` index would therefore still need to process most of the table.

Adding it would also impose:

- extra storage;
- additional `INSERT`, `UPDATE`, and `DELETE` maintenance;
- another overlapping index on the high-write `BOOKING_REQUEST` table.

The existing `IX_G08_BR_Start` already provides a narrower covering scan for Query 02. For this workload, retaining the current plan is a more balanced choice than creating an additional low-selectivity index solely because it appears in the missing-index DMV.

Missing-index DMVs were therefore treated as tuning evidence rather than automatic index-creation instructions.

---

## 9. Storage and Maintenance Trade-offs

The six indexes used approximately:

| Index                                    |   Used space |
| ---------------------------------------- | -----------: |
| `IX_G08_BD_Approved_Booking`             |      3.41 MB |
| `IX_G08_BD_Approved_DecisionTime`        |      4.05 MB |
| `IX_G08_BR_Space_Start`                  |      5.77 MB |
| `IX_G08_BR_Start`                        |      5.75 MB |
| `IX_G08_Facility_Space_Name`             |      0.02 MB |
| `IX_G08_Maint_Space_Impact_Status_Start` |      0.07 MB |
| **Total**                                | **19.07 MB** |

The two `BOOKING_REQUEST` indexes account for most of the storage and will increase the cost of booking writes.

They are nevertheless not redundant:

- `(space_code, start_time)` supports same-space conflict and availability searches;
- `(start_time)` supports semester-oriented reporting.

Similarly, the two filtered `BOOKING_DECISION` indexes have different leading keys:

- `booking_id` for approved-decision joins;
- `decision_time` for Query 02's semester range.

The measured performance improvements justify this additional read-optimization cost for the evaluated workload.

---

## 10. Final Recommended Index Set

```sql
CREATE NONCLUSTERED INDEX IX_G08_BR_Space_Start
ON dbo.BOOKING_REQUEST(space_code, start_time)
INCLUDE(end_time, status);

CREATE NONCLUSTERED INDEX IX_G08_BR_Start
ON dbo.BOOKING_REQUEST(start_time)
INCLUDE(space_code, end_time, status);

CREATE NONCLUSTERED INDEX IX_G08_BD_Approved_Booking
ON dbo.BOOKING_DECISION(booking_id)
WHERE is_approved = 1;

CREATE NONCLUSTERED INDEX IX_G08_BD_Approved_DecisionTime
ON dbo.BOOKING_DECISION(decision_time)
INCLUDE(booking_id)
WHERE is_approved = 1;

CREATE NONCLUSTERED INDEX IX_G08_Facility_Space_Name
ON dbo.FACILITY(space_code, facility_name);

CREATE NONCLUSTERED INDEX IX_G08_Maint_Space_Impact_Status_Start
ON dbo.MAINTENANCE_RECORD
    (space_code, impact_level, status, start_time)
INCLUDE(end_time);
```

---

## 11. Conclusion

The indexing experiment successfully improved all four required workloads.

The strongest result was the **room finder**, where logical reads decreased by **97.29%** and average elapsed time decreased by **98.04%**. The **booking conflict check** changed from a clustered scan to selective index seeks and reduced logical reads by **74.55%**. **Query 01** reduced logical reads by **76.78%**, while **Query 02** reduced them by **69.03%**.

The execution plans demonstrate that the gains are attributable to more appropriate access paths rather than timing variation alone:

- large or repeatedly executed clustered scans were replaced by nonclustered index seeks;
- reporting queries used narrower filtered or covering indexes;
- small-table scans were retained where scanning remained inexpensive;
- one low-selectivity `status` index recommendation was intentionally rejected after considering its expected selectivity and write overhead.

Therefore, the final index set provides a measured improvement to the required workload while avoiding unnecessary indexes whose maintenance cost is not justified by the observed query patterns.
