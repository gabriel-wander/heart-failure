# Status do conteúdo clínico — IC Flow

**Versão do conteúdo:** `0.2.0-dev` · **Última atualização:** 2026-06-05
**Estado de validação:** `isClinicalContentValidated = false` (em validação)

> Este documento descreve o que existe, o que já foi conferido internamente e o que
> ainda depende de revisão médica formal. Enquanto a flag acima for `false`, o app
> exibe o aviso "Conteúdo clínico em validação".

---

## 1. Escopo atual

| Módulo | Estado | Observações |
|---|---|---|
| ICFEr crônica (4 pilares) | Implementado | INRA/IECA/BRA, betabloqueador, ARM, iSGLT2 com status, doses-exemplo, monitoramento, alertas. |
| ICFEr — terapias adicionais | Implementado | Hidralazina+nitrato, ivabradina, vericiguate, digoxina, ferro IV (encaminhamento). |
| IC aguda congesta | Implementado | Perfis de Stevenson, estimativa de diurético IV (2,5×), equivalências, bloqueio sequencial do néfron, red flags. |
| ICFEp / ICFEm | Implementado (educacional) | Classificação por FEVE, escore H2FPEF, iSGLT2, congestão, comorbidades, encaminhamento. |
| Checklist de alta | Implementado | 10 itens de prontidão pós-descompensação. |
| Completude de dados / gating | Implementado | Bloqueia recomendação específica sem dados essenciais. |
| Cenário Choque / IC refratária | Implementado (educacional) | Triagem por red flags; encaminhamento, sem dose. |
| Otimização GDMT + interação SRAA/ARM | Implementado | Síntese de pilares + alerta de hipercalemia. |
| Overlays IC + FA / IC + DRC | Implementado (educacional) | Acionados por ritmo = FA e TFGe < 60. |
| Calculadoras (CHA₂DS₂-VASc, CKD-EPI, Ganzoni, Na corrigido, natriurese) | Implementado | Fórmulas com testes; **limiares/uso pendentes de revisão**. |

## 2. Conteúdo validado vs. não validado

**Conferido internamente (estrutura e coerência), NÃO validado clinicamente:**
- Carregamento e integridade referencial (testes automatizados: `ContentRepositoryTests`).
- Paridade estrutural PT/EN (`LocalizationContentTests`).
- Regras críticas de segurança (hipercalemia, TFGe, hipotensão, bradicardia, angioedema,
  resposta inadequada, gating de dados ausentes) cobertas por testes unitários.

**Pendente de validação clínica formal (revisão médica):**
- Limiares numéricos das regras (ex.: K⁺ > 5,5; TFGe < 30/20; FC < 50; PAS < 90/95/100).
- Doses iniciais e alvo de todos os fármacos (atualmente **exemplos**).
- Fator de equivalência e multiplicador do diurético (2,5×) e dose de cautela (> 1000 mg/dia).
- Pesos e pontos de corte do escore H2FPEF.
- Textos de justificativa, notas e alertas.

## 3. Pendências de revisão médica

- [ ] Revisão dos limiares e status por classe (ICFEr) por cardiologista.
- [ ] Revisão das doses (iniciais/alvo) frente a bulas e diretrizes vigentes.
- [ ] Revisão da estratégia de diurético IV e do bloqueio sequencial do néfron.
- [ ] Revisão do escore H2FPEF e da classificação por FEVE.
- [ ] Revisão dos itens do checklist de alta.
- [ ] Conferência das referências (atualidade e correspondência com cada recomendação).

## 4. Como sinalizar conteúdo validado

Quando o conteúdo for revisado e aprovado conforme o `VALIDATION_PLAN.md`:
1. Atualizar `contentVersion`/`lastReviewed` nos JSON e neste documento.
2. Definir `ClinicalContent.isClinicalContentValidated = true`
   (`ICFlowCore/Sources/ICFlowCore/Models/ClinicalContentStatus.swift`).
3. Registrar a revisão (responsável, data, diretrizes de referência) no `VALIDATION_PLAN.md`.
