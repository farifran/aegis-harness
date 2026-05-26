cat >> ~/.bashrc <<'EOF'

export OPENAI_API_BASE="https://integrate.api.nvidia.com/v1"

export OPENAI_API_KEY="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"

EOF

source ~/.bashrc

echo $OPENAI_API_BASE

curl https://integrate.api.nvidia.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model":"meta/llama-3.3-70b-instruct",
    "messages":[
      {
        "role":"user",
        "content":"Reply only with OK"
      }
    ],
    "temperature":0
  }'

timeout 20 aider \
  --model openai/meta/llama-3.3-70b-instruct \
  --message "Reply ONLY with: OK" \
  --yes-always \
  --no-show-model-warnings \
  --no-stream \
  --no-pretty \
  --map-tokens 0 \
  --no-git \
  --exit

# Aegis Harness

Um runtime epistemológico para engenharia estruturalmente limitada com modelos frontier.

O Aegis não é:
- um framework tradicional de orquestração;
- um pipeline rígido multiagente;
- um serializador completo de cognição;
- um controlador arquitetural determinístico.

O sistema existe para preservar cognição integrada de modelos frontier enquanto contém seletivamente as gravidades cognitivas mais propensas a degradar confiabilidade estrutural:
- convergência prematura;
- certeza sem suporte estrutural;
- drift de otimização;
- contaminação adversarial;
- expansão arquitetural descontrolada;
- vazamento de orquestração.

O Aegis protege a formação de verdade estrutural sem destruir momentum operacional.

---

# Identidade Arquitetural

O Aegis separa explicitamente:

| Camada | Responsabilidade |
|---|---|
| `AGENTS.md` | governança constitucional |
| `mode_*.md` | cognição local especializada |
| `runtime/orchestrator` | sequenciamento operacional |
| enforcement | contenção mecanicamente aplicável |
| `architecture_graph.json` | metadata estrutural epistemológica |
| `active_task.md` | contexto operacional volátil |

Essas camadas não devem colapsar silenciosamente umas nas outras.

O sistema previne intencionalmente:
- colapso entre governança e runtime;
- vazamento de orquestração;
- loops cognitivos recursivos;
- autoridade implícita de redesign;
- pressão de convergência oculta.

---

# Filosofia Central

O objetivo do Aegis não é controle operacional máximo.

O objetivo é:
- cognição limitada de forma proporcional;
- confiança proporcional à evidência;
- execução estruturalmente fundamentada;
- otimização proporcional;
- falsificação adversarial limitada;
- validação sensível à incerteza.

O sistema restringe seletivamente gravidades cognitivas perigosas enquanto preserva raciocínio operacional integrado.

---

# Arquitetura Cognitiva

| Modo | Função |
|---|---|
| Mode 0 | percepção semântica e expansão de possibilidade |
| Mode 1 | calibração de confiança e preservação de ambiguidade |
| Mode 2 | cognição integrada de execução |
| Mode 3 | cognição proporcional de otimização |
| Mode 4 | falsificação adversarial |
| Mode 5 | validação residual de confiança |

---

# Fluxo Cognitivo

```text
Mode 0 → Mode 1 → Mode 2 → Mode 3 → Mode 4 → Mode 5
```

Nem todos os fluxos precisam utilizar todos os modos.

A orquestração de runtime determina dinamicamente:
- sequenciamento;
- escalada;
- interrupção;
- continuação operacional.

Os modos não orquestram outros modos.

Os modos podem:
- expor incerteza;
- sinalizar necessidade de escalada;
- revelar condições de contradição.

Os modos não devem:
- redefinir fluxo de orquestração;
- invocar recursivamente outras camadas epistemológicas;
- criar loops cognitivos implícitos.

---

# Modelo de Verdade Estrutural

Verdade estrutural deve permanecer fundamentada em:
- estrutura observável do repositório;
- relacionamentos de dependência;
- comportamento de execução;
- restrições mecanicamente aplicáveis.

Os seguintes elementos permanecem apenas como sinais consultivos até confirmação estrutural:
- interpretação semântica;
- sinais fracos;
- relações inferidas;
- documentação;
- contexto operacional volátil.

Confiança deve permanecer proporcional à evidência observável.

Ausência de contradição não estabelece correção.

---

# Filosofia de Confiança

Confiança é:
- limitada pela evidência;
- sensível à incerteza;
- proporcional à exposição estrutural.

Validação melhora confiança, mas não estabelece certeza de correção.

Incerteza residual deve permanecer explicitamente visível.

O Aegis separa intencionalmente:
- falsificação;
- validação;
- estimativa de confiança.

Essas operações possuem naturezas epistemológicas diferentes.

---

# Filosofia de Otimização

Otimização existe para reduzir complexidade operacional materialmente relevante.

Otimização deve permanecer:
- proporcional;
- observável;
- estruturalmente limitada;
- operacionalmente justificável.

Otimização não deve:
- perseguir elegância abstrata;
- inflar abstrações;
- realizar redesign implícito;
- otimizar para complexidade futura hipotética.

Otimizações locais repetidas não devem acumular em drift de redesign.

---

# Filosofia de Falsificação

Cognição adversarial existe para:
- expor premissas vulneráveis a contradição;
- pressionar superfícies estruturalmente expostas;
- invalidar confiança operacional sem suporte.

Probing adversarial deve permanecer:
- limitado;
- temporário;
- proporcional;
- orientado à contradição.

