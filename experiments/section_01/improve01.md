# Improve - Section 01: Business Requirement Analysis

## Round Summary

| Round | Score | Main Issues | Agent Updates | Skill Updates |
| ----- | ----- | ----------- | ------------- | ------------- |
| 1     | 7.2/10 | Missing domain value enumerations, missing staff reporting requirements, no workflow descriptions, no assumptions/scope sections, flat business rules | Add verification step: cross-check result against project description enumerated lists | Add domain value extraction step, staff view requirements section, workflow descriptions, assumptions section, scope boundaries, categorized business rules |
| 2     | 8.2/10 | Missing explicit relationships/cardinalities, inconsistent diagram (CANCELLED state missing), inferred enumerations missing (Account/Maintenance Statuses), Role-Action matrix precision issues | Align role actions with prompt descriptions | Add Relationships & Cardinalities section, require diagram validation against text, require enumerating inferred statuses and adding them to assumptions, require Role-Action Matrix alignment |
| 3     | 9.5/10 | Minor formatting polish needed | Applied missed verification rules from R1/R2 to Agent.md | None |

---

## Round 1

### Evaluation

Score: 7.2/10

Strengths

- All 7 entities correctly identified with attributes matching Agent.md exactly
- All 6 actors correctly listed with no hallucinated roles
- Business Purpose narrative is well-written and accurately captures the "why"
- All 11 business rules from Agent.md are present and correctly stated
- Entity attribute tables include proper PK/FK/constraint annotations
- No hallucinated attributes or entities were introduced

Issues

- **Missing enumerated domain values:** The project description explicitly lists Space Types (6 values: Auditorium, Classroom, Computer Laboratory, Project Laboratory, Meeting Room, Student Workspace), Space Statuses (5 values), Booking Types (7 values), Booking Statuses (7 values), Facility examples (6 values), and Maintenance problem types (5 values). While some of these appear in attribute descriptions within the result, they are not systematically extracted as a dedicated domain values reference.
- **Missing staff reporting/view requirements:** The project description states staff should be able to view "Booking History, Upcoming Bookings, Spaces Under Maintenance, No-show Bookings" — these are functional requirements that were not captured in the result.
- **Missing maintenance problem types enumeration:** Project description lists Broken Projectors, Air-conditioning Failure, Damaged Furniture, Cleaning Issues, Network Problems as specific problem categories.
- **No role-based access rules:** Actor descriptions list responsibilities but no explicit rules about which roles can perform which actions (e.g., who can approve bookings, who can perform check-ins).
- **No workflow/process descriptions:** Booking lifecycle (Submit → Pending → Approved/Rejected → Checked In → Completed/No-show) and Maintenance lifecycle are implicit from statuses but never described as workflows.
- **No assumptions section:** The result does not document inferred or assumed requirements (e.g., assumptions about single-department users, booking time granularity).
- **No scope boundaries:** No explicit statement of what is in-scope vs. out-of-scope for the system.
- **Business rules are flat-listed:** All 11 rules in a single numbered list without categorization (booking constraints, space constraints, data preservation, etc.).
- **Rules 2 and 3 relationship unclear:** Rule 2 (spaces with certain statuses cannot be booked) and Rule 3 (spaces with active maintenance cannot be booked) overlap conceptually but their distinct enforcement points are not clarified.

Evaluator Overreach (rejected — conflicts with Agent.md source of truth)

- Adding `facility_id` FK to MAINTENANCE_RECORD — not in Agent.md
- Adding `created_at` timestamps to entities — not in Agent.md
- Adding `decision` attribute to BOOKING_APPROVAL — not in Agent.md
- Adding `status`/`condition`/`quantity` to FACILITY — not in Agent.md

These suggestions would modify the entity schema defined in Agent.md Section 3, which is the source of truth. The evaluator overstepped by proposing schema changes. No action taken.

### Improvements

Agent Updates

- **Verification: cross-check enumerated values.** Before finalizing any result, verify that all enumerated lists from the project description (status values, type values, domain categories) are explicitly captured in the output. Add to Agent.md Section 6 (Verification Behavior): "Verify that all domain value enumerations from the project description are extracted and listed."
- **Verification: cross-check functional requirements.** Ensure staff view/reporting requirements stated in the project description are captured even when they don't map to entity attributes. Add to verification checklist: "Verify that functional/view requirements from the project description are documented."

Skill Updates

- **Add Domain Value Enumeration section (Section 3.5 or similar).** The skill should instruct the agent to extract and list all enumerated domain values from the project description in a dedicated subsection. This includes:
  - Space Types: Auditorium, Classroom, Computer Laboratory, Project Laboratory, Meeting Room, Student Workspace
  - Space Statuses: Available, In Use, Under Maintenance, Temporarily Closed, Retired
  - Booking Types: Lecture, Examination, Seminar, Workshop, Meeting, Student Activity, Administrative Event
  - Booking Statuses: Pending, Approved, Rejected, Cancelled, Checked In, Completed, No-show
  - Facility Examples: Projector, Whiteboard, Microphone, Computer, Livestreaming Equipment, Air Conditioner
  - Maintenance Problem Types: Broken Projectors, Air-conditioning Failure, Damaged Furniture, Cleaning Issues, Network Problems
- **Add Staff View/Reporting Requirements section.** The skill should instruct the agent to capture functional requirements for staff views: Booking History, Upcoming Bookings, Spaces Under Maintenance, No-show Bookings.
- **Add Workflow/Lifecycle Descriptions section.** The skill should instruct the agent to describe key process flows:
  - Booking lifecycle: Submit → Pending → Approved/Rejected → (if approved) Checked In → Completed/No-show → (if rejected) preserve rejection_reason
  - Maintenance lifecycle: Report → Assign → In Progress → Completed
