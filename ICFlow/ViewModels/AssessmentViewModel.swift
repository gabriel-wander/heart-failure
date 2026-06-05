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

/// Owns the de-identified input and the engine output for the current session.
/// Nothing here is persisted to disk.
final class AssessmentViewModel: ObservableObject {
    @Published var scenario: Scenario = .chronicHFrEF
    @Published var draft = InputDraft()
    @Published private(set) var result: AssessmentResult?

    let repository: ContentRepository?
    let loadError: String?
    private let engine: DecisionEngine?

    init(repository: ContentRepository) {
        self.repository = repository
        self.engine = DecisionEngine(repository: repository)
        self.loadError = nil
    }

    init(loadError: Error) {
        self.repository = nil
        self.engine = nil
        self.loadError = String(describing: loadError)
    }

    /// Loop-diuretic agents available for the acute-flow picker.
    var loopAgents: [Medication] {
        repository?.loopDiuretics() ?? []
    }

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
