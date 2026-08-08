# 13 - Concurrency Tests (G08)

These scripts demonstrate the booking-approval race and its prevention using the
locking strategy implemented in `12-concurrency-implementation-G08.sql`.

The protected procedure uses this lock order:

```text
UPDLOCK BOOKING_REQUEST(booking_id)
              |
              v
UPDLOCK SPACES(space_code)
              |
              v
Check approved overlap
              |
              v
Approve if safe
```

The first `UPDLOCK` keeps the selected booking request stable for the transaction.
The second `UPDLOCK` serializes all approval attempts for the same space.

## Prerequisites

Run these first:

```text
10-schema-migration-G08.sql
12-concurrency-implementation-G08.sql
```

Use two SQL Server query windows connected to:

```text
campus_space_management
```

---

## Part A - Demonstrate the unsafe race

1. Run `01-setup.sql` once.
2. Run `02-unsafe-session-A.sql` in Window A.
3. During Session A's 12-second delay, run `03-unsafe-session-B.sql` in Window B.
4. After both sessions finish, run `04-verify-unsafe.sql`.

Expected result:

```text
G08_UNSAFE_B1 -> approved
G08_UNSAFE_B2 -> approved

approved_booking_count          = 2
overlapping_approved_pair_count = 1
```

This demonstrates the check-then-act race when the overlap check and approval
are performed without the protected locking protocol.

---

## Part B - Demonstrate prevention

1. Run `05-reset.sql`.
2. Run `06-safe-session-A.sql` in Window A.
3. During Session A's 12-second hold, run `07-safe-session-B.sql` in Window B.
4. Run `08-verify-safe.sql`.

Expected sequence:

```text
Window A:
    U(BOOKING_REQUEST G08_SAFE_B1) -> GRANTED
    U(SPACES G08_CONC_ROOM)        -> GRANTED
    holds both locks for 12 seconds

Window B:
    U(BOOKING_REQUEST G08_SAFE_B2) -> GRANTED
    U(SPACES G08_CONC_ROOM)        -> WAIT

Window A:
    approves G08_SAFE_B1
    COMMIT
    releases locks

Window B:
    obtains U(SPACES G08_CONC_ROOM)
    re-checks overlap
    sees G08_SAFE_B1
    receives error 52105
    ROLLBACK
```

Final expected result:

```text
approved_booking_count          = 1
overlapping_approved_pair_count = 0
```

---

## Cleanup

Run:

```text
09-cleanup.sql
```

The unsafe scripts intentionally bypass
`dbo.usp_G08_ApproveBookingConcurrentSafe` so the race can be reproduced.

The safe scripts use the protected procedure and therefore follow the required
`BOOKING_REQUEST -> SPACES` locking order.
