import Foundation
import ICFlowCore

/// Keys for every user-interface string (app chrome). Clinical text comes from
/// the localized JSON via `ContentRepository`; this table covers buttons,
/// titles, field labels and other interface chrome.
enum UIString: String {
    // App / disclaimer
    case appSubtitle
    case disclaimerWarningTitle
    case disclaimerBullet1, disclaimerBullet2, disclaimerBullet3, disclaimerBullet4, disclaimerBullet5
    case disclaimerAgree
    case disclaimerFootnote

    // Scenario
    case scenarioSelectTitle
    case navScenario

    // Common
    case disclaimerBanner
    case emptyResultTitle, emptyResultDesc
    case alertsNoneTitle, alertsNoneDesc
    case referencesFootnote
    case languageMenuTitle

    // Input
    case navClinicalData
    case inputScenarioFooter
    case sectionVentricular, sectionLab, sectionClinical
    case fieldLVEF, fieldNYHA, fieldSBP, fieldHR, fieldRhythm
    case fieldEGFR, fieldPotassium, fieldCreatinine
    case toggleCongestion, toggleHypoperfusion, togglePriorDiuretic
    case fieldLoopAgent, fieldOralDose
    case generateButton
    case inputAcuteFooter
    case nyhaNone
    case unitPercent, unitMmHg, unitBpm, unitEgfr, unitMmolL, unitMgdl, unitMg

    // Results
    case navResult
    case tabRecommendations, tabAlerts, tabSummary, tabReferences
    case newAssessment

    // Recommendations
    case profileTitle
    case diureticEstimateTitle
    case metricPerDose, metricFrequency, metricTotalDay
    case generalNotesTitle
    case secJustification, secDoses, doseInitial, doseTarget
    case secMonitoring, secSafetyAlerts, secNotes
    case perDaySuffix

    // Alerts
    case refPrefix

    // Summary
    case sumScenario, sumInputData, sumNoNumericData, sumRecsTitle
    case sumDiureticTitle, sumAlertsTitle, sumCriticalPrefix
    case copyButton, copiedButton
    case yes, no
    case sumCongestion, sumHypoperfusion, sumPriorDiuretic
    case sumProfile
    case txtHeader, txtData, txtRecommendations, txtDiuretic, txtAlerts, txtDisclaimer

    // References
    case refsThisCase, refsAll, refsOthers

    // v0.2 — content validation & missing data
    case contentValidationBanner
    case missingDataTitle

    // v0.2 — H2FPEF (HFpEF/HFmrEF module)
    case h2fpefTitle
    case h2fpefPointsLabel
    case h2fpefIncompleteHint

    // v0.2 — discharge checklist
    case checklistNavTitle
    case checklistSubtitle
    case checklistFootnote

    // v0.2 — input markers & HFpEF section
    case essentialLegend
    case essentialMissingWarning
    case sectionHFpEF
    case fieldAge, unitYears
    case toggleAngioedema
    case toggleSymptomsHF, toggleObesity, toggleHypertension, toggleAntihtn2
    case toggleAtrialFib, toggleDiabetes, toggleCKD, toggleCoronary, toggleSleepApnea
    case toggleInfiltrative, toggleValvular, togglePulmonary, toggleAnemia, toggleNonCardiacEdema
    case fieldPASP, fieldEoverE, triNotAssessed
    case resultBlocksTitle

    // v0.3 — export
    case exportButton

    // v0.3 — calculators
    case calcNavTitle, calcSubtitle
    case calcCHA2Title, calcHF, calcStroke, calcVascular, calcFemale, calcScoreLabel
    case calcEGFRTitle
    case calcIronTitle, calcWeight, calcHbCurrent, calcHbTarget, unitKg, unitGdl, calcDeficitLabel
    case calcSodiumTitle, calcNaMeasured, calcGlucose, calcCorrectedLabel

    // v0.3 — cardiogenic shock inputs
    case sectionShock, fieldLactate, toggleOliguria, toggleAlteredMentation

    // v0.4 — natriuresis calculator
    case calcNatriuresisTitle, calcUrineNa, calcUrineOutput, unitMlH, calcResponseLabel

