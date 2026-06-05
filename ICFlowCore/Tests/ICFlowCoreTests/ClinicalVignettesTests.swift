import XCTest
@testable import ICFlowCore

/// Fictional, de-identified clinical vignettes used for content validation
/// (see VALIDATION_PLAN.md / VIGNETTES.md). Each test encodes the expected key
/// output for a reviewer-defined case. These assert the **current** engine
/// behavior; a cardiologist reviewer confirms whether each expectation is
/// clinically correct before the content is marked validated.
final class ClinicalVignettesTests: XCTestCase {

    private var engine: DecisionEngine { TestSupport.engine }

    // V1 — Stable HFrEF: all four pillars should be candidates to consider.
    func testV1_StableHFrEF() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .chronicHFrEF, lvef: 30, nyha: .ii, systolicBP: 120,
            heartRate: 75, rhythm: .sinus, egfr: 65, potassium: 4.2, creatinine: 1.0
        ))
        XCTAssertEqual(r.status(forClass: "renin_angiotensin"), .consider)
        XCTAssertEqual(r.status(forClass: "beta_blocker"), .consider)
        XCTAssertEqual(r.status(forClass: "mra"), .consider)
        XCTAssertEqual(r.status(forClass: "sglt2"), .consider)
        XCTAssertTrue(r.missingEssentialData.isEmpty)
    }

    // V2 — Severe hyperkalemia (K 5.9): RAS and MRA contraindicated.
    func testV2_SevereHyperkalemia() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .chronicHFrEF, lvef: 30, systolicBP: 120, heartRate: 70,
            rhythm: .sinus, egfr: 60, potassium: 5.9
        ))
        XCTAssertEqual(r.status(forClass: "renin_angiotensin"), .contraindicated)
        XCTAssertEqual(r.status(forClass: "mra"), .contraindicated)
    }

    // V3 — eGFR 25: MRA contraindicated.
    func testV3_LowEGFR() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .chronicHFrEF, lvef: 30, systolicBP: 120, heartRate: 70,
            rhythm: .sinus, egfr: 25, potassium: 4.5
        ))
        XCTAssertEqual(r.status(forClass: "mra"), .contraindicated)
    }

    // V4 — Hypotension (SBP 85): RAS contraindicated.
    func testV4_Hypotension() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .chronicHFrEF, lvef: 30, systolicBP: 85, heartRate: 80,
            rhythm: .sinus, egfr: 60, potassium: 4.2
        ))
        XCTAssertEqual(r.status(forClass: "renin_angiotensin"), .contraindicated)
    }

    // V5 — Bradycardia (HR 48): beta-blocker contraindicated.
    func testV5_Bradycardia() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .chronicHFrEF, lvef: 30, systolicBP: 120, heartRate: 48,
            rhythm: .sinus, egfr: 60, potassium: 4.2
        ))
        XCTAssertEqual(r.status(forClass: "beta_blocker"), .contraindicated)
    }

    // V6 — Angioedema history: RAS contraindicated.
    func testV6_Angioedema() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .chronicHFrEF, lvef: 30, systolicBP: 120, heartRate: 70,
            rhythm: .sinus, egfr: 60, potassium: 4.2, historyOfAngioedema: true
        ))
        XCTAssertEqual(r.status(forClass: "renin_angiotensin"), .contraindicated)
    }

    // V7 — Atrial fibrillation: HF+AF overlay present; ivabradine not suggested.
    func testV7_AtrialFibrillation() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .chronicHFrEF, lvef: 30, systolicBP: 120, heartRate: 95,
            rhythm: .afib, egfr: 60, potassium: 4.2
        ))
        XCTAssertNotNil(r.recommendation(id: "hf_af"))
        XCTAssertNil(r.recommendation(id: "add_ivabradine"))
    }

    // V8 — Acute warm & wet, loop-naive: IV diuretic plan suggested.
    func testV8_AcuteWarmWetLoopNaive() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .acuteCongestion, systolicBP: 120, heartRate: 90,
            egfr: 60, potassium: 4.2, congestion: true
        ))
        XCTAssertEqual(r.congestionProfile, .wetWarm)
        XCTAssertEqual(r.recommendation(id: "iv_diuretic")?.status, .consider)
        XCTAssertNotNil(r.diureticPlan)
    }

    // V9 — Acute with hypoperfusion: urgent referral, no diuretic plan.
    func testV9_AcuteHypoperfusion() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .acuteCongestion, systolicBP: 110, egfr: 50, potassium: 4.5,
            congestion: true, hypoperfusion: true
        ))
        XCTAssertEqual(r.recommendation(id: "specialist_eval")?.status, .urgentReferral)
        XCTAssertNil(r.diureticPlan)
    }

    // V10 — Prior diuretic marked without dose: no estimate, insufficient data.
    func testV10_PriorDiureticWithoutDose() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .acuteCongestion, systolicBP: 120, egfr: 60, potassium: 4.2,
            congestion: true, priorDiureticUse: true
        ))
        XCTAssertNil(r.diureticPlan)
        XCTAssertEqual(r.recommendation(id: "iv_diuretic")?.status, .insufficientData)
    }

    // V11 — HFpEF with high H2FPEF.
    func testV11_HFpEFHighScore() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .hfpefHFmrEF, lvef: 55, age: 72, atrialFibrillation: true,
            symptomsSignsHF: true, obesity: true, hypertension: true,
            antihypertensives2plus: true, paspOver35: true, eOverEprimeOver9: true
        ))
        XCTAssertEqual(r.h2fpef?.category, .high)
        XCTAssertNotNil(r.recommendation(id: "hfpef_classification"))
    }

    // V12 — Cardiogenic shock red flags: urgent referral + critical alert.
    func testV12_CardiogenicShock() {
        let r = engine.evaluate(ClinicalInput(
            scenario: .cardiogenicShock, systolicBP: 80, hypoperfusion: true, lactate: 4.0
        ))
        XCTAssertEqual(r.recommendation(id: "shock_triage")?.status, .urgentReferral)
        XCTAssertTrue(r.safetyAlerts.contains { $0.id == "shock_redflags" && $0.severity == .critical })
    }
}
