# IC Flow

**App educacional de apoio à decisão clínica em insuficiência cardíaca (iOS · Swift · SwiftUI). Versão 1.0.**

> ⚠️ **Aviso:** ferramenta **educacional**, destinada a médicos. **Conteúdo clínico
> em validação** (ver `CLINICAL_CONTENT_STATUS.md` e `VALIDATION_PLAN.md`). As
> recomendações devem ser interpretadas por médico habilitado, à luz do contexto
> clínico, diretrizes vigentes, protocolos institucionais e bulas oficiais. **Não
> substitui o julgamento clínico**, **não emite ordens absolutas** e **não armazena
> dados identificáveis de pacientes**. Funciona **totalmente offline**: sem login,
> banco remoto, assinatura, notificações ou integração externa.

## Novidades da versão 0.2

- **Motor clínico mais confiável**, com status de recomendação em **6 estados**
  (`recommended / consider / caution / contraindicated / insufficientData /
  urgentReferral`) e linguagem não imperativa.
- **Validação de completude (dados ausentes):** o motor não ignora dados em falta;
  exige os parâmetros essenciais por cenário e, quando faltam, marca a classe como
  *dados insuficientes* em vez de afirmar elegibilidade. A interface mostra
  "Dados ausentes que limitam a recomendação".
- **ICFEr expandida:** além dos quatro pilares, terapias adicionais conforme perfil
  (hidralazina+nitrato, ivabradina, vericiguate, digoxina, ferro IV como
  encaminhamento) e regras novas (ex.: angioedema contraindica INRA/IECA; ivabradina
  apenas em ritmo sinusal).
- **IC aguda expandida:** equivalências de diurético de alça e orientação de
  resposta inadequada com bloqueio sequencial do néfron (tiazídico, metolazona,
  acetazolamida).
- **Novo módulo ICFEp / ICFEm** com **escore H2FPEF** (reportado apenas quando há
  dados objetivos; caso contrário, "escore incompleto").
- **Checklist de alta** pós-descompensação (tela opcional).
- **Conteúdo versionado** (`contentVersion` / `lastReviewed`) e **rastreável por
  referência**.

## Ferramentas adicionais (v0.3)

- **Exportar/compartilhar** a avaliação como **PDF anônimo** (aba Resumo → folha de
  compartilhamento do iOS). Sem identificadores de paciente.
- **Calculadoras**: CHA₂DS₂-VASc, TFGe (CKD-EPI 2021), déficit de ferro (Ganzoni) e
  sódio corrigido para hiperglicemia.
- **Plano de otimização (GDMT)** no fluxo ICFEr: quais pilares considerar otimizar vs.
  bloqueados, com **alerta de interação** (duplo bloqueio SRAA + ARM → hipercalemia).
- **Novo cenário: Choque / IC refratária** — triagem educacional de instabilidade/baixo
  débito (encaminhamento a ambiente monitorizado), fora do fluxo de congestão simples.

## Mais ferramentas (v0.4)

- **Histórico local anônimo** — casos salvos **apenas no aparelho** (criptografados em
  repouso), sem nuvem/login e **sem identificadores** (apenas dados clínicos +
  rótulo livre não identificável). Salvar/abrir/“apagar tudo”.
- **Natriurese guiada** — calculadora de resposta diurética (sódio urinário spot /
  débito urinário → adequada / inadequada / incompleta).
- **Overlays no fluxo ICFEr** — orientações de **IC + FA** (ritmo = FA) e **IC + DRC**
  (TFGe < 60), a partir de dados já coletados.
- **Referências com busca** offline + metadados (ano · tipo · nível de evidência) e
  **acessibilidade** (Dynamic Type via fontes semânticas; ícones decorativos ocultos do
  VoiceOver).

**Idiomas:** português (padrão) e inglês, com **seletor de idioma dentro do app**
(menu do globo 🌐). A troca é ao vivo: recarrega o conteúdo clínico e reavalia o caso.

---

## Escopo

Três fluxos clínicos + um checklist:

1. **ICFEr crônica** — insuficiência cardíaca com fração de ejeção reduzida (FEVE ≤ 40%).
   Avalia elegibilidade dos quatro pilares fundamentais:
   - INRA / IECA / BRA
   - Betabloqueador
   - Antagonista do receptor mineralocorticoide (MRA)
   - Inibidor de SGLT2 (iSGLT2)

   Para cada classe: **elegível / cautela / contraindicado**, justificativa breve,
   dose inicial e dose-alvo (mock), monitoramento e alertas de segurança.

