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
        var classStatuses: [String: RecommendationStatus] = [:]

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
            classStatuses[classId] = status

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
                    group: .prognosis,
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

        // Additional, profile-based therapies (non-pillars): ivabradine,
        // hydralazine+nitrate, vericiguat, digoxin, IV iron referral, etc.
        for rule in (ruleSet.hfrefAdditionalRules ?? []) where RuleMatcher.matches(rule, input: input) {
            guard
                let classId = rule.classId,
                let med = repository.primaryMedication(forClass: classId, scenario: .chronicHFrEF)
            else { continue }

            let recStatus = rule.status.map { RecommendationStatus(eligibility: $0) } ?? .consider
            let group: RecommendationGroup = (classId == "iv_iron") ? .referral : .additional
            let recAlerts = repository.alerts(withIds: rule.safetyAlertIds + med.safetyAlertIds)
                .reduce(into: [SafetyAlert]()) { acc, a in if !acc.contains(where: { $0.id == a.id }) { acc.append(a) } }
            let refs = repository.references(withIds: rule.referenceIds + med.referenceIds)
                .reduce(into: [Reference]()) { acc, r in if !acc.contains(where: { $0.id == r.id }) { acc.append(r) } }
            refs.forEach { usedReferenceIds.insert($0.id) }
            recAlerts.forEach { usedAlertIds.insert($0.id) }

            recommendations.append(
                Recommendation(
                    id: "add_\(med.id)",
                    title: rule.title ?? med.genericName,
                    classId: classId,
                    displayDrug: med.genericName,
                    status: recStatus,
                    group: group,
                    justifications: [rule.justification],
                    startingDose: med.startingDose,
                    targetDose: med.targetDose,
                    monitoring: med.monitoring,
                    safetyAlerts: recAlerts,
                    references: refs,
                    notes: []
                )
            )
        }

        // GDMT optimization synthesis + cross-class interaction alerts.
        let order = ruleSet.hfrefClassOrder
        let optimizable = order.filter { classStatuses[$0] == .consider }
        let blocked = order.filter {
            let s = classStatuses[$0]
            return s == .caution || s == .contraindicated || s == .insufficientData
        }
        var gdmtJust: [String] = []
        if !optimizable.isEmpty {
            gdmtJust.append(EngineMessages.fill(messages.gdmtOptimize,
                ["classes": optimizable.map { repository.classLabel($0) }.joined(separator: ", ")]))
        }
        if !blocked.isEmpty {
            gdmtJust.append(EngineMessages.fill(messages.gdmtBlocked,
                ["classes": blocked.map { repository.classLabel($0) }.joined(separator: ", ")]))
        }
        var gdmtAlerts: [SafetyAlert] = []
        if let rasS = classStatuses["renin_angiotensin"], let mraS = classStatuses["mra"],
           rasS != .contraindicated, mraS != .contraindicated {
            gdmtJust.append(messages.gdmtDualRASMRANote)
            gdmtAlerts = orderedUniqueAlerts(repository.alerts(withIds: ["ras_hyperkalemia", "mra_hyperkalemia"]))
            gdmtAlerts.forEach { usedAlertIds.insert($0.id) }
        }
        if gdmtJust.isEmpty { gdmtJust = [messages.gdmtIntro] }
        let gdmtRefs = orderedUniqueReferences(repository.references(withIds: ["greene2023", "patolia2023"]))
        gdmtRefs.forEach { usedReferenceIds.insert($0.id) }
        recommendations.append(
            Recommendation(
                id: "gdmt_optimization",
                title: messages.gdmtTitle,
                classId: nil,
                displayDrug: nil,
                status: .consider,
                group: .general,
                justifications: gdmtJust,
                safetyAlerts: gdmtAlerts,
                references: gdmtRefs,
                notes: []
            )
        )

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
