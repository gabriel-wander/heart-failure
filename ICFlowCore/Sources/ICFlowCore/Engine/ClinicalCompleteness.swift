import Foundation

/// Determines, per scenario, which **essential** clinical inputs are missing and
/// therefore limit the safety of a recommendation. Missing data is never ignored
/// silently — the engine surfaces it so the physician can complete the picture.
public enum ClinicalCompleteness {

    /// Essential fields that, when absent, limit the overall recommendation.
    public static func missingEssential(for input: PatientInput) -> [ClinicalField] {
        switch input.scenario {
        case .chronicHFrEF:
            var missing: [ClinicalField] = []
            if input.lvef == nil { missing.append(.lvef) }
            if input.systolicBP == nil { missing.append(.systolicBP) }
            if input.heartRate == nil { missing.append(.heartRate) }
            if input.egfr == nil { missing.append(.egfr) }
            if input.potassium == nil { missing.append(.potassium) }
            return missing

        case .acuteCongestion:
            var missing: [ClinicalField] = []
            if input.systolicBP == nil { missing.append(.systolicBP) }
            if input.egfr == nil && input.creatinine == nil { missing.append(.egfr) }
            if input.potassium == nil { missing.append(.potassium) }
            return missing
        }
    }

    /// Fields required to determine eligibility for the renin–angiotensin and MRA
    /// classes (blood pressure, potassium, renal function). When any is missing the
    /// engine must not assert a class-specific recommendation.
    public static func missingForRASandMRA(_ input: PatientInput) -> [ClinicalField] {
        var missing: [ClinicalField] = []
        if input.systolicBP == nil { missing.append(.systolicBP) }
        if input.potassium == nil { missing.append(.potassium) }
        if input.egfr == nil { missing.append(.egfr) }
        return missing
    }

    /// Fields required to reason about beta-blocker / rate-control eligibility.
    public static func missingForBetaBlocker(_ input: PatientInput) -> [ClinicalField] {
        var missing: [ClinicalField] = []
        if input.heartRate == nil { missing.append(.heartRate) }
        return missing
    }

    /// Whether the IV diuretic dose can be estimated for a prior diuretic user:
    /// requires both the agent and a positive home daily dose.
    public static func canEstimateDiuretic(_ input: PatientInput) -> Bool {
        guard input.priorDiureticUse else { return true } // loop-naive path is fine
        let hasAgent = (input.currentLoopAgentId?.isEmpty == false)
        let hasDose = (input.currentLoopOralDailyDoseMg ?? 0) > 0
        return hasAgent && hasDose
    }
}
