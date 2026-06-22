---
description: Run the autonomous SQL validation pipeline on a database definition file
---

Use the autonomous SQL validation pipeline skill in:

`evaluating_skills/Auto-SQL-Validator.md`

Read the target SQL definition file from:

`$ARGUMENTS`

Run the full validation loop (Phase 1 Docker syntax check and Phase 2 Atlas architectural linting). Log all failures and fixes to a validation log, and loop autonomously until the target file passes both phases with zero errors.