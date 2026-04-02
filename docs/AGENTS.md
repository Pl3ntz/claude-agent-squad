# Catálogo de Agentes

Referência rápida de todos os 16 agentes, organizados por squad.

---

## Planning & Design Squad

### architect

| Campo | Valor |
|-------|-------|
| **Modelo** | Opus |
| **Tipo** | Read-only (análise) |
| **Ferramentas** | Read, Grep, Glob, Skill(local-mind:super-search) |
| **Quando usar** | Decisões de arquitetura, design de sistema, avaliação de trade-offs |

**O que faz:** Analisa a arquitetura atual e propõe decisões de design com alternativas e trade-offs. Sempre apresenta múltiplas opções — nunca uma solução única.

**Output:** Decisão de design + tabela de alternativas (prós/contras) + trade-offs + RESUMO

---

### planner

| Campo | Valor |
|-------|-------|
| **Modelo** | Opus |
| **Tipo** | Read-only (análise) |
| **Ferramentas** | Read, Grep, Glob, Skill(local-mind:super-search) |
| **Quando usar** | Features complexas que precisam de plano faseado com riscos e dependências |

**O que faz:** Cria planos de implementação detalhados com fases, passos, riscos e mitigações. Cada passo referencia file paths específicos.

**Output:** Plano em fases + riscos + RESUMO

---

## Quality Gate Squad

> Todos os agentes deste squad são **read-only** e **sempre rodam em paralelo**.

### code-reviewer

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Read-only |
| **Ferramentas** | Read, Grep, Glob, Bash, Skill(local-mind:super-search) |
| **Quando usar** | Após escrever ou modificar código — valida qualidade, segurança e manutenabilidade |

**O que faz:** Revisa código por prioridade: CRITICAL (segurança, perda de dados) > HIGH (lógica, error handling) > MEDIUM (qualidade, performance) > LOW (estilo, naming). Verifica patterns Python/FastAPI e TypeScript.

**Output:** Achados ordenados por severidade + RESUMO

---

### security-reviewer

| Campo | Valor |
|-------|-------|
| **Modelo** | Opus |
| **Tipo** | Read-only |
| **Ferramentas** | Read, Bash, Grep, Glob, Skill(local-mind:super-search) |
| **Quando usar** | Auditoria de infraestrutura, hardening, secrets, firewall, SSL, systemd |

**O que faz:** Audita segurança de infraestrutura (SSH, firewall, systemd, PostgreSQL, Redis, Nginx, SSL). Diferente do code-reviewer — foca em infra, não em patterns de código.

**Output:** Tabela de ameaças por área + achados + RESUMO

---

### ux-reviewer

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Read-only |
| **Ferramentas** | Read, Grep, Glob, Bash, Skill(local-mind:super-search) |
| **Quando usar** | Após mudanças de UI — acessibilidade (WCAG 2.2 AA), consistência, estados de interação |

**O que faz:** Revisa frontend por acessibilidade, contraste, navegação por teclado, touch targets, design consistency, estados de interação (hover, focus, disabled, loading, error, empty).

**Output:** Achados ordenados por impacto no usuário + RESUMO

---

### staff-engineer

| Campo | Valor |
|-------|-------|
| **Modelo** | Opus |
| **Tipo** | Read-only |
| **Ferramentas** | Read, Grep, Glob, Bash, Skill(local-mind:super-search) |
| **Quando usar** | Mudanças que afetam múltiplos projetos ou infraestrutura compartilhada |

**O que faz:** Avalia impacto organizacional (L4): cross-system dependencies, propagação de padrões, dívida técnica com impacto no negócio.

**Output:** Impacto cross-system + propagação de padrão + dívida técnica + RESUMO

---

## Implementation Squad

> Todos os agentes deste squad **escrevem código** e precisam de **zone assignment** do PE.

### tdd-guide

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Write (escrita de código) |
| **Ferramentas** | Read, Write, Edit, Bash, Grep, Glob |
| **Quando usar** | Novas features, bug fixes, refactoring — sempre com testes primeiro |

**O que faz:** Implementa usando TDD (Red-Green-Refactor). Escreve testes primeiro, depois implementação mínima para passar. Garante cobertura 80%+.

**Output:** Testes escritos + cobertura + RESUMO

---

### e2e-runner

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Write |
| **Ferramentas** | Read, Write, Edit, Bash, Grep, Glob |
| **Quando usar** | Testes de fluxos críticos de usuário com Playwright |

**O que faz:** Cria e executa testes E2E com Playwright. Gerencia testes instáveis (flaky), captura screenshots/vídeos, e usa Page Object Model.

