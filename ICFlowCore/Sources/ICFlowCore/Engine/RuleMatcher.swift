import Foundation

/// Evaluates `ClinicalRule` conditions against a `PatientInput`.
///
/// Missing numeric inputs make threshold conditions evaluate to `false` so the
/// engine never raises a false contraindication from absent data.
public enum RuleMatcher {

    /// Returns true when the rule's conditions are satisfied for the given input.
    public static func matches(_ rule: ClinicalRule, input: PatientInput) -> Bool {
        guard !rule.conditions.isEmpty else { return false }
        switch rule.logic {
        case .all:
            return rule.conditions.allSatisfy { evaluate($0, input: input) }
        case .any:
            return rule.conditions.contains { evaluate($0, input: input) }
        }
    }

    static func evaluate(_ condition: RuleCondition, input: PatientInput) -> Bool {
        switch condition.op {
        case .isTrue:
            return input.boolValue(for: condition.field) == true
        case .isFalse:
            return input.boolValue(for: condition.field) == false

        case .equal:
            return matchesEquality(condition, input: input)
        case .notEqual:
            // Only meaningful when the underlying value exists.
            guard hasValue(condition.field, in: input) else { return false }
            return !matchesEquality(condition, input: input)

        case .lessThan, .lessThanOrEqual, .greaterThan, .greaterThanOrEqual:
            guard
                case .number(let threshold)? = condition.value,
                let lhs = input.numericValue(for: condition.field)
            else { return false }
            return compare(lhs, condition.op, threshold)
        }
    }

    private static func compare(_ lhs: Double, _ op: ConditionOperator, _ rhs: Double) -> Bool {
        switch op {
        case .lessThan: return lhs < rhs
        case .lessThanOrEqual: return lhs <= rhs
        case .greaterThan: return lhs > rhs
        case .greaterThanOrEqual: return lhs >= rhs
        default: return false
        }
    }

    private static func matchesEquality(_ condition: RuleCondition, input: PatientInput) -> Bool {
        switch condition.value {
        case .string(let str):
            return input.stringValue(for: condition.field) == str
        case .bool(let flag):
            return input.boolValue(for: condition.field) == flag
        case .number(let num):
            guard let lhs = input.numericValue(for: condition.field) else { return false }
            return lhs == num
        case .none:
            return false
        }
    }

    private static func hasValue(_ field: ConditionField, in input: PatientInput) -> Bool {
        input.numericValue(for: field) != nil
            || input.boolValue(for: field) != nil
            || input.stringValue(for: field) != nil
    }
}
