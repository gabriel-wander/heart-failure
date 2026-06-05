import Foundation

/// A bibliographic reference shown on the references screen and linked from
/// recommendations and safety alerts.
public struct Reference: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public let authors: String
    public let title: String
    public let source: String
    public let year: Int
    /// Tópicos para agrupamento (ex.: "diuretics", "chronicHFrEF").
    public let topics: [String]

    public init(
        id: String,
        authors: String,
        title: String,
        source: String,
        year: Int,
        topics: [String] = []
    ) {
        self.id = id
        self.authors = authors
        self.title = title
        self.source = source
        self.year = year
        self.topics = topics
    }

    /// Citação formatada de forma compacta.
    public var citation: String {
        "\(authors) \(title). \(source)."
    }
}
