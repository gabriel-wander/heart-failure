import Foundation

/// De-identified clinical input collected from the data-entry screen.
///
/// The app never persists this structure to disk and it contains **no patient
/// identifiers** — only non-identifying clinical parameters used by the decision
/// engine (age/sex/weight are allowed; name, ID, record number, phone, etc. are
/// never requested).
public struct ClinicalInput: Codable, Equatable, Sendable {
    public var scenario: Scenario

    // Numeric parameters (nil = not provided; rules treat missing values as "not evaluated").
    public var lvef: Double?           // Fração de ejeção do VE (%)
    public var nyha: NYHAClass?        // Classe funcional NYHA
    public var systolicBP: Double?     // PA sistólica (mmHg)
    public var heartRate: Double?      // Frequência cardíaca (bpm)
    public var rhythm: Rhythm          // Ritmo
    public var egfr: Double?           // TFGe (mL/min/1,73 m²)
    public var potassium: Double?      // Potássio (mmol/L)
    public var creatinine: Double?     // Creatinina (mg/dL)
    public var sodium: Double?         // Sódio (mmol/L)

    public var congestion: Bool        // Sinais de congestão
    public var hypoperfusion: Bool     // Sinais de hipoperfusão
    public var priorDiureticUse: Bool  // Uso prévio de diurético (de alça)

    // Demographics (non-identifying).
    public var age: Double?            // Idade (anos)
    public var sex: Sex
    public var weightKg: Double?       // Peso (kg)

    // Comorbidities / history (booleans; default false = not flagged).
    public var diabetes: Bool
    public var ckd: Bool
    public var copdOrAsthma: Bool
    public var atrialFibrillation: Bool
    public var pregnancyOrBreastfeeding: Bool
    public var historyOfAngioedema: Bool

    // HFpEF / diagnostic context (optional).
    public var bnp: Double?            // BNP/NT-proBNP (valor informado)

    // Optional details for the IV diuretic estimate (acute flow).
    public var currentLoopAgentId: String?       // ex.: "furosemide"
    public var currentLoopOralDailyDoseMg: Double?

    public init(
        scenario: Scenario,
        lvef: Double? = nil,
        nyha: NYHAClass? = nil,
        systolicBP: Double? = nil,
        heartRate: Double? = nil,
        rhythm: Rhythm = .sinus,
        egfr: Double? = nil,
        potassium: Double? = nil,
        creatinine: Double? = nil,
        sodium: Double? = nil,
        congestion: Bool = false,
        hypoperfusion: Bool = false,
        priorDiureticUse: Bool = false,
        age: Double? = nil,
        sex: Sex = .unspecified,
        weightKg: Double? = nil,
        diabetes: Bool = false,
        ckd: Bool = false,
        copdOrAsthma: Bool = false,
        atrialFibrillation: Bool = false,
        pregnancyOrBreastfeeding: Bool = false,
        historyOfAngioedema: Bool = false,
        bnp: Double? = nil,
        currentLoopAgentId: String? = nil,
        currentLoopOralDailyDoseMg: Double? = nil
    ) {
        self.scenario = scenario
        self.lvef = lvef
        self.nyha = nyha
        self.systolicBP = systolicBP
        self.heartRate = heartRate
        self.rhythm = rhythm
        self.egfr = egfr
        self.potassium = potassium
        self.creatinine = creatinine
        self.sodium = sodium
        self.congestion = congestion
        self.hypoperfusion = hypoperfusion
        self.priorDiureticUse = priorDiureticUse
        self.age = age
        self.sex = sex
        self.weightKg = weightKg
        self.diabetes = diabetes
        self.ckd = ckd
        self.copdOrAsthma = copdOrAsthma
        self.atrialFibrillation = atrialFibrillation
        self.pregnancyOrBreastfeeding = pregnancyOrBreastfeeding
        self.historyOfAngioedema = historyOfAngioedema
        self.bnp = bnp
        self.currentLoopAgentId = currentLoopAgentId
        self.currentLoopOralDailyDoseMg = currentLoopOralDailyDoseMg
    }

    // MARK: - Field access for the rule engine

    /// Numeric value for a rule field, or nil when not applicable / not provided.
    public func numericValue(for field: ConditionField) -> Double? {
        switch field {
        case .lvef: return lvef
        case .nyha: return nyha?.numericValue
        case .systolicBP: return systolicBP
        case .heartRate: return heartRate
        case .egfr: return egfr
        case .potassium: return potassium
        case .creatinine: return creatinine
        case .sodium: return sodium
        case .age: return age
        case .bnp: return bnp
        case .rhythm, .congestion, .hypoperfusion, .priorDiureticUse,
             .atrialFibrillation, .historyOfAngioedema, .diabetes, .ckd:
            return nil
        }
    }

    /// Boolean value for a rule field, or nil when the field is not boolean.
    public func boolValue(for field: ConditionField) -> Bool? {
        switch field {
        case .congestion: return congestion
        case .hypoperfusion: return hypoperfusion
        case .priorDiureticUse: return priorDiureticUse
        case .atrialFibrillation: return atrialFibrillation
        case .historyOfAngioedema: return historyOfAngioedema
        case .diabetes: return diabetes
        case .ckd: return ckd
        default: return nil
        }
    }

    /// String value for a rule field (enums), or nil when not applicable.
    public func stringValue(for field: ConditionField) -> String? {
        switch field {
        case .rhythm: return rhythm.rawValue
        case .nyha: return nyha?.rawValue
        default: return nil
        }
    }
}

/// Backwards-compatible alias retained from v0.1.
public typealias PatientInput = ClinicalInput
