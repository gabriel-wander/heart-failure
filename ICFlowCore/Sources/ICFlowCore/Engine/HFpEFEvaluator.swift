import Foundation

/// Educational evaluator for the HFpEF / HFmrEF flow: classifies by ejection
/// fraction, computes the H2FPEF probability score, and surfaces guidance on
/// diagnosis (exclusion of mimics), SGLT2 inhibition, congestion control,
/// comorbidity management and specialist referral. All text is localized.
struct HFpEFEvaluator {
    let repository: ContentRepository

    private var messages: EngineMessages { repository.messages }

    func evaluate(_ input: ClinicalInput) -> AssessmentResult {
        var recommendations: [Recommendation] = []
        var usedAlertIds: Set<String> = []
        var usedReferenceIds: Set<String> = []
        var generalNotes: [String] = []
        var missing: [ClinicalField] = []

        usedReferenceIds.insert("greene2023")
        let baseRefs = repository.references(withIds: ["greene2023"])

        // 1) Classification by LVEF.
        let classText: String
        let classStatus: RecommendationStatus
        var classAlerts: [SafetyAlert] = []
        if let lvef = input.lvef {
            if lvef >= 50 {
                classText = messages.hfpefClassPreserved
                classStatus = .consider
                classAlerts = repository.alerts(withIds: ["hfpef_mimics"])
                classAlerts.forEach { usedAlertIds.insert($0.id) }
            } else if lvef >= 41 {
                classText = messages.hfpefClassMidrange
                classStatus = .consider
            } else {
                classText = messages.hfpefClassReduced
                classStatus = .consider
            }
        } else {
            classText = messages.hfpefClassPreserved
            classStatus = .insufficientData
            missing.append(.lvef)
        }

        recommendations.append(
            Recommendation(
                id: "hfpef_classification",
                title: messages.hfpefClassificationTitle,
                classId: nil,
                displayDrug: nil,
                status: classStatus,
                group: .general,
                justifications: [classText],
                safetyAlerts: classAlerts,
                references: baseRefs,
                missingData: input.lvef == nil ? [.lvef] : []
            )
        )

        // 2) H2FPEF probability score (incomplete unless the objective items exist).
        let score = H2FPEFCalculator.score(for: input)

        // 3) SGLT2 inhibitor (benefit across the EF spectrum).
        let sglt2 = repository.primaryMedication(forClass: "sglt2", scenario: .chronicHFrEF)
        recommendations.append(
            Recommendation(
                id: "hfpef_sglt2",
                title: messages.hfpefSGLT2Title,
                classId: "sglt2",
                displayDrug: sglt2?.genericName,
                status: .consider,
                group: .prognosis,
                justifications: [messages.hfpefSGLT2Justification],
                startingDose: sglt2?.startingDose,
                targetDose: sglt2?.targetDose,
                monitoring: sglt2?.monitoring ?? [],
                references: baseRefs
            )
        )

        // 4) Congestion control.
        if input.congestion {
            generalNotes.append(messages.hfpefCongestionNote)
        }

        // 5) Comorbidity management.
        recommendations.append(
            Recommendation(
                id: "hfpef_comorbidities",
                title: messages.hfpefComorbiditiesTitle,
                status: .consider,
                group: .additional,
                justifications: [messages.hfpefComorbiditiesJustification],
                references: baseRefs
            )
        )

        // 6) Specialist referral when red flags are present.
        let needsReferral = input.suspectedInfiltrative
            || input.valvularDisease
            || input.pulmonaryDisease
            || (input.paspOver35 == true)
        if needsReferral {
            recommendations.append(
                Recommendation(
                    id: "hfpef_referral",
                    title: messages.hfpefReferralTitle,
                    status: .urgentReferral,
                    group: .referral,
                    justifications: [messages.hfpefReferralJustification],
                    references: baseRefs
                )
            )
        }

        generalNotes.append(messages.hfpefGeneralNote)

        let alerts = repository.alerts(withIds: Array(usedAlertIds))
            .sorted { $0.severity.sortRank < $1.severity.sortRank }
        let references = repository.references(withIds: Array(usedReferenceIds))

        return AssessmentResult(
            scenario: .hfpefHFmrEF,
            recommendations: recommendations,
            safetyAlerts: alerts,
            references: references,
            h2fpef: score,
            missingEssentialData: missing,
            generalNotes: generalNotes
        )
    }
}
