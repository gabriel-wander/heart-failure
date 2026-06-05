import Foundation

/// Evaluates the four foundational HFrEF drug classes against the patient input
/// and produces one recommendation per class. All composed text comes from the
/// repository's localized `EngineMessages`.
struct HFrEFEvaluator {
    let repository: ContentRepository

    private var messages: EngineMessages { repository.messages }
    private var language: AppLanguage { repository.language }

    func evaluate(_ input: PatientInput) -> AssessmentResult {
        let ruleSet = repository.ruleSet
        var recommendations: [Recommendation] = []
        var usedAlertIds: Set<String> = []
        var usedReferenceIds: Set<String> = []
        var generalNotes: [String] = []

        if let lvef = input.lvef, lvef > 40 {
            generalNotes.append(
                EngineMessages.fill(messages.hfrefLvefNote, ["lvef": language.format(lvef)])
            )
        }

        for classId in ruleSet.hfrefClassOrder {
            guard let primary = repository.primaryMedication(forClass: classId, scenario: .chronicHFrEF) else {
                continue
            }

            let classRules = ruleSet.hfrefRules.filter { rule in
                rule.classId == classId && appliesToSubclass(rule, subclass: primary.subclass)
            }
            let matched = classRules.filter { RuleMatcher.matches($0, input: input) }

            let contraindications = matched.filter { $0.status == .contraindicated }
            let cautions = matched.filter { $0.status == .caution }

            let eligibility: EligibilityStatus
            let activeRules: [ClinicalRule]
            if !contraindications.isEmpty {
                eligibility = .contraindicated
                activeRules = contraindications
            } else if !cautions.isEmpty {
                eligibility = .caution
                activeRules = cautions
            } else {
                eligibility = .eligible
                activeRules = []
            }

            // Data-completeness gating: never assert a class-specific eligibility
            // when the essential inputs for that class are missing.
            let missingForClass = missingFields(forClass: classId, input: input)
            let status: RecommendationStatus
            var justifications: [String]
            if missingForClass.isEmpty {
                status = RecommendationStatus(eligibility: eligibility)
                justifications = activeRules.map { $0.justification }
                if justifications.isEmpty {
                    justifications = [messages.hfrefEligibleDefault]
                }
            } else {
                status = .insufficientData
                justifications = [messages.hfrefInsufficientClass]
            }

            // Alerts: those triggered by active rules + the class's standing alerts.
            let triggeredAlertIds = activeRules.flatMap { $0.safetyAlertIds }
            let classAlerts = repository.safetyAlerts.filter { $0.relatedClassIds.contains(classId) }
            let recAlerts = orderedUniqueAlerts(
                repository.alerts(withIds: triggeredAlertIds) + classAlerts
            )
            recAlerts.forEach { usedAlertIds.insert($0.id) }

            // References: active rules + primary medication.
            let refIds = activeRules.flatMap { $0.referenceIds } + primary.referenceIds
            let recReferences = orderedUniqueReferences(repository.references(withIds: refIds))
            recReferences.forEach { usedReferenceIds.insert($0.id) }

            recommendations.append(
                Recommendation(
                    id: classId,
                    title: repository.classLabel(classId),
                    classId: classId,
                    displayDrug: "\(primary.genericName) (\(primary.subclass))",
                    status: status,
                    justifications: justifications,
                    startingDose: primary.startingDose,
                    targetDose: primary.targetDose,
                    monitoring: primary.monitoring,
                    safetyAlerts: recAlerts,
                    references: recReferences,
                    missingData: missingForClass,
                    notes: alternativeNote(forClass: classId, excluding: primary)
                )
            )
        }

        if input.hypoperfusion {
            generalNotes.append(messages.hfrefHypoperfusionNote)
        }
        if input.congestion || input.hypoperfusion {
            generalNotes.append(messages.hfrefDecompensationNote)
        }
        generalNotes.append(messages.hfrefMissingDataNote)

        let aggregatedAlerts = orderedUniqueAlerts(repository.alerts(withIds: Array(usedAlertIds)))
            .sorted { $0.severity.sortRank < $1.severity.sortRank }
        let aggregatedReferences = orderedUniqueReferences(repository.references(withIds: Array(usedReferenceIds)))

        return AssessmentResult(
            scenario: .chronicHFrEF,
            recommendations: recommendations,
            safetyAlerts: aggregatedAlerts,
            references: aggregatedReferences,
            missingEssentialData: ClinicalCompleteness.missingEssential(for: input),
            generalNotes: generalNotes
        )
    }

    // MARK: - Helpers

    /// Essential inputs whose absence prevents a class-specific recommendation.
    private func missingFields(forClass classId: String, input: PatientInput) -> [ClinicalField] {
        switch classId {
        case "renin_angiotensin", "mra":
            return ClinicalCompleteness.missingForRASandMRA(input)
        case "beta_blocker":
            return ClinicalCompleteness.missingForBetaBlocker(input)
        default:
            return []
        }
    }

    private func appliesToSubclass(_ rule: ClinicalRule, subclass: String) -> Bool {
        guard let subclasses = rule.appliesToSubclasses else { return true }
        return subclasses.contains(subclass)
    }

    private func alternativeNote(forClass classId: String, excluding primary: Medication) -> [String] {
        let alternatives = repository
            .medications(forClass: classId, scenario: .chronicHFrEF)
            .filter { $0.id != primary.id }
        guard !alternatives.isEmpty else { return [] }
        let names = alternatives.map { "\($0.genericName) (\($0.subclass)): \($0.startingDose) → \($0.targetDose)" }
        return [messages.hfrefAlternativesPrefix + names.joined(separator: "; ") + "."]
    }

    private func orderedUniqueAlerts(_ alerts: [SafetyAlert]) -> [SafetyAlert] {
        var seen: Set<String> = []
        return alerts.filter { seen.insert($0.id).inserted }
    }

    private func orderedUniqueReferences(_ refs: [Reference]) -> [Reference] {
        var seen: Set<String> = []
        return refs.filter { seen.insert($0.id).inserted }
    }
}
