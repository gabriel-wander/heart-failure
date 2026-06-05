import Foundation

/// Computes an approximate initial IV loop-diuretic strategy for the acute flow.
///
/// Logic is grounded in Felker et al. (2020): an empiric IV loop dose of roughly
/// 2.5× the total daily home (oral) dose given in divided doses, or a standard
/// initial dose if the patient is loop-naive. All values are illustrative and
/// must be individualized.
public struct DiureticCalculator {
    private let config: AcuteCongestionConfig
    /// Mapa de fator de equivalência por id de agente (ex.: "furosemide": 1.0).
    private let equivalenceFactors: [String: Double]

    public init(config: AcuteCongestionConfig, loopDiuretics: [Medication]) {
        self.config = config
        var factors: [String: Double] = [:]
        for med in loopDiuretics {
            if let factor = med.furosemideEquivalentFactor {
                factors[med.id] = factor
            }
        }
        self.equivalenceFactors = factors
    }

    /// Builds the IV diuretic plan from prior-use information.
    public func makePlan(
        priorUse: Bool,
        agentId: String?,
        oralDailyDoseMg: Double?
    ) -> DiureticPlan {
        // Decide whether we have enough info to treat as a prior oral user.
        if priorUse, let dose = oralDailyDoseMg, dose > 0 {
            let factor = agentId.flatMap { equivalenceFactors[$0] } ?? 1.0
            let furosemideEquiv = dose * factor
            let totalIV = config.ivLoopMultiplier * furosemideEquiv
            let doses = max(config.minDailyDoses, 1)
            let perDose = roundToStep(totalIV / Double(doses), step: 10)
            let roundedTotal = perDose * Double(doses)
            let highDose = totalIV > config.cautionDailyFurosemideEquivMg

            let agentLabel = agentId ?? "diurético de alça"
            var text = """
            Em uso prévio de \(agentLabel) \(formatMg(dose)) mg/dia VO \
            (≈ \(formatMg(furosemideEquiv)) mg/dia de furosemida equivalente). \
            Dose IV inicial estimada ≈ \(config.ivLoopMultiplier.cleanString)× a dose oral diária = \
            \(formatMg(roundedTotal)) mg/dia de furosemida IV, fracionada em \(doses)× \
            (~\(formatMg(perDose)) mg por dose). Administrar ao menos 2×/dia e reavaliar resposta em 2–6 h.
            """
            if highDose {
                text += " Atenção: dose elevada (> \(formatMg(config.cautionDailyFurosemideEquivMg)) mg/dia de furosemida equivalente) com dados de segurança limitados."
            }
            return DiureticPlan(
                strategy: .priorOralUser,
                oralFurosemideEquivalentMg: furosemideEquiv,
                totalDailyIVFurosemideMg: roundedTotal,
                perDoseMg: perDose,
                dosesPerDay: doses,
                highDoseCaution: highDose,
                description: text
            )
        }

        // Loop-naive (or insufficient data): standard initial dose.
        let initial = config.loopNaiveInitialFurosemideIVmg
        let text = """
        Paciente virgem de diurético de alça (ou sem dose oral informada). \
        Dose inicial padrão sugerida: furosemida \(formatMg(initial)) mg IV em bolus \
        (faixa habitual 40–80 mg). Reavaliar a resposta diurética em ~2 h e manter \
        ao menos 2×/dia se necessário.
        """
        return DiureticPlan(
            strategy: .loopNaive,
            oralFurosemideEquivalentMg: nil,
            totalDailyIVFurosemideMg: initial,
            perDoseMg: initial,
            dosesPerDay: 1,
            highDoseCaution: false,
            description: text
        )
    }

    // MARK: - Helpers

    private func roundToStep(_ value: Double, step: Double) -> Double {
        guard step > 0 else { return value }
        let rounded = (value / step).rounded() * step
        // Never round a positive dose down to zero.
        return rounded < step ? step : rounded
    }

    private func formatMg(_ value: Double) -> String {
        value.cleanString
    }
}

extension Double {
    /// Formats a number without a trailing ".0" (e.g. 200 -> "200", 2.5 -> "2,5").
    public var cleanString: String {
        if self == rounded() {
            return String(Int(self))
        }
        return String(format: "%g", self).replacingOccurrences(of: ".", with: ",")
    }
}
