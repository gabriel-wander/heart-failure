import Foundation

/// Display-oriented status for a recommendation (v0.2).
///
/// Conveys not only eligibility but also **data sufficiency** and **urgency**,
/// in deliberately non-imperative language — the app never issues absolute
/// orders, it supports the physician's judgment ("considerar", "avaliar",
/// "sugerir se elegível").
public enum RecommendationStatus: String, Codable, Sendable, CaseIterable {
    /// Strong case to consider (no barriers, robust indication).
    case recommended
    /// Consider starting / optimizing / up-titrating, if eligible.
    case consider
    /// Proceed with caution; conditions warrant closer monitoring.
    case caution
    /// Contraindicated / avoid with the current data.
    case contraindicated
    /// Essential data missing — eligibility cannot be determined safely.
    case insufficientData
    /// Outside this flow — warrants urgent / specialist evaluation.
    case urgentReferral

    /// Maps a rule-derived eligibility to a (non-imperative) display status.
    public init(eligibility: EligibilityStatus) {
        switch eligibility {
        case .eligible: self = .consider
        case .caution: self = .caution
        case .contraindicated: self = .contraindicated
        }
    }

    /// Ordering used when aggregating/sorting (higher = more attention).
    public var severityRank: Int {
        switch self {
        case .urgentReferral: return 5
        case .contraindicated: return 4
        case .caution: return 3
        case .insufficientData: return 2
        case .consider: return 1
        case .recommended: return 0
        }
    }
}
