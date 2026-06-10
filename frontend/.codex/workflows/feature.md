# Feature Workflow

Use this workflow for new user-visible functionality.

## Steps

1. Read the task.
2. Read `AGENTS.md`.
3. Read `docs/architecture/overview.md`.
4. Read relevant `docs/flows/*.md` and `docs/contracts/*.md`.
5. Ask Planner for implementation plan when scope is non-trivial.
6. Implement minimal vertical slice.
7. Run checks.
8. Run Reviewer on the final diff.
9. Fix reviewer findings if requested by the human.
10. Produce final report.

## Required Checks

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Preferred:

```bash
.codex/scripts/check.sh
```

## Completion Criteria

- Feature works end-to-end for the requested path.
- No architecture violations.
- No unrelated changes.
- Loading, empty, and error states are handled when applicable.
- Checks pass or failures are clearly reported.
- Contracts/docs updated if behavior changed.

## Must Not

- Do not implement future-week features unless requested.
- Do not introduce new dependencies without approval.
- Do not hide failing checks.
- Do not skip user story acceptance criteria that are in scope.
