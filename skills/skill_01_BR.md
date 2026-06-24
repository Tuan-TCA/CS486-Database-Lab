# Skill 01: Business Requirement Analysis

## 1. Context Scope

When working on this step, only load the following files into context:

- Initial project prompt/brief
- `AGENT.md` (Sections 4, 5, and 6)
- `evaluations/evaluation-01.md` (if available)

## 2. Required Document Structure

Your output must be formatted as a Markdown document with the following distinct sections. Do not embed narrative explanations into tables.

- **1. Business Purpose:** A dedicated narrative paragraph explaining the "why" behind the system (replacing manual spreadsheets, enforcing no double-booking at the data level). Do not put this in a table.
- **2. System Actors:** A bulleted list of the system actors. You must use exactly: Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, and Facility Manager.
- **3. Entities and Attributes:** Markdown tables defining the 7 core entities and their attributes exactly as defined in `AGENT.md` Section 4.
- **4. Business Rules:** A numbered list of all business rules exactly as defined in `AGENT.md` Section 5.

## 3. Execution Strategy (Agent Directives)

- **No Hallucinations:** Do not invent roles like "System Administrators". Stick exclusively to the approved list of actors.
- **Rule Traceability:** Ensure all 10 rules from `AGENT.md` are explicitly written out.
- **Formatting:** Use standard Markdown headers (`##`) for the sections listed above.

## 4. Verification Checklist

Before saving your final result to `experiments/section_01/result_roundN.md`, you must mentally check these items and log them as PASS/FAIL in your improvement log:

- [ ] Is there a dedicated "Business Purpose" heading with a narrative explanation (not a table)?
- [ ] Are the actors explicitly listed as Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, and Facility Manager?
- [ ] Are there zero hallucinated roles (e.g., no "System Administrators")?
- [ ] Is the rule "Every user must have a university account" explicitly listed in the Business Rules section?
- [ ] Do all entity names and attributes match `AGENT.md` byte-for-byte?
