import Foundation

/// Thematic block a recommendation belongs to, for the grouped results view.
public enum RecommendationGroup: String, Codable, Sendable {
    /// Terapias modificadoras de prognóstico (pilares).
    case prognosis
    /// Controle de sintomas / congestão.
    case symptomCongestion
    /// Terapias adicionais conforme perfil.
    case additional
    /// Encaminhamento / avaliação especializada.
    case referral
    /// Sem agrupamento específico.
    case general
}

/// A single recommendation produced by the decision engine for a medication
/// class (HFrEF flow) or for the IV diuretic strategy (acute flow).
public struct Recommendation: Identifiable, Equatable, Sendable {
    public let id: String
    /// Título exibido (ex.: rótulo da classe ou "Diurético de alça IV").
    public let title: String
    /// Classe associada (quando aplicável).
    public let classId: String?
    /// Fármaco/representante exibido (ex.: "Sacubitril/Valsartana (INRA)").
    public let displayDrug: String?
    public let status: RecommendationStatus
    /// Bloco temático ao qual a recomendação pertence (visão em blocos).
    public let group: RecommendationGroup
    /// Justificativas breves para o status.
    public let justifications: [String]
    public let startingDose: String?
    public let targetDose: String?
    public let monitoring: [String]
    public let safetyAlerts: [SafetyAlert]
    public let references: [Reference]
    /// Dados ausentes relevantes que limitam esta recomendação.
    public let missingData: [ClinicalField]
    /// Observações adicionais (ex.: plano de diurético, notas de escopo).
    public let notes: [String]

    public init(
        id: String,
        title: String,
        classId: String? = nil,
        displayDrug: String? = nil,
        status: RecommendationStatus,
        group: RecommendationGroup = .general,
        justifications: [String] = [],
        startingDose: String? = nil,
        targetDose: String? = nil,
        monitoring: [String] = [],
        safetyAlerts: [SafetyAlert] = [],
        references: [Reference] = [],
        missingData: [ClinicalField] = [],
        notes: [String] = []
    ) {
        self.id = id
        self.title = title
        self.classId = classId
        self.displayDrug = displayDrug
        self.status = status
        self.group = group
        self.justifications = justifications
        self.startingDose = startingDose
        self.targetDose = targetDose
        self.monitoring = monitoring
        self.safetyAlerts = safetyAlerts
        self.references = references
        self.missingData = missingData
        self.notes = notes
    }
}

/// The computed IV loop-diuretic estimate for the acute-congestion flow.
public struct DiureticPlan: Equatable, Sendable {
    public enum Strategy: String, Sendable {
        case loopNaive       // Virgem de diurético
        case priorOralUser   // Uso prévio de diurético oral

        public var displayName: String {
            switch self {
            case .loopNaive: return "Virgem de diurético"
            case .priorOralUser: return "Uso prévio de diurético oral"
            }
        }
    }

    public let strategy: Strategy
    /// Dose oral diária convertida para furosemida equivalente (quando aplicável).
    public let oralFurosemideEquivalentMg: Double?
    /// Dose IV total diária estimada (mg de furosemida).
    public let totalDailyIVFurosemideMg: Double
    /// Dose IV por administração (mg).
    public let perDoseMg: Double
    public let dosesPerDay: Int
    /// Sinaliza dose elevada com dados de segurança limitados.
    public let highDoseCaution: Bool
    /// Texto descritivo pronto para exibição.
    public let description: String

    public init(
        strategy: Strategy,
        oralFurosemideEquivalentMg: Double?,
        totalDailyIVFurosemideMg: Double,
        perDoseMg: Double,
        dosesPerDay: Int,
        highDoseCaution: Bool,
        description: String
    ) {
        self.strategy = strategy
        self.oralFurosemideEquivalentMg = oralFurosemideEquivalentMg
        self.totalDailyIVFurosemideMg = totalDailyIVFurosemideMg
        self.perDoseMg = perDoseMg
        self.dosesPerDay = dosesPerDay
        self.highDoseCaution = highDoseCaution
        self.description = description
    }
}

/// The full output of an assessment, consumed by the UI.
public struct AssessmentResult: Equatable, Sendable {
    public let scenario: Scenario
    /// Recomendações por classe (ICFEr) ou estratégia de diurético (aguda).
    public let recommendations: [Recommendation]
    /// Alertas de segurança agregados e relevantes ao caso.
    public let safetyAlerts: [SafetyAlert]
    /// Referências utilizadas no caso.
    public let references: [Reference]
    /// Perfil hemodinâmico (apenas fluxo agudo).
    public let congestionProfile: CongestionProfile?
    /// Plano de diurético IV (apenas fluxo agudo, quando indicado).
    public let diureticPlan: DiureticPlan?
    /// Resultado do escore H2FPEF (apenas fluxo ICFEp/ICFEm).
    public let h2fpef: H2FPEFResult?
    /// Dados essenciais ausentes que limitam a avaliação global.
    public let missingEssentialData: [ClinicalField]
    /// Notas gerais (ex.: dados ausentes, escopo, avaliação especializada).
    public let generalNotes: [String]

    public init(
        scenario: Scenario,
        recommendations: [Recommendation],
        safetyAlerts: [SafetyAlert],
        references: [Reference],
        congestionProfile: CongestionProfile? = nil,
        diureticPlan: DiureticPlan? = nil,
        h2fpef: H2FPEFResult? = nil,
        missingEssentialData: [ClinicalField] = [],
        generalNotes: [String] = []
    ) {
        self.scenario = scenario
        self.recommendations = recommendations
        self.safetyAlerts = safetyAlerts
        self.references = references
        self.congestionProfile = congestionProfile
        self.diureticPlan = diureticPlan
        self.h2fpef = h2fpef
        self.missingEssentialData = missingEssentialData
        self.generalNotes = generalNotes
    }
}