    // v0.4 — anonymous local history
    case cancel
    case historyNavTitle, historySubtitle
    case historyEmptyTitle, historyEmptyDesc, historyFootnote
    case historyDeleteAll, historySaveButton, historySaved
    case historySaveMessage, historyLabelPlaceholder
}

/// Static lookup of interface strings and enum labels per language.
enum Localizer {
    static func string(_ key: UIString, _ language: AppLanguage) -> String {
        (table[language]?[key]) ?? (table[.pt]?[key]) ?? key.rawValue
    }

    // MARK: - Enum labels

    static func scenarioName(_ s: Scenario, _ l: AppLanguage) -> String {
        switch (s, l) {
        case (.chronicHFrEF, .pt): return "ICFEr crônica"
        case (.chronicHFrEF, .en): return "Chronic HFrEF"
        case (.acuteCongestion, .pt): return "IC aguda congesta"
        case (.acuteCongestion, .en): return "Acute congestive HF"
        case (.hfpefHFmrEF, .pt): return "ICFEp / ICFEm"
        case (.hfpefHFmrEF, .en): return "HFpEF / HFmrEF"
        case (.cardiogenicShock, .pt): return "Choque / IC refratária"
        case (.cardiogenicShock, .en): return "Shock / refractory HF"
        }
    }

    static func scenarioDetail(_ s: Scenario, _ l: AppLanguage) -> String {
        switch (s, l) {
        case (.chronicHFrEF, .pt): return "Insuficiência cardíaca crônica com fração de ejeção reduzida (FEVE ≤ 40%)."
        case (.chronicHFrEF, .en): return "Chronic heart failure with reduced ejection fraction (LVEF ≤ 40%)."
        case (.acuteCongestion, .pt): return "IC aguda/descompensada com congestão, sem choque cardiogênico."
        case (.acuteCongestion, .en): return "Acute/decompensated HF with congestion, without cardiogenic shock."
        case (.hfpefHFmrEF, .pt): return "Fração de ejeção preservada ou levemente reduzida, com foco em diagnóstico, comorbidades e congestão."
        case (.hfpefHFmrEF, .en): return "Preserved or mildly reduced ejection fraction, focusing on diagnosis, comorbidities and congestion."
        case (.cardiogenicShock, .pt): return "Triagem de instabilidade hemodinâmica / baixo débito — fora do fluxo de congestão simples."
        case (.cardiogenicShock, .en): return "Triage of hemodynamic instability / low output — outside the simple congestion flow."
        }
    }

    static func h2fpefCategoryName(_ c: H2FPEFResult.Category, _ l: AppLanguage) -> String {
        switch (c, l) {
        case (.low, .pt): return "Baixa probabilidade"
        case (.low, .en): return "Low probability"
        case (.intermediate, .pt): return "Probabilidade intermediária"
        case (.intermediate, .en): return "Intermediate probability"
        case (.high, .pt): return "Alta probabilidade"
        case (.high, .en): return "High probability"
        case (.incomplete, .pt): return "Escore incompleto"
        case (.incomplete, .en): return "Incomplete score"
        }
    }

    static func diureticResponseName(_ r: Calculators.DiureticResponse, _ l: AppLanguage) -> String {
        switch (r, l) {
        case (.adequate, .pt): return "Adequada"
        case (.adequate, .en): return "Adequate"
        case (.inadequate, .pt): return "Inadequada — considerar escalonar"
        case (.inadequate, .en): return "Inadequate — consider escalation"
        case (.incomplete, .pt): return "—"
        case (.incomplete, .en): return "—"
        }
    }

    static func groupName(_ g: RecommendationGroup, _ l: AppLanguage) -> String {
        switch (g, l) {
        case (.prognosis, .pt): return "Terapias modificadoras de prognóstico"
        case (.prognosis, .en): return "Prognosis-modifying therapies"
        case (.symptomCongestion, .pt): return "Controle de sintomas/congestão"
        case (.symptomCongestion, .en): return "Symptom/congestion control"
        case (.additional, .pt): return "Terapias adicionais conforme perfil"
        case (.additional, .en): return "Additional therapies by profile"
        case (.referral, .pt): return "Encaminhamento/avaliação"
        case (.referral, .en): return "Referral/evaluation"
        case (.general, .pt): return "Avaliação"
        case (.general, .en): return "Assessment"
        }
    }

