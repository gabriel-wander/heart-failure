import SwiftUI
import ICFlowCore

/// Maps core (UI-agnostic) enums to SwiftUI presentation, keeping color/icon
/// decisions out of the clinical engine.
extension EligibilityStatus {
    var color: Color {
        switch self {
        case .eligible: return .green
        case .caution: return .orange
        case .contraindicated: return .red
        }
    }

    var systemImage: String {
        switch self {
        case .eligible: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .contraindicated: return "xmark.octagon.fill"
        }
    }
}

extension RecommendationStatus {
    var color: Color {
        switch self {
        case .recommended: return .green
        case .consider: return .green
        case .caution: return .orange
        case .contraindicated: return .red
        case .insufficientData: return .gray
        case .urgentReferral: return .red
        }
    }

    var systemImage: String {
        switch self {
        case .recommended: return "checkmark.seal.fill"
        case .consider: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .contraindicated: return "xmark.octagon.fill"
        case .insufficientData: return "questionmark.circle.fill"
        case .urgentReferral: return "cross.case.fill"
        }
    }
}

extension AlertSeverity {
    var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }

    var systemImage: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}

extension Scenario {
    var systemImage: String {
        switch self {
        case .chronicHFrEF: return "heart.text.square.fill"
        case .acuteCongestion: return "drop.fill"
        }
    }
}
