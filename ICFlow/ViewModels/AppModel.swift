import Foundation
import Combine
import ICFlowCore

/// Mutable, UI-friendly draft of the clinical input. Numeric fields are kept as
/// strings so text fields can be empty and accept comma/period decimals.
struct InputDraft: Equatable {
    var lvef = ""
    var nyha: NYHAClass? = nil
    var systolicBP = ""
    var heartRate = ""
    var rhythm: Rhythm = .sinus
    var egfr = ""
    var potassium = ""
    var creatinine = ""
    var congestion = false
    var hypoperfusion = false
    var priorDiureticUse = false
    var currentLoopAgentId: String? = nil
    var currentLoopOralDose = ""
    var historyOfAngioedema = false

    // HFpEF / HFmrEF module
    var age = ""
    var symptomsSignsHF = false
    var obesity = false
    var hypertension = false
    var antihypertensives2plus = false
    var atrialFibrillation = false
    var diabetes = false
    var ckd = false
    var coronaryDisease = false
    var sleepApnea = false
    var suspectedInfiltrative = false
    var valvularDisease = false
    var pulmonaryDisease = false
    var anemia = false
    var nonCardiacEdema = false
    var paspOver35: Bool? = nil
    var eOverEprimeOver9: Bool? = nil

    // Cardiogenic shock / instability
    var lactate = ""
    var oliguria = false
    var alteredMentation = false

    private func number(_ string: String) -> Double? {
        let normalized = string
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        return Double(normalized)
    }

    func toPatientInput(scenario: Scenario) -> PatientInput {
        PatientInput(
            scenario: scenario,
            lvef: number(lvef),
            nyha: nyha,
            systolicBP: number(systolicBP),
            heartRate: number(heartRate),
            rhythm: rhythm,
            egfr: number(egfr),
            potassium: number(potassium),
            creatinine: number(creatinine),
            congestion: congestion,
            hypoperfusion: hypoperfusion,
            priorDiureticUse: priorDiureticUse,
            age: number(age),
            diabetes: diabetes,
            ckd: ckd,
            atrialFibrillation: atrialFibrillation,
            historyOfAngioedema: historyOfAngioedema,
            symptomsSignsHF: symptomsSignsHF,
            obesity: obesity,
            hypertension: hypertension,
            antihypertensives2plus: antihypertensives2plus,
            coronaryDisease: coronaryDisease,
            sleepApnea: sleepApnea,
            suspectedInfiltrative: suspectedInfiltrative,
            valvularDisease: valvularDisease,
            pulmonaryDisease: pulmonaryDisease,
            anemia: anemia,
            nonCardiacEdema: nonCardiacEdema,
            paspOver35: paspOver35,
            eOverEprimeOver9: eOverEprimeOver9,
            lactate: number(lactate),
            oliguria: oliguria,
            alteredMentation: alteredMentation,
            currentLoopAgentId: priorDiureticUse ? (currentLoopAgentId ?? "furosemide") : nil,
            currentLoopOralDailyDoseMg: priorDiureticUse ? number(currentLoopOralDose) : nil
        )
    }

    /// Essential numeric fields missing for the current scenario (UI-side hint
    /// mirroring the engine's completeness rules).
    func missingEssential(scenario: Scenario) -> [ClinicalField] {
        func empty(_ s: String) -> Bool { s.trimmingCharacters(in: .whitespaces).isEmpty }
        switch scenario {
        case .chronicHFrEF:
            var m: [ClinicalField] = []
            if empty(lvef) { m.append(.lvef) }
            if empty(systolicBP) { m.append(.systolicBP) }
            if empty(heartRate) { m.append(.heartRate) }
            if empty(egfr) { m.append(.egfr) }
            if empty(potassium) { m.append(.potassium) }
            return m
        case .acuteCongestion:
            var m: [ClinicalField] = []
            if empty(systolicBP) { m.append(.systolicBP) }
            if empty(egfr) && empty(creatinine) { m.append(.egfr) }
            if empty(potassium) { m.append(.potassium) }
            return m
        case .hfpefHFmrEF:
            return empty(lvef) ? [.lvef] : []
        case .cardiogenicShock:
            return empty(systolicBP) ? [.systolicBP] : []
        }
    }
}

