# Bugfix Workflow

Use this workflow for fixing broken behavior.

## Steps

1. Reproduce or understand the bug.
2. Identify the root cause.
3. Inspect relevant flow and contract docs.
4. Ask Tester to add a failing regression test before production code changes when reasonable.
5. Make the smallest possible fix.
6. Run checks.
7. Explain why the bug is fixed and which regression test protects it.

## Must Not

- Do not refactor unrelated code.
- Do not change behavior outside bug scope.
- Do not mask symptoms without addressing cause.
- Do not weaken validation to make tests pass.
- Do not skip the regression test step without explaining why it is impossible or unreasonable.
- Do not hide failing checks.

## Output Format

```md
### Root Cause

### Fix

### Files Changed

### Checks Run

### Regression Risk
```
