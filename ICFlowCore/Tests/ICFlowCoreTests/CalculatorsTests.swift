import XCTest
@testable import ICFlowCore

final class CalculatorsTests: XCTestCase {

    func testCHA2DS2VAScKnownCases() {
        // 80yo woman with HTN and diabetes: A2(2)+H(1)+D(1)+Sc(1) = 5
        XCTAssertEqual(
            Calculators.cha2ds2vasc(heartFailure: false, hypertension: true, age: 80,
                                    diabetes: true, strokeOrTIA: false, vascularDisease: false, female: true),
            5
        )
        // 60yo man, no risk factors: 0
        XCTAssertEqual(
            Calculators.cha2ds2vasc(heartFailure: false, hypertension: false, age: 60,
                                    diabetes: false, strokeOrTIA: false, vascularDisease: false, female: false),
            0
        )
        // 70yo (1) with prior stroke (2) and HF (1): 4
        XCTAssertEqual(
            Calculators.cha2ds2vasc(heartFailure: true, hypertension: false, age: 70,
                                    diabetes: false, strokeOrTIA: true, vascularDisease: false, female: false),
            4
        )
    }

    func testCKDEPI2021() {
        // 70yo man, creatinine 1.0 mg/dL → ~81 mL/min/1.73m²
        let male = Calculators.ckdEpiEGFR(creatinineMgDl: 1.0, age: 70, female: false)
        XCTAssertNotNil(male)
        XCTAssertEqual(male!, 81, accuracy: 2.0)
        // 70yo woman, creatinine 1.0 → lower than the man
        let female = Calculators.ckdEpiEGFR(creatinineMgDl: 1.0, age: 70, female: true)!
        XCTAssertLessThan(female, male!)
        // Invalid input
        XCTAssertNil(Calculators.ckdEpiEGFR(creatinineMgDl: 0, age: 70, female: false))
    }

    func testGanzoniIronDeficit() {
        // 70 kg, Hb 9 → target 15: 70*(6)*2.4 + 500 = 1008 + 500 = 1508 mg
        XCTAssertEqual(Calculators.ganzoniIronDeficitMg(weightKg: 70, currentHb: 9, targetHb: 15)!,
                       1508, accuracy: 0.5)
        // Light patient uses 15 mg/kg stores: 20 kg, Hb 10, target 13:
        // 20*3*2.4 + 15*20 = 144 + 300 = 444
        XCTAssertEqual(Calculators.ganzoniIronDeficitMg(weightKg: 20, currentHb: 10, targetHb: 13)!,
                       444, accuracy: 0.5)
        // target <= current → nil
        XCTAssertNil(Calculators.ganzoniIronDeficitMg(weightKg: 70, currentHb: 16, targetHb: 15))
    }

    func testCorrectedSodium() {
        // Na 130, glucose 600 → 130 + 1.6*5 = 138
        XCTAssertEqual(Calculators.correctedSodium(measuredNa: 130, glucoseMgDl: 600), 138, accuracy: 0.001)
        // Normoglycemia → unchanged
        XCTAssertEqual(Calculators.correctedSodium(measuredNa: 140, glucoseMgDl: 100), 140, accuracy: 0.001)
    }
}
