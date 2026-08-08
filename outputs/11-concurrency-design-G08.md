# 11 - Concurrency Design (G08)

## 1. Scope

This design prevents two overlapping bookings for the same space from being approved concurrently.

The solution uses SQL Server pessimistic locking with `UPDLOCK`. It does not use application locks, `HOLDLOCK`, or a transaction-wide `SERIALIZABLE` isolation level.

---

## 2. Identified Conflict

Assume two pending bookings request the same space during overlapping periods:

```text
Booking A: A101, 09:00-11:00
Booking B: A101, 10:00-12:00
```

Without concurrency control, both sessions can check for overlap before either approval commits:

| Step | Session A | Session B |
|---|---|---|
| 1 | Checks overlap; none exists | |
| 2 | | Checks overlap; none exists |
| 3 | Approves Booking A | |
| 4 | | Approves Booking B |
| 5 | Commits | Commits |

The final state contains two overlapping approved bookings. This is a **check-then-act race**.

The unique constraint on `BOOKING_DECISION.booking_id` only prevents multiple decisions for the same booking. It does not prevent two different overlapping bookings from both being approved.

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

Therefore, `09:00-10:00` and `10:00-11:00` do not overlap.

---

## 4. Selected Locking Strategy

The transaction locks resources in this order:

```text
BOOKING_REQUEST(booking_id)
          |
          v
SPACES(space_code)
          |
          v
Check overlap
          |
          v
Approve if safe
```

### 4.1 Lock the booking request first

The target booking is read with `UPDLOCK` immediately:

```sql
SELECT
    @space_code = br.space_code,
    @start_time = br.start_time,
    @end_time = br.end_time,
    @status = br.status
FROM dbo.BOOKING_REQUEST AS br WITH (UPDLOCK)
WHERE br.booking_id = @booking_id;
```

This gives the procedure all values required for the approval and prevents another incompatible update from changing the same booking while the transaction is active.

Because this first read is protected by `UPDLOCK`, the booking values remain stable until `COMMIT` or `ROLLBACK`. Therefore, the procedure does **not** need to re-read or reload the booking later.

Example:

```text
Session A:
U(BOOKING_REQUEST B001) -> GRANTED

Another session tries to update B001:
X(BOOKING_REQUEST B001) -> WAIT
```

### 4.2 Lock the space second

After obtaining `space_code`, the procedure locks the corresponding existing row in `SPACES`:

```sql
SELECT @space_lock_code = s.space_code
FROM dbo.SPACES AS s WITH (UPDLOCK)
WHERE s.space_code = @space_code;
```

Every approval transaction for the same space requests an Update lock on the same `SPACES` row.

```text
Session A -> U(SPACES A101) -> GRANTED
Session B -> U(SPACES A101) -> WAIT
```

Two Update locks on the same resource are incompatible, so only one approval workflow for a space can enter the overlap-check-and-write section at a time.

The Update locks remain held until the transaction ends.

---

## 5. Relevant Lock Compatibility

| Existing lock | Another `S` | Another `U` | Another `X` |
|---|---:|---:|---:|
| `S` | Compatible | Compatible | Blocked |
| `U` | Compatible | Blocked | Blocked |
| `X` | Blocked | Blocked | Blocked |

The key rule for this design is:

```text
U + U = Blocked
```

An ordinary Shared read can still coexist with an Update lock, so normal readers are not unnecessarily blocked.

---

## 6. Why Lock `BOOKING_REQUEST` First?

The booking contains the values used by the approval decision:

```text
space_code
start_time
end_time
status
```

If the first read were not protected, these values could become stale while the transaction waited for the `SPACES` lock.

With `UPDLOCK` on the first read:

```text
read booking
     |
     v
hold U lock on booking
     |
     v
booking cannot be incompatibly modified
     |
     v
lock SPACES row
```

The transaction prevents the stale-value problem instead of allowing the row to change and then re-reading it later.

---

## 7. Why the `SPACES` Lock Is Still Required

Locking only the booking row is not enough.

Two overlapping requests are different rows:

```text
B001 -> A101
B002 -> A101
```

Session A can hold `U(B001)` while Session B holds `U(B002)` because they are different resources.

The common resource is the space row:

```text
B001 ----+
         +--> U(SPACES A101)
B002 ----+
```

That common `SPACES` lock serializes approvals for the same physical space.

---

## 8. Protected Approval Sequence

`dbo.usp_G08_ApproveBookingConcurrentSafe` performs:

1. Start a transaction.
2. Read and `UPDLOCK` the target `BOOKING_REQUEST` row.
3. Confirm the booking exists and is still `pending`.
4. Obtain `UPDLOCK` on the corresponding `SPACES` row.
5. Check for another approved, non-cancelled overlapping booking.
6. Insert the approved `BOOKING_DECISION`.
7. Change the booking status to `approved`.
8. Commit.

The two important Update locks remain held until Step 8:

```text
U(BOOKING_REQUEST booking_id)
U(SPACES space_code)
```

---

## 9. Timeline Example

Assume:

```text
B001 -> A101 -> 09:00-11:00
B002 -> A101 -> 10:00-12:00
```

```text
Time ---------------------------------------------------------------------->

Session A                              Session B

BEGIN                                  BEGIN

U(B001) -> GRANTED                     U(B002) -> GRANTED

U(SPACES A101) -> GRANTED              requests U(SPACES A101)
                                       WAIT
                                       |
check overlap -> none                  |
                                       |
insert approval for B001               |
update B001 -> approved                |
                                       |
COMMIT                                 |
release U(B001)                        |
release U(SPACES A101)                 |
                                       v
                                       U(SPACES A101) -> GRANTED

                                       check overlap
                                       -> finds approved B001

                                       THROW overlap error
                                       ROLLBACK
```

The second transaction performs its overlap check only after the first transaction commits, so it sees the first approval and cannot approve the conflicting booking.

---

## 10. Different Spaces Can Proceed Concurrently

```text
Session A -> U(SPACES A101) -> GRANTED
Session B -> U(SPACES B202) -> GRANTED
```

Different spaces use different rows, so they can be processed concurrently.

---

## 11. New Booking Requests

The per-space Update lock is part of the approval workflow, not ordinary request submission.

A new pending request for the same space may still be inserted while another booking is being approved, subject to normal database constraints.

When that request is later approved, it follows the same protocol:

```text
UPDLOCK BOOKING_REQUEST
          |
          v
UPDLOCK SPACES
          |
          v
Check overlap
          |
          v
Approve if safe
```

---

## 12. Required Lock Ordering

The procedure consistently locks:

```text
BOOKING_REQUEST
      |
      v
SPACES
```

Other workflows that need both resources should use the same order where practical. Consistent lock ordering reduces deadlock risk.

---

## 13. Required Approval Protocol

Every path that can approve a booking must follow the same protocol:

```text
Staff approval -----------+
Automatic approval -------+--> lock BOOKING_REQUEST
Other approval path ------+           |
                                      v
                               lock SPACES row
                                      |
                                      v
                               check overlap
                                      |
                                      v
                               approve if safe
```

If an approval path bypasses the `SPACES` lock and directly writes an approved decision, it can reintroduce the race condition.

---

## 14. Why This Solution Is Appropriate

This design is suitable because:

- the booking row already exists;
- the space row already exists;
- `UPDLOCK` keeps the booking values stable from the first read;
- no second booking read is required;
- the `SPACES` row gives every booking for that space one common serialization point;
- different spaces can still proceed concurrently;
- the overlap check and both approval writes occur in the same transaction.

The central rule is:

> Lock the booking request first to keep its values stable, then lock the corresponding space to serialize approval decisions for that space.
