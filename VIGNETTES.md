# Vinhetas clínicas de validação — IC Flow

Casos **fictícios e anônimos** (sem dados reais de pacientes) usados para validar o
conteúdo clínico, conforme o `VALIDATION_PLAN.md`. Para cada vinheta há um **teste
automatizado** correspondente em `ICFlowCoreTests/ClinicalVignettesTests.swift`, que
verifica a saída atual do motor.

**Como usar (revisor cardiologista):** para cada caso, marque se o resultado esperado
está **correto** clinicamente ou anote o **ajuste** necessário. Ajustes devem ser feitos
preferencialmente nos arquivos JSON de conteúdo (sem alterar código). Ao final, com tudo
aprovado e o CI verde, define-se `isClinicalContentValidated = true`.

> Estado atual: **em validação** (`isClinicalContentValidated = false`).

| # | Caso (fictício) | Resultado esperado (atual) | Aprovado? / Ajuste |
|---|---|---|---|
| V1 | ICFEr estável: FEVE 30%, PAS 120, FC 75, sinusal, TFGe 65, K⁺ 4,2 | 4 pilares = **Considerar**; sem dados ausentes | |
| V2 | Hipercalemia grave: K⁺ 5,9 | INRA/IECA/BRA e ARM = **Contraindicado** | |
| V3 | Disfunção renal: TFGe 25 | ARM = **Contraindicado** | |
| V4 | Hipotensão: PAS 85 | INRA/IECA/BRA = **Contraindicado** | |
| V5 | Bradicardia: FC 48 | Betabloqueador = **Contraindicado** | |
| V6 | História de angioedema | INRA/IECA/BRA = **Contraindicado** | |
| V7 | Fibrilação atrial (ritmo = FA) | Card **IC + FA** presente; **ivabradina não sugerida** | |
| V8 | IC aguda quente‑úmido, virgem de diurético | **Plano de diurético IV** (dose padrão) sugerido | |
| V9 | IC aguda com hipoperfusão | **Avaliação urgente**; sem cálculo de dose | |
| V10 | Uso prévio de diurético marcado, sem dose | **Dados insuficientes**; não calcula dose | |
| V11 | ICFEp: FEVE 55%, 72 anos, FA, obesidade, HAS, ≥2 anti‑HAS, PSAP>35, E/e'>9 | **H2FPEF = alta probabilidade**; classificação ICFEp | |
| V12 | Choque: PAS 80 + hipoperfusão + lactato 4,0 | **Avaliação urgente** + alerta **crítico** | |

## Cobertura

As vinhetas cobrem os itens do `VALIDATION_PLAN.md`: paciente estável; hipercalemia;
disfunção renal; hipotensão; bradicardia; angioedema; fibrilação atrial; congestão
quente‑úmida; hipoperfusão aguda; uso prévio de diurético sem dose; ICFEp com H2FPEF
alto; e instabilidade/choque. Vinhetas adicionais (ex.: H2FPEF incompleto, IC + DRC,
natriurese) podem ser acrescentadas conforme a revisão avançar.
