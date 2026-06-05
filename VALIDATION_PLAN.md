# Plano de validação do conteúdo clínico — IC Flow

Objetivo: levar o conteúdo clínico do estado **"em validação"** (v0.2) para um estado
**revisado e aprovado**, de forma rastreável e reprodutível, mantendo a separação entre
conteúdo (JSON), motor de decisão e interface.

> Natureza: ferramenta **educacional** para médicos. Este plano cobre a qualidade do
> conteúdo; não constitui, por si só, certificação como dispositivo médico.

---

## 1. Revisão por cardiologista

- Designar ao menos **um cardiologista revisor** (idealmente dois, para consenso).
- Para cada arquivo de conteúdo (`medications`, `clinical_rules`, `safety_alerts`,
  `references`, `engine_messages`, `discharge_checklist`):
  - conferir **limiares**, **doses**, **status** e **textos** frente às diretrizes vigentes;
  - registrar comentários por `id` de regra/medicamento;
  - aprovar, ajustar ou rejeitar cada item.
- Itens de **maior risco** (contraindicações, hipercalemia, TFGe, hipotensão, bradicardia,
  diurético IV, angioedema) recebem revisão prioritária.

## 2. Testes com casos clínicos fictícios

- Elaborar um conjunto de **vinhetas clínicas fictícias** (sem dados reais de pacientes)
  cobrindo: paciente estável; hipercalemia leve/grave; TFGe reduzida; hipotensão;
  bradicardia; FA; angioedema; congestão quente-úmida; frio-úmido; hipotensão aguda;
  uso prévio de diurético com/sem dose; ICFEp com H2FPEF alto/baixo/incompleto.
- Resultado esperado **definido pelo revisor**; comparar com a saída do app.
- Divergências viram itens de correção (no JSON, sempre que possível, sem alterar código).
- Cada vinheta deve ter um **teste unitário** correspondente em `ICFlowCoreTests`.

## 3. Comparação com diretrizes

- Mapear cada regra/dose à(s) **fonte(s)** correspondente(s) (diretriz/estudo), com ano.
- Garantir que todo `referenceId` citado resolve em `references.json` (já coberto por teste).
- Registrar a **versão das diretrizes** usadas como base da revisão.

## 4. Registro de mudanças (changelog do conteúdo)

- Toda alteração de conteúdo deve:
  - incrementar `contentVersion` e atualizar `lastReviewed` nos JSON;
  - ser descrita em um changelog (PR/commit) com o `id` afetado e a justificativa/fonte;
  - manter a **paridade PT/EN** (ids, contagem de regras e limiares idênticos entre idiomas).

## 5. Critérios para considerar o conteúdo "validado"

O conteúdo é marcado como validado (`isClinicalContentValidated = true`) quando:

1. Todos os itens de conteúdo foram **revisados e aprovados** pelo(s) cardiologista(s).
2. O conjunto de **vinhetas clínicas** passa (saída do app = esperado do revisor).
3. Cada recomendação tem **referência** rastreável e atual.
4. A suíte de **testes automatizados** está verde (núcleo + build do app).
5. `contentVersion`/`lastReviewed` atualizados e a revisão registrada (responsável + data).

## 6. Pós-validação (manutenção)

- Reavaliar o conteúdo a cada atualização relevante de diretrizes ou bulas.
- Reverter `isClinicalContentValidated` para `false` enquanto uma revisão maior estiver em curso.
