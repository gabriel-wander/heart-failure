# Relatório — Aplicativo IC Flow
### Apoio à decisão clínica em insuficiência cardíaca (iOS)

**[Cidade]**, 5 de junho de 2026.

**De:** Dr. Gabriel Wander
**Para:** Presidente **[Nome do Presidente]** — **[Instituição]**
**Assunto:** Apresentação do aplicativo **IC Flow** (apoio à decisão clínica em insuficiência cardíaca)

> _Campos entre colchetes (**[...]**) devem ser preenchidos antes do envio._

---

## 1. Sumário executivo
O **IC Flow** é um aplicativo para iPhone que **auxilia o médico na condução da insuficiência cardíaca (IC)**, organizando, de forma rápida e padronizada, as duas decisões mais frequentes à beira do leito: (1) a **terapia dos quatro pilares** na IC crônica com fração de ejeção reduzida e (2) o **manejo inicial da congestão na IC aguda**, incluindo uma estimativa estruturada de diurético endovenoso. Nesta etapa o aplicativo tornou‑se **bilíngue (português/inglês)** e passou a ter **verificação automática de qualidade**, que confirma que o programa **compila e que todas as regras clínicas passam nos testes**. O projeto está **funcional e pronto para demonstração** em iPhone.

## 2. O que o aplicativo faz

### Fluxo 1 — IC crônica com fração de ejeção reduzida (FEVE ≤ 40%)
A partir de parâmetros do paciente (FEVE, classe NYHA, pressão arterial, frequência cardíaca, ritmo, função renal/TFGe, potássio, creatinina), o app avalia a **elegibilidade dos quatro pilares** do tratamento:

- **INRA / IECA / BRA** (ex.: sacubitril‑valsartana, enalapril, valsartana)
- **Betabloqueador** (ex.: carvedilol, succinato de metoprolol, bisoprolol)
- **Antagonista do receptor mineralocorticoide – MRA** (ex.: espironolactona, eplerenona)
- **Inibidor de SGLT2** (ex.: dapagliflozina, empagliflozina)

Para **cada classe**, o app indica um status — **Elegível / Cautela / Contraindicado** — com **justificativa objetiva**, **dose inicial e dose‑alvo** (exemplos), **parâmetros de monitoramento** e **alertas de segurança**. Exemplos de critérios embutidos: contraindicar bloqueio do SRAA/MRA com **potássio > 5,5 mmol/L**, betabloqueador com **FC < 50 bpm**, MRA com **TFGe < 30**, iSGLT2 com **TFGe < 20**, e cautela em hipotensão/congestão. Quando vários critérios incidem, prevalece **o mais restritivo**; **campos não preenchidos não geram contraindicações falsas**.

### Fluxo 2 — IC aguda congesta (sem choque cardiogênico)
O app classifica o **perfil hemodinâmico** (congestão × perfusão — perfis de Stevenson: quente/frio × úmido/seco) e, no perfil **congesto e bem perfundido**, sugere uma **estrutura de diurético de alça endovenoso**:

- Paciente **já em uso** de diurético oral → dose EV inicial ≈ **2,5× a dose oral diária** (Felker et al., JACC 2020), fracionada em **≥ 2 administrações**;
- Paciente **virgem** de diurético → **furosemida 40 mg EV** (faixa 40–80 mg);
- Conversão entre agentes (furosemida 1× · bumetanida 40× · torsemida 2×) e **sinalização de dose elevada**;
- **Monitoramento**: diurese, peso, balanço hídrico, PA/FC, creatinina/TFGe, sódio, potássio, magnésio.
- **Sinais de alerta para avaliação especializada**: PAS < 90 mmHg, hipoperfusão, potássio > 6,0 mmol/L ou TFGe < 30.

### Experiência de uso (telas)
Aviso/_Disclaimer_ → escolha do cenário → entrada de dados clínicos → **resultado** organizado em abas: **Recomendações**, **Alertas de segurança**, **Resumo** e **Referências**. Há um **seletor de idioma (🌐)** que troca PT/EN ao vivo.

## 3. Diferenciais e governança clínica
- **Conteúdo clínico editável e auditável:** medicamentos, doses, limiares, alertas e referências ficam em arquivos estruturados, **separados da lógica e da interface**. Isso permite que um médico/comitê **revise e atualize** o conteúdo **sem reprogramar** o app.
- **Confiabilidade verificada:** a lógica clínica é coberta por **testes automatizados** (hipercalemia, disfunção renal, hipotensão, bradicardia, cálculo de diurético, paridade PT/EN). Toda alteração é checada por uma esteira que **compila o app e roda os testes** — hoje **100% verde**.
- **Privacidade por desenho:** funciona **totalmente offline**, **sem login**, **sem servidores** e **sem armazenar dados identificáveis de paciente** (apenas parâmetros fisiológicos, em memória).
- **Bilíngue (PT/EN).**

## 4. O que foi entregue nesta etapa
1. **Internacionalização completa** (conteúdo clínico + interface) com troca de idioma ao vivo.
2. **Esteira de verificação automática (CI)** em Mac real: compila o app para iPhone e executa toda a bateria de testes clínicos — **resultado atual: aprovado**.
3. **Correção técnica** que garantiu a **compilação limpa** do projeto.
4. **Projeto pronto para instalação em iPhone** para demonstração.

## 5. Natureza e limitações (importante)
- Trata‑se de um **protótipo educacional (MVP) destinado a médicos**; é **ferramenta de apoio**, que **não substitui o julgamento clínico**, as **bulas** nem as **diretrizes** vigentes.
- As **doses são exemplos ilustrativos**; devem ser confirmadas caso a caso.
- **Não é, neste momento, um dispositivo médico certificado/registrado** (p.ex., ANVISA). Uso assistencial em escala exigiria **validação clínica formal** e, conforme a finalidade, **avaliação regulatória**.

## 6. Fundamentação científica
- Felker GM, et al. *Diuretic Therapy for Patients With Heart Failure.* JACC. 2020;75(10):1178–1195.
- Greene SJ, et al. *Management of Worsening HFrEF.* JACC. 2023;82(6):559–571.
- Patolia H, et al. *Implementing Guideline‑Directed Medical Therapy for Heart Failure.* JACC. 2023;82(6):529–543.

## 7. Status e próximos passos sugeridos
**Status:** funcional, compilação verificada e testes aprovados; pronto para demonstração em iPhone.

**Próximos passos (opcionais):** validação por comitê clínico; ampliação de cenários (ICFEp, titulação/ajuste de dose); distribuição controlada via TestFlight; e, se houver intenção de uso assistencial, definição do caminho regulatório.

---

Atenciosamente,

**Dr. Gabriel Wander**
[Cargo / Instituição]
[Contato]
