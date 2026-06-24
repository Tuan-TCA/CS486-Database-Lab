# CS486 Database Project - Human-Supervised Experiment Framework - Group08

## Purpose

This repository contains two independent components:

1. Final human-made deliverables submitted for the project.
2. A human-supervised experiment framework used to improve Agent and Skills.

The final deliverables and the experiment framework are intentionally separated.

The experiment does NOT attempt to generate the final submission directly.

Its purpose is to progressively build reusable knowledge.

---

# Project Structure

```text
project/

├── doc/
|   ├── project_description.md
│   └── report.md
|
│
├── output/
│   ├── 01-business-req-analysis-G08.md
│   ├── 02-erd-design-G08.md
│   ├── 03-logical-design-G08.md
│   ├── 04-design-validation-G08.md
│   ├── 05-db-definition-G08.sql
│   ├── 06-sample-data-G08.sql
│   └── 07-query-design-G08.sql
│
├── evaluation/
│   ├── evaluation_01.md
│   ├── evaluation_02.md
│   ├── ...
│   └── evaluation_07.md
│
├── agent/
│   └── AGENT.md
│
├── skills/
│   ├── skill_01_BR.md
│   ├── skill_02_ERD.md
│   ├── skill_03_LogicalSchema.md
│   ├── skill_04_Validation.md
│   ├── skill_05_SQL.md
│   ├── skill_06_SampleData.md
│   └── skill_07_QueryDesign.md
│
├── experiments/
│   ├── section_01/
│   │   ├── result_round1.md
│   │   ├── result_round2.md
│   │   ├── result_round3.md
│   │   └── improve01.md
│   │
│   ├── section_02/
│   │   └── ...
│   │
│   └── ...
│
└── prompts/
    ├── 00-experiment-policy.md
    ├── 01-workflow-prompt.md
    ├── 02-skill-builder-prompt.md
    ├── 03-result-generator-prompt.md
    ├── 04-evaluate-prompt.md
    └── 05-improve-prompt.md
```

---

# Folder Description

## doc/

Contains documents of the project.

---

## output/

Contains the final deliverables manually created and approved by the group.

These files are the final submission artifacts.

These files are OUTSIDE the experiment universe.

During experiments:

* Do NOT read output
* Do NOT compare output
* Do NOT copy output
* Do NOT use output as references

---

## evaluation/

Contains fixed evaluation rubrics.

Each file defines the scoring criteria for one section.

Rules:

* Each section is evaluated out of 10 points
* The same evaluation file is reused across all rounds
* Evaluation files never change between rounds

evaluation may ONLY be used during the Evaluate phase.

Outside the Evaluate phase:

* Do NOT read evaluation
* Do NOT search for evaluation
* Do NOT use evaluation indirectly

---

## agent/

Contains AGENT.md.

AGENT stores global reusable knowledge shared across all sections.

Examples:

* anti-hallucination
* requirement traceability
* naming consistency
* verification behavior

Rules:

* Do NOT rewrite
* Do NOT replace
* Do NOT clear

Only append.

Update AGENT only when the lesson is globally reusable.

---

## skills/

Contains section-specific reusable knowledge.

Each skill file stores methodologies rather than outputs.

Examples:

skill_03_LogicalSchema.md

* convert entities into relations
* identify candidate keys
* verify foreign keys
* preserve constraints

Each skill should contain:

* methodology
* checklists
* verification procedures
* common mistakes
* consistency rules

---

## experiments/

Contains experiment artifacts.

Each section contains:

### result_round1.md

Benchmark generated using the current Agent and skill_xx.

### result_round2.md

Benchmark generated after learning from Round1.

### result_round3.md

Benchmark generated after learning from previous rounds.

Results are benchmarks only.

Results are NOT the experiment objective.

---

### improveXX.md

Learning memory for a section.

Stores:

* issues
* root causes
* proposed skill updates
* proposed agent updates
* lessons learned

improveXX is cumulative.

It acts as the bridge between iterations.

---

## prompts/

Contains the experiment framework.

### 00-experiment-policy.md

Global immutable rules.

### 01-workflow-prompt.md

Workflow orchestrator.

### 02-skill-builder-prompt.md

Convert lessons into reusable skills.

### 03-result-generator-prompt.md

Generate benchmark results.

### 04-evaluate-prompt.md

Evaluate benchmark quality.

### 05-improve-prompt.md

Convert findings into reusable knowledge.

---

# Experiment Workflow

Phase0

Create skill_xx

↓

Round1

Generate benchmark

↓

Evaluate benchmark

↓

Create improveXX

↓

STOP

↓

Wait Human

---

Round2

Read improveXX

↓

Update skill_xx

↓

Optionally update Agent

↓

Generate benchmark

↓

Evaluate benchmark

↓

Update improveXX

↓

STOP

↓

Wait Human

---

Round3

Read improveXX

↓

Update skill_xx

↓

Optionally update Agent

↓

Generate benchmark

↓

Evaluate benchmark

↓

Update improveXX

↓

STOP

---

Finalization

Review Agent

↓

Review skill_xx

↓

Review improveXX

↓

STOP

---

# Human Approval Protocol

OpenCode is a research assistant.

It may:

* Analyze
* Generate drafts
* Evaluate
* Propose improvements

It may NOT:

* Apply changes
* Modify files
* Make decisions

Always follow:

Propose

↓

STOP

↓

Wait Human

↓

AC

↓

Apply

Only these commands are approvals:

* AC
* AC Result
* AC Improve
* AC Skill
* AC Agent

Everything else is NOT approval.

---

# Overall Principles

output/

= Final deliverables

evaluation/

= Fixed scoring rubrics

result_roundX

= Benchmark results

improveXX

= Learning memory

Agent

= Global reusable knowledge

skill_xx

= Section-specific reusable knowledge

The objective of the experiment is NOT to maximize a single result.

The objective is to progressively build more robust, consistent, and reusable knowledge over multiple iterations.
