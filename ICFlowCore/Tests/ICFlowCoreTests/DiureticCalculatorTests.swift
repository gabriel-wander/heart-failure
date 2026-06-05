import XCTest
@testable import ICFlowCore

/// Tests for the IV loop-diuretic dose estimate (grounded in Felker et al., 2020).
final class DiureticCalculatorTests: XCTestCase {

    private var calculator: DiureticCalculator {
        let repo = TestSupport.repository
        return DiureticCalculator(
            config: repo.ruleSet.acuteCongestionConfig,
            loopDiuretics: repo.loopDiuretics()
        )
    }

    func testLoopNaiveUsesStandardInitialDose() {
        let plan = calculator.makePlan(priorUse: false, agentId: nil, oralDailyDoseMg: nil)
        XCTAssertEqual(plan.strategy, .loopNaive)
        XCTAssertEqual(plan.totalDailyIVFurosemideMg, 40, accuracy: 0.001)
        XCTAssertFalse(plan.highDoseCaution)
    }

    func testPriorFurosemideUsesTwoPointFiveTimesRule() {
        // 80 mg/dia VO de furosemida -> 2,5x = 200 mg/dia IV, 100 mg 2x/dia.
        let plan = calculator.makePlan(priorUse: true, agentId: "furosemide", oralDailyDoseMg: 80)
        XCTAssertEqual(plan.strategy, .priorOralUser)
        XCTAssertEqual(plan.oralFurosemideEquivalentMg ?? 0, 80, accuracy: 0.001)
        XCTAssertEqual(plan.totalDailyIVFurosemideMg, 200, accuracy: 0.001)
        XCTAssertEqual(plan.perDoseMg, 100, accuracy: 0.001)
        XCTAssertEqual(plan.dosesPerDay, 2)
        XCTAssertFalse(plan.highDoseCaution)
    }

    func testBumetanideConvertsToFurosemideEquivalent() {
        // Bumetanida 2 mg/dia ~ furosemida 80 mg/dia -> 200 mg/dia IV.
        let plan = calculator.makePlan(priorUse: true, agentId: "bumetanide", oralDailyDoseMg: 2)
        XCTAssertEqual(plan.oralFurosemideEquivalentMg ?? 0, 80, accuracy: 0.001)
        XCTAssertEqual(plan.totalDailyIVFurosemideMg, 200, accuracy: 0.001)
    }

    func testTorsemideConvertsToFurosemideEquivalent() {
        // Torsemida 40 mg/dia ~ furosemida 80 mg/dia -> 200 mg/dia IV.
        let plan = calculator.makePlan(priorUse: true, agentId: "torsemide", oralDailyDoseMg: 40)
        XCTAssertEqual(plan.oralFurosemideEquivalentMg ?? 0, 80, accuracy: 0.001)
        XCTAssertEqual(plan.totalDailyIVFurosemideMg, 200, accuracy: 0.001)
    }

    func testVeryHighOralDoseFlagsCaution() {
        // 500 mg/dia VO -> 1250 mg/dia IV (> 1000) deve sinalizar cautela.
        let plan = calculator.makePlan(priorUse: true, agentId: "furosemide", oralDailyDoseMg: 500)
        XCTAssertTrue(plan.highDoseCaution)
        XCTAssertEqual(plan.dosesPerDay, 2)
        XCTAssertGreaterThan(plan.perDoseMg, 600)
    }

    func testPriorUseWithoutDoseFallsBackToLoopNaive() {
        let plan = calculator.makePlan(priorUse: true, agentId: nil, oralDailyDoseMg: nil)
        XCTAssertEqual(plan.strategy, .loopNaive)
    }
}
