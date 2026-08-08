# 11 - Concurrency Design (G08)

## 1. Scope

The concurrency deliverables add only the logic needed to prevent two
overlapping bookings for the same space from being approved concurrently.

---

## 2. Identified Conflict

Two pending bookings request the same space during overlapping periods:

```text
Booking A: 09:00-11:00
Booking B: 10:00-12:00
```

Without serialization, two sessions can execute this sequence:

| Step | Session A | Session B |
|---|---|---|
| 1 | Checks for an approved overlap; none exists | |
| 2 | | Checks for an approved overlap; none exists |
| 3 | Waits | Approves Booking B and commits |
| 4 | Approves Booking A and commits | |

Both sessions performed the conflict check before either approval was visible.
The final state contains two overlapping approved bookings.

This is a check-then-act race. It can occur between:

- two staff members;
- a staff member and the automatic approval process; or
- two automatic approval workers.

The existing unique constraint on `BOOKING_DECISION.booking_id` prevents two
decisions for the same booking, but it does not prevent different overlapping
bookings from both being approved.

---

## 3. Required Invariant

For one `space_code`, two approved and non-cancelled bookings must not satisfy:

```text
existing.start_time < candidate.end_time
AND candidate.start_time < existing.end_time
```

Intervals are treated as half-open:

```text
[start_time, end_time)
```

Therefore, a booking ending at 10:00 does not overlap another booking starting
at 10:00.

---

## 4. Selected Solution

The implementation uses a transaction-owned SQL Server application lock keyed
by space:

```text
SPACE_BOOKING:<space_code>
```

The lock is obtained through `sys.sp_getapplock` using:

```text
LockMode  = Exclusive
LockOwner = Transaction
```

Only one protected approval transaction can hold the lock for a particular
space at a time. Approvals for different spaces use different lock resources
and may continue concurrently.

---

## 5. Protected Approval Sequence

`dbo.usp_G08_ApproveBookingConcurrentSafe` performs only the
concurrency-specific workflow:

1. Start a transaction.
2. Read the booking only to obtain its `space_code`.
3. Acquire `SPACE_BOOKING:<space_code>`.
4. Reload the booking while holding the lock.
5. Confirm that it is still pending.
6. Check for another approved, non-cancelled overlapping booking.
7. Insert the approved `BOOKING_DECISION`.
8. Change the booking status to `approved`.
9. Commit.

All existing constraints, triggers, and other database-side checks remain active
when the procedure performs the insert and update. File 12 does not recreate
them.

The conflict check and both writes are inside the same transaction and are
covered by the same space lock.

---

## 6. Why the Solution Works

Assume Session A and Session B approve overlapping requests for the same space.

1. Both request the same application-lock resource.
2. Only one session obtains the exclusive lock.
3. The first session checks the current committed state, approves, and commits.
4. The second session then obtains the lock.
5. It repeats the overlap check and sees the first committed approval.
6. It rolls back with a controlled conflict error.

Therefore, both overlapping requests cannot be approved through the protected
procedure.

---
