import Foundation

/// Loads and holds all clinical content for a given language from the bundled
/// JSON files.
///
/// The repository is the single source of truth for medications, clinical rules,
/// safety alerts, references and engine message templates. Updating the medical
/// content (in any language) is done by editing the JSON resources — no Swift
/// code changes required (see README).
public final class ContentRepository: Sendable {
    public let language: AppLanguage
    public let medications: [Medication]
    public let safetyAlerts: [SafetyAlert]
    public let references: [Reference]
    public let ruleSet: ClinicalRuleSet
    public let messages: EngineMessages

    // Fast lookup tables.
    private let alertsById: [String: SafetyAlert]
    private let referencesById: [String: Reference]

    public init(
        language: AppLanguage,
        medications: [Medication],
        safetyAlerts: [SafetyAlert],
        references: [Reference],
        ruleSet: ClinicalRuleSet,
        messages: EngineMessages
    ) {
        self.language = language
        self.medications = medications
        self.safetyAlerts = safetyAlerts
        self.references = references
        self.ruleSet = ruleSet
        self.messages = messages
        self.alertsById = Dictionary(safetyAlerts.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.referencesById = Dictionary(references.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    // MARK: - Lookups

    public func alerts(withIds ids: [String]) -> [SafetyAlert] {
        ids.compactMap { alertsById[$0] }
    }

    public func references(withIds ids: [String]) -> [Reference] {
        ids.compactMap { referencesById[$0] }
    }

    public func medications(forClass classId: String, scenario: Scenario) -> [Medication] {
        medications.filter { $0.classId == classId && $0.scenario == scenario }
    }

    public func primaryMedication(forClass classId: String, scenario: Scenario) -> Medication? {
        let inClass = medications(forClass: classId, scenario: scenario)
        return inClass.first(where: { $0.isPrimary }) ?? inClass.first
    }

    public func loopDiuretics() -> [Medication] {
        medications.filter { $0.furosemideEquivalentFactor != nil }
    }

    public func classLabel(_ classId: String) -> String {
        ruleSet.classLabels[classId] ?? classId
    }

    // MARK: - Loading

    public enum LoadError: Error, CustomStringConvertible {
        case missingResource(String)
        case decoding(String, underlying: Error)

        public var description: String {
            switch self {
            case .missingResource(let name):
                return "Recurso não encontrado no bundle: \(name).json"
            case .decoding(let name, let underlying):
                return "Falha ao decodificar \(name).json: \(underlying)"
            }
        }
    }

    /// Loads the repository for a language (defaults to Portuguese) from the
    /// package's resource bundle.
    public static func load(language: AppLanguage = .pt) throws -> ContentRepository {
        // `Bundle.module` is internal to the package; reference it here (in the
        // function body) rather than as a public default argument.
        let bundle = Bundle.module
        let decoder = JSONDecoder()
        let suffix = language.resourceSuffix
        let medications = try decode("medications_\(suffix)", bundle: bundle, as: [Medication].self, decoder: decoder)
        let alerts = try decode("safety_alerts_\(suffix)", bundle: bundle, as: [SafetyAlert].self, decoder: decoder)
        let references = try decode("references_\(suffix)", bundle: bundle, as: [Reference].self, decoder: decoder)
        let ruleSet = try decode("clinical_rules_\(suffix)", bundle: bundle, as: ClinicalRuleSet.self, decoder: decoder)
        let messages = try decode("engine_messages_\(suffix)", bundle: bundle, as: EngineMessages.self, decoder: decoder)
        return ContentRepository(
            language: language,
            medications: medications,
            safetyAlerts: alerts,
            references: references,
            ruleSet: ruleSet,
            messages: messages
        )
    }

    private static func decode<T: Decodable>(
        _ name: String,
        bundle: Bundle,
        as type: T.Type,
        decoder: JSONDecoder
    ) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw LoadError.missingResource(name)
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch let error as LoadError {
            throw error
        } catch {
            throw LoadError.decoding(name, underlying: error)
        }
    }
}
