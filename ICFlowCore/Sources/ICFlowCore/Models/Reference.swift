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

    // MARK: v0.2 — optional metadata (additive; absent in v0.1 JSON)

    /// Título curto para exibição compacta.
    public let shortTitle: String?
    /// Tipo de documento (ex.: "Diretriz", "Estudo", "Revisão").
    public let guidelineOrStudy: String?
    /// URL opcional (pode não abrir offline).
    public let url: String?
    /// Nível de evidência opcional.
    public let evidenceLevel: String?
    /// Data da última revisão do conteúdo (ISO ou texto curto).
    public let lastReviewed: String?

    public init(
        id: String,
        authors: String,
        title: String,
        source: String,
        year: Int,
        topics: [String] = [],
        shortTitle: String? = nil,
        guidelineOrStudy: String? = nil,
        url: String? = nil,
        evidenceLevel: String? = nil,
        lastReviewed: String? = nil
    ) {
        self.id = id
        self.authors = authors
        self.title = title
        self.source = source
        self.year = year
        self.topics = topics
        self.shortTitle = shortTitle
        self.guidelineOrStudy = guidelineOrStudy
        self.url = url
        self.evidenceLevel = evidenceLevel
        self.lastReviewed = lastReviewed
    }

    /// Citação formatada de forma compacta.
    public var citation: String {
        "\(authors) \(title). \(source)."
    }
}
