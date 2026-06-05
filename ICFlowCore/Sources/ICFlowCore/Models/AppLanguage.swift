import Foundation

/// Languages supported by the app. Drives which localized JSON content is
/// loaded and how numbers are formatted. The core is language-aware (a content
/// concern) but remains free of any UI framework.
public enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case pt
    case en

    public var id: String { rawValue }

    /// Name shown in its own language (for the in-app picker).
    public var nativeName: String {
        switch self {
        case .pt: return "Português"
        case .en: return "English"
        }
    }

    /// Short tag for compact UI (e.g. a globe menu).
    public var shortTag: String {
        switch self {
        case .pt: return "PT"
        case .en: return "EN"
        }
    }

    /// Suffix used to locate localized JSON resources (e.g. `medications_pt.json`).
    public var resourceSuffix: String { rawValue }

    /// Best-effort mapping from a system locale identifier.
    public static func from(localeIdentifier identifier: String) -> AppLanguage {
        identifier.lowercased().hasPrefix("pt") ? .pt : .en
    }

    /// Formats a number using the language's decimal separator and without a
    /// trailing ".0" (e.g. 200 -> "200"; 2.5 -> "2,5" in pt / "2.5" in en).
    public func format(_ value: Double) -> String {
        let base: String
        if value == value.rounded() {
            base = String(Int(value))
        } else {
            base = String(format: "%g", value)
        }
        return self == .pt ? base.replacingOccurrences(of: ".", with: ",") : base
    }
}
