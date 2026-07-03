# CS486 Database Project – Group 08

This repository contains the complete development process for the CS486 Database System project.

Besides the final project deliverables, it also includes a human-supervised framework for improving an AI database-design agent through iterative experiments.

The goal is not to automatically generate the final submission, but to continuously improve reusable knowledge, methodologies, and evaluation procedures.

---

# Repository Structure

```text
.
├── agent/
├── doc/
├── evaluation/
├── ExperimentAgent/
├── experiments/
├── outputs/
├── report/
├── skills/
└── temp/
```

---

# Directory Overview

## `doc/`

Project documentation.

- Project description
- Supporting documents

---

## `outputs/`

Final deliverables submitted for the project.

```
01-business-req-analysis
02-erd-design
03-logical-design
04-design-validation
05-db-definition
06-sample-data
07-query-design
```

These files represent the final approved solution.

---

## `skills/`

Reusable methodologies for each project section.

Each skill focuses on **how to solve** a class of problems rather than storing project-specific outputs.

Typical contents include:

- methodology
- workflow
- verification checklist
- common mistakes
- best practices

---

## `agent/`

Stores global knowledge shared by all skills.

Examples include:

- requirement traceability
- consistency checking
- anti-hallucination
- verification strategy
- reusable design principles

Unlike Skills, Agent knowledge is independent of any single project section.

---

## `ExperimentAgent/`

Contains the implementation of the experimental AI agent used during iterative improvement.

The agent consumes the Skills, follows the experiment prompts, generates benchmark results, and assists the human throughout the improvement process.

---

## `evaluation/`

Evaluation rubrics for every project section.

Each rubric is reused across all experiment rounds to ensure consistent assessment.

---

## `experiments/`

Stores artifacts produced during iterative experiments.

Each section contains multiple benchmark generations together with the accumulated improvement history.

Typical structure:

```text
section_xx/

result_round1.md
result_round2.md
result_round3.md

improveXX.md
```

Benchmark results are snapshots of the agent's capability at different stages.

Improvement files record lessons learned between iterations.

---


## `report/`

Source files for the final report.

Includes:

- LaTeX sources
- figures
- generated assets

---

## `temp/`

Temporary workspace.

Contains experimental files, prototypes, and intermediate resources that are not part of the final repository.

---

# Experiment Workflow

The improvement process follows an iterative cycle.

```text
Create Skill
      │
      ▼
Generate Benchmark
      │
      ▼
Evaluate Benchmark
      │
      ▼
Identify Weaknesses
      │
      ▼
Update Skill
      │
      ▼
(Optional) Update Agent
      │
      ▼
Generate Next Benchmark
```

The human remains responsible for reviewing results and approving all modifications.

---

# Project Philosophy

The repository separates **project deliverables** from **knowledge generation**.

- **Outputs** represent the final submission.
- **Skills** capture reusable methodologies.
- **Agent** stores reusable global knowledge.
- **Experiments** document the evolution of the agent.
- **Evaluations** provide objective assessment.

The objective is to build an increasingly reliable database-design assistant through repeated human-supervised refinement rather than optimizing a single generated result.