import XCTest
@testable import ICFlowCore

/// Critical clinical-rule tests for the acute / decompensated congestion flow.
final class AcuteCongestionTests: XCTestCase {

    private var engine: DecisionEngine { TestSupport.engine }

    private func input(
        sbp: Double? = 120,
        hr: Double? = 90,
        egfr: Double? = 60,
        potassium: Double? = 4.2,
        congestion: Bool = true,
        hypoperfusion: Bool = false,
        priorDiuretic: Bool = false,
        agentId: String? = nil,
        oralDose: Double? = nil
    ) -> PatientInput {
        PatientInput(
            scenario: .acuteCongestion, systolicBP: sbp, heartRate: hr,
            egfr: egfr, potassium: potassium, congestion: congestion,
            hypoperfusion: hypoperfusion, priorDiureticUse: priorDiuretic,
            currentLoopAgentId: agentId, currentLoopOralDailyDoseMg: oralDose
        )
    }

    func testWarmAndWetRecommendsIVDiuretic() {
        let result = engine.evaluate(input())
        XCTAssertEqual(result.congestionProfile, .wetWarm)
        XCTAssertNotNil(result.recommendation(id: "iv_diuretic"))
        XCTAssertNotNil(result.diureticPlan)
    }

    func testColdAndWetEscalatesToSpecialist() {
        let result = engine.evaluate(input(hypoperfusion: true))
        XCTAssertEqual(result.congestionProfile, .wetCold)
        XCTAssertNotNil(result.recommendation(id: "specialist_eval"))
        XCTAssertNil(result.diureticPlan, "Não deve sugerir diurético padrão com hipoperfusão")
        XCTAssertTrue(result.alertIds.contains("acute_hypotension"))
    }

    func testHypotensionEscalatesEvenWhenWarm() {
        let result = engine.evaluate(input(sbp: 85))
        XCTAssertNotNil(result.recommendation(id: "specialist_eval"))
        XCTAssertNil(result.diureticPlan)
        XCTAssertTrue(result.alertIds.contains("acute_hypotension"))
    }

    func testNoCongestionDoesNotRecommendDiuretic() {
        let result = engine.evaluate(input(congestion: false))
        XCTAssertEqual(result.congestionProfile, .dryWarm)
        XCTAssertNotNil(result.recommendation(id: "no_diuretic"))
        XCTAssertNil(result.diureticPlan)
    }

    func testSevereHyperkalemiaRaisesCriticalAlert() {
        let result = engine.evaluate(input(potassium: 6.5))
        XCTAssertTrue(result.alertIds.contains("acute_hyperkalemia"))
        XCTAssertTrue(result.safetyAlerts.contains { $0.id == "acute_hyperkalemia" && $0.severity == .critical })
    }

    func testLowEGFRRaisesRenalRedFlag() {
        let result = engine.evaluate(input(egfr: 25))
        XCTAssertTrue(result.alertIds.contains("acute_renal"))
    }

    func testMonitoringParametersIncludeElectrolytes() {
        let result = engine.evaluate(input())
        let rec = result.recommendation(id: "iv_diuretic")
        let monitoring = rec?.monitoring.joined(separator: " ") ?? ""
        XCTAssertTrue(monitoring.contains("Potássio"))
        XCTAssertTrue(monitoring.contains("Magnésio"))
        XCTAssertTrue(monitoring.contains("Sódio"))
    }
}
