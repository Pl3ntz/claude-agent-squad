# Crawler Protocol — Paralelismo por Waves

## Princípio

**Paralelo é o padrão. Sequencial é a exceção.**

Só vá sequencial quando há dependência real de dados (o output do agente A é input do agente B).

## Wave Execution Model

Em vez de cadeias sequenciais, o PE agrupa trabalho em **ondas (waves)**. Dentro de cada wave, todos os agentes rodam em paralelo. Entre waves, sequencial.

```
Wave 1 (PARALELO — reconhecimento):
  ├── Explore: estrutura do codebase + patterns existentes
  ├── Explore: cobertura de testes + dependências
  └── deep-researcher: pesquisa externa (se necessário)

Wave 2 (SEQUENCIAL — planejamento):
  └── planner ou architect: plano baseado nos resultados da Wave 1

Wave 3 (PARALELO — implementação):
  ├── tdd-guide: testes + implementação (zona A)
  └── devops-specialist: mudanças CI/CD (zona B)

Wave 4 (PARALELO — validação):
  ├── code-reviewer: qualidade de código
  ├── security-reviewer: auditoria de segurança
  └── ux-reviewer: revisão de UI (se aplicável)
```

## Zone Assignment — Prevenção de Conflitos

**Antes de spawnar agentes paralelos que ESCREVEM código, o PE deve:**

1. **Mapear file zones** — listar quais arquivos cada agente vai tocar
2. **Verificar overlap** — dois agentes não podem modificar o mesmo arquivo na mesma wave
3. **Atribuir zones no prompt** — dizer explicitamente a cada agente quais arquivos ele pode modificar

```
Exemplo de zone assignment no prompt do agente:
"Sua zona: src/api/**, tests/api/**. Não modifique arquivos fora da sua zona."
```

**Agentes read-only (code-reviewer, security-reviewer, etc.) não precisam de zones** — podem ler os mesmos arquivos em paralelo sem conflito.

### Quando usar `isolation: worktree`

Se o overlap de arquivos é **inevitável**, use `isolation: worktree` no frontmatter do agente. Cada agente recebe uma cópia isolada do repositório via git worktree.

## Routing Tables

### Sempre Paralelo (sem dependências)

| Trigger | Agentes (PARALELO) |
|---|---|
| Review de código/PR | code-reviewer + security-reviewer + (ux-reviewer se UI) |
| Avaliar arquitetura | architect + staff-engineer |
| Audit de projeto | security-reviewer + performance-optimizer + code-reviewer |
| Investigar issue | Explore (codebase) + deep-researcher (web) |
| Validar implementação | code-reviewer + security-reviewer + tdd-guide (rodar testes) |
| Análise multi-projeto | 1 agente por projeto, todos paralelo |

### Wave-Based (paralelo dentro de waves, sequencial entre)

| Trigger | Wave 1 (paralelo) | Wave 2 (sequencial) | Wave 3 (paralelo) |
|---|---|---|---|
| Nova feature | Explore + deep-researcher | planner | tdd-guide + code-reviewer + security-reviewer |
| Novo endpoint API | Explore + deep-researcher | planner | tdd-guide + code-reviewer + security-reviewer |
| Refactor | Explore (estrutura) + Explore (testes) | architect | refactor-cleaner + code-reviewer |
| Fix de bug (complexo) | Explore (código) + Explore (testes) | tdd-guide | code-reviewer |
| Mudança UI | Explore + deep-researcher | planner | tdd-guide + ux-reviewer + code-reviewer |

## Regras de Execução

1. **3-5 agentes max por wave** — mais gera overhead de coordenação
2. **Agentes read-only sempre paralelizam** — sem risco de conflito
3. **Agentes write precisam de zone assignment** — PE verifica overlap antes
4. **Agente que falha não bloqueia os outros** — PE trata via Chain Failure Recovery
5. **PE é o único sintetizador** — agentes nunca veem output uns dos outros
6. **Background agents para trabalho non-blocking** — use `run_in_background: true`

## Fan-Out / Fan-In Pattern

```
1. PE decompõe o request do Captain em N sub-tarefas independentes
2. PE spawna N agentes em paralelo (fan-out)
   - Cada agente recebe: descrição da tarefa + zone assignment + output contract
3. PE coleta todos os resultados
4. PE sintetiza em resposta unificada (fan-in)
5. PE apresenta análise coerente ao Captain
```
