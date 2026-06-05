import Foundation

/// Localized templates for text composed by the decision engine (notes,
/// justifications and the diuretic plan). Loaded from `engine_messages_<lang>.json`
/// so that engine output can be translated without code changes.
///
/// Templates use `{placeholder}` tokens filled in by the engine.
public struct EngineMessages: Codable, Equatable, Sendable {
    // HFrEF
    public let hfrefEligibleDefault: String
    public let hfrefAlternativesPrefix: String
    public let hfrefLvefNote: String              // {lvef}
    public let hfrefDecompensationNote: String
    public let hfrefMissingDataNote: String
    /// Mensagem quando faltam dados essenciais para a elegibilidade da classe.
    public let hfrefInsufficientClass: String
    /// Nota quando há hipoperfusão no fluxo crônico (cenário possivelmente instável).
    public let hfrefHypoperfusionNote: String

    // Diuretic plan (acute)
    public let diureticPriorUser: String          // {agent} {oralDose} {furoEquiv} {total} {doses} {perDose}
    public let diureticHighDoseSuffix: String     // {threshold}
    public let diureticLoopNaive: String          // {dose}
    public let diureticNaiveAgentFallback: String

    // Acute recommendations
    public let acuteIvTitle: String
    public let acuteIvDrug: String
    public let acuteIvJustification: String
    public let acuteIvNotes: [String]
    public let acuteIvGeneralNote: String

    public let acuteSpecialistTitle: String
    public let acuteSpecialistJustification: String
    public let acuteSpecialistNotes: [String]
    public let acuteSpecialistGeneralNote: String

    public let acuteNoDiureticTitle: String
    public let acuteNoDiureticJustification: String
    public let acuteNoDiureticNoteDefault: String
    public let acuteNoDiureticNoteHypoperfusion: String

    /// Recomendação de diurético limitada por falta de fármaco/dose domiciliar.
    public let acuteDiureticNeedsInfoTitle: String
    public let acuteDiureticNeedsInfoJustification: String
    /// Nota geral quando a avaliação aguda está limitada por dados ausentes.
    public let acuteInsufficientDataNote: String

    // Diuretic resistance / sequential nephron blockade
    public let acuteResistanceTitle: String
    public let acuteResistanceJustification: String
    public let acuteResistanceNotes: [String]
    /// Tabela de equivalências de diurético de alça (texto pronto).
    public let acuteEquivalenceNote: String

    public let acuteGeneralNote: String

    /// Replaces `{key}` tokens in `template` with the provided values.
    public static func fill(_ template: String, _ values: [String: String]) -> String {
        var result = template
        for (key, value) in values {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return result
    }
}
