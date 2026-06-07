# Changelog — IC Flow

Formato: [Keep a Changelog](https://keepachangelog.com/). Versão do app segue SemVer.

## v1.0 — 2026-06-06

Primeira versão consolidada. App **educacional** de apoio à decisão clínica em
insuficiência cardíaca (iOS · Swift/SwiftUI), **offline**, **PT/EN**, **sem dados
identificáveis de paciente**.

### Fluxos clínicos
- **ICFEr crônica** — elegibilidade dos 4 pilares (INRA/IECA/BRA, betabloqueador, ARM,
  iSGLT2) com status em 6 estados, justificativa, doses-exemplo, monitoramento e alertas;
  terapias adicionais (ivabradina, hidralazina+nitrato, vericiguate, digoxina, ferro IV);
  **plano de otimização (GDMT)** com alerta de interação SRAA+ARM; overlays **IC+FA** e **IC+DRC**.
- **IC aguda congesta** — perfis de Stevenson, estimativa de diurético IV (≈2,5×),
  equivalências de alça, bloqueio sequencial do néfron, *red flags* de encaminhamento.
- **ICFEp/ICFEm** — classificação por FEVE + escore **H2FPEF**, iSGLT2, comorbidades.
- **Choque / IC refratária** — triagem de instabilidade com encaminhamento.

### Ferramentas
- **Checklist de alta** pós-descompensação.
- **Calculadoras** — CHA₂DS₂-VASc, TFGe (CKD-EPI 2021), ferro (Ganzoni), sódio corrigido,
  natriurese guiada.
- **Histórico local anônimo** (no aparelho, criptografado, sem identificadores).
- **Exportar/compartilhar** a avaliação em **PDF anônimo**.
- **Referências** com busca offline; **acessibilidade** (Dynamic Type, VoiceOver).

### Segurança e governança
- **Completude de dados** com *gating* (não afirma elegibilidade sem dados essenciais).
- Disclaimer profissional; linguagem **não imperativa**.
- Conteúdo versionado e rastreável por referência; **`VIGNETTES.md`**, `VALIDATION_PLAN.md`,
  `CLINICAL_CONTENT_STATUS.md`.

> ⚠️ Conteúdo clínico **em validação** (`isClinicalContentValidated = false`):
> doses/limiares são exemplos educacionais, pendentes de revisão por cardiologista.

### Infra
- CI: testes do núcleo no **Linux** a cada push; build do app no **macOS sob demanda**.
