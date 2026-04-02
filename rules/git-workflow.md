# Git Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Note: Attribution disabled globally via ~/.claude/settings.json.

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

## Feature Implementation Workflow

Seguir Crawler Protocol (PE rule seção 15) com waves:
1. **Wave 1:** planner → plano com fases e riscos
2. **Wave 2:** tdd-guide → TDD (red-green-refactor), cobertura 80%+
3. **Wave 3 (paralelo):** code-reviewer + security-reviewer
4. **Commit:** conventional commits format
