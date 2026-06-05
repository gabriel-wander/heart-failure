import XCTest
@testable import ICFlowCore

/// Critical clinical-rule tests for the chronic HFrEF flow.
final class HFrEFEvaluatorTests: XCTestCase {

    private var engine: DecisionEngine { TestSupport.engine }

    private func input(
        lvef: Double? = 30,
        nyha: NYHAClass? = .ii,
        sbp: Double? = 120,
        hr: Double? = 70,
        rhythm: Rhythm = .sinus,
        egfr: Double? = 60,
        potassium: Double? = 4.2,
        creatinine: Double? = 1.0,
        congestion: Bool = false,
        hypoperfusion: Bool = false
    ) -> PatientInput {
        PatientInput(
            scenario: .chronicHFrEF, lvef: lvef, nyha: nyha, systolicBP: sbp,
            heartRate: hr, rhythm: rhythm, egfr: egfr, potassium: potassium,
            creatinine: creatinine, congestion: congestion, hypoperfusion: hypoperfusion
        )
    }

    func testStablePatientAllFourPillarsEligible() {
        let result = engine.evaluate(input())
        XCTAssertEqual(result.recommendations.count, 4)
        XCTAssertEqual(result.status(forClass: "renin_angiotensin"), .eligible)
        XCTAssertEqual(result.status(forClass: "beta_blocker"), .eligible)
        XCTAssertEqual(result.status(forClass: "mra"), .eligible)
        XCTAssertEqual(result.status(forClass: "sglt2"), .eligible)
    }

    func testSevereHyperkalemiaContraindicatesRASandMRA() {
        let result = engine.evaluate(input(potassium: 5.8))
        XCTAssertEqual(result.status(forClass: "renin_angiotensin"), .contraindicated)
        XCTAssertEqual(result.status(forClass: "mra"), .contraindicated)
    }

    func testBorderlineHyperkalemiaIsCaution() {
        let result = engine.evaluate(input(potassium: 5.1))
        XCTAssertEqual(result.status(forClass: "renin_angiotensin"), .caution)
        XCTAssertEqual(result.status(forClass: "mra"), .caution)
    }

    func testLowEGFRContraindicatesMRA() {
        let result = engine.evaluate(input(egfr: 25))
        XCTAssertEqual(result.status(forClass: "mra"), .contraindicated)
    }

    func testSevereHypotensionContraindicatesRAS() {
        let result = engine.evaluate(input(sbp: 85))
        XCTAssertEqual(result.status(forClass: "renin_angiotensin"), .contraindicated)
        XCTAssertEqual(result.status(forClass: "beta_blocker"), .caution)
        XCTAssertEqual(result.status(forClass: "sglt2"), .caution)
    }

    func testBradycardiaContraindicatesBetaBlocker() {
        let result = engine.evaluate(input(hr: 48))
        XCTAssertEqual(result.status(forClass: "beta_blocker"), .contraindicated)
    }

    func testDecompensationMakesBetaBlockerCaution() {
        let result = engine.evaluate(input(congestion: true))
        XCTAssertEqual(result.status(forClass: "beta_blocker"), .caution)
        // Outros pilares geralmente permanecem elegíveis.
        XCTAssertEqual(result.status(forClass: "sglt2"), .eligible)
    }

    func testSGLT2RemainsEligibleAtModeratelyReducedEGFR() {
        // dapagliflozina pode ser iniciada em faixas baixas de TFGe (>= 25).
        let result = engine.evaluate(input(egfr: 30))
        XCTAssertEqual(result.status(forClass: "sglt2"), .eligible)
    }

    func testContraindicationCarriesJustificationAndAlert() {
        let result = engine.evaluate(input(potassium: 5.8))
        let mra = result.recommendation(id: "mra")
        XCTAssertNotNil(mra)
        XCTAssertFalse(mra!.justifications.isEmpty, "Contraindicação deve ter justificativa")
        XCTAssertTrue(mra!.safetyAlerts.contains { $0.id == "mra_hyperkalemia" })
        XCTAssertTrue(mra!.status == .contraindicated)
    }

    func testRecommendationsExposeMockDoses() {
        let result = engine.evaluate(input())
        let ras = result.recommendation(id: "renin_angiotensin")
        XCTAssertNotNil(ras?.startingDose)
        XCTAssertNotNil(ras?.targetDose)
        XCTAssertFalse(ras?.monitoring.isEmpty ?? true)
    }

    func testHighLVEFAddsScopeNote() {
        let result = engine.evaluate(input(lvef: 55))
        XCTAssertTrue(result.generalNotes.contains { $0.contains("ICFEr") })
    }
}
