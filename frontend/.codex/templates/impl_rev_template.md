# Implementer + Reviewer Template

Spawn 2 subagents: Implementer and Reviewer.
Use project `AGENTS.md` first.

## Task

<Task goes here>

## Workflow

1. Implementer works first.
2. Implementer must read:
   - `AGENTS.md`
   - `.codex/agents/implementer.md`
   - `.codex/workflows/feature.md` or `.codex/workflows/bugfix.md`
   - relevant skills from `.codex/skills/`
   - `docs/architecture/overview.md`
   - relevant docs from `docs/flows/`
   - relevant contracts from `docs/contracts/`
3. Implementer implements the task with minimal safe changes.
4. Implementer runs available checks.
5. Reviewer starts only after Implementer finishes.
6. Reviewer must read:
   - `AGENTS.md`
   - `.codex/agents/reviewer.md`
   - `.codex/review/architecture.md`
   - `.codex/review/performance.md`
   - `.codex/review/security.md`
   - relevant flow and contract docs
7. Reviewer reviews only the final diff.
8. If Reviewer finds issues, produce a fix plan. Do not apply fixes automatically unless explicitly asked.

## Constraints

- no unrelated refactoring;
- no new dependencies without approval;
- preserve existing architecture;
- do not hide failing checks;
- keep AI assistant grounded in vehicle data;
- do not invent backend behavior beyond contracts.

## Final Output

```md
### Implementer Summary

### Reviewer Verdict

### Reviewer Findings

### Checks Run

### Remaining Risks
```