2. **IC aguda congesta** — descompensação com congestão, **sem choque cardiogênico**.
   Classifica congestão × perfusão e, para o perfil **congesto sem hipoperfusão grave**,
   sugere uma estrutura de **diurético de alça IV**:
   - Em uso prévio de diurético oral → dose IV inicial ≈ **2,5× a dose oral diária**
     (Felker et al., 2020), fracionada em ≥ 2 administrações.
   - Virgem de diurético → dose inicial padrão (furosemida 40 mg IV; faixa 40–80 mg).
   - Monitoramento de diurese, peso, balanço hídrico, PA, creatinina, sódio, potássio
     e magnésio.
   - **Alertas para avaliação especializada** em hipotensão, hipoperfusão, oligúria,
     hipercalemia grave ou deterioração renal importante.

3. **ICFEp / ICFEm** — fração de ejeção preservada (≥ 50%) ou levemente reduzida
   (41–49%), com foco em diagnóstico (exclusão de mimetizadores), **escore H2FPEF**,
   consideração de iSGLT2, controle de congestão e manejo de comorbidades.

Além disso, um **Checklist de alta** pós-descompensação (tela opcional).

### Telas
Disclaimer → Escolha do cenário (ou Checklist de alta) → Entrada de dados clínicos →
Resultado, que reúne em abas: **Recomendações** (em blocos), **Alertas de segurança**,
**Resumo** e **Referências**.

---

## Arquitetura

O projeto separa **conteúdo clínico** e **lógica de decisão** da **interface**.

```
heart-failure/
├── ICFlow.xcodeproj            # Projeto do app iOS (referencia o pacote local ICFlowCore)
├── ICFlow/                     # Camada de UI (SwiftUI) — NÃO contém regras clínicas
│   ├── App/                    # Ponto de entrada e navegação
│   ├── ViewModels/             # Estado da sessão (nada é persistido)
│   ├── Views/                  # As 7 telas do MVP
│   └── Components/             # Componentes e tema reutilizáveis
│
└── ICFlowCore/                 # Pacote Swift (Foundation puro, SEM SwiftUI) — o "cérebro"
    ├── Package.swift
    ├── Sources/ICFlowCore/
    │   ├── Models/             # Medication, ClinicalRule, SafetyAlert, Reference,
    │   │                       #   Recommendation, PatientInput, enums
    │   ├── Content/            # ContentRepository (carrega os JSON)
    │   ├── Engine/             # DecisionEngine + avaliadores + cálculo de diurético
    │   └── Resources/          # *** CONTEÚDO CLÍNICO EM JSON (por idioma) ***
    │       ├── medications_pt.json      / medications_en.json
    │       ├── clinical_rules_pt.json   / clinical_rules_en.json
    │       ├── safety_alerts_pt.json    / safety_alerts_en.json
    │       ├── references_pt.json       / references_en.json
    │       ├── engine_messages_pt.json  / engine_messages_en.json
    │       └── discharge_checklist_pt.json / discharge_checklist_en.json
    └── Tests/ICFlowCoreTests/  # Testes unitários das regras clínicas críticas
```

**Princípios:**
- `ICFlowCore` não importa SwiftUI/UIKit → a lógica clínica é testável isoladamente
  e roda em qualquer plataforma (`swift test`).
- **Nenhuma recomendação clínica é "hardcoded" nas views.** Todo o conteúdo
  (medicamentos, doses, regras, limiares, alertas, referências) vive nos arquivos JSON.
- O `DecisionEngine` lê os JSON e gera `Recommendation`/`AssessmentResult`; as views
  apenas renderizam o resultado.

### Como funciona o motor de decisão

As regras de elegibilidade são **dados**, não código. Cada `ClinicalRule` em
`clinical_rules.json` descreve condições sobre os campos do paciente:

```json
{
  "id": "mra_contra_hyperkalemia",
  "classId": "mra",
  "logic": "all",
  "status": "contraindicated",
  "conditions": [{ "field": "potassium", "op": "gt", "value": 5.5 }],
  "justification": "Potássio > 5,5 mmol/L: contraindicado iniciar MRA; corrigir e reavaliar.",
  "safetyAlertIds": ["mra_hyperkalemia"],
  "referenceIds": ["patolia2023", "greene2023"]
}
```

Para cada classe, o motor coleta as regras que disparam e aplica o status **mais
restritivo** (contraindicado > cautela > elegível). Campos não preenchidos não são
avaliados (nunca geram contraindicação falsa).

---

## Como atualizar o conteúdo médico

