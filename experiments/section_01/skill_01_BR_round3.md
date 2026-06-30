# Skill 01: Business Requirement Analysis (Round 3 Snapshot)

## 1. Context Scope
- Initial project prompt/brief
- `AGENT.md` (Sections 3, 4, 5, and 6)

## 2. Required Document Structure
- **1. Business Purpose:** A narrative paragraph explaining the "why" behind the system.
- **2. System Actors:** A list of the system actors with brief descriptions.
- **3. Entities and Attributes:** Tables defining the entities and their attributes exactly as defined in `AGENT.md`.
- **3.5 Relationships & Cardinalities:** Explicitly map out the 1:N and 1:1 relationships. **CRITICAL:** Do not conflate distinct relationships (e.g., separate reporter vs. assigned staff on Maintenance records).
- **4. Domain Value Enumerations:** List ALL enumerated domain values. Inferred values (Account Statuses, Maintenance Statuses) MUST be enumerated here but explicitly declared as inferred in Assumptions.
- **5. Business Rules:** A categorized list of all business rules. Must include a clarification note regarding distinct enforcement mechanisms for Rule 2 and Rule 3.
- **6. Role-Action Matrix:** A summary defining which actors can perform which key actions based *strictly* on the actor descriptions (e.g., Check-in is performed by Facility Staff, not Facility Manager, unless explicitly stated in Assumptions).
- **7. Staff View/Reporting Requirements:** Capture functional requirements explicitly stated for staff views.
- **8. Workflow/Lifecycle Descriptions:** Describe key process flows. Diagrams MUST perfectly match text and be logically sound (e.g., Booking diagram MUST include CANCELLED state as a terminal node).
- **9. Assumptions:** Document any inferred requirements or assumptions not explicitly stated.
- **10. Scope Boundaries:** Define what is in-scope and what is explicitly out-of-scope.

## 3. Verification Checklist
- [ ] Are all enumerated domain values from the project description listed?
- [ ] Are staff view/reporting requirements captured?
- [ ] Are booking and maintenance lifecycle workflows described, and do diagrams match text (including CANCELLED)?
- [ ] Are explicit entity relationships and cardinalities mapped without conflation?
- [ ] Is the Role-Action matrix strictly aligned with project descriptions without unauthorized inferences?
- [ ] Are assumptions explicitly documented, including inferred enumeration values?
- [ ] Are scope boundaries defined?
- [ ] Are business rules categorized?
