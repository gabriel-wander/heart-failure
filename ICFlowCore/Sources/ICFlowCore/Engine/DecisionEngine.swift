import Foundation

/// Entry point of the clinical decision support logic.
///
/// The engine is deliberately simple: it reads content/rules from the
/// `ContentRepository` and dispatches to the scenario-specific evaluator.
public struct DecisionEngine {
    private let repository: ContentRepository
    private let hfref: HFrEFEvaluator
    private let acute: AcuteCongestionEvaluator
    private let hfpef: HFpEFEvaluator

    public init(repository: ContentRepository) {
        self.repository = repository
        self.hfref = HFrEFEvaluator(repository: repository)
        self.acute = AcuteCongestionEvaluator(repository: repository)
        self.hfpef = HFpEFEvaluator(repository: repository)
    }

    /// Produces a full assessment for the given de-identified input.
    public func evaluate(_ input: PatientInput) -> AssessmentResult {
        switch input.scenario {
        case .chronicHFrEF:
            return hfref.evaluate(input)
        case .acuteCongestion:
            return acute.evaluate(input)
        case .hfpefHFmrEF:
            return hfpef.evaluate(input)
        }
    }
}