Todo o conteúdo clínico está em `ICFlowCore/Sources/ICFlowCore/Resources/`.
Em geral, **não é preciso alterar código Swift** — basta editar os JSON.
Cada tipo de arquivo existe **por idioma** (sufixo `_pt`/`_en`); edite a versão do
idioma desejado (ou ambas). Os nomes abaixo referem-se a cada par de arquivos.

### 1. Medicamentos e doses — `medications.json`
Cada item:

| Campo | Descrição |
|---|---|
| `id` | identificador único |
| `genericName` | nome exibido |
| `classId` | classe (`renin_angiotensin`, `beta_blocker`, `mra`, `sglt2`, `loop_diuretic`) |
| `subclass` | rótulo (ex.: `INRA`, `Betabloqueador`) |
| `scenario` | `chronicHFrEF` ou `acuteCongestion` |
| `isPrimary` | `true` no representante exibido por padrão na classe |
| `startingDose` / `targetDose` | doses (mock) |
| `monitoring` | lista de parâmetros |
| `safetyAlertIds` / `referenceIds` | referências cruzadas (devem existir nos outros JSON) |
| `furosemideEquivalentFactor` | só para diuréticos de alça (furosemida=1.0, bumetanida=40, torsemida=2) |

### 2. Regras clínicas — `clinical_rules.json`
- `contentVersion` / `lastReviewed`: versão e data de revisão do conteúdo (rastreabilidade).
- `hfrefRules`: regras de elegibilidade dos pilares (campo `status`).
- `hfrefAdditionalRules`: regras que sugerem terapias adicionais (não-pilares) conforme
  perfil (ivabradina, hidralazina+nitrato, vericiguate, digoxina, ferro IV).
- `acuteCongestionRules`: regras de "red flag" do fluxo agudo (sem `status`, apenas alertas).
- `acuteCongestionConfig`: parâmetros do cálculo de diurético
  (`ivLoopMultiplier`, `loopNaiveInitialFurosemideIVmg`, `minDailyDoses`,
  `cautionDailyFurosemideEquivMg`, `monitoringParameters`).
- `hfrefClassOrder` / `classLabels`: ordem e rótulos das classes.

**Operadores de condição** (`op`): `lt`, `lte`, `gt`, `gte`, `eq`, `neq`, `isTrue`, `isFalse`.
**Campos** (`field`): `lvef`, `nyha`, `systolicBP`, `heartRate`, `egfr`, `potassium`,
`creatinine`, `rhythm`, `congestion`, `hypoperfusion`, `priorDiureticUse`.
**Lógica** (`logic`): `all` (todas as condições) ou `any` (qualquer condição).

Para mudar um limiar (ex.: contraindicar MRA com K⁺ > 6,0 em vez de 5,5), altere apenas
o `value` da condição correspondente.

### 3. Alertas de segurança — `safety_alerts.json`
`id`, `title`, `severity` (`info`/`warning`/`critical`), `message`,
`relatedClassIds`, `referenceIds`.

### 4. Referências — `references.json`
`id`, `authors`, `title`, `source`, `year`, `topics`.

### Regras de integridade
- Todo `safetyAlertId` citado deve existir em `safety_alerts.json`.
- Todo `referenceId` citado deve existir em `references.json`.
- Todo `classId` em `hfrefClassOrder` deve ter ao menos um medicamento e um rótulo.

Após editar, rode os testes (`ContentRepositoryTests` valida o carregamento e as
referências cruzadas).

---

## Idiomas (i18n: português e inglês)

A localização é separada em duas camadas:

1. **Conteúdo clínico (pacote `ICFlowCore`)** — cada arquivo JSON tem uma versão por
   idioma com sufixo `_pt` / `_en` (medicamentos, regras, alertas, referências e os
   *templates* de mensagens do motor em `engine_messages_<lang>.json`). O
   `ContentRepository.load(language:)` escolhe os arquivos do idioma. A **estrutura**
   (ids, limiares das regras, fatores) é idêntica entre idiomas; só o **texto** muda.

2. **Interface (app `ICFlow`)** — as strings de tela e os rótulos de enums ficam em
   `ICFlow/App/Localization.swift` (tabelas `pt`/`en` + helpers de rótulo). O `AppModel`
   resolve as strings conforme o idioma atual.

O idioma escolhido é persistido em `UserDefaults`; na primeira execução o app tenta
seguir o idioma do sistema (português se o sistema estiver em PT, senão inglês).