**Output:** Resultados (passou/falhou/instável) + falhas + RESUMO

---

### build-error-resolver

| Campo | Valor |
|-------|-------|
| **Modelo** | Haiku |
| **Tipo** | Write |
| **Ferramentas** | Read, Write, Edit, Bash, Grep, Glob |
| **Quando usar** | Build falhou, type errors, serviço não inicia |

**O que faz:** Corrige erros de build com minimal diff. Não refatora, não otimiza, não redesenha — apenas corrige o erro e verifica que o build passa.

**Output:** Erros corrigidos + pendentes + RESUMO

---

### refactor-cleaner

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Write |
| **Ferramentas** | Read, Write, Edit, Bash, Grep, Glob |
| **Quando usar** | Remoção de dead code, cleanup, consolidação de duplicatas |

**O que faz:** Identifica e remove código morto, dependências não utilizadas, e duplicatas. Usa ferramentas de análise (knip, vulture) e verifica todas as referências antes de remover.

**Output:** Itens removidos + impacto + RESUMO

---

## Operations Squad

### incident-responder

| Campo | Valor |
|-------|-------|
| **Modelo** | Opus |
| **Tipo** | Read-only (diagnóstico) |
| **Ferramentas** | Read, Bash, Grep, Glob, Skill(local-mind:super-search) |
| **Quando usar** | Serviço caiu, erros aumentando, usuários reportando problemas |

**O que faz:** Segue workflow de 5 fases: Triage (2min) > Diagnose (5-10min) > Remediate (opções) > Verify > Document. Nunca executa correções — apenas diagnostica e recomenda.

**Output:** Serviços afetados + causa raiz + opções (rápida vs completa) + RESUMO

---

### devops-specialist

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Write |
| **Ferramentas** | Read, Write, Edit, Bash, Grep, Glob |
| **Quando usar** | CI/CD, deploy, systemd, monitoring, Nginx, SSL |

**O que faz:** Analisa e melhora pipelines CI/CD, automatiza deploys, configura serviços systemd, e gerencia infraestrutura (Nginx, SSL). Sempre apresenta antes de executar.

**Output:** Achados + mudanças propostas + RESUMO

---

### performance-optimizer

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Read-only |
| **Ferramentas** | Read, Bash, Grep, Glob, Skill(local-mind:super-search) |
| **Quando usar** | Serviço lento, recursos limitados, antes de decisões de scaling |

**O que faz:** Mede métricas de sistema (CPU, memória, disco), analisa queries PostgreSQL lentas, Redis, Nginx tuning, e patterns async Python/FastAPI. Sempre com valores medidos, nunca suposições.

**Output:** Métricas + gargalos + RESUMO

---

### database-specialist

| Campo | Valor |
|-------|-------|
| **Modelo** | Sonnet |
| **Tipo** | Read-only |
| **Ferramentas** | Read, Bash, Grep, Glob, Skill(local-mind:super-search) |
| **Quando usar** | Design de schema, queries lentas, indexação, migrations, saúde do banco |

**O que faz:** Analisa saúde do PostgreSQL, identifica queries lentas via EXPLAIN ANALYZE, recomenda indexes, valida segurança de migrations, e monitora bloat/vacuum.

**Output:** Achados com evidência de EXPLAIN ANALYZE + RESUMO

---

## Intelligence Squad

### deep-researcher

| Campo | Valor |
|-------|-------|
| **Modelo** | Opus |
| **Tipo** | Read-only (pesquisa web) |
| **Ferramentas** | WebSearch, WebFetch, Bash, Read, Grep, Glob, Skill(local-mind:super-search) |
| **Quando usar** | Pesquisa profunda multi-fonte, comparações, OSINT, triangulação |

**O que faz:** Pesquisa em 6 fases: Plan > Search > Distill > Evaluate > Iterate > Synthesize. Usa 7 estratégias de reformulação de queries. Toda afirmação precisa de 3+ fontes para confiança HIGH.

**Output:** Achados com nível de confiança + contradições + lacunas + RESUMO

---

### doc-updater

| Campo | Valor |
|-------|-------|
| **Modelo** | Haiku |
| **Tipo** | Write |
| **Ferramentas** | Read, Write, Edit, Bash, Grep, Glob |
| **Quando usar** | Atualizar codemaps, READMEs, documentação |

**O que faz:** Gera e atualiza documentação baseada no código real. Nunca documenta de memória — sempre lê o codebase atual primeiro.

**Output:** Alterações realizadas + RESUMO
