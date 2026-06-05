import Foundation

/// Patient field referenced by a rule condition.
public enum ConditionField: String, Codable, Sendable {
    case lvef
    case nyha
    case systolicBP
    case heartRate
    case egfr
    case potassium
    case creatinine
    case sodium
    case rhythm
    case congestion
    case hypoperfusion
    case priorDiureticUse
    // v0.2 — comorbidities / history
    case atrialFibrillation
    case historyOfAngioedema
    case diabetes
    case ckd
    case age
    case bnp
}

/// Comparison operator supported by the rule engine.
public enum ConditionOperator: String, Codable, Sendable {
    case lessThan = "lt"
    case lessThanOrEqual = "lte"
    case greaterThan = "gt"
    case greaterThanOrEqual = "gte"
    case equal = "eq"
    case notEqual = "neq"
    case isTrue
    case isFalse
}

/// A loosely typed JSON value used as the right-hand side of a condition.
public enum ConditionValue: Codable, Equatable, Sendable {
    case number(Double)
    case bool(Bool)
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Order matters: probe Bool before Double so `true`/`false` are not coerced.
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Valor de condição não suportado")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        }
    }
}

/// One predicate evaluated against `PatientInput`.
public struct RuleCondition: Codable, Equatable, Sendable {
    public let field: ConditionField
    public let op: ConditionOperator
    public let value: ConditionValue?

    public init(field: ConditionField, op: ConditionOperator, value: ConditionValue? = nil) {
        self.field = field
        self.op = op
        self.value = value
    }
}

/// How multiple conditions in a rule combine.
public enum RuleLogic: String, Codable, Sendable {
    case all
    case any
}

/// A data-driven clinical rule. When its conditions match the patient input, the
/// engine applies `status` to the target medication class with a justification,
/// linked safety alerts and references. No clinical thresholds live in the UI.
public struct ClinicalRule: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    /// Classe alvo (ex.: "renin_angiotensin"). Nil = aplica a alertas do cenário agudo.
    public let classId: String?
    /// Subclasses específicas afetadas (nil = todas as subclasses da classe).
    public let appliesToSubclasses: [String]?
    public let logic: RuleLogic
    public let conditions: [RuleCondition]
    /// Status resultante quando a regra dispara (para regras de elegibilidade).
    public let status: EligibilityStatus?
    public let justification: String
    public let safetyAlertIds: [String]
    public let referenceIds: [String]

    // MARK: v0.2 — optional metadata (additive; absent in v0.1 JSON)

    /// Título legível da regra.
    public let title: String?
    /// Texto de recomendação associado (não imperativo).
    public let recommendation: String?
    /// Racional clínico estendido.
    public let rationale: String?
    /// Severidade associada (para ordenação/realce).
    public let severity: AlertSeverity?
    /// Campos necessários para a regra ter validade.
    public let requiredInputs: [ClinicalField]?
    /// Comportamento quando faltam dados (ex.: "insufficientData", "skip").
    public let missingDataBehavior: String?

    public init(
        id: String,
        classId: String? = nil,
        appliesToSubclasses: [String]? = nil,
        logic: RuleLogic = .all,
        conditions: [RuleCondition],
        status: EligibilityStatus? = nil,
        justification: String,
        safetyAlertIds: [String] = [],
        referenceIds: [String] = [],
        title: String? = nil,
        recommendation: String? = nil,
        rationale: String? = nil,
        severity: AlertSeverity? = nil,
        requiredInputs: [ClinicalField]? = nil,
        missingDataBehavior: String? = nil
    ) {
        self.id = id
        self.classId = classId
        self.appliesToSubclasses = appliesToSubclasses
        self.logic = logic
        self.conditions = conditions
        self.status = status
        self.justification = justification
        self.safetyAlertIds = safetyAlertIds
        self.referenceIds = referenceIds
        self.title = title
        self.recommendation = recommendation
        self.rationale = rationale
        self.severity = severity
        self.requiredInputs = requiredInputs
        self.missingDataBehavior = missingDataBehavior
    }
}

/// Configuration parameters for the acute-congestion diuretic estimate.
public struct AcuteCongestionConfig: Codable, Equatable, Sendable {
    /// Multiplicador da dose oral domiciliar para estimar dose IV total (Felker 2020 ≈ 2,5×).
    public let ivLoopMultiplier: Double
    /// Dose IV de furosemida (mg) para paciente virgem de diurético.
    public let loopNaiveInitialFurosemideIVmg: Double
    /// Número mínimo de administrações diárias da dose IV.
    public let minDailyDoses: Int
    /// Dose diária de furosemida-equivalente (mg) acima da qual há cautela / dados limitados.
    public let cautionDailyFurosemideEquivMg: Double
    /// Parâmetros a monitorar durante a diurese.
    public let monitoringParameters: [String]
    public let referenceIds: [String]

    public init(
        ivLoopMultiplier: Double,
        loopNaiveInitialFurosemideIVmg: Double,
        minDailyDoses: Int,
        cautionDailyFurosemideEquivMg: Double,
        monitoringParameters: [String],
        referenceIds: [String]
    ) {
        self.ivLoopMultiplier = ivLoopMultiplier
        self.loopNaiveInitialFurosemideIVmg = loopNaiveInitialFurosemideIVmg
        self.minDailyDoses = minDailyDoses
        self.cautionDailyFurosemideEquivMg = cautionDailyFurosemideEquivMg
        self.monitoringParameters = monitoringParameters
        self.referenceIds = referenceIds
    }
}

/// Top-level structure decoded from `clinical_rules.json`.
public struct ClinicalRuleSet: Codable, Equatable, Sendable {
    public let hfrefRules: [ClinicalRule]
    /// Regras que sugerem terapias adicionais (não-pilares) conforme perfil.
    public let hfrefAdditionalRules: [ClinicalRule]?
    public let acuteCongestionRules: [ClinicalRule]
    public let acuteCongestionConfig: AcuteCongestionConfig
    /// Ordem de exibição das classes do módulo ICFEr.
    public let hfrefClassOrder: [String]
    /// Rótulos legíveis das classes.
    public let classLabels: [String: String]

    // MARK: v0.2 — content versioning (optional; absent in v0.1 JSON)

    /// Versão do conteúdo clínico (para rastreabilidade).
    public let contentVersion: String?
    /// Data da última revisão do conteúdo.
    public let lastReviewed: String?

    public init(
        hfrefRules: [ClinicalRule],
        hfrefAdditionalRules: [ClinicalRule]? = nil,
        acuteCongestionRules: [ClinicalRule],
        acuteCongestionConfig: AcuteCongestionConfig,
        hfrefClassOrder: [String],
        classLabels: [String: String],
        contentVersion: String? = nil,
        lastReviewed: String? = nil
    ) {
        self.hfrefRules = hfrefRules
        self.hfrefAdditionalRules = hfrefAdditionalRules
        self.acuteCongestionRules = acuteCongestionRules
        self.acuteCongestionConfig = acuteCongestionConfig
        self.hfrefClassOrder = hfrefClassOrder
        self.classLabels = classLabels
        self.contentVersion = contentVersion
        self.lastReviewed = lastReviewed
    }
}
