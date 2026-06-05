import Foundation

/// Result of the simplified H2FPEF score for the probability of HFpEF.
public struct H2FPEFResult: Equatable, Sendable {
    public enum Category: String, Sendable {
        case low
        case intermediate
        case high
        /// Not enough objective data to compute a probability.
        case incomplete
    }

    public let points: Int
    public let isComplete: Bool
    public let category: Category

    public init(points: Int, isComplete: Bool, category: Category) {
        self.points = points
        self.isComplete = isComplete
        self.category = category
    }
}

/// Computes a simplified H2FPEF score (educational).
///
/// Weights: obesity/BMI>30 = 2, ≥2 antihypertensives = 1, atrial fibrillation = 3,
/// estimated PASP > 35 mmHg = 1, age > 60 = 1, E/e' > 9 = 1 (range 0–9).
///
/// The score is only reported as a probability when the objective components
/// (age and the two echo-derived items) are available; otherwise it is
/// `incomplete` — the engine never fabricates a result from missing data.
public enum H2FPEFCalculator {
    public static func score(for input: ClinicalInput) -> H2FPEFResult {
        var points = 0
        if input.obesity { points += 2 }
        if input.antihypertensives2plus { points += 1 }
        if input.atrialFibrillation { points += 3 }
        if input.paspOver35 == true { points += 1 }
        if let age = input.age, age > 60 { points += 1 }
        if input.eOverEprimeOver9 == true { points += 1 }

        let isComplete = input.age != nil
            && input.paspOver35 != nil
            && input.eOverEprimeOver9 != nil

        let category: H2FPEFResult.Category
        if !isComplete {
            category = .incomplete
        } else if points <= 1 {
            category = .low
        } else if points >= 6 {
            category = .high
        } else {
            category = .intermediate
        }

        return H2FPEFResult(points: points, isComplete: isComplete, category: category)
    }
}
