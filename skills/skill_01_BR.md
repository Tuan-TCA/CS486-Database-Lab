# Skill 01: Business Requirement Analysis

## 1. Context Scope

When working on this step, only load the following files into context:

- Initial project prompt/brief
- `AGENT.md` (Sections 3, 4, 5, and 6)
- `evaluations/evaluation-01.md` (if available)

## 2. Required Document Structure

Your output must be formatted as a Markdown document with the following distinct sections. Do not embed narrative explanations into tables.

- **1. Business Purpose:** A dedicated narrative paragraph explaining the "why" behind the system (replacing manual spreadsheets, enforcing no double-booking at the data level). Do not put this in a table.
- **2. System Actors:** A bulleted list of the system actors with brief descriptions. You must use exactly: Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, and Facility Manager.
- **3. Entities and Attributes:** Markdown tables defining the 7 core entities and their attributes exactly as defined in `AGENT.md` Section 3.
- **3.5 Relationships & Cardinalities:** Explicitly map out the 1:N and 1:1 relationships between the entities (e.g., `USER (1) to BOOKING_REQUEST (N)`). **CRITICAL:** Do not conflate relationships. If an entity has multiple foreign keys to another (e.g., `USAGE_SESSION` has `checked_in_by_user_id` and `completed_by_user_id`), list each relationship distinctly.
- **4. Domain Value Enumerations:** A dedicated subsection listing ALL enumerated domain values from the project description:
  - Space Types: Auditorium, Classroom, Computer Laboratory, Project Laboratory, Meeting Room, Student Workspace
  - Space Statuses: Available, In Use, Under Maintenance, Temporarily Closed, Retired
  - Booking Types: Lecture, Examination, Seminar, Workshop, Meeting, Student Activity, Administrative Event
  - Booking Statuses: Pending, Approved, Rejected, Cancelled, Checked In, Completed, No-show
  - Facility Examples: Projector, Whiteboard, Microphone, Computer, Livestreaming Equipment, Air Conditioner
  - Maintenance Problem Types: Broken Projectors, Air-conditioning Failure, Damaged Furniture, Cleaning Issues, Network Problems
  - Inferred Values (MUST enumerate these but explicitly declare them as inferred in Assumptions): Account Statuses, Maintenance Statuses.
- **5. Business Rules:** A numbered list of all business rules exactly as defined in `AGENT.md` Section 4, **organized by category**:
  - Booking Constraints (Rules 1, 4)
  - Space Availability Constraints (Rules 2, 3) — include a clarification note: Rule 2 checks the space's `current_status` field; Rule 3 checks for existence of active `MAINTENANCE_RECORD` rows. These are two distinct enforcement mechanisms.
  - Approval Rules (Rules 5, 7)
  - Usage Session Rules (Rules 6, 8, 9)
  - Data Integrity Rules (Rules 10, 11)
- **6. Role-Action Matrix:** A summary defining which actors can perform which key actions based *strictly* on the actor descriptions in the project description (e.g., Check-in is performed by Facility Staff, not Facility Manager, unless explicitly stated in Assumptions).
- **7. Staff View/Reporting Requirements:** Capture functional requirements explicitly stated in the project description. Staff should be able to view:
  - Booking History
  - Upcoming Bookings
  - Spaces Under Maintenance
  - No-show Bookings
- **8. Workflow/Lifecycle Descriptions:** Describe key process flows and ensure diagrams perfectly match text and are logically sound:
  - Booking lifecycle: Submit → Pending → Approved/Rejected/Cancelled → Checked In → Completed/No-show. (Diagram MUST include CANCELLED state as a terminal state. Terminal states like CANCELLED and NO-SHOW must NOT have downstream arrows).
  - Maintenance lifecycle: Report → Assign → In Progress → Completed
  - Ensure ALL 5 defined space statuses (Available, In Use, Under Maintenance, Temporarily Closed, Retired) are explicitly mapped in the workflow descriptions (e.g., create a dedicated Space Status Lifecycle diagram). Keep ASCII diagrams clean, centered, and readable.
