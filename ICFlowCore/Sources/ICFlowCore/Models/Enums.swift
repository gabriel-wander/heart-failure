import Foundation

/// The two clinical flows supported by the MVP.
public enum Scenario: String, Codable, CaseIterable, Identifiable, Sendable {
    /// Chronic heart failure with reduced ejection fraction (HFrEF).
    case chronicHFrEF
    /// Acute / decompensated heart failure with congestion, without cardiogenic shock.
    case acuteCongestion

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .chronicHFrEF: return "ICFEr crônica"
        case .acuteCongestion: return "IC aguda congesta"
        }
    }

    public var detail: String {
        switch self {
        case .chronicHFrEF:
            return "Insuficiência cardíaca crônica com fração de ejeção reduzida (FEVE ≤ 40%)."
        case .acuteCongestion:
            return "IC aguda/descompensada com congestão, sem choque cardiogênico."
        }
    }
}

/// New York Heart Association functional class.
public enum NYHAClass: String, Codable, CaseIterable, Identifiable, Sendable {
    case i = "I"
    case ii = "II"
    case iii = "III"
    case iv = "IV"

    public var id: String { rawValue }
    public var displayName: String { "NYHA \(rawValue)" }

    /// Numeric value used by threshold-based clinical rules.
    public var numericValue: Double {
        switch self {
        case .i: return 1
        case .ii: return 2
        case .iii: return 3
        case .iv: return 4
        }
    }
}

/// Cardiac rhythm captured on the clinical input screen.
public enum Rhythm: String, Codable, CaseIterable, Identifiable, Sendable {
    case sinus
    case afib
    case other

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .sinus: return "Ritmo sinusal"
        case .afib: return "Fibrilação atrial"
        case .other: return "Outro"
        }
    }
}

/// Eligibility status produced by the decision engine for a medication class.
public enum EligibilityStatus: String, Codable, Sendable {
    case eligible
    case caution
    case contraindicated

    public var displayName: String {
        switch self {
        case .eligible: return "Elegível"
        case .caution: return "Cautela"
        case .contraindicated: return "Contraindicado"
        }
    }

    /// Ordering used to pick the most restrictive status when several rules match.
    public var severityRank: Int {
        switch self {
        case .eligible: return 0
        case .caution: return 1
        case .contraindicated: return 2
        }
    }
}

/// Severity of a safety alert, used for grouping and sorting on the alerts screen.
public enum AlertSeverity: String, Codable, Sendable {
    case info
    case warning
    case critical

    public var displayName: String {
        switch self {
        case .info: return "Informativo"
        case .warning: return "Atenção"
        case .critical: return "Crítico"
        }
    }

    public var sortRank: Int {
        switch self {
        case .critical: return 0
        case .warning: return 1
        case .info: return 2
        }
    }
}

/// Hemodynamic profile derived from congestion × perfusion (Stevenson profiles).
public enum CongestionProfile: String, Codable, Sendable {
    /// Congesto e bem perfundido.
    case wetWarm
    /// Congesto e hipoperfundido.
    case wetCold
    /// Sem congestão e bem perfundido.
    case dryWarm
    /// Hipoperfundido sem congestão.
    case dryCold

    public var displayName: String {
        switch self {
        case .wetWarm: return "Quente e úmido"
        case .wetCold: return "Frio e úmido"
        case .dryWarm: return "Quente e seco"
        case .dryCold: return "Frio e seco"
        }
    }

    public var summary: String {
        switch self {
        case .wetWarm: return "Congesto e bem perfundido — perfil típico para diurético IV."
        case .wetCold: return "Congesto e hipoperfundido — possível baixo débito; avaliação especializada."
        case .dryWarm: return "Sem congestão e bem perfundido — diurético IV não indicado."
        case .dryCold: return "Hipoperfundido sem congestão — avaliar hipovolemia/baixo débito; avaliação especializada."
        }
    }

    public var hasCongestion: Bool { self == .wetWarm || self == .wetCold }
    public var hasHypoperfusion: Bool { self == .wetCold || self == .dryCold }

    public static func from(congestion: Bool, hypoperfusion: Bool) -> CongestionProfile {
        switch (congestion, hypoperfusion) {
        case (true, false): return .wetWarm
        case (true, true): return .wetCold
        case (false, false): return .dryWarm
        case (false, true): return .dryCold
        }
    }
}
