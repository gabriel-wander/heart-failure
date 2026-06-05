import Foundation

/// Evaluates the acute / decompensated congestion flow: classifies the
/// hemodynamic profile, builds an IV diuretic strategy when appropriate, and
/// surfaces red-flag alerts that warrant specialized evaluation. All composed
/// text comes from the repository's localized `EngineMessages`.
struct AcuteCongestionEvaluator {
    let repository: ContentRepository

    private var messages: EngineMessages { repository.messages }
    private var language: AppLanguage { repository.language }

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
        triggeredRules.flatMap { $0.safetyAlertIds }.forEach { usedAlertIds.insert($0) }
        triggeredRules.flatMap { $0.referenceIds }.forEach { usedReferenceIds.insert($0) }

        let needsSpecialist = profile.hasHypoperfusion
            || (input.systolicBP.map { $0 < 90 } ?? false)

        config.referenceIds.forEach { usedReferenceIds.insert($0) }
        let planReferences = repository.references(withIds: config.referenceIds)

        if needsSpecialist {
            // Hypoperfusion and/or hypotension (SBP < 90) → outside the
            // "congested without shock" scope: flag for urgent / specialist
            // evaluation rather than a simple diuretic.
            recommendations.append(
                Recommendation(
                    id: "specialist_eval",
                    title: messages.acuteSpecialistTitle,
                    classId: nil,
                    displayDrug: nil,
                    status: .urgentReferral,
                    group: .referral,
                    justifications: [messages.acuteSpecialistJustification],
                    startingDose: nil,
                    targetDose: nil,
                    monitoring: config.monitoringParameters,
                    safetyAlerts: repository.alerts(withIds: Array(usedAlertIds))
                        .sorted { $0.severity.sortRank < $1.severity.sortRank },
                    references: planReferences,
                    notes: messages.acuteSpecialistNotes
                )
            )
            generalNotes.append(messages.acuteSpecialistGeneralNote)
        } else if profile.hasCongestion {
            // Warm & wet → IV diuretic strategy, gated on the data needed to
            // estimate a dose (prior agent + home dose).
            if ClinicalCompleteness.canEstimateDiuretic(input) {
                let agentName = input.currentLoopAgentId.flatMap { id in
                    repository.medications.first(where: { $0.id == id })?.genericName
                }
                let calculator = DiureticCalculator(
                    config: config,
                    loopDiuretics: repository.loopDiuretics(),
                    messages: messages,
                    language: language
                )
                let plan = calculator.makePlan(
                    priorUse: input.priorDiureticUse,
                    agentId: input.currentLoopAgentId,
                    agentName: agentName,
                    oralDailyDoseMg: input.currentLoopOralDailyDoseMg
                )
                diureticPlan = plan

                // Standing alerts for the loop diuretic plus any triggered red flag.
                let standingAlertIds = repository
                    .primaryMedication(forClass: "loop_diuretic", scenario: .acuteCongestion)?
                    .safetyAlertIds ?? []
                standingAlertIds.forEach { usedAlertIds.insert($0) }
                let planAlerts = repository.alerts(withIds: Array(usedAlertIds))

                recommendations.append(
                    Recommendation(
                        id: "iv_diuretic",
                        title: messages.acuteIvTitle,
                        classId: "loop_diuretic",
                        displayDrug: messages.acuteIvDrug,
                        status: .consider,
                        group: .symptomCongestion,
                        justifications: [messages.acuteIvJustification, plan.description],
                        startingDose: nil,
                        targetDose: nil,
                        monitoring: config.monitoringParameters,
                        safetyAlerts: planAlerts.sorted { $0.severity.sortRank < $1.severity.sortRank },
                        references: planReferences,
                        notes: messages.acuteIvNotes + [messages.acuteEquivalenceNote]
                    )
                )
                generalNotes.append(messages.acuteIvGeneralNote)

                // Inadequate response → sequential nephron blockade options.
                let nephronOptions = repository.medications(forClass: "sequential_nephron", scenario: .acuteCongestion)
                if !nephronOptions.isEmpty {
                    let optionNotes = nephronOptions.map { "\($0.genericName) (\($0.subclass)): \($0.startingDose)" }
                    let resistAlerts = repository.alerts(withIds: ["acute_electrolytes"])
                    resistAlerts.forEach { usedAlertIds.insert($0.id) }
                    recommendations.append(
                        Recommendation(
                            id: "diuretic_resistance",
                            title: messages.acuteResistanceTitle,
                            classId: "sequential_nephron",
                            displayDrug: nil,
                            status: .consider,
                            group: .additional,
                            justifications: [messages.acuteResistanceJustification],
                            monitoring: [],
                            safetyAlerts: resistAlerts,
                            references: planReferences,
                            notes: optionNotes + messages.acuteResistanceNotes
                        )
                    )
                }
            } else {
                // Prior diuretic use marked without agent/dose → do not compute a
                // dose silently; ask for the missing information.
                recommendations.append(
                    Recommendation(
                        id: "iv_diuretic",
                        title: messages.acuteDiureticNeedsInfoTitle,
                        classId: "loop_diuretic",
                        displayDrug: nil,
                        status: .insufficientData,
                        group: .symptomCongestion,
                        justifications: [messages.acuteDiureticNeedsInfoJustification],
                        startingDose: nil,
                        targetDose: nil,
                        monitoring: config.monitoringParameters,
                        safetyAlerts: repository.alerts(withIds: Array(usedAlertIds))
                            .sorted { $0.severity.sortRank < $1.severity.sortRank },
                        references: planReferences,
                        missingData: [.homeDiureticAgent, .homeDiureticDose],
                        notes: []
                    )
                )
            }
        } else {
            // Warm & dry → diuretic not indicated.
            recommendations.append(
                Recommendation(
                    id: "no_diuretic",
                    title: messages.acuteNoDiureticTitle,
                    classId: nil,
                    displayDrug: nil,
                    status: .consider,
                    group: .symptomCongestion,
                    justifications: [messages.acuteNoDiureticJustification],
                    startingDose: nil,
                    targetDose: nil,
                    monitoring: [],
                    safetyAlerts: [],
                    references: planReferences,
                    notes: [messages.acuteNoDiureticNoteDefault]
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

        let missingEssential = ClinicalCompleteness.missingEssential(for: input)
        if !missingEssential.isEmpty {
            generalNotes.append(messages.acuteInsufficientDataNote)
        }
        generalNotes.append(messages.acuteGeneralNote)

        return AssessmentResult(
            scenario: .acuteCongestion,
            recommendations: recommendations,
            safetyAlerts: aggregatedAlerts,
            references: aggregatedReferences,
            congestionProfile: profile,
            diureticPlan: diureticPlan,
            missingEssentialData: missingEssential,
            generalNotes: generalNotes
        )
    }
}
