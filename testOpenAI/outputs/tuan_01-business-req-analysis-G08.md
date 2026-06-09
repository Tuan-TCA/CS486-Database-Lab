# 01 - Business Requirement Analysis

## Source
Based on the Campus Space Management System project specification.

---

# 1. Business Purpose

The purpose of the Campus Space Management System is to help the School of Computer Science manage shared campus spaces efficiently by:

- Managing space booking requests.
- Preventing overlapping bookings.
- Preventing the use of unavailable spaces.
- Managing approvals and check-ins.
- Managing maintenance activities.
- Recording incidents and facility usage history.
- Supporting reporting and utilization monitoring.

---

# 2. Actors

| Actor | Description |
|---------|---------|
| Student | Requests and uses campus spaces. |
| Lecturer | Requests and uses campus spaces. |
| Teaching Assistant | Requests and uses campus spaces. |
| Facility Staff | Approves bookings, performs check-in/check-out, manages maintenance. |
| Department Administrator | Monitors and manages facility usage. |
| Facility Manager | Oversees facilities, approvals, and maintenance operations. |

---

# 3. Main Entities and Attributes

## 3.1 User

**Attributes**

- UserID (PK)
- FullName
- Email
- PhoneNumber
- Role
  - Student
  - Lecturer
  - Teaching Assistant
  - Facility Staff
  - Department Administrator
  - Facility Manager
- Department
- AccountStatus
    ---

## 3.2 Space

**Attributes**
- SpaceCode (PK)
- SpaceName
- SpaceType
- Building
- Floor
- RoomNumber
- Capacity
- CurrentStatus
  - Available
  - In Use
  - Under Maintenance
  - Temporarily Closed
  - Retired
- UsagePolicy
    ---

## 3.3 Facility

**Attributes**
- FacilityID (PK)
- FacilityName
- FacilityType

---

## 3.4 BookingRequest

**Attributes**
- BookingID (PK)
- RequestedStartTime
- RequestedEndTime
- PurposeOfUse
- ExpectedParticipants
- BookingType
- BookingStatus

---

## 3.5 Approval

**Attributes**
- ApprovalID (PK)
- Decision
- DecisionTime
- DecisionNote
- RejectionReason

---

## 3.6 UsageSession

**Attributes**
- SessionID (PK)
- ActualStartTime
- ActualEndTime
- InitialCondition
- FinalCondition
- UsageNotes

---

## 3.7 MaintenanceRecord

**Attributes**
- MaintenanceID (PK)
- ProblemDescription
- StartTime
- CompletionTime
- Status
- ResultNote

---

# 4. Relationships and Cardinalities

## User submits BookingRequest

- User (1) —— (N) BookingRequest

A user may submit many booking requests.

---

## Space receives BookingRequest

- Space (1) —— (N) BookingRequest

A space may be requested many times.

---

## BookingRequest has Approval

- BookingRequest (1) —— (0..1) Approval

A booking may or may not require approval.

---

## Facility Staff performs Approval

- User (1) —— (N) Approval

One staff member may process many approvals.

---

## BookingRequest creates UsageSession

- BookingRequest (1) —— (0..1) UsageSession

Only approved bookings may result in actual usage sessions.

---

## User checks in UsageSession

- User (1) —— (N) UsageSession

Facility staff perform check-in and completion operations.

---

## Space contains Facility

- Space (M) —— (N) Facility

A space may contain multiple facilities.
A facility type may exist in multiple spaces.

---

## Space has MaintenanceRecord

- Space (1) —— (N) MaintenanceRecord

A space may have multiple maintenance records.

---

## User reports MaintenanceRecord

- User (1) —— (N) MaintenanceRecord

A user may report many maintenance issues.

---

## User assigned to MaintenanceRecord

- User (1) —— (N) MaintenanceRecord

A staff member may be assigned multiple maintenance tasks.

---

# 5. Participation Constraints

| Relationship | Participation |
|-------------|--------------|
| BookingRequest -> User | Total |
| BookingRequest -> Space | Total |
| Approval -> BookingRequest | Total |
| UsageSession -> BookingRequest | Total |
| MaintenanceRecord -> Space | Total |
| Space -> Facility | Partial |
| User -> MaintenanceRecord (Reporter) | Total |
| User -> Approval (Approver) | Total |

---

# 6. Business Rules

1. Every user must have a university account.
2. Each user has a unique UserID.
3. Each space has a unique SpaceCode.
4. A space may be available, in use, under maintenance, temporarily closed, or retired.
5. A booking request must specify a space, start time, end time, purpose, and expected participants.
6. The same space cannot have two approved bookings with overlapping time periods.
7. Spaces under maintenance cannot be booked.
8. Spaces marked closed cannot be booked.
9. Retired spaces cannot be booked.
10. A booking may require approval.
11. Approval records must store approver, decision time, and decision note.
12. Rejected bookings must store a rejection reason.
13. Facility staff may check in approved bookings.
14. Actual usage information must be recorded.
15. Maintenance records must track problem description, status, and resolution.
16. Historical booking records must be preserved.
17. Historical maintenance records must be preserved.
18. Staff must be able to view upcoming bookings.
19. Staff must be able to view no-show bookings.
20. Staff must be able to view spaces under maintenance.

---

# 7. Assumptions

1. All actors are represented in the User entity using the Role attribute.
2. Facility Staff and Facility Manager are authorized approvers.
3. Only approved bookings can be checked in.
4. Every maintenance record references exactly one space.
5. A booking references exactly one space.
6. A usage session corresponds to one booking.