    static func nyhaName(_ n: NYHAClass, _ l: AppLanguage) -> String { "NYHA \(n.rawValue)" }

    static func rhythmName(_ r: Rhythm, _ l: AppLanguage) -> String {
        switch (r, l) {
        case (.sinus, .pt): return "Ritmo sinusal"
        case (.sinus, .en): return "Sinus rhythm"
        case (.afib, .pt): return "Fibrilação atrial"
        case (.afib, .en): return "Atrial fibrillation"
        case (.other, .pt): return "Outro"
        case (.other, .en): return "Other"
        }
    }

    static func statusName(_ s: EligibilityStatus, _ l: AppLanguage) -> String {
        switch (s, l) {
        case (.eligible, .pt): return "Elegível"
        case (.eligible, .en): return "Eligible"
        case (.caution, .pt): return "Cautela"
        case (.caution, .en): return "Caution"
        case (.contraindicated, .pt): return "Contraindicado"
        case (.contraindicated, .en): return "Contraindicated"
        }
    }

    static func recStatusName(_ s: RecommendationStatus, _ l: AppLanguage) -> String {
        switch (s, l) {
        case (.recommended, .pt): return "Recomendado"
        case (.recommended, .en): return "Recommended"
        case (.consider, .pt): return "Considerar"
        case (.consider, .en): return "Consider"
        case (.caution, .pt): return "Cautela"
        case (.caution, .en): return "Caution"
        case (.contraindicated, .pt): return "Contraindicado"
        case (.contraindicated, .en): return "Contraindicated"
        case (.insufficientData, .pt): return "Dados insuficientes"
        case (.insufficientData, .en): return "Insufficient data"
        case (.urgentReferral, .pt): return "Avaliação urgente"
        case (.urgentReferral, .en): return "Urgent referral"
        }
    }

    /// Localized label for a clinical input field (used in the missing-data list).
    static func fieldName(_ f: ClinicalField, _ l: AppLanguage) -> String {
        switch f {
        case .lvef: return string(.fieldLVEF, l)
        case .nyha: return string(.fieldNYHA, l)
        case .systolicBP: return string(.fieldSBP, l)
        case .heartRate: return string(.fieldHR, l)
        case .rhythm: return string(.fieldRhythm, l)
        case .egfr: return string(.fieldEGFR, l)
        case .creatinine: return string(.fieldCreatinine, l)
        case .potassium: return string(.fieldPotassium, l)
        case .sodium: return l == .pt ? "Sódio" : "Sodium"
        case .congestion: return string(.toggleCongestion, l)
        case .hypoperfusion: return string(.toggleHypoperfusion, l)
        case .priorDiureticUse: return string(.togglePriorDiuretic, l)
        case .homeDiureticAgent: return string(.fieldLoopAgent, l)
        case .homeDiureticDose: return string(.fieldOralDose, l)
        }
    }

    static func severityName(_ s: AlertSeverity, _ l: AppLanguage) -> String {
        switch (s, l) {
        case (.info, .pt): return "Informativo"
        case (.info, .en): return "Info"
        case (.warning, .pt): return "Atenção"
        case (.warning, .en): return "Warning"
        case (.critical, .pt): return "Crítico"
        case (.critical, .en): return "Critical"
        }
    }

    static func profileName(_ p: CongestionProfile, _ l: AppLanguage) -> String {
        switch (p, l) {
        case (.wetWarm, .pt): return "Quente e úmido"
        case (.wetWarm, .en): return "Warm and wet"
        case (.wetCold, .pt): return "Frio e úmido"
        case (.wetCold, .en): return "Cold and wet"
        case (.dryWarm, .pt): return "Quente e seco"
        case (.dryWarm, .en): return "Warm and dry"
        case (.dryCold, .pt): return "Frio e seco"
        case (.dryCold, .en): return "Cold and dry"
        }
    }

