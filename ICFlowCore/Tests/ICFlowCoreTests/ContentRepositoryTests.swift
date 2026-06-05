import XCTest
@testable import ICFlowCore

final class ContentRepositoryTests: XCTestCase {

    func testContentLoadsFromBundle() throws {
        let repo = try ContentRepository.load()
        XCTAssertFalse(repo.medications.isEmpty, "Deveria carregar medicamentos do JSON")
        XCTAssertFalse(repo.safetyAlerts.isEmpty, "Deveria carregar alertas de segurança")
        XCTAssertFalse(repo.references.isEmpty, "Deveria carregar referências")
        XCTAssertFalse(repo.ruleSet.hfrefRules.isEmpty, "Deveria carregar regras de ICFEr")
    }

    func testFourFoundationalClassesArePresent() {
        let repo = TestSupport.repository
        for classId in ["renin_angiotensin", "beta_blocker", "mra", "sglt2"] {
            XCTAssertNotNil(
                repo.primaryMedication(forClass: classId, scenario: .chronicHFrEF),
                "Classe \(classId) deveria ter um medicamento principal")
        }
    }

    func testEveryRuleAlertReferenceResolves() {
        let repo = TestSupport.repository
        let allRules = repo.ruleSet.hfrefRules
            + (repo.ruleSet.hfrefAdditionalRules ?? [])
            + repo.ruleSet.acuteCongestionRules
        for rule in allRules {
            for alertId in rule.safetyAlertIds {
                XCTAssertEqual(repo.alerts(withIds: [alertId]).count, 1,
                               "Alerta \(alertId) da regra \(rule.id) não encontrado")
            }
            for refId in rule.referenceIds {
                XCTAssertEqual(repo.references(withIds: [refId]).count, 1,
                               "Referência \(refId) da regra \(rule.id) não encontrada")
            }
        }
    }

    func testLoopDiureticsHaveEquivalenceFactors() {
        let loops = TestSupport.repository.loopDiuretics()
        XCTAssertFalse(loops.isEmpty)
        for loop in loops {
            XCTAssertNotNil(loop.furosemideEquivalentFactor)
        }
    }

    func testClinicalContentIsVersioned() {
        let repo = TestSupport.repository
        XCTAssertNotNil(repo.ruleSet.contentVersion, "Conteúdo clínico deve declarar versão")
        XCTAssertNotNil(repo.ruleSet.lastReviewed, "Conteúdo clínico deve declarar data de revisão")
    }

    func testDischargeChecklistLoads() {
        XCTAssertFalse(TestSupport.repository.dischargeChecklist.isEmpty,
                       "Deveria carregar o checklist de alta do JSON")
    }
}