- **Add Assumptions section.** The skill should instruct the agent to document any inferred requirements or assumptions not explicitly stated in the project description.
- **Add Scope Boundaries section.** The skill should instruct the agent to define what is in-scope (booking, approval, usage tracking, maintenance) and out-of-scope (billing, external calendar sync, notifications, etc.).
- **Categorize Business Rules.** The skill should instruct the agent to organize business rules by category rather than a flat list:
  - Booking Constraints (Rules 1, 4)
  - Space Availability Constraints (Rules 2, 3)
  - Approval Rules (Rules 5, 7)
  - Usage Session Rules (Rules 6, 8, 9)
  - Data Integrity Rules (Rules 10, 11)
- **Clarify Rules 2 vs 3 relationship.** The skill should instruct the agent to add a clarification note explaining that Rule 2 checks the space's `current_status` field while Rule 3 checks for existence of active MAINTENANCE_RECORD rows — these are two distinct enforcement mechanisms.
- **Add Role-Action Matrix.** The skill should instruct the agent to define which actors can perform which key actions (submit bookings, approve bookings, check-in, report maintenance, etc.) based on the actor descriptions in the project description.
- **Update Verification Checklist.** Add the following checks to skill_01_BR.md Section 4:
  - [ ] Are all enumerated domain values from the project description listed?
  - [ ] Are staff view/reporting requirements captured?
  - [ ] Are booking and maintenance lifecycle workflows described?
  - [ ] Are assumptions explicitly documented?
  - [ ] Are scope boundaries defined?
  - [ ] Are business rules categorized?

---

## Round 2

### Evaluation

Score: 8.2/10

Strengths

- The previous round's improvements were successfully implemented, including added enumerations, reporting requirements, workflow descriptions, assumptions, scope boundaries, and categorized business rules.

Issues

- **Missing Explicit Relationships & Cardinalities:** The Phase 1 project description implicitly requires mapping relationships and cardinalities (e.g., USER (1) to BOOKING_REQUEST (N)). A dedicated section is needed.
- **Inconsistent Diagram:** The Booking Lifecycle ASCII diagram omits the CANCELLED state, even though the text beneath describes it.
- **Inferred Enumerations Missing:** Account Statuses and Maintenance Statuses were used but not enumerated in Section 4. They are not in the project description. They should be enumerated, AND they must be explicitly declared in the Assumptions section as inferred values since the prompt did not provide them.
- **Role-Action Matrix Precision:** The matrix gave Check-in and Complete operational actions to the Facility Manager, but the text only mentions Facility Staff. This needs to be strictly aligned or stated as an assumption.

### Improvements

Agent Updates

- **Verification: strictly align role actions.** Before finalizing the Role-Action matrix, cross-check against project description roles to ensure no unauthorized role actions are inferred without being explicitly stated as assumptions.

Skill Updates

- **Add Explicit Relationships & Cardinalities section.** The skill should instruct the agent to include a dedicated section mapping entity relationships and cardinalities explicitly (e.g., USER (1) to BOOKING_REQUEST (N)).
- **Fix Diagram Accuracy.** Update the skill to require validation of the Booking Lifecycle ASCII diagram so it matches the accompanying text exactly, including the CANCELLED state.
- **Inferred Enumerations & Assumptions.** The skill should instruct the agent to enumerate inferred values (like Account Statuses and Maintenance Statuses) in the enumerations section, and explicitly declare them in the Assumptions section since they were not provided in the project description.
- **Role-Action Alignment.** The skill should instruct the agent to strictly align the Role-Action Matrix with the exact roles provided in the prompt (e.g., Check-in and Complete are for Facility Staff, not Facility Manager), or state any deviations as explicit assumptions.

---

## Round 3

### Evaluation

Score: 9.5/10

Strengths

- Successfully integrated Section 3.5 tracking 11 distinct explicit relationships.
- The Booking Lifecycle ASCII diagram now accurately visualizes the `CANCELLED` state.
- `Account Statuses` and `Maintenance Statuses` are clearly listed as inferred domain enumerations and accurately logged in the Assumptions section.
- Role actions were successfully reduced for the Facility Manager to strictly align with operational limitations outlined in the prompt (preventing hallucinated Check-in/Completion duties).
- Clean Space Status Lifecycle diagram introduced.

Issues

- None significant.

### Improvements

Agent Updates

- Applied the missing `Verification Behavior` additions from Round 1 and Round 2 to `Agent.md` (verifying domain enumerations, functional requirements, and Role-Action alignment).

Skill Updates

- None

---

## Overall Summary

Initial weaknesses

- Missing domain value enumerations, functional reporting requirements, workflow descriptions, assumptions, and scope boundaries.
- Flat listing of business rules and lack of explicit relationships and cardinalities.

Major improvements

- Added comprehensive domain value extraction, staff view requirements, and categorized business rules.
- Included explicit relationships, cardinalities, and diagram logic validations.
- Handled inferred values, missing rules, and missing roles correctly by using an Assumptions section.
- Fixed ASCII diagram discrepancies and strictly limited Role-Action capabilities to avoid hallucination.

Final observations

- By strictly relying on Agent.md as the source of truth, we successfully documented requirements without hallucination. Using an explicit Assumptions section safely accommodated missing logic (e.g., account statuses, capacity rules) and ensured strict role-action alignment and state diagrams.

Final score: 9.5/10

---

## Rules

Agent Updates

- Hallucination
- Requirement traceability
- Naming consistency
- Output formatting
- Reasoning process
- Verification behavior

Skill Updates

- Missing entities
- Missing relationships
- Missing cardinalities
- Missing participation constraints
- Missing keys
- Incorrect SQL
- Missing edge cases
