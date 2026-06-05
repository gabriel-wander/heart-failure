import Foundation

/// A reusable safety alert, defined as data and linked to medication classes/rules.
public struct SafetyAlert: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let severity: AlertSeverity
    public let message: String
    /// Classes às quais o alerta se aplica (para agregação por classe).
    public let relatedClassIds: [String]
    public let referenceIds: [String]

    public init(
        id: String,
        title: String,
        severity: AlertSeverity,
        message: String,
        relatedClassIds: [String] = [],
        referenceIds: [String] = []
    ) {
        self.id = id
        self.title = title
        self.severity = severity
        self.message = message
        self.relatedClassIds = relatedClassIds
        self.referenceIds = referenceIds
    }
}
