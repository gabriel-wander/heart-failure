import Foundation

/// Educational bedside calculators (pure, UI-free, fully testable).
///
/// All results are illustrative and must be interpreted by a qualified
/// physician. No patient identifiers are involved.
public enum Calculators {

    // MARK: - CHA₂DS₂-VASc (atrial fibrillation stroke risk)

    /// CHA₂DS₂-VASc score (0–9).
    /// - C: heart failure/LV dysfunction (1); H: hypertension (1);
    ///   A₂: age ≥75 (2) or 65–74 (1); D: diabetes (1); S₂: stroke/TIA/TE (2);
    ///   V: vascular disease (1); Sc: female sex (1).
    public static func cha2ds2vasc(
        heartFailure: Bool,
        hypertension: Bool,
        age: Double?,
        diabetes: Bool,
        strokeOrTIA: Bool,
        vascularDisease: Bool,
        female: Bool
    ) -> Int {
        var score = 0
        if heartFailure { score += 1 }
        if hypertension { score += 1 }
        if let age {
            if age >= 75 { score += 2 } else if age >= 65 { score += 1 }
        }
        if diabetes { score += 1 }
        if strokeOrTIA { score += 2 }
        if vascularDisease { score += 1 }
        if female { score += 1 }
        return score
    }

    // MARK: - eGFR (CKD-EPI 2021 creatinine, race-free)

    /// Estimated GFR (mL/min/1.73 m²) using the 2021 CKD-EPI creatinine equation.
    /// - Parameters:
    ///   - creatinineMgDl: serum creatinine in mg/dL
    ///   - age: years
    ///   - female: biological sex
    public static func ckdEpiEGFR(creatinineMgDl scr: Double, age: Double, female: Bool) -> Double? {
        guard scr > 0, age > 0 else { return nil }
        let kappa = female ? 0.7 : 0.9
        let alpha = female ? -0.241 : -0.302
        let ratio = scr / kappa
        let minTerm = pow(min(ratio, 1.0), alpha)
        let maxTerm = pow(max(ratio, 1.0), -1.200)
        var egfr = 142.0 * minTerm * maxTerm * pow(0.9938, age)
        if female { egfr *= 1.012 }
        return egfr
    }

    // MARK: - Ganzoni iron deficit

    /// Total iron deficit (mg) by the Ganzoni formula:
    /// `weight × (targetHb − currentHb) × 2.4 + ironStores`,
    /// with iron stores = 500 mg (weight ≥ 35 kg) or 15 mg/kg (weight < 35 kg).
    public static func ganzoniIronDeficitMg(
        weightKg: Double,
        currentHb: Double,
        targetHb: Double = 15.0
    ) -> Double? {
        guard weightKg > 0, currentHb >= 0, targetHb > currentHb else { return nil }
        let ironStores = weightKg >= 35 ? 500.0 : 15.0 * weightKg
        let deficit = weightKg * (targetHb - currentHb) * 2.4 + ironStores
        return max(deficit, 0)
    }

    // MARK: - Sodium corrected for hyperglycemia

    /// Measured sodium corrected for hyperglycemia (Katz factor 1.6):
    /// `Na + 1.6 × ((glucose − 100) / 100)`.
    public static func correctedSodium(measuredNa: Double, glucoseMgDl: Double) -> Double {
        measuredNa + 1.6 * ((glucoseMgDl - 100.0) / 100.0)
    }

    // MARK: - Natriuresis-guided diuretic response

    public enum DiureticResponse: String, Sendable {
        case adequate
        case inadequate
        case incomplete
    }

    /// Educational interpretation of the early diuretic response: a spot urine
    /// sodium ≥ ~70 mmol/L (≈1–2 h post-dose) or urine output ≥ ~150 mL/h
    /// suggests an adequate response; otherwise consider escalation (Mullens/ESC).
    public static func natriuresisResponse(
        urineSodiumMmolL: Double?,
        urineOutputMlPerH: Double?
    ) -> DiureticResponse {
        if urineSodiumMmolL == nil && urineOutputMlPerH == nil { return .incomplete }
        let naAdequate = urineSodiumMmolL.map { $0 >= 70 } ?? false
        let outputAdequate = urineOutputMlPerH.map { $0 >= 150 } ?? false
        return (naAdequate || outputAdequate) ? .adequate : .inadequate
    }
}
