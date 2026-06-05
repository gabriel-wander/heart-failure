import Foundation

/// Educational triage for cardiogenic shock / advanced-refractory HF. This is a
/// **safety/escalation** flow — it never proposes a simple diuretic; it flags
/// instability and points to monitored, specialist care.
struct CardiogenicShockEvaluator {
    let repository: ContentRepository

    private var messages: EngineMessages { repository.messages }

    func evaluate(_ input: ClinicalInput) -> AssessmentResult {
        // Red flags for low output / shock.
        let lowBP = (input.systolicBP.map { $0 < 90 } ?? false)
        let redFlags = lowBP
            || input.hypoperfusion
            || input.oliguria
            || input.alteredMentation
            || (input.lactate.map { $0 > 2.0 } ?? false)

        var alerts: [SafetyAlert] = []
        var notes: [String] = []
        let references = repository.references(withIds: ["felker2020", "greene2023"])

        let status: RecommendationStatus
        let justifications: [String]
        if redFlags {
            status = .urgentReferral
            justifications = [messages.shockJustification]
            alerts = repository.alerts(withIds: ["shock_redflags"])
        } else {
            status = .caution
            justifications = [messages.shockStableNote]
        }

        let recommendation = Recommendation(
            id: "shock_triage",
            title: messages.shockTitle,
            classId: nil,
            displayDrug: nil,
            status: status,
            group: .referral,
            justifications: justifications,
            monitoring: [],
            safetyAlerts: alerts,
            references: references,
            notes: messages.shockSteps
        )

        notes.append(messages.shockGeneralNote)

        // Essential context for this triage.
        var missing: [ClinicalField] = []
        if input.systolicBP == nil { missing.append(.systolicBP) }

        return AssessmentResult(
            scenario: .cardiogenicShock,
            recommendations: [recommendation],
            safetyAlerts: alerts,
            references: references,
            missingEssentialData: missing,
            generalNotes: notes
        )
    }
}
