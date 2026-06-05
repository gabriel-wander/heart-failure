import XCTest
@testable import ICFlowCore

final class CardiogenicShockTests: XCTestCase {

    private var engine: DecisionEngine { TestSupport.engine }

    func testHypotensionTriggersUrgentReferralWithCriticalAlert() {
        let input = ClinicalInput(scenario: .cardiogenicShock, systolicBP: 80, hypoperfusion: true)
        let result = engine.evaluate(input)
        let rec = result.recommendation(id: "shock_triage")
        XCTAssertEqual(rec?.status, .urgentReferral)
        XCTAssertTrue(result.safetyAlerts.contains { $0.id == "shock_redflags" && $0.severity == .critical })
        XCTAssertFalse(rec?.notes.isEmpty ?? true, "Deve listar passos de conduta")
    }

    func testElevatedLactateIsARedFlag() {
        let input = ClinicalInput(scenario: .cardiogenicShock, systolicBP: 110, lactate: 4.0)
        let result = engine.evaluate(input)
        XCTAssertEqual(result.recommendation(id: "shock_triage")?.status, .urgentReferral)
    }

    func testNoRedFlagsIsCaution() {
        let input = ClinicalInput(
            scenario: .cardiogenicShock, systolicBP: 120, hypoperfusion: false,
            lactate: 1.2, oliguria: false, alteredMentation: false
        )
        let result = engine.evaluate(input)
        XCTAssertEqual(result.recommendation(id: "shock_triage")?.status, .caution)
        XCTAssertFalse(result.safetyAlerts.contains { $0.id == "shock_redflags" })
    }

    func testMissingBPReported() {
        let result = engine.evaluate(ClinicalInput(scenario: .cardiogenicShock))
        XCTAssertTrue(result.missingEssentialData.contains(.systolicBP))
    }
}