/// Central app state: current language, loaded clinical content, the assessment
/// input and result. Switching language reloads the content and re-runs the
/// engine so the whole UI (including engine-generated text) updates live.
/// Nothing here is persisted except the chosen language preference.
final class AppModel: ObservableObject {
    @Published private(set) var language: AppLanguage
    @Published var scenario: Scenario = .chronicHFrEF
    @Published var draft = InputDraft()
    @Published private(set) var result: AssessmentResult?
    @Published private(set) var loadError: String?

    private(set) var repository: ContentRepository?
    private var engine: DecisionEngine?

    private static let languageKey = "icflow.language"

    init() {
        let initial = AppModel.savedLanguage() ?? AppModel.systemLanguage()
        self.language = initial
        loadContent(for: initial)
    }

    // MARK: - Localization helpers

    func t(_ key: UIString) -> String { Localizer.string(key, language) }
    func format(_ value: Double) -> String { language.format(value) }

    func name(_ s: Scenario) -> String { Localizer.scenarioName(s, language) }
    func detail(_ s: Scenario) -> String { Localizer.scenarioDetail(s, language) }
    func name(_ n: NYHAClass) -> String { Localizer.nyhaName(n, language) }
    func name(_ r: Rhythm) -> String { Localizer.rhythmName(r, language) }
    func name(_ s: EligibilityStatus) -> String { Localizer.statusName(s, language) }
    func name(_ s: RecommendationStatus) -> String { Localizer.recStatusName(s, language) }
    func name(_ f: ClinicalField) -> String { Localizer.fieldName(f, language) }
    func name(_ s: AlertSeverity) -> String { Localizer.severityName(s, language) }

    /// Whether the bundled clinical content has been formally validated.
    var isContentValidated: Bool { ClinicalContent.isClinicalContentValidated }
    func name(_ p: CongestionProfile) -> String { Localizer.profileName(p, language) }
    func summary(_ p: CongestionProfile) -> String { Localizer.profileSummary(p, language) }
    func name(_ c: H2FPEFResult.Category) -> String { Localizer.h2fpefCategoryName(c, language) }
    func name(_ r: Calculators.DiureticResponse) -> String { Localizer.diureticResponseName(r, language) }
    func groupName(_ g: RecommendationGroup) -> String { Localizer.groupName(g, language) }
    func name(_ s: DiureticPlan.Strategy) -> String { Localizer.strategyName(s, language) }

    /// Loop-diuretic agents available for the acute-flow picker.
    var loopAgents: [Medication] { repository?.loopDiuretics() ?? [] }

    // MARK: - Language

    func setLanguage(_ newLanguage: AppLanguage) {
        guard newLanguage != language else { return }
        language = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: AppModel.languageKey)
        loadContent(for: newLanguage)
        // Re-run the engine so any existing result is shown in the new language.
        if result != nil {
            generate()
        }
    }

    private func loadContent(for language: AppLanguage) {
        do {
            let repo = try ContentRepository.load(language: language)
            repository = repo
            engine = DecisionEngine(repository: repo)
            loadError = nil
        } catch {
            repository = nil
            engine = nil
            loadError = String(describing: error)
        }
    }

    private static func savedLanguage() -> AppLanguage? {
        guard let raw = UserDefaults.standard.string(forKey: languageKey) else { return nil }
        return AppLanguage(rawValue: raw)
    }

    private static func systemLanguage() -> AppLanguage {
        AppLanguage.from(localeIdentifier: Locale.preferredLanguages.first ?? "pt")
    }

    // MARK: - Assessment

    func startNewAssessment(scenario: Scenario) {
        self.scenario = scenario
        self.draft = InputDraft()
        self.result = nil
    }

    func generate() {
        guard let engine else { return }
        result = engine.evaluate(draft.toPatientInput(scenario: scenario))
    }

    func reset() {
        draft = InputDraft()
        result = nil
    }

    /// Loads a saved (anonymous) case and re-runs the engine on it.
    func load(_ saved: SavedCase) {
        scenario = saved.scenario
        draft = InputDraft(from: saved.input)
        generate()
    }
}
