# Padrões Aplicados

Este documento explica os padrões e técnicas que fundamentam o Quarterdeck. Cada padrão foi pesquisado, validado com múltiplas fontes, e testado em produção.

---

## 1. Comunicação Estruturada (Inspirado no Golden Circle)

**Origem:** Simon Sinek — "Start with Why"

**Conceito:** Comunicar na ordem impacto → abordagem → resultado. Em vez de começar pelo "o quê" (encontrei 3 bugs), começar pelo "por quê" (o sistema tinha risco de perda de dados).

**Como aplicamos:** Cada agente termina com um `### RESUMO` que flui naturalmente nessa ordem:
1. Qual o impacto no sistema/negócio
2. Como foi analisado/abordado
3. O que foi encontrado/entregue com números concretos

**Por que funciona:** O Captain entende a importância antes do detalhe técnico. Pode parar de ler a qualquer momento e já tem o contexto necessário para decidir.

---

## 2. Squad Model (Inspirado em Squads Spotify)

**Origem:** Modelo organizacional do Spotify adaptado para agentes de IA

**Conceito:** Em vez de uma hierarquia rígida (Tier 1/2/3), organizar por **função** em squads autônomos:
- **Planning & Design** — pensa antes de fazer
- **Quality Gate** — valida sem modificar (read-only, sempre em paralelo)
- **Implementation** — escreve código (com zone assignment)
- **Operations** — mantém o sistema rodando
- **Intelligence** — pesquisa e documenta

**Por que funciona:** Cada squad tem regras diferentes. Quality Gate sempre roda em paralelo porque é read-only. Implementation precisa de zonas de arquivo para evitar conflitos. Essa separação é impossível com uma hierarquia genérica.

---

## 3. Crawler Protocol (Inspirado em Web Crawlers)

**Origem:** Padrão fan-out/fan-in de web crawlers + wave execution de computação paralela

**Conceito:** Em vez de executar agentes um após o outro (A → B → C → D), agrupar em ondas paralelas:
- Wave 1: reconhecimento (múltiplos agentes exploram simultaneamente)
- Wave 2: planejamento (sequencial, baseado nos resultados da Wave 1)
- Wave 3: validação (múltiplos revisores em paralelo)

**Como prevenimos conflitos:** Zone assignment — cada agente que escreve código recebe uma zona exclusiva de arquivos. Dois agentes nunca editam o mesmo arquivo na mesma wave.

**Por que funciona:** Reduz tempo em 40-60% para tasks multi-agente. 3 revisores em paralelo terminam no tempo de 1, não de 3.

---

## 4. Ground Truth Protocol (Inspirado em "Read Before Write")

**Origem:** Anthropic — "Effective Context Engineering for AI Agents" (2025)

**Conceito:** Todo agente deve ler o código/configs existentes ANTES de analisar ou recomendar qualquer coisa. Agentes que assumem o estado do código alucinam.

**Regras:**
1. Leia antes de agir
2. Busque padrões existentes no projeto
3. Pergunte quando tiver dúvida — verifique antes de afirmar
4. Explique o porquê de cada recomendação

**Por que funciona:** Elimina recomendações baseadas em suposições. O agente adapta suas sugestões ao que o projeto JÁ faz, em vez de propor padrões teóricos.

---

## 5. Active Debate Protocol (Inspirado em Red Team/Blue Team)

**Origem:** Prática militar de red teaming + abordagem adversarial de machine learning

**Conceito:** Agentes estratégicos não são executores passivos — são **advisors que desafiam decisões**:
- Buscam memória de sessões anteriores para contexto histórico
- Desafiam decisões quando identificam conflitos com o passado
- Apresentam alternativas com trade-offs claros
- Flagram padrões que causaram problemas antes

**Por que funciona:** Previne repetição de erros. Se um padrão causou bug antes, o agente avisa antes de repetir. Decisões são debatidas, não rubber-stamped.

---

## 6. Instruções Positivas (Inspirado na "Pink Elephant Theory")

**Origem:** Ironic Process Theory (Daniel Wegner) + pesquisa 16x Engineer (2025)

**Conceito:** Dizer ao modelo o que NÃO fazer ("NEVER guess") pode paradoxalmente aumentar a chance do comportamento indesejado. A alternativa: instruções positivas ("Sempre verifique antes de afirmar").

**Como aplicamos:** Todos os agents usam formulação positiva:
- Em vez de "NEVER assume" → "Sempre verifique"
- Em vez de "DO NOT guess" → "Pergunte quando tiver dúvida"
- Em vez de "NEVER execute without approval" → "Apresente achados e aguarde aprovação"

**Por que funciona:** LLMs respondem melhor a instruções claras sobre o que FAZER do que a proibições sobre o que NÃO fazer. Reduz ambiguidade e melhora consistência.

---

## 7. Context Engineering (Inspirado na Anthropic 2025)

**Origem:** Anthropic — "Context Engineering" (2025, renomeação de "Prompt Engineering")

**Conceito:** Não é sobre escrever prompts mais longos — é sobre cada token contribuir para o comportamento desejado. Signal-to-noise ratio alto.

**Como aplicamos:**
- Agents têm token budget definido (200-800 tokens dependendo do tipo)
- Seções são ordenadas: Role → Ground Truth → Instruções → Output Format
- Ferramentas são o mínimo necessário (não herda tudo)
- Exemplos concretos (`<example>`) para consistência de output

**Por que funciona:** Agentes com prompts enxutos e focados produzem outputs mais consistentes e consomem menos tokens.

---

## 8. Aprendizado Contínuo

**Origem:** Self-Improvement Protocol + Auto-Learning Protocol

**Conceito:** O sistema aprende com seus próprios erros e acertos:
- **Tips:** Padrões de sucesso extraídos de sessões e salvos em memória
- **Error Memory:** Erros detectados automaticamente via hooks, resoluções logadas, índice consultado antes de retentativas
- **Debate Protocol:** Agentes consultam memória de sessões anteriores antes de recomendar

**Por que funciona:** Em vez de repetir os mesmos erros, o sistema acumula conhecimento ao longo do tempo. Um erro corrigido uma vez é lembrado para sempre.

---

## 9. Maker-Checker (Evaluator-Optimizer)

**Origem:** Padrão bancário de dual-control adaptado para agentes

**Conceito:** Para mudanças de código, o agente que faz (maker) é diferente do que valida (checker):
```
tdd-guide (maker) → code-reviewer (checker) → PASS/FAIL
```

Se o checker reprova, feedback específico volta ao maker para retry (max 2x). Se falha após 2 retentativas, escala ao Captain.

**Por que funciona:** Previne que bugs passem despercebidos. O maker foca em implementar, o checker foca em encontrar problemas. Perspectivas diferentes encontram problemas que uma perspectiva única perderia.

---

## 10. Hierarquia Explícita (Captain > PE > Agentes)

**Origem:** Cadeia de comando militar adaptada para orquestração de IA

**Conceito:** Três camadas com responsabilidades claras:
- **Captain:** Decide. Aprova planos, direciona trabalho, escolhe alternativas.
- **PE:** Orquestra. Decompõe demandas, spawna agentes, sintetiza resultados, debate.
- **Agentes:** Executam. Trabalham no escopo atribuído, reportam ao PE.

**Regra absoluta:** Agentes nunca agem independentemente. Nunca override PE ou Captain. O PE é o único que sintetiza resultados de múltiplos agentes.

**Por que funciona:** Elimina ambiguidade sobre quem decide o quê. O Captain nunca é surpreendido por uma ação não autorizada.