    static func profileSummary(_ p: CongestionProfile, _ l: AppLanguage) -> String {
        switch (p, l) {
        case (.wetWarm, .pt): return "Congesto e bem perfundido — perfil típico para diurético IV."
        case (.wetWarm, .en): return "Congested and well perfused — typical profile for an IV diuretic."
        case (.wetCold, .pt): return "Congesto e hipoperfundido — possível baixo débito; avaliação especializada."
        case (.wetCold, .en): return "Congested and hypoperfused — possible low output; specialist evaluation."
        case (.dryWarm, .pt): return "Sem congestão e bem perfundido — diurético IV não indicado."
        case (.dryWarm, .en): return "No congestion and well perfused — IV diuretic not indicated."
        case (.dryCold, .pt): return "Hipoperfundido sem congestão — avaliar hipovolemia/baixo débito; avaliação especializada."
        case (.dryCold, .en): return "Hypoperfused without congestion — assess hypovolemia/low output; specialist evaluation."
        }
    }

    static func strategyName(_ s: DiureticPlan.Strategy, _ l: AppLanguage) -> String {
        switch (s, l) {
        case (.loopNaive, .pt): return "Virgem de diurético"
        case (.loopNaive, .en): return "Loop-diuretic-naive"
        case (.priorOralUser, .pt): return "Uso prévio de diurético oral"
        case (.priorOralUser, .en): return "Prior oral diuretic use"
        }
    }

    // MARK: - Interface string table

    static let table: [AppLanguage: [UIString: String]] = [
        .pt: ptTable,
        .en: enTable
    ]

