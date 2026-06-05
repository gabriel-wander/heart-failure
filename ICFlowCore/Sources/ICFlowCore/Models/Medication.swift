import Foundation

/// A medication (or drug class representative) described entirely by data.
///
/// Doses are illustrative/mock values for an educational prototype and must be
/// reviewed against current guidelines and the local formulary before any use.
public struct Medication: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    /// Nome genérico exibido (ex.: "Sacubitril/Valsartana").
    public let genericName: String
    /// Identificador da classe terapêutica (ex.: "renin_angiotensin").
    public let classId: String
    /// Subclasse legível (ex.: "INRA", "IECA", "BRA", "Betabloqueador").
    public let subclass: String
    /// Cenário em que o fármaco é considerado.
    public let scenario: Scenario
    /// Indica o representante principal da classe (exibido por padrão).
    public let isPrimary: Bool
    /// Dose inicial (mock).
    public let startingDose: String
    /// Dose-alvo (mock).
    public let targetDose: String
    /// Parâmetros de monitoramento necessários.
    public let monitoring: [String]
    /// IDs de alertas de segurança relacionados.
    public let safetyAlertIds: [String]
    /// IDs de referências de apoio.
    public let referenceIds: [String]

    // MARK: Loop-diuretic specific (acute flow)

    /// Fator de conversão da dose oral deste agente para furosemida oral equivalente.
    /// Ex.: furosemida = 1.0, bumetanida = 40, torsemida = 2. Nil para não-diuréticos.
    public let furosemideEquivalentFactor: Double?

    public init(
        id: String,
        genericName: String,
        classId: String,
        subclass: String,
        scenario: Scenario,
        isPrimary: Bool = false,
        startingDose: String,
        targetDose: String,
        monitoring: [String] = [],
        safetyAlertIds: [String] = [],
        referenceIds: [String] = [],
        furosemideEquivalentFactor: Double? = nil
    ) {
        self.id = id
        self.genericName = genericName
        self.classId = classId
        self.subclass = subclass
        self.scenario = scenario
        self.isPrimary = isPrimary
        self.startingDose = startingDose
        self.targetDose = targetDose
        self.monitoring = monitoring
        self.safetyAlertIds = safetyAlertIds
        self.referenceIds = referenceIds
        self.furosemideEquivalentFactor = furosemideEquivalentFactor
    }
}