- **9. Assumptions:** Document any inferred requirements or assumptions not explicitly stated in the project description. *Crucially*, you must explicitly declare any inferred domain enumerations (like Maintenance Statuses or Account Statuses) here. Also document implicit rules like `expected_participants <= capacity` as assumptions to avoid hallucinating them as strict Agent.md business rules.
- **10. Scope Boundaries:** Define what is in-scope (booking, approval, usage tracking, maintenance) and what is explicitly out-of-scope (e.g., billing, external calendar sync, notifications, recurring bookings).

## 3. Execution Strategy (Agent Directives)

- **No Hallucinations:** Do not invent roles like "System Administrators". Stick exclusively to the approved list of actors.
- **Rule Traceability:** Ensure all 10 rules from `AGENT.md` are explicitly written out plus Rule 11 ("Every user must have a university account").
- **Formatting:** Use standard Markdown headers (`##`) for the sections listed above.
- **Domain Value Extraction:** Systematically extract ALL enumerated lists from the project description. Do not leave domain values implicit.
- **Functional Requirement Extraction:** Capture staff view/reporting requirements even when they don't map directly to entity attributes.

## 4. Verification Checklist

Before saving your final result to `experiments/section_01/result_roundN.md`, you must mentally check these items and log them as PASS/FAIL in your improvement log:

- [ ] Is there a dedicated "Business Purpose" heading with a narrative explanation (not a table)?
- [ ] Are the actors explicitly listed as Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, and Facility Manager?
- [ ] Are there zero hallucinated roles (e.g., no "System Administrators")?
- [ ] Is the rule "Every user must have a university account" explicitly listed in the Business Rules section?
- [ ] Do all entity names and attributes match `AGENT.md` byte-for-byte?
- [ ] Are entity relationships and cardinalities explicitly mapped in a dedicated section?
- [ ] Are all enumerated domain values from the project description listed?
- [ ] Are inferred domain values (Account/Maintenance statuses) listed in Enumerations and explicitly declared as inferred in Assumptions?
- [ ] Is the implicit rule `expected_participants <= capacity` stated as an assumption?
- [ ] Are staff view/reporting requirements captured?
- [ ] Are booking and maintenance lifecycle workflows described, and do the diagrams perfectly match the text (e.g., does the Booking diagram include the CANCELLED state as a terminal node)?
- [ ] Are all space statuses (including "In Use") explicitly mapped in the workflow descriptions?
- [ ] Is the Role-Action matrix strictly aligned with prompt role descriptions?
- [ ] Are assumptions explicitly documented?
- [ ] Are scope boundaries defined?
- [ ] Are business rules categorized (not flat-listed)?

## 5. Common Mistakes

- Omitting enumerated domain values and leaving them implicit in attribute descriptions
- Missing staff reporting/view requirements from the project description
- Flat-listing business rules without categorization
- Not clarifying the relationship between Rules 2 and 3
- Missing lifecycle/workflow descriptions for booking and maintenance processes
- Not documenting assumptions or scope boundaries

## 6. Anti-Hallucination Rules

- Do NOT add attributes not defined in `AGENT.md` Section 3
- Do NOT invent roles beyond the 6 approved actors
- Do NOT modify the entity schema (no new FKs, no new fields)
- If an attribute or requirement is inferred rather than explicit, document it in the Assumptions section

## 7. Lessons Integrated

- **Round 1:** Domain value enumerations must be a dedicated section, not left implicit. Staff view requirements from the project description are functional requirements that must be captured. Business rules benefit from categorization. Rules 2 vs 3 need clarification of their distinct enforcement mechanisms. Assumptions and scope boundaries should always be documented.
- **Round 2:** Relationships and cardinalities must be explicitly mapped in a dedicated section. Workflow diagrams must perfectly match their textual descriptions (e.g., CANCELLED state must be in the diagram). Inferred domain values (Account/Maintenance Statuses) must be enumerated and explicitly declared as assumptions. Role-Action matrix must strictly align with project description without unauthorized inferences.
