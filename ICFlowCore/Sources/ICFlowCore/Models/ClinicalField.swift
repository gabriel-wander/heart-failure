import Foundation

/// A clinical input field, used to report **missing data** that limits a
/// recommendation. The core stays UI-free: it returns these identifiers and the
/// presentation layer renders localized labels.
public enum ClinicalField: String, Codable, Sendable, CaseIterable {
    case lvef
    case nyha
    case systolicBP
    case heartRate
    case rhythm
    case egfr
    case creatinine
    case potassium
    case sodium
    case congestion
    case hypoperfusion
    case priorDiureticUse
    case homeDiureticAgent
    case homeDiureticDose
}
