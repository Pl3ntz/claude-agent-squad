# Exemplo: Configuração de Projeto

Este é um template de como configurar o contexto do seu projeto para os agentes.

## CLAUDE.md (coloque na raiz do seu projeto)

```markdown
# Meu Projeto

## Stack
- Backend: Python 3.12 / FastAPI
- Frontend: TypeScript / React / Vite
- Database: PostgreSQL 16
- Cache: Redis 7
- Process Manager: systemd

## Serviços
| Serviço | Porta | Health Check |
|---------|-------|-------------|
| backend | 8000 | /health |
| scheduler | - | systemctl status |
| frontend | 3000 | / |

## Convenções
- Testes: pytest (backend), Vitest (frontend)
- Linting: ruff (Python), ESLint (TypeScript)
- Formatação: ruff format (Python), Prettier (TypeScript)
- Commits: conventional commits (feat, fix, refactor, etc.)
- Imutabilidade: sempre criar novos objetos, nunca mutar

## Deploy
- Server: via SSH
- Branch de produção: master
- Deploy: git pull → systemctl restart
- Backup: pg_dump antes de cada deploy

## Variáveis de Ambiente
- Credenciais em `.env` (nunca commitado)
- Carregar com `set -a && source .env && set +a`
```

## Context Preamble (o PE usa antes de spawnar agentes)

```markdown
---context---
project: meu-projeto
stack: Python 3.12, FastAPI, PostgreSQL 16, Redis 7
path: /path/to/my-project (ou ssh my-server "/path/to/project")
services: backend.service, scheduler.service
state: git status limpo, serviços rodando
scope: src/api/auth.py, tests/test_auth.py
constraints: production server, load .env before commands
---end-context---
```

## Customizações por Projeto

### Projeto com Docker
Se seu projeto usa Docker ao invés de systemd, ajuste o `incident-responder.md` e `devops-specialist.md` para usar `docker compose` ao invés de `systemctl`.

### Projeto com Kubernetes
Se usa K8s, considere criar um agente `k8s-specialist.md` baseado no template do `devops-specialist.md`.

### Projeto monorepo
Para monorepos, o zone assignment do Crawler Protocol é essencial — cada agente recebe uma pasta diferente do monorepo.
