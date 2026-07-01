# Skill 06: Sample Data Preparation (Round 1 Baseline Snapshot)

# Purpose
Insert realistic sample data to support testing of normal operations and important exceptional cases. Produces a single idempotent `.sql` file of INSERT statements that covers every booking status, every user role, every space type, and every maintenance status.

# Methodology
1. **Dependency Order:** 
   - `DELETE` in reverse order.
   - `INSERT` in forward order (`USER` and `SPACE` first).
2. **Nullable FKs:** `USAGE_SESSION.completed_by_user_id` and `MAINTENANCE_RECORD.assigned_staff_user_id` can be NULL.
3. **Idempotency:** Always begin with DELETE statements.
4. **Explicit values:** Do not rely on DEFAULT values.
5. **Consistency:** Ensure bookings in 'Checked In' or 'Completed' status have corresponding records in `USAGE_SESSION`.

# Verification
1. Mentally execute and validate the SQL INSERT statements.
2. Ensure Foreign Key dependencies are respected.
3. Ensure all statuses and roles are represented.
