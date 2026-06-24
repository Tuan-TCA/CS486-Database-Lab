# Skill 03: Logical Database Design

## 1. Context Scope

When beginning or improving this step, you are strictly limited to loading the following files into your context window:

- `AGENT.md` (Sections 4, 5, and 6)
- `outputs/01-business-req-analysis-G08.md`
- `outputs/02-erd-design-G08.md`
- `evaluations/evaluation-03.md` (if beginning an improvement round)

## 2. Required Document Structure

Your output must be formatted as a Markdown document (`outputs/03-logical-design-G08.md`) containing the following distinct sections:

- **1. Relational Schema:** Define all 7 required relations (USER, SPACE, FACILITY, BOOKING_REQUEST, BOOKING_APPROVAL, USAGE_SESSION, MAINTENANCE_RECORD). Format this using text notation (e.g., `TABLE_NAME (Column1, Column2, ...)`) with **bold** for Primary Keys and _italics_ for Foreign Keys.
- **2. Attribute Data Dictionary:** Markdown tables for each relation specifying the attribute name, data type, nullability, and a brief description. Data types must be appropriate for standard SQL.
- **3. Keys Analysis:** A dedicated section (tables or lists) documenting:
  - **Primary Keys:** The definitive PK for each relation.
  - **Candidate Keys:** All alternative unique identifiers, explicitly including composite keys.
- **4. Referential Integrity (Foreign Keys):** A table mapping all 11 expected foreign keys. Include the Child Table, Foreign Key Attribute, Parent Table, and Parent Primary Key.
- **5. Business Rule Enforcement:** A numbered list tracking back to the business rules in `AGENT.md`. For each rule, explicitly state whether it is enforced at the schema level (e.g., via `CHECK`, `UNIQUE`, `NOT NULL`, or `FOREIGN KEY` constraints) or at the application/trigger level.

## 3. Execution Strategy (Agent Directives)

- **Source of Truth Compliance:** Every relation and attribute name must match `AGENT.md` Section 4 byte-for-byte. Do not rename, add, or drop attributes.
- **Composite Key Identification:** Do not limit uniqueness evaluations to single attributes. Evaluate attribute combinations (such as a building and a room number) that together form a candidate key to represent physical realities.
- **No Redundant Relations:** Do not create linking tables for relationships that are already resolved via 1-to-many Foreign Keys in the required 7 entities.

## 4. Verification Checklist

Before saving your final result to `experiments/section_03/result_roundN.md`, you must mentally perform these checks and log them as PASS/FAIL in your `improve03.md` file:

- [ ] Are exactly 7 relations present, matching `AGENT.md` without any additions or omissions?
- [ ] Do all attribute names match `AGENT.md` exactly?
- [ ] Are all 11 expected foreign keys properly identified and placed in the appropriate child relations?
- [ ] Did I explicitly document the composite candidate key `SPACE(building, room_number)`?
- [ ] Is there a corresponding schema-level `UNIQUE (building, room_number)` constraint specified in the enforcement section?
- [ ] Are all active business rules from `AGENT.md` listed with a clear enforcement strategy (Schema vs. Application layer)?