    private static let ptTable: [UIString: String] = [
        .appSubtitle: "Apoio à decisão em insuficiência cardíaca",
        .disclaimerWarningTitle: "Aviso importante",
        .disclaimerBullet1: "Ferramenta educacional destinada a médicos. Não substitui o julgamento clínico individual.",
        .disclaimerBullet2: "Conteúdo clínico em validação. As recomendações devem ser interpretadas por médico habilitado, à luz do contexto clínico, diretrizes vigentes, protocolos institucionais e bulas oficiais.",
        .disclaimerBullet3: "Não armazena dados identificáveis de pacientes. Insira apenas parâmetros clínicos de forma anônima.",
        .disclaimerBullet4: "Funciona totalmente offline. Não há login, banco de dados remoto nem integração externa.",
        .disclaimerBullet5: "Escopo do MVP: ICFEr crônica e IC aguda congesta sem choque cardiogênico.",
        .disclaimerAgree: "Li e concordo — continuar",
        .disclaimerFootnote: "Ao continuar, você reconhece a natureza educacional desta ferramenta.",
        .scenarioSelectTitle: "Selecione o cenário clínico",
        .navScenario: "Cenário",
        .disclaimerBanner: "Ferramenta educacional, com conteúdo clínico em validação. Não substitui o julgamento clínico nem as bulas/diretrizes vigentes.",
        .emptyResultTitle: "Sem avaliação",
        .emptyResultDesc: "Volte e gere uma avaliação a partir dos dados clínicos.",
        .alertsNoneTitle: "Sem alertas",
        .alertsNoneDesc: "Nenhum alerta de segurança específico foi disparado com os dados fornecidos. Mantenha a vigilância clínica habitual.",
        .referencesFootnote: "Conteúdo clínico baseado nas fontes acima. As referências são fornecidas para fins educacionais; consulte sempre as versões completas e as diretrizes vigentes.",
        .languageMenuTitle: "Idioma",
        .navClinicalData: "Dados clínicos",
        .inputScenarioFooter: "Insira apenas dados clínicos anônimos. Campos em branco não são avaliados pelas regras.",
        .sectionVentricular: "Função ventricular e hemodinâmica",
        .sectionLab: "Laboratório",
        .sectionClinical: "Estado clínico",
        .fieldLVEF: "FEVE",
        .fieldNYHA: "NYHA",
        .fieldSBP: "PA sistólica",
        .fieldHR: "Frequência cardíaca",
        .fieldRhythm: "Ritmo",
        .fieldEGFR: "TFGe",
        .fieldPotassium: "Potássio",
        .fieldCreatinine: "Creatinina",
        .toggleCongestion: "Sinais de congestão",
        .toggleHypoperfusion: "Sinais de hipoperfusão",
        .togglePriorDiuretic: "Uso prévio de diurético",
        .fieldLoopAgent: "Diurético em uso",
        .fieldOralDose: "Dose oral total/dia",
        .generateButton: "Gerar recomendações",
        .inputAcuteFooter: "No fluxo agudo, a dose IV de diurético é estimada a partir do uso prévio (≈ 2,5× a dose oral domiciliar) ou de uma dose inicial padrão se virgem de diurético.",
        .nyhaNone: "—",
        .unitPercent: "%",
        .unitMmHg: "mmHg",
        .unitBpm: "bpm",
        .unitEgfr: "mL/min/1,73m²",
        .unitMmolL: "mmol/L",
        .unitMgdl: "mg/dL",
        .unitMg: "mg",
        .navResult: "Resultado",
        .tabRecommendations: "Recomendações",
        .tabAlerts: "Alertas",
        .tabSummary: "Resumo",
        .tabReferences: "Referências",
        .newAssessment: "Nova avaliação",
        .profileTitle: "Perfil hemodinâmico",
        .diureticEstimateTitle: "Estimativa de diurético IV",
        .metricPerDose: "por dose",
        .metricFrequency: "frequência",
        .metricTotalDay: "total/dia",
        .generalNotesTitle: "Notas gerais",
        .secJustification: "Justificativa",
        .secDoses: "Doses (exemplo)",
        .doseInitial: "Inicial",
        .doseTarget: "Alvo",
        .secMonitoring: "Monitoramento",
        .secSafetyAlerts: "Alertas de segurança",
        .secNotes: "Observações",
        .perDaySuffix: "×/dia",
        .refPrefix: "Ref.: ",
        .sumScenario: "Cenário",
        .sumInputData: "Dados inseridos",
        .sumNoNumericData: "Nenhum dado numérico informado.",
        .sumRecsTitle: "Síntese das recomendações",
        .sumDiureticTitle: "Diurético IV (estimativa)",
        .sumAlertsTitle: "Alertas",
        .sumCriticalPrefix: "Crítico: ",
        .copyButton: "Copiar resumo (texto)",
        .copiedButton: "Resumo copiado",
        .yes: "Sim",
        .no: "Não",
        .sumCongestion: "Congestão",
        .sumHypoperfusion: "Hipoperfusão",
        .sumPriorDiuretic: "Uso prévio de diurético",
        .sumProfile: "Perfil",
        .txtHeader: "IC Flow — resumo (educacional, dados anônimos)",
        .txtData: "Dados",
        .txtRecommendations: "Recomendações:",
        .txtDiuretic: "Diurético IV",
        .txtAlerts: "Alertas",
        .txtDisclaimer: "Ferramenta educacional — não substitui o julgamento clínico.",
        .refsThisCase: "Referências deste caso",
        .refsAll: "Referências",
        .refsOthers: "Outras referências",
        .contentValidationBanner: "Conteúdo clínico em validação — uso educacional, sujeito a revisão médica.",
        .missingDataTitle: "Dados ausentes que limitam a recomendação",
        .h2fpefTitle: "Escore H2FPEF",
        .h2fpefPointsLabel: "pontos",
        .h2fpefIncompleteHint: "Escore incompleto: informe idade, PSAP estimada (> 35 mmHg) e E/e' (> 9) para estimar a probabilidade.",
        .checklistNavTitle: "Checklist de alta",
        .checklistSubtitle: "Verificação de prontidão para alta pós-descompensação.",
        .checklistFootnote: "Lista educacional de apoio; não substitui o julgamento clínico. Nada é armazenado.",
        .essentialLegend: "• Campo essencial para a recomendação",
        .essentialMissingWarning: "Campos essenciais em branco podem limitar a recomendação:",
        .sectionHFpEF: "ICFEp / comorbidades",
        .fieldAge: "Idade",
        .unitYears: "anos",
        .toggleAngioedema: "História de angioedema",
        .toggleSymptomsHF: "Sintomas/sinais de IC",
        .toggleObesity: "Obesidade (IMC > 30)",
        .toggleHypertension: "Hipertensão arterial",
        .toggleAntihtn2: "≥ 2 anti-hipertensivos",
        .toggleAtrialFib: "Fibrilação atrial",
        .toggleDiabetes: "Diabetes",
        .toggleCKD: "Doença renal crônica",
        .toggleCoronary: "Doença coronariana",
        .toggleSleepApnea: "Apneia do sono",
        .toggleInfiltrative: "Suspeita de amiloidose/infiltrativa",
        .toggleValvular: "Doença valvar relevante",
        .togglePulmonary: "Doença pulmonar relevante",
        .toggleAnemia: "Anemia",
        .toggleNonCardiacEdema: "Edema possivelmente não cardíaco",
        .fieldPASP: "PSAP estimada > 35 mmHg",
        .fieldEoverE: "E/e' > 9",
        .triNotAssessed: "Não avaliado",
        .resultBlocksTitle: "Recomendações",
        .exportButton: "Exportar / compartilhar (PDF)",
        .calcNavTitle: "Calculadoras",
        .calcSubtitle: "Escores e cálculos de apoio (anônimos).",
        .calcCHA2Title: "CHA₂DS₂-VASc (risco de AVC na FA)",
        .calcHF: "Insuficiência cardíaca / disfunção de VE",
        .calcStroke: "AVC / AIT / tromboembolismo prévio",
        .calcVascular: "Doença vascular",
        .calcFemale: "Sexo feminino",
        .calcScoreLabel: "Escore",
        .calcEGFRTitle: "TFGe (CKD-EPI 2021)",
        .calcIronTitle: "Déficit de ferro (Ganzoni)",
        .calcWeight: "Peso",
        .calcHbCurrent: "Hb atual",
        .calcHbTarget: "Hb alvo",
        .unitKg: "kg",
        .unitGdl: "g/dL",
        .calcDeficitLabel: "Déficit de ferro",
        .calcSodiumTitle: "Sódio corrigido (hiperglicemia)",
        .calcNaMeasured: "Sódio medido",
        .calcGlucose: "Glicemia",
        .calcCorrectedLabel: "Sódio corrigido",
        .calcNatriuresisTitle: "Natriurese / resposta ao diurético",
        .calcUrineNa: "Sódio urinário (spot)",
        .calcUrineOutput: "Débito urinário",
        .unitMlH: "mL/h",
        .calcResponseLabel: "Resposta",
        .sectionShock: "Instabilidade / choque",
        .fieldLactate: "Lactato",
        .toggleOliguria: "Oligúria importante",
        .toggleAlteredMentation: "Alteração de consciência",
        .cancel: "Cancelar",
        .historyNavTitle: "Histórico",
        .historySubtitle: "Casos salvos neste aparelho (anônimos).",
        .historyEmptyTitle: "Sem casos salvos",
        .historyEmptyDesc: "Gere uma avaliação e toque em \"Salvar no histórico\" no Resumo.",
        .historyFootnote: "Casos salvos apenas neste aparelho, de forma anônima. Não insira identificadores (nome, CPF, prontuário). Você pode apagar a qualquer momento.",
        .historyDeleteAll: "Apagar tudo",
        .historySaveButton: "Salvar no histórico",
        .historySaved: "Salvo no histórico",
        .historySaveMessage: "Salvo apenas neste aparelho, sem identificadores de paciente. Use um rótulo não identificável (ex.: \"Leito 3B\").",
        .historyLabelPlaceholder: "Rótulo (opcional, sem identificadores)"
    ]