Se uma contradição material surgir:
- escalada ou interrupção ocorre antes da validação residual de confiança.

---

# Runtime e Orquestração

A orquestração de runtime é externalizada das camadas cognitivas.

O runtime:
- sequencia o fluxo operacional;
- determina rotas de escalada;
- decide interrupções;
- compõe fluxos proporcionais de execução.

O runtime não é governança constitucional.

Os modos não são orquestradores.

---

# Grafo Epistemológico

`.harness/architecture_graph.json` fornece metadata estrutural epistemológica.

O grafo pode informar:
- legalidade de dependências;
- proporcionalidade de mutação;
- contenção de otimização;
- proporcionalidade de falsificação;
- sensibilidade de confiança;
- criticidade estrutural.

O grafo informa cognição proporcional, mas não:
- substitui governança constitucional;
- define orquestração de runtime;
- controla sequenciamento cognitivo.

---

# Filosofia de Enforcement

Enforcement existe para:
- preservar observabilidade estrutural;
- conter expansão oculta de execução;
- reduzir opacidade operacional;
- limitar drift de redesign;
- preservar raciocínio limitado.

O objetivo não é pureza estilística.

O objetivo é confiabilidade epistemológica.

Containment mecânico pode incluir:
- garantias do TypeScript;
- boundaries do ESLint;
- enforcement via AST;
- validação contínua;
- contenção de mutação.

Enforcement contém.
Ele não governa.

---

# Contexto Operacional Volátil

`docs/active_task.md` armazena:
- raciocínio operacional temporário;
- contexto limitado de execução;
- observações de otimização;
- achados de falsificação;
- notas residuais de confiança.

Contexto operacional permanece:
- provisório;
- sensível à incerteza;
- não autoritativo;
até confirmação estrutural.

`active_task.md` não é:
- governança constitucional;
- orquestração de runtime;
- verdade arquitetural;
- memória persistente do sistema.

---

# Autoridade Humana

Humanos mantêm autoridade sobre:
- direção arquitetural;
- aprovação de redesign;
- evolução do grafo;
- aprovação de escaladas;
- aceitação de risco;
- evolução constitucional.

A IA auxilia através de:
- percepção;
- calibração;
- execução;
- otimização;
- falsificação;
- validação de confiança.

A IA não deve redefinir autonomamente a arquitetura do sistema.

---

# Estrutura do Repositório

```text
.harness/
  architecture_graph.json
  enforcement/
  modes/

.skills/
  00_architecture_core.md
  mode_*.md

docs/
  active_task.md

AGENTS.md
```

---

# Objetivo de Design

O Aegis existe para cooperar com modelos frontier de programação em vez de lutar contra eles.

O sistema preserva cognição integrada enquanto contém seletivamente as gravidades cognitivas mais propensas a degradar confiabilidade estrutural.

O objetivo não é orquestração procedural rígida.

O objetivo é confiabilidade epistemológica limitada e proporcional sob complexidade operacional real.

---

# Longitudinal Architectural Pressure

O Aegis Harness reconhece que pressão arquitetural recorrente pode emergir ao longo do tempo sem que isso automaticamente justifique redesign.

O sistema pode registrar:
- recorrência de fragilidade estrutural;
- pressão adversarial persistente;
- hotspots recorrentes;
- contenção operacional excessiva;
- acoplamento repetidamente exposto;
- exposição estrutural longitudinal.

Esses sinais permanecem:
- consultivos;
- não autoritativos;
- supervisionados por humanos;
- epistemologicamente transitórios.

Nenhuma pressão arquitetural concede autoridade automática para:
- redesign;
- reinterpretação arquitetural;
- mudança estrutural ampla;
- orquestração adaptativa.

A autoridade arquitetural permanece humana.

A pressão arquitetural longitudinal é armazenada operacionalmente em:
`docs/active_task.md`

Ela NÃO representa verdade estrutural consolidada.

---

# Proportional Cognitive Posture

O `architecture_graph.json` não é um orquestrador.

Ele funciona como metadata estrutural epistemológica para modular proporcionalmente:
- intensidade de ceticismo;
- cautela de mutação;
- agressividade adversarial;
- pressão de validação;
- degradação de confiança;
- agressividade de otimização.

O graph:
- não decide fluxo;
- não executa heurísticas;
- não adapta runtime;
- não controla orquestração.

O runtime permanece determinístico.

Os modos ajustam postura cognitiva proporcionalmente ao risco estrutural.

---

# Adversarial Falsification

O Mode 4 não é:
- replay de lint;
- inspeção passiva;
- negatividade semântica;
- validação atrasada.

O objetivo do adversarial é:
- pressionar hipóteses;
- procurar contradições;
- expor acoplamento oculto;
- desafiar invariantes implícitos;
- degradar confiança injustificada.

Ausência de contradição não estabelece corretude.

Execução bem-sucedida não estabelece verdade arquitetural.

---

# Epistemic Memory Model

O Aegis separa explicitamente:

| Tipo de memória | Papel |
|---|---|
| `active_task.md` | memória operacional viva e transitória |
| Git | memória histórica estrutural consolidada |

O `active_task.md` preserva:
- evidência estrutural;
- suspeita semântica;
- exposição residual;
- pressão adversarial;
- pressão arquitetural longitudinal.

O Git preserva apenas:
- mudanças sobreviventes;
- evolução estrutural consolidada;
- histórico validado.

O sistema evita fossilizar suspeitas operacionais em verdade histórica.
