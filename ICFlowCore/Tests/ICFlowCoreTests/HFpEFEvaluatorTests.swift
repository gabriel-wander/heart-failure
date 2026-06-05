import XCTest
@testable import ICFlowCore

/// Tests for the HFpEF / HFmrEF flow and the H2FPEF score.
final class HFpEFEvaluatorTests: XCTestCase {

    private var engine: DecisionEngine { TestSupport.engine }

    private func input(
        lvef: Double? = 55,
        congestion: Bool = false,
        age: Double? = nil,
        obesity: Bool = false,
        hypertension: Bool = false,
        antihypertensives2plus: Bool = false,
        atrialFibrillation: Bool = false,
        suspectedInfiltrative: Bool = false,
        valvularDisease: Bool = false,
        pulmonaryDisease: Bool = false,
        paspOver35: Bool? = nil,
        eOverEprimeOver9: Bool? = nil
    ) -> ClinicalInput {
        ClinicalInput(
            scenario: .hfpefHFmrEF,
            lvef: lvef,
            congestion: congestion,
            age: age,
            atrialFibrillation: atrialFibrillation,
            obesity: obesity,
            hypertension: hypertension,
            antihypertensives2plus: antihypertensives2plus,
            suspectedInfiltrative: suspectedInfiltrative,
            valvularDisease: valvularDisease,
            pulmonaryDisease: pulmonaryDisease,
            paspOver35: paspOver35,
            eOverEprimeOver9: eOverEprimeOver9
        )
    }

    func testPreservedEFSuggestsHFpEFAndMimicsAlert() {
        let result = engine.evaluate(input(lvef: 55))
        let classification = result.recommendation(id: "hfpef_classification")
        XCTAssertNotNil(classification)
        XCTAssertTrue(classification?.justifications.first?.contains("ICFEp") ?? false)
        XCTAssertTrue(classification?.safetyAlerts.contains { $0.id == "hfpef_mimics" } ?? false,
                      "ICFEp deve alertar para exclusão de mimetizadores")
    }

    func testMidrangeEFClassifiedAsHFmrEF() {
        let result = engine.evaluate(input(lvef: 45))
        let classification = result.recommendation(id: "hfpef_classification")
        XCTAssertTrue(classification?.justifications.first?.contains("ICFEm") ?? false)
    }

    func testH2FPEFHighProbabilityWhenComplete() {
        let result = engine.evaluate(input(
            age: 72, obesity: true, antihypertensives2plus: true,
            atrialFibrillation: true, paspOver35: true, eOverEprimeOver9: true
        ))
        let score = result.h2fpef
        XCTAssertNotNil(score)
        XCTAssertTrue(score?.isComplete ?? false)
        XCTAssertEqual(score?.points, 9)
        XCTAssertEqual(score?.category, .high)
    }

    func testH2FPEFIncompleteWhenEchoMissing() {
        let result = engine.evaluate(input(age: 70, obesity: true, paspOver35: nil))
        XCTAssertEqual(result.h2fpef?.category, .incomplete)
        XCTAssertEqual(result.h2fpef?.isComplete, false)
    }

    func testSuspectedInfiltrativeTriggersReferral() {
        let result = engine.evaluate(input(suspectedInfiltrative: true))
        let referral = result.recommendation(id: "hfpef_referral")
        XCTAssertNotNil(referral)
        XCTAssertEqual(referral?.status, .urgentReferral)
    }

    func testSGLT2IsConsidered() {
        let result = engine.evaluate(input())
        XCTAssertEqual(result.recommendation(id: "hfpef_sglt2")?.status, .consider)
    }

    func testMissingLVEFMakesClassificationInsufficient() {
        let result = engine.evaluate(input(lvef: nil))
        XCTAssertEqual(result.recommendation(id: "hfpef_classification")?.status, .insufficientData)
        XCTAssertTrue(result.missingEssentialData.contains(.lvef))
    }
}
