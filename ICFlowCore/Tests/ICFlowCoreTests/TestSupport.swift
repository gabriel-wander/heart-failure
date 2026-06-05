import XCTest
@testable import ICFlowCore

/// Shared helpers for the clinical-logic test suite.
enum TestSupport {
    /// Loads the real bundled content once per test process.
    static let repository: ContentRepository = {
        do {
            return try ContentRepository.load()
        } catch {
            fatalError("Falha ao carregar conteúdo clínico para os testes: \(error)")
        }
    }()

    static var engine: DecisionEngine { DecisionEngine(repository: repository) }
}

extension AssessmentResult {
    /// Status of the recommendation for a given medication class.
    func status(forClass classId: String) -> EligibilityStatus? {
        recommendations.first(where: { $0.classId == classId })?.status
    }

    func recommendation(id: String) -> Recommendation? {
        recommendations.first(where: { $0.id == id })
    }

    var alertIds: Set<String> { Set(safetyAlerts.map(\.id)) }
}
