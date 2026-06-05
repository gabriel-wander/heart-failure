import Foundation

/// Evaluates the acute / decompensated congestion flow: classifies the
/// hemodynamic profile, builds an IV diuretic strategy when appropriate, and
/// surfaces red-flag alerts that warrant specialized evaluation.
struct AcuteCongestionEvaluator {
    let repository: ContentRepository

    func evaluate(_ input: PatientInput) -> AssessmentResult {
        let config = repository.ruleSet.acuteCongestionConfig
        let profile = CongestionProfile.from(
            congestion: input.congestion,
            hypoperfusion: input.hypoperfusion
        )

        var recommendations: [Recommendation] = []
        var diureticPlan: DiureticPlan?
        var usedAlertIds: Set<String> = []
        var usedReferenceIds: Set<String> = []
        var generalNotes: [String] = []

        // Red-flag rules (status nil → pure alert rules for the acute flow).
        let triggeredRules = repository.ruleSet.acuteCongestionRules
            .filter { RuleMatcher.matches($0, input: input) }
        let triggeredAlertIds = triggeredRules.flatMap { $0.safetyAlertIds }
        triggeredAlertIds.forEach { usedAlertIds.insert($0) }
        triggeredRules.flatMap { $0.referenceIds }.forEach { usedReferenceIds.insert($0) }

        let needsSpecialist = profile.hasHypoperfusion
            || (input.systolicBP.map { $0 < 90 } ?? false)

        config.referenceIds.forEach { usedReferenceIds.insert($0) }
        let planReferences = repository.references(withIds: config.referenceIds)

        if profile.hasCongestion && !needsSpecialist {
            // Warm & wet → IV diuretic strategy.
            let calculator = DiureticCalculator(config: config, loopDiuretics: repository.loopDiuretics())
            let plan = calculator.makePlan(
                priorUse: input.priorDiureticUse,
                agentId: input.currentLoopAgentId,
                oralDailyDoseMg: input.currentLoopOralDailyDoseMg
            )
            diureticPlan = plan

            // Standing alerts for the loop diuretic (e.g. distúrbios eletrolíticos)
            // plus any red-flag alert triggered by the rules above.
            let standingAlertIds = repository
                .primaryMedication(forClass: "loop_diuretic", scenario: .acuteCongestion)?
                .safetyAlertIds ?? []
            standingAlertIds.forEach { usedAlertIds.insert($0) }
            let planAlerts = repository.alerts(withIds: Array(usedAlertIds))

            recommendations.append(
                Recommendation(
                    id: "iv_diuretic",
                    title: "Diurético de alça intravenoso",
                    classId: "loop_diuretic",
                    displayDrug: "Furosemida IV",
                    status: .eligible,
                    justifications: [
                        "Perfil \(profile.displayName.lowercased()): congestão presente sem hipoperfusão grave — indicação de diurético de alça IV.",
                        plan.description
                    ],
                    startingDose: nil,
                    targetDose: nil,
                    monitoring: config.monitoringParameters,
                    safetyAlerts: planAlerts.sorted { $0.severity.sortRank < $1.severity.sortRank },
                    references: planReferences,
                    notes: [
                        "Doses IV devem ser administradas ao menos 2×/dia (retenção de sódio pós-dose).",
                        "Reavaliar resposta (diurese/UOP) em 2–6 h e titular a dose conforme objetivo de débito urinário.",
                        "Resposta inadequada/oligúria sugere resistência diurética — considerar intensificação (bloqueio sequencial do néfron) e avaliação especializada."
                    ]
                )
            )
            generalNotes.append("Estimativa de diurético é aproximada e educacional; individualizar conforme função renal, PA e resposta clínica.")
        } else if profile.hasCongestion && needsSpecialist {
            // Wet & cold (or hypotensive) → out of scope, escalate.
            recommendations.append(
                Recommendation(
                    id: "specialist_eval",
                    title: "Avaliação especializada",
                    classId: nil,
                    displayDrug: nil,
                    status: .caution,
                    justifications: [
                        "Congestão com hipoperfusão e/ou hipotensão (PAS < 90 mmHg) sugere baixo débito. Diurético isolado pode ser insuficiente ou deletério."
                    ],
                    startingDose: nil,
                    targetDose: nil,
                    monitoring: config.monitoringParameters,
                    safetyAlerts: repository.alerts(withIds: Array(usedAlertIds))
                        .sorted { $0.severity.sortRank < $1.severity.sortRank },
                    references: planReferences,
                    notes: [
                        "Considerar avaliação para suporte inotrópico/vasoativo e monitorização. Fora do escopo deste fluxo (sem choque cardiogênico).",
                        "Diurético IV pode ser considerado com cautela após estabilização hemodinâmica."
                    ]
                )
            )
            generalNotes.append("Cenário fora do escopo do fluxo de diurético simples — priorizar avaliação especializada.")
        } else {
            // Dry profiles → diuretic not indicated.
            recommendations.append(
                Recommendation(
                    id: "no_diuretic",
                    title: "Diurético IV não indicado",
                    classId: nil,
                    displayDrug: nil,
                    status: .caution,
                    justifications: [
                        "Sem sinais de congestão registrados (perfil \(profile.displayName.lowercased()))."
                    ],
                    startingDose: nil,
                    targetDose: nil,
                    monitoring: [],
                    safetyAlerts: [],
                    references: planReferences,
                    notes: [
                        "Reavaliar o diagnóstico e a volemia; otimizar terapia de base (GDMT) conforme indicado.",
                        profile.hasHypoperfusion ? "Hipoperfusão sem congestão sugere hipovolemia/baixo débito — avaliação especializada." : "Diurético de alça IV não é indicado na ausência de congestão."
                    ]
                )
            )
        }

        let aggregatedAlerts = repository.alerts(withIds: Array(usedAlertIds))
            .reduce(into: [SafetyAlert]()) { acc, alert in
                if !acc.contains(where: { $0.id == alert.id }) { acc.append(alert) }
            }
            .sorted { $0.severity.sortRank < $1.severity.sortRank }

        let aggregatedReferences = repository.references(withIds: Array(usedReferenceIds))
            .reduce(into: [Reference]()) { acc, ref in
                if !acc.contains(where: { $0.id == ref.id }) { acc.append(ref) }
            }

        generalNotes.append("Fluxo restrito a congestão sem choque cardiogênico. Reavaliar continuamente PA, perfusão e função renal.")

        return AssessmentResult(
            scenario: .acuteCongestion,
            recommendations: recommendations,
            safetyAlerts: aggregatedAlerts,
            references: aggregatedReferences,
            congestionProfile: profile,
            diureticPlan: diureticPlan,
            generalNotes: generalNotes
        )
    }
}
