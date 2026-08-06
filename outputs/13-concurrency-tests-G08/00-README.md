# 13 - Concurrency Tests (G08)

These scripts demonstrate one conflict and its prevention without recreating
the constraints, triggers, or general checks already supplied by the database.

## Prerequisites

Run:

```text
10-schema-migration-G08.sql
12-concurrency-implementation-G08.sql
```

Use two SQL Server query windows connected to `campus_space_management`.

## Part A: demonstrate the unsafe race

1. Run `01-setup.sql` once.
2. Run `02-unsafe-session-A.sql` in Window A.
3. During its 12-second wait, run `03-unsafe-session-B.sql` in Window B.
4. Run `04-verify-unsafe.sql`.

Expected: both overlapping bookings become approved.

## Part B: demonstrate prevention

1. Run `05-reset.sql`.
2. Run `06-safe-session-A.sql` in Window A.
3. During its 12-second hold, run `07-safe-session-B.sql` in Window B.
4. Run `08-verify-safe.sql`.

Expected:

- Window B waits for Window A;
- Window A approves its request;
- Window B then receives error 52107; and
- exactly one protected booking is approved.

## Cleanup

Run `09-cleanup.sql`.

The unsafe scripts deliberately use direct check-then-write SQL to reproduce the
race. The safe scripts use `dbo.usp_G08_ApproveBookingConcurrentSafe`.
