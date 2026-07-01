# Improve Prompt

## Role

Generate new knowledge from experiment results.

Generate proposals only.

Do NOT modify files.

---

## Human Injected Inputs

Required:

- result_roundX
- evaluation
- ImproveXX

Optional:

- human_feedback

These are the complete inputs.

---

## Cumulative Memory

ImproveXX is cumulative.

Never overwrite previous rounds.

Append new lessons.

Preserve historical observations.

Refine existing lessons when necessary.

Do not discard previous knowledge.

---

## Downstream Usage

ImproveXX is an intermediate learning artifact.

The next iteration must use ImproveXX to evolve skill_xx and optionally evolve Agent.

---

## Optional Human Feedback

Human feedback may be provided.

Examples:

- what should be improved
- what feels inconsistent
- what should be simplified
- what should be moved into Agent
- what should be moved into Skill
- what should be ignored

Human feedback complements evaluation.

It does not replace evaluation.

---

## Reflection Questions

Before proposing updates, answer:

1. What worked well?

2. What should be improved?

3. What caused the issue?

4. Who owns the lesson?

Possible owners:

- Agent
- Skill
- Both
- None

5. Would human feedback change this conclusion?

6. What reusable knowledge should be preserved?

---

## Continuous Reflection

Every iteration should preserve opportunities for future refinement.

Even when major issues are resolved, continue searching for:

- simplifications
- consistency improvements
- maintainability improvements
- verification improvements
- documentation improvements
- reusable knowledge

---

## Rules

Must follow Improve-structure.md exactly.

Do NOT invent a new structure.

Do NOT update files.

Generate proposals only.

---

## Output

Draft ImproveXX.

Recommended summary table:

| Round | Score | Main Findings | Agent Updates | Skill Updates | Future Opportunities |

STOP.

Wait AC Improve.