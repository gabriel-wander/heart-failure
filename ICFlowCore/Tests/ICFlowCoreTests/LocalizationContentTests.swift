import XCTest
@testable import ICFlowCore

/// Verifies the English content set loads, mirrors the Portuguese structure, and
/// produces translated engine output.
final class LocalizationContentTests: XCTestCase {

    func testEnglishContentLoads() throws {
        let en = try ContentRepository.load(language: .en)
        XCTAssertEqual(en.language, .en)
        XCTAssertFalse(en.medications.isEmpty)
        XCTAssertFalse(en.safetyAlerts.isEmpty)
        XCTAssertFalse(en.references.isEmpty)
        XCTAssertFalse(en.ruleSet.hfrefRules.isEmpty)
    }

    func testPortugueseAndEnglishHaveSameStructure() throws {
        let pt = try ContentRepository.load(language: .pt)
        let en = try ContentRepository.load(language: .en)
        XCTAssertEqual(Set(pt.medications.map(\.id)), Set(en.medications.map(\.id)))
        XCTAssertEqual(Set(pt.safetyAlerts.map(\.id)), Set(en.safetyAlerts.map(\.id)))
        XCTAssertEqual(pt.ruleSet.hfrefRules.count, en.ruleSet.hfrefRules.count)
        XCTAssertEqual(pt.ruleSet.acuteCongestionRules.count, en.ruleSet.acuteCongestionRules.count)
        XCTAssertEqual(pt.ruleSet.hfrefClassOrder, en.ruleSet.hfrefClassOrder)
    }

    func testEnglishEngineOutputIsTranslated() throws {
        let en = try ContentRepository.load(language: .en)
        let engine = DecisionEngine(repository: en)
        let input = PatientInput(
            scenario: .chronicHFrEF, lvef: 30, nyha: .ii, systolicBP: 120,
            heartRate: 70, rhythm: .sinus, egfr: 60, potassium: 4.2, creatinine: 1.0
        )
        let result = engine.evaluate(input)
        let eligibleRas = result.recommendations.first { $0.classId == "renin_angiotensin" }
        XCTAssertEqual(eligibleRas?.status, .eligible)
        // English default justification.
        XCTAssertTrue(eligibleRas?.justifications.first?.contains("No contraindications") ?? false)
        // English missing-data note.
        XCTAssertTrue(result.generalNotes.contains { $0.contains("Fields left blank") })
    }

    func testEnglishDiureticPlanIsTranslatedAndUsesPeriodDecimal() throws {
        let en = try ContentRepository.load(language: .en)
        let engine = DecisionEngine(repository: en)
        let input = PatientInput(
            scenario: .acuteCongestion, systolicBP: 120, heartRate: 90, egfr: 60,
            potassium: 4.2, congestion: true, hypoperfusion: false,
            priorDiureticUse: true, currentLoopAgentId: "furosemide",
            currentLoopOralDailyDoseMg: 80
        )
        let result = engine.evaluate(input)
        let plan = result.diureticPlan
        XCTAssertNotNil(plan)
        // 80 -> 200 mg/day IV, unchanged across languages.
        XCTAssertEqual(plan?.totalDailyIVFurosemideMg ?? 0, 200, accuracy: 0.001)
        XCTAssertTrue(plan?.description.contains("IV furosemide") ?? false)
        XCTAssertTrue(plan?.description.contains("2.5×") ?? false, "EN should use a period decimal separator")
    }

    func testNumberFormattingPerLanguage() {
        XCTAssertEqual(AppLanguage.pt.format(2.5), "2,5")
        XCTAssertEqual(AppLanguage.en.format(2.5), "2.5")
        XCTAssertEqual(AppLanguage.pt.format(200), "200")
        XCTAssertEqual(AppLanguage.en.format(200), "200")
    }
}
