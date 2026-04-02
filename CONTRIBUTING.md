# Contribuindo

Obrigado por considerar contribuir com o Quarterdeck!

## Como Contribuir

### Reportar Bugs

1. Abra uma [issue](https://github.com/Pl3ntz/quarterdeck/issues) descrevendo:
   - Qual agente apresentou o problema
   - O que você esperava vs o que aconteceu
   - Versão do Claude Code (`claude --version`)

### Sugerir Melhorias

1. Abra uma issue com a tag `enhancement`
2. Descreva o caso de uso e por que a melhoria seria útil

### Contribuir com Código

1. Fork o repositório
2. Crie uma branch: `git checkout -b feat/meu-agente`
3. Faça suas alterações seguindo as convenções abaixo
4. Commit: `git commit -m "feat: adiciona agente X"`
5. Push: `git push origin feat/meu-agente`
6. Abra um Pull Request

## Convenções

### Formato de Commit

```
<tipo>: <descrição>
```

Tipos: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

### Estrutura de Agentes

Todo agente deve seguir esta estrutura:

```yaml
---
name: nome-do-agente
description: Descrição curta. Quando usar este agente.
tools: [ferramentas necessárias]
model: sonnet|opus|haiku
---
```

Seções obrigatórias:
1. **Ground Truth First** — Instruções de "leia antes de agir"
2. **Seções de domínio** — Conteúdo específico do agente
3. **Output Format (MANDATORY)** — Formato de saída padronizado com ACHADOS + RESUMO

### Regras de Output

Todo agente deve ter:
- `### ACHADOS` — Ordenados por severidade
- `### PRÓXIMO PASSO` — Ação recomendada
- `### RESUMO:` — Texto fluido: impacto → abordagem → resultado concreto
- Regra de idioma pt-BR
- Token budget definido

### Dados Sensíveis

Antes de fazer PR, verifique que não há:
- Nomes de servidores ou IPs
- Nomes de projetos reais
- Caminhos absolutos pessoais (`/root/`, `/home/user/`)
- API keys, tokens, ou senhas
- Nomes de empresas ou clientes

Use placeholders genéricos: `your-server`, `your-project`, `/path/to/<project>`

## Estrutura de Diretórios

```
agents/     → Definições de agentes (1 arquivo por agente)
rules/      → Rules de orquestração do PE
docs/       → Documentação detalhada
examples/   → Exemplos e templates
```

## Dúvidas?

Abra uma issue ou entre em contato via GitHub.
