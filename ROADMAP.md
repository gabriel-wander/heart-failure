# Roadmap — IC Flow

Documento estratégico de evolução do **IC Flow** (app educacional de apoio à decisão
clínica em insuficiência cardíaca, iOS · Swift/SwiftUI). Escrito a partir de uma leitura
ampla do código na **v1.0**. É um documento vivo — revisar a cada release.

---

## 1. Objetivo do projeto e trilhos invioláveis

**Objetivo:** dar ao médico, à beira do leito, apoio rápido, padronizado e rastreável
para as decisões mais comuns em IC (pilares da ICFEr, congestão aguda, ICFEp/ICFEm,
instabilidade), **sem substituir o julgamento clínico**.

**Trilhos que NÃO mudam** (qualquer item do roadmap respeita):
1. **Segurança clínica primeiro** — nada de ordens absolutas; linguagem "considerar/avaliar".
2. **Privacidade por desenho** — sem dados identificáveis de paciente; offline; sem login.
3. **Conteúdo separado da interface** — regras/doses/limiares em JSON, versionados e
   rastreáveis por referência.
4. **Validação antes do uso assistencial** — `isClinicalContentValidated` só vira `true`
   após revisão por cardiologista (ver `VALIDATION_PLAN.md`).

---

## 2. Estado atual (leitura do código, v1.0)

**Arquitetura (sólida):**
- `ICFlowCore` (pacote Swift, **Foundation puro**, sem UIKit/SwiftUI): modelos, motor
  (`DecisionEngine` + avaliadores por cenário, `RuleMatcher`, calculadoras), conteúdo
  (`ContentRepository` + JSON por idioma). **Testável e multiplataforma** (testes rodam no Linux).
- `ICFlow` (SwiftUI): só apresentação; consome o motor e os JSON.
- ~56 arquivos Swift · 12 JSON de conteúdo · 10 suítes de teste · CI em Mac/Linux.

**Pontos fortes:** motor data-driven; i18n estruturada; testes das regras críticas e
vinhetas; *gating* de dados ausentes; status em 6 estados; export/checklist/histórico/
calculadoras; privacidade por desenho.

**Dívidas técnicas / oportunidades observadas:**
- **i18n manual** (`Localization.swift` é uma tabela grande) → migrar para **String
  Catalogs (`.xcstrings`)** nativos.
- **Sem SwiftLint/format** no CI; sem **snapshot tests** de UI; build do app não roda em
  todo push (custo de minutos).
- **Sem testes de UI** automatizados; cobertura concentrada no núcleo.
- **Conteúdo de referências** mínimo (3 fontes) e sem `evidenceLevel`/`guidelineOrStudy`
  preenchidos; fichas de fármacos com campos opcionais ainda vazios.
- **Otimização da GDMT** é uma síntese; ainda não rastreia terapia/doses atuais do paciente.
- **Assinatura/distribuição** ainda manual (sem fastlane/TestFlight).
- Projeto `.pbxproj` com **um único target**; sem esquemas de build (Debug/Beta/Release)
  nem flags de ambiente além de `isClinicalContentValidated`.

---

## 3. Roadmap por horizontes

Prioridade: **P0** (gate/bloqueante) · **P1** (alto valor) · **P2** (valioso) · **P3** (futuro).
Esforço: S/M/L/XL.

### Horizonte 1 — "Pronto para piloto" (0–3 meses)

| Eixo | Item | Prio | Esf. |
|---|---|---|---|
| Validação | Revisão das vinhetas (`VIGNETTES.md`) por cardiologista; corrigir limiares/doses nos JSON; ampliar vinhetas (H2FPEF incompleto, IC+DRC, natriurese, doses). | **P0** | M |
| Validação | Atualizar **referências** para diretrizes vigentes (ESC 2021 + focused update 2023; AHA/ACC/HFSA 2022; Diretriz Brasileira de IC — SBC) e preencher `evidenceLevel`/`guidelineOrStudy`/`lastReviewed`. | **P0** | M |
| Validação | Critérios objetivos para `isClinicalContentValidated = true` + processo de changelog do conteúdo. | **P0** | S |
| Conformidade | **Política de Privacidade** e **Termo de Uso** no app; registro do aceite do disclaimer (data/versão, local). | **P0** | S |
| Distribuição | **Apple Developer Program** + **TestFlight**: build assinado (fastlane), beta com 5–10 médicos. | **P1** | M |
| Qualidade | Restaurar CI (minutos); **SwiftLint** + format no CI; build do app obrigatório em PR (sob demanda hoje). | **P1** | S |
| UX | **Launch screen** + *design system* mínimo (tokens de cor/tipografia/espaçamento); polir cartões e badges. | **P2** | M |

### Horizonte 2 — "Beta clínico amplo" (3–6 meses)

