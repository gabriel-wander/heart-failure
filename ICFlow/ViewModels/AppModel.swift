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
            currentLoopAgentId: priorDiureticUse ? (currentLoopAgentId ?? "furosemide") : nil,
            currentLoopOralDailyDoseMg: priorDiureticUse ? number(currentLoopOralDose) : nil
        )
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
}
