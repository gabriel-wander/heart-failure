import Foundation

/// Evaluates the four foundational HFrEF drug classes against the patient input
/// and produces one recommendation per class.
struct HFrEFEvaluator {
    let repository: ContentRepository

    func evaluate(_ input: PatientInput) -> AssessmentResult {
        let ruleSet = repository.ruleSet
        var recommendations: [Recommendation] = []
        var usedAlertIds: Set<String> = []
        var usedReferenceIds: Set<String> = []
        var generalNotes: [String] = []

        if let lvef = input.lvef, lvef > 40 {
            generalNotes.append("FEVE informada (\(lvef.cleanString)%) acima de 40%. Os critérios deste módulo assumem ICFEr (FEVE ≤ 40%).")
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

            let status: EligibilityStatus
            let activeRules: [ClinicalRule]
            if !contraindications.isEmpty {
                status = .contraindicated
                activeRules = contraindications
            } else if !cautions.isEmpty {
                status = .caution
                activeRules = cautions
            } else {
                status = .eligible
                activeRules = []
            }

            // Justifications.
            var justifications = activeRules.map { $0.justification }
            if justifications.isEmpty {
                justifications = ["Sem contraindicações ou cautelas identificadas com os dados fornecidos."]
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
                    notes: alternativeNote(forClass: classId, excluding: primary)
                )
            )
        }

        if input.congestion || input.hypoperfusion {
            generalNotes.append("Sinais de descompensação presentes: priorizar compensação clínica antes de iniciar/uptitular betabloqueador; demais pilares geralmente podem ser iniciados/mantidos conforme tolerância.")
        }
        generalNotes.append("Campos não preenchidos não são avaliados pelas regras; preencha todos os dados para uma avaliação mais completa.")

        let aggregatedAlerts = orderedUniqueAlerts(repository.alerts(withIds: Array(usedAlertIds)))
            .sorted { $0.severity.sortRank < $1.severity.sortRank }
        let aggregatedReferences = orderedUniqueReferences(repository.references(withIds: Array(usedReferenceIds)))

        return AssessmentResult(
            scenario: .chronicHFrEF,
            recommendations: recommendations,
            safetyAlerts: aggregatedAlerts,
            references: aggregatedReferences,
            generalNotes: generalNotes
        )
    }

    // MARK: - Helpers

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
        return ["Alternativas da classe: " + names.joined(separator: "; ") + "."]
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