| Eixo | Item | Prio | Esf. |
|---|---|---|---|
| Clínico | **Titulação longitudinal**: capturar terapia/doses atuais (não identificável) para sugerir o **próximo passo real** de otimização. | **P1** | L |
| Clínico | Aprofundar **choque/refratariedade** (perfis hemodinâmicos, inotrópicos/vasopressores como referência, suporte mecânico, encaminhamento). | **P1** | L |
| Clínico | **Motor de interações** medicamentosas data-driven (além de SRAA+ARM): bradicardizantes, nefrotóxicos, QT, etc. | **P2** | M |
| Clínico | Mais **calculadoras** (MAGGIC, Seattle HF, KDIGO, MELD-XI, peso seco) e suporte a **unidades SI/convencional**. | **P2** | M |
| Conformidade | Avaliar enquadramento **ANVISA SaMD** (RDC 751/2022 e correlatas) caso o uso evolua de educacional para assistencial; classificação de risco e requisitos. | **P1** | L |
| Segurança | **Bloqueio do app por Face ID/senha** opcional para abrir o histórico; expurgo automático configurável. | **P2** | M |
| i18n | Migrar para **String Catalogs**; adicionar **Espanhol**; revisão linguística por par. | **P2** | M |
| Qualidade | **Snapshot tests** de UI; testes de acessibilidade; aumentar cobertura. | **P2** | M |

### Horizonte 3 — "Produto maduro" (6–12 meses)

| Eixo | Item | Prio | Esf. |
|---|---|---|---|
| Distribuição | **Publicação na App Store** (categoria Medical; metadados; conformidade de revisão Apple; conta organizacional/CNPJ). | **P1** | L |
| Clínico | Novos cenários: **IC pós-IAM**, **IC direita**, **cardiomiopatias específicas** (fluxo de amiloidose), **cardio-obstetrícia**, **cardio-oncologia**. | **P2** | XL |
| Conteúdo | **Biblioteca de fármacos** completa (indicações, titulação, ajustes renais, adversos); **material educativo para paciente** (genérico, sem PII, imprimível). | **P2** | L |
| Plataforma | **iPad** (split view), **widgets**, **Atalhos/Siri**, **Apple Watch** (referência rápida). | **P3** | L |
| Educação | Modo **treinamento/quiz** para residentes; "por que esta recomendação?" com referência inline. | **P3** | M |

### Horizonte 4 — "Escala e ecossistema" (12+ meses)

| Eixo | Item | Prio | Esf. |
|---|---|---|---|
| Operação | **Métricas anônimas opt-in** (uso de features, sem PII) para priorização — ponderar privacidade; ou manter zero telemetria. | **P3** | M |
| Integração | Avaliar **FHIR**/integração com prontuário **apenas** se houver enquadramento regulatório e modelo de privacidade adequados (fora do escopo educacional atual). | **P3** | XL |
| Conteúdo | Atualização contínua frente a novas diretrizes; comitê editorial; cadência de revisão. | **P2** | — |

---

## 4. Dependências e sequenciamento

- **Validação clínica (H1) é pré-requisito** para qualquer uso além de educacional e para
  marketing como ferramenta de decisão.
- **Apple Developer Program** habilita TestFlight (H1) → App Store (H3).
- **Titulação longitudinal (H2)** depende de um modelo de "terapia atual" não identificável.
- **ANVISA/SaMD (H2)** só é necessária se o posicionamento mudar de "educacional" para
  "assistencial"; decisão de produto/jurídica antes de engenharia.

## 5. Riscos principais

- **Regulatório/jurídico:** mudar de "educacional" para "decisão assistencial" sem
  validação/registro adequados. *Mitigação:* manter o gate de validação e o disclaimer;
  decisão consciente antes de reposicionar.
- **Conteúdo desatualizado:** diretrizes mudam. *Mitigação:* versionamento + cadência de
  revisão + `lastReviewed`.
- **Privacidade:** pressão para guardar dados identificáveis. *Mitigação:* manter o trilho;
  se necessário, caminho via prontuário institucional, não no app.
- **Custo de CI (macOS):** minutos. *Mitigação:* testes no Linux + macOS sob demanda (já feito).

## 6. Definição de "pronto para uso assistencial" (checklist)

- [ ] Vinhetas revisadas e aprovadas por cardiologista; suíte verde.
- [ ] Referências atuais mapeadas a cada recomendação (com nível de evidência).
- [ ] Doses/limiares revisados frente a bulas e diretrizes vigentes.
- [ ] Política de privacidade, termo de uso e registro de consentimento.
- [ ] Avaliação de enquadramento regulatório concluída (educacional vs. SaMD).
- [ ] `isClinicalContentValidated = true` + changelog do conteúdo registrado.