    private static let enTable: [UIString: String] = [
        .appSubtitle: "Heart failure decision support",
        .disclaimerWarningTitle: "Important notice",
        .disclaimerBullet1: "Educational tool intended for physicians. It does not replace individual clinical judgment.",
        .disclaimerBullet2: "Clinical content under validation. Recommendations must be interpreted by a qualified physician, in light of the clinical context, current guidelines, institutional protocols and official drug labels.",
        .disclaimerBullet3: "Stores no identifiable patient data. Enter only anonymous clinical parameters.",
        .disclaimerBullet4: "Works fully offline. No login, remote database or external integration.",
        .disclaimerBullet5: "MVP scope: chronic HFrEF and acute congestive HF without cardiogenic shock.",
        .disclaimerAgree: "I have read and agree — continue",
        .disclaimerFootnote: "By continuing, you acknowledge the educational nature of this tool.",
        .scenarioSelectTitle: "Select the clinical scenario",
        .navScenario: "Scenario",
        .disclaimerBanner: "Educational tool, with clinical content under validation. It does not replace clinical judgment or current labels/guidelines.",
        .emptyResultTitle: "No assessment",
        .emptyResultDesc: "Go back and generate an assessment from the clinical data.",
        .alertsNoneTitle: "No alerts",
        .alertsNoneDesc: "No specific safety alert was triggered with the data provided. Maintain usual clinical vigilance.",
        .referencesFootnote: "Clinical content based on the sources above. References are provided for educational purposes; always consult the full versions and current guidelines.",
        .languageMenuTitle: "Language",
        .navClinicalData: "Clinical data",
        .inputScenarioFooter: "Enter only anonymous clinical data. Blank fields are not evaluated by the rules.",
        .sectionVentricular: "Ventricular function and hemodynamics",
        .sectionLab: "Laboratory",
        .sectionClinical: "Clinical status",
        .fieldLVEF: "LVEF",
        .fieldNYHA: "NYHA",
        .fieldSBP: "Systolic BP",
        .fieldHR: "Heart rate",
        .fieldRhythm: "Rhythm",
        .fieldEGFR: "eGFR",
        .fieldPotassium: "Potassium",
        .fieldCreatinine: "Creatinine",
        .toggleCongestion: "Signs of congestion",
        .toggleHypoperfusion: "Signs of hypoperfusion",
        .togglePriorDiuretic: "Prior diuretic use",
        .fieldLoopAgent: "Current diuretic",
        .fieldOralDose: "Total oral dose/day",
        .generateButton: "Generate recommendations",
        .inputAcuteFooter: "In the acute flow, the IV diuretic dose is estimated from prior use (≈ 2.5× the home oral dose) or a standard initial dose if loop-diuretic-naive.",
        .nyhaNone: "—",
        .unitPercent: "%",
        .unitMmHg: "mmHg",
        .unitBpm: "bpm",
        .unitEgfr: "mL/min/1.73m²",
        .unitMmolL: "mmol/L",
        .unitMgdl: "mg/dL",
        .unitMg: "mg",
        .navResult: "Result",
        .tabRecommendations: "Recommendations",
        .tabAlerts: "Alerts",
        .tabSummary: "Summary",
        .tabReferences: "References",
        .newAssessment: "New assessment",
        .profileTitle: "Hemodynamic profile",
        .diureticEstimateTitle: "IV diuretic estimate",
        .metricPerDose: "per dose",
        .metricFrequency: "frequency",
        .metricTotalDay: "total/day",
        .generalNotesTitle: "General notes",
        .secJustification: "Rationale",
        .secDoses: "Doses (example)",
        .doseInitial: "Initial",
        .doseTarget: "Target",
        .secMonitoring: "Monitoring",
        .secSafetyAlerts: "Safety alerts",
        .secNotes: "Notes",
        .perDaySuffix: "×/day",
        .refPrefix: "Ref.: ",
        .sumScenario: "Scenario",
        .sumInputData: "Entered data",
        .sumNoNumericData: "No numeric data entered.",
        .sumRecsTitle: "Recommendation summary",
        .sumDiureticTitle: "IV diuretic (estimate)",
        .sumAlertsTitle: "Alerts",
        .sumCriticalPrefix: "Critical: ",
        .copyButton: "Copy summary (text)",
        .copiedButton: "Summary copied",
        .yes: "Yes",
        .no: "No",
        .sumCongestion: "Congestion",
        .sumHypoperfusion: "Hypoperfusion",
        .sumPriorDiuretic: "Prior diuretic use",
        .sumProfile: "Profile",
        .txtHeader: "IC Flow — summary (educational, anonymous data)",
        .txtData: "Data",
        .txtRecommendations: "Recommendations:",
        .txtDiuretic: "IV diuretic",
        .txtAlerts: "Alerts",
        .txtDisclaimer: "Educational tool — does not replace clinical judgment.",
        .refsThisCase: "References for this case",
        .refsAll: "References",
        .refsOthers: "Other references",
        .contentValidationBanner: "Clinical content under validation — educational use, pending medical review.",
        .missingDataTitle: "Missing data limiting the recommendation",
        .h2fpefTitle: "H2FPEF score",
        .h2fpefPointsLabel: "points",
        .h2fpefIncompleteHint: "Incomplete score: provide age, estimated PASP (> 35 mmHg) and E/e' (> 9) to estimate the probability.",
        .checklistNavTitle: "Discharge checklist",
        .checklistSubtitle: "Readiness check for post-decompensation discharge.",
        .checklistFootnote: "Educational support list; it does not replace clinical judgment. Nothing is stored.",
        .essentialLegend: "• Field essential to the recommendation",
        .essentialMissingWarning: "Essential fields left blank may limit the recommendation:",
        .sectionHFpEF: "HFpEF / comorbidities",
        .fieldAge: "Age",
        .unitYears: "years",
        .toggleAngioedema: "History of angioedema",
        .toggleSymptomsHF: "Symptoms/signs of HF",
        .toggleObesity: "Obesity (BMI > 30)",
        .toggleHypertension: "Hypertension",
        .toggleAntihtn2: "≥ 2 antihypertensives",
        .toggleAtrialFib: "Atrial fibrillation",
        .toggleDiabetes: "Diabetes",
        .toggleCKD: "Chronic kidney disease",
        .toggleCoronary: "Coronary disease",
        .toggleSleepApnea: "Sleep apnea",
        .toggleInfiltrative: "Suspected amyloidosis/infiltrative",
        .toggleValvular: "Significant valvular disease",
        .togglePulmonary: "Significant pulmonary disease",
        .toggleAnemia: "Anemia",
        .toggleNonCardiacEdema: "Possibly non-cardiac edema",
        .fieldPASP: "Estimated PASP > 35 mmHg",
        .fieldEoverE: "E/e' > 9",
        .triNotAssessed: "Not assessed",
        .resultBlocksTitle: "Recommendations",
        .exportButton: "Export / share (PDF)",
        .calcNavTitle: "Calculators",
        .calcSubtitle: "Supportive scores and calculations (anonymous).",
        .calcCHA2Title: "CHA₂DS₂-VASc (AF stroke risk)",
        .calcHF: "Heart failure / LV dysfunction",
        .calcStroke: "Prior stroke / TIA / thromboembolism",
        .calcVascular: "Vascular disease",
        .calcFemale: "Female sex",
        .calcScoreLabel: "Score",
        .calcEGFRTitle: "eGFR (CKD-EPI 2021)",
        .calcIronTitle: "Iron deficit (Ganzoni)",
        .calcWeight: "Weight",
        .calcHbCurrent: "Current Hb",
        .calcHbTarget: "Target Hb",
        .unitKg: "kg",
        .unitGdl: "g/dL",
        .calcDeficitLabel: "Iron deficit",
        .calcSodiumTitle: "Corrected sodium (hyperglycemia)",
        .calcNaMeasured: "Measured sodium",
        .calcGlucose: "Glucose",
        .calcCorrectedLabel: "Corrected sodium",
        .calcNatriuresisTitle: "Natriuresis / diuretic response",
        .calcUrineNa: "Spot urine sodium",
        .calcUrineOutput: "Urine output",
        .unitMlH: "mL/h",
        .calcResponseLabel: "Response",
        .sectionShock: "Instability / shock",
        .fieldLactate: "Lactate",
        .toggleOliguria: "Significant oliguria",
        .toggleAlteredMentation: "Altered mentation",
        .cancel: "Cancel",
        .historyNavTitle: "History",
        .historySubtitle: "Cases saved on this device (anonymous).",
        .historyEmptyTitle: "No saved cases",
        .historyEmptyDesc: "Generate an assessment and tap \"Save to history\" on the Summary.",
        .historyFootnote: "Cases are saved only on this device, anonymously. Do not enter identifiers (name, ID, record number). You can delete them at any time.",
        .historyDeleteAll: "Delete all",
        .historySaveButton: "Save to history",
        .historySaved: "Saved to history",
        .historySaveMessage: "Saved only on this device, with no patient identifiers. Use a non-identifying label (e.g., \"Bed 3B\").",
        .historyLabelPlaceholder: "Label (optional, no identifiers)"
    ]
}