### Como adicionar um novo idioma
1. Adicione o caso em `AppLanguage` (núcleo) com `nativeName`/`shortTag`/`resourceSuffix`.
2. Crie os 6 JSON com o novo sufixo em `ICFlowCore/.../Resources/` (copie os `_en` e
   traduza): `medications`, `clinical_rules`, `safety_alerts`, `references`,
   `engine_messages` e `discharge_checklist`. Mantenha **ids, limiares e contagem de
   regras** idênticos aos demais.
3. Acrescente as colunas do idioma em `Localizer` (tabela de strings + helpers de enums)
   em `ICFlow/App/Localization.swift`.
4. Rode os testes — `LocalizationContentTests` valida que os conjuntos de ids batem
   entre idiomas e que a saída do motor é traduzida.

---

## Como abrir, compilar e testar

**Requisitos:** macOS com Xcode 16+ (deployment target iOS 16).

```bash
open ICFlow.xcodeproj
```
Selecione o esquema **ICFlow** e um simulador → ⌘R para executar.

**Testes unitários das regras clínicas:**
- No Xcode: ⌘U.
- Ou via linha de comando (apenas o núcleo, sem UI):
  ```bash
  cd ICFlowCore && swift test
  ```

> Se o Xcode não resolver o pacote local automaticamente:
> *File ▸ Packages ▸ Reset Package Caches*. Em último caso, é possível recriar um
> app iOS chamado `ICFlow`, adicionar o pacote local via
> *File ▸ Add Package Dependencies… ▸ Add Local…* apontando para `ICFlowCore`,
> e arrastar a pasta `ICFlow/` para o target.

---

## Testes incluídos (regras críticas)

- `HFrEFEvaluatorTests` — paciente estável (4 pilares elegíveis); hipercalemia
  (contraindica SRAA/MRA); hipercalemia limítrofe (cautela); TFGe baixa (contraindica
  MRA); hipotensão grave (contraindica SRAA, cautela em BB/iSGLT2); bradicardia
  (contraindica BB); descompensação (cautela em BB); justificativas/alertas anexados.
- `AcuteCongestionTests` — perfis quente-úmido (diurético IV), frio-úmido e
  hipotensão (encaminhamento), seco (sem diurético); red flags de hipercalemia e renal.
- `DiureticCalculatorTests` — regra 2,5× (furosemida/bumetanida/torsemida),
  dose padrão se virgem de diurético, sinalização de dose elevada.
- `ContentRepositoryTests` — carregamento dos JSON, integridade das referências cruzadas,
  versionamento do conteúdo e checklist de alta.
- `LocalizationContentTests` — carga do conteúdo em inglês, paridade estrutural PT/EN,
  saída do motor traduzida e formatação numérica por idioma (2,5 vs 2.5).
- `HFpEFEvaluatorTests` — classificação por FEVE, escore H2FPEF (alto/incompleto),
  encaminhamento e iSGLT2.
- *(v0.2)* gating de dados ausentes (ICFEr/aguda), terapias adicionais (ivabradina/
  angioedema) e resposta inadequada (bloqueio sequencial do néfron).

---

## Limitações da versão 0.2

- **Conteúdo clínico ainda em validação** (`isClinicalContentValidated = false`):
  doses, limiares e textos são exemplos educacionais, pendentes de revisão por
  cardiologista. Ver `CLINICAL_CONTENT_STATUS.md` e `VALIDATION_PLAN.md`.
- O **escore H2FPEF** é uma implementação simplificada e só estima probabilidade
  quando há dados objetivos (idade, PSAP, E/e'); caso contrário fica "incompleto".
- O módulo **ICFEp/ICFEm** é educacional e enfatiza diagnóstico/comorbidades, não um
  protocolo terapêutico completo.
- **Fora do escopo desta versão:** login, backend, nuvem, banco de pacientes,
  assinatura, notificações, exportação de PDF, integração com prontuário, Apple Health
  e analytics.

## Fontes do conteúdo clínico

- Felker GM, Ellison DH, Mullens W, Cox ZL, Testani JM. *Diuretic Therapy for Patients
  With Heart Failure: JACC State-of-the-Art Review.* J Am Coll Cardiol. 2020;75(10):1178–1195.
- Greene SJ, Bauersachs J, Brugts JJ, et al. *Management of Worsening Heart Failure With
  Reduced Ejection Fraction: JACC State-of-the-Art Review.* J Am Coll Cardiol. 2023;82(6):559–571.
- Patolia H, Khan MS, Fonarow GC, Greene SJ, Khan SS. *Implementing Guideline-Directed
  Medical Therapy for Heart Failure.* J Am Coll Cardiol. 2023;82(6):529–543.

As referências são fornecidas para fins educacionais; consulte sempre as versões
completas e as diretrizes vigentes.
