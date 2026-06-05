import Foundation

/// Computes an approximate initial IV loop-diuretic strategy for the acute flow.
///
/// Logic is grounded in Felker et al. (2020): an empiric IV loop dose of roughly
/// 2.5× the total daily home (oral) dose given in divided doses, or a standard
/// initial dose if the patient is loop-naive. All values are illustrative and
/// must be individualized. Display text is taken from localized templates.
public struct DiureticCalculator {
    private let config: AcuteCongestionConfig
    private let messages: EngineMessages
    private let language: AppLanguage
    /// Mapa de fator de equivalência por id de agente (ex.: "furosemide": 1.0).
    private let equivalenceFactors: [String: Double]

    public init(
        config: AcuteCongestionConfig,
        loopDiuretics: [Medication],
        messages: EngineMessages,
        language: AppLanguage
    ) {
        self.config = config
        self.messages = messages
        self.language = language
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
        agentName: String?,
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

            let agentLabel = agentName ?? messages.diureticNaiveAgentFallback
            var text = EngineMessages.fill(messages.diureticPriorUser, [
                "agent": agentLabel,
                "oralDose": language.format(dose),
                "furoEquiv": language.format(furosemideEquiv),
                "total": language.format(roundedTotal),
                "doses": String(doses),
                "perDose": language.format(perDose)
            ])
            if highDose {
                text += " " + EngineMessages.fill(messages.diureticHighDoseSuffix, [
                    "threshold": language.format(config.cautionDailyFurosemideEquivMg)
                ])
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
        let text = EngineMessages.fill(messages.diureticLoopNaive, [
            "dose": language.format(initial)
        ])
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
}
