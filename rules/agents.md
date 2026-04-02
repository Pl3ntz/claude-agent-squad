# Agent Orchestration (Squad Model)

## Hierarchy (ABSOLUTE)

```
CTO (decision-maker)
  └── PE (orchestrator) — orchestrates all agents, synthesizes results
        │
        ├── 🔍 Planning & Design Squad
        │   ├── architect (opus) — HOW to build (patterns, trade-offs, ADRs)
        │   └── planner (opus) — IN WHAT ORDER (phases, risks, dependencies)
        │
        ├── 🛡️ Quality Gate Squad (read-only, ALWAYS PARALLEL)
        │   ├── code-reviewer (sonnet) — code quality, patterns, bugs
        │   ├── security-reviewer (opus) — infra security, threats, secrets
        │   ├── ux-reviewer (sonnet) — accessibility, consistency, states
        │   └── staff-engineer (opus) — cross-system impact, tech debt
        │
        ├── 🔨 Implementation Squad (write code, ZONE ASSIGNMENT required)
        │   ├── tdd-guide (sonnet) — TDD, tests-first, coverage 80%+
        │   ├── e2e-runner (sonnet) — Playwright, user journeys
        │   ├── build-error-resolver (haiku) — build errors, minimal diff
        │   └── refactor-cleaner (sonnet) — dead code cleanup
        │
        ├── ⚙️ Operations Squad
        │   ├── incident-responder (opus) — production incidents (REACTIVE)
        │   ├── devops-specialist (sonnet) — CI/CD, deploy, systemd (PROACTIVE)
        │   ├── performance-optimizer (sonnet) — profiling, bottlenecks
        │   └── database-specialist (sonnet) — PostgreSQL, schema, queries
        │
        └── 📚 Intelligence Squad
            ├── deep-researcher (opus) — multi-source research, triangulation
            └── doc-updater (haiku) — documentation, codemaps
```

## Squad Rules

1. **Quality Gate squad ALWAYS runs in parallel** — never sequential between these agents
2. **Implementation squad requires zone assignment** — PE maps file zones before spawning, no two agents modify the same file
3. **Operations squad**: incident-responder has priority (skip approval for read-only triage)
4. **Planning & Design**: architect before planner when "how" is unclear; planner direct when "how" is obvious
5. **Intelligence squad**: deep-researcher only for complex multi-source queries; PE handles simple lookups directly

## Parallel Execution

Ver seção 15 (Crawler Protocol) do `principal-engineer-always-on.md` para regras detalhadas de wave execution, zone assignment e fan-out/fan-in.

## Agent Teams vs Subagents (When to Use Which)

Claude Code supports two coordination models. The PE decides which to use based on the task.

### Subagents (Default — Our Standard Model)

PE spawns agents via Task tool. Each agent works independently and returns results to PE.

**Use when:**
- Task is focused and scoped (code review, planning, TDD)
- Only the result matters, not inter-agent discussion
- Standard chain workflows (planner → tdd-guide → code-reviewer)
- Most day-to-day operations

**Strengths:** Lower token cost, simpler coordination, stable, predictable

### Agent Teams (Experimental — For Specific Workflows)

Multiple Claude Code instances coordinate via shared task list and peer-to-peer mailbox.

**Use when:**
- Agents need to **communicate with each other** (not just report to PE)
- **Competing hypotheses**: Multiple agents investigate different theories in parallel and challenge each other
- **Cross-layer features**: Frontend, backend, and test changes each owned by a different agent to avoid file conflicts
- **Parallel deep review**: Multiple reviewers inspect different aspects simultaneously and share findings

**Best candidate workflows:**
- `evaluate architecture` → architect + staff-engineer debating via mailbox
- `debug complex issue` → competing hypotheses pattern
- `implement cross-layer feature` → frontend + backend + test agents with separate contexts

**Limitations (experimental status):**
- No session resumption with in-process teammates
- Task status can lag (teammates may not mark tasks completed reliably)
- One team per session, no nested teams
- Not suitable for production-critical workflows yet

**Rule:** Default to subagents. Only propose Agent Teams to the CTO for specific workflows listed above, with explicit mention of the experimental status.
