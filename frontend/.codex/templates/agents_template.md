# Planner + Implementer + Reviewer Template

Spawn 3 subagents: Planner, Implementer, and Reviewer.

Use project `AGENTS.md` first.

## Task

<Task goes here>

## Context

Project: My Talking Shaha Flutter client.

The app is a digital car twin platform. The Flutter client must follow feature-first architecture, Riverpod state management, GoRouter navigation, project design system, documented API contracts, and user flows.

## Workflow

### 1. Planner works first

Planner must read:

* `AGENTS.md`
* `.codex/agents/planner.md`
* `docs/architecture/overview.md`
* relevant docs from `docs/flows/`
* relevant contracts from `docs/contracts/`
* relevant skills from `.codex/skills/`

Planner must:

* understand the requested task;
* identify affected user stories and acceptance criteria;
* identify the owning feature;
* define a minimal vertical slice;
* identify files to inspect;
* identify files likely to change;
* identify architecture impact;
* identify risks, dependencies, and open questions;
* decide which checks should be run.

Planner must not:

* write code;
* modify files;
* perform refactors;
* expand scope beyond the requested task;
* invent backend contracts without marking them as assumptions.

Planner output format:

```md
### Understanding

### User Stories / Acceptance Criteria

### Proposed Approach

### Files to Inspect

### Files Likely to Change

### Architecture Impact

### Risks

### Questions for Human, if any
```

If Planner has blocking questions, stop and ask the human before implementation.

If Planner has no blocking questions, Implementer may proceed using the plan.

---

### 2. Implementer works after Planner

Implementer must read:

* `AGENTS.md`
* `.codex/agents/implementer.md`
* `.codex/workflows/feature.md` or `.codex/workflows/bugfix.md`
* Planner output
* relevant skills from `.codex/skills/`
* `docs/architecture/overview.md`
* `docs/architecture/design_overview.md`
* `docs/architecture/ui_component_inventory.md`
* relevant docs from `docs/flows/`
* relevant design examples from `dosc/design`
* relevant contracts from `docs/contracts/`

Implementer must:

* follow the Planner’s proposed approach unless there is a clear reason to adjust it;
* implement the task with minimal safe changes;
* keep changes small and reviewable;
* preserve feature-first architecture;
* preserve Riverpod and GoRouter conventions;
* use the existing design system and UI primitives;
* accord to existing docs about design
* update docs/contracts if implementation depends on new behavior;
* add or update tests when behavior changes;
* run available checks;
* report checks honestly.

Implementer must not:

* rewrite unrelated code;
* introduce dependencies without approval;
* change public contracts unless required and documented;
* hide failing checks;
* put HTTP code in presentation;
* parse JSON in widgets;
* import Flutter into domain;
* make the AI assistant answer without grounding in vehicle data.

Implementer output format:

```md
### Summary

### Files Changed

### Checks Run

### Assumptions

### Notes for Reviewer
```

---

### 3. Reviewer works only after Implementer finishes

Reviewer must read:

* `AGENTS.md`
* `.codex/agents/reviewer.md`
* `.codex/review/architecture.md`
* `.codex/review/performance.md`
* `.codex/review/security.md`
* Planner output
* Implementer output
* relevant flow docs and contracts

Reviewer must:

* review only the final diff;
* check correctness against the task, user stories, and acceptance criteria;
* check feature ownership;
* check architecture boundaries;
* check API contract usage;
* check Riverpod state management;
* check GoRouter navigation correctness;
* check error/loading/empty states;
* check tests and executed checks;
* detect overengineering;
* detect unrelated changes.

Reviewer must not:

* request unnecessary rewrites;
* complain about unchanged code;
* suggest subjective changes without impact;
* ask for broad refactors if a smaller fix solves the issue;
* approve if checks were not run and no reason was given.

Severity levels:

* `[P0] Critical`: crash, data loss, security issue, broken build, impossible to use app.
* `[P1] Major`: broken user flow, wrong API contract, architecture violation, persisted wrong data.
* `[P2] Minor`: maintainability, naming, missing small validation, style issue with real impact.

Reviewer output format:

```md
### Verdict
APPROVE / REQUEST CHANGES

### Findings
- [P1] path/to/file.dart:42 — issue description and impact

### Missing Checks

### Suggested Fixes
```

---

## Fix Policy

If Reviewer finds issues:

1. Do not apply fixes automatically unless explicitly asked.
2. Produce a fix plan.
3. Keep the fix plan limited to Reviewer findings.
4. Do not introduce new unrelated changes while fixing review comments.

If the human asks to fix Reviewer findings, run the Implementer again using:

* original task;
* Planner output;
* Reviewer findings;
* relevant docs and contracts.

Then run Reviewer again on the updated final diff.

## Constraints

* No unrelated refactoring.
* No new dependencies without approval.
* Preserve existing feature-first architecture.
* Preserve existing Riverpod approach.
* Preserve existing GoRouter approach.
* Preserve existing design system.
* Do not hide failing checks.
* Do not hardcode secrets.
* Do not log tokens.
* Do not invent backend behavior beyond documented contracts.
* Keep AI assistant responses grounded in vehicle data, rules, and available context.
* If there is not enough data for an AI answer, use the documented fallback behavior.

## Required Checks

Run available checks after implementation:

```bash
.codex/scripts/check.sh
```

If the full check script cannot run, run available checks manually:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Never claim checks passed if they were not executed.

## Final Output

```md
### Planner Summary

### Implementer Summary

### Reviewer Verdict

### Reviewer Findings

### Checks Run

### Remaining Risks

### Follow-up Tasks
```
