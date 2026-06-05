import Foundation
import Combine
import ICFlowCore

/// A locally-saved case — **anonymous by design**. It holds only the
/// de-identified clinical input plus an optional, user-chosen label (which the
/// UI explicitly asks to keep non-identifying). No name/ID/record number.
struct SavedCase: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var label: String
    var scenario: Scenario
    var input: ClinicalInput

    init(id: UUID = UUID(), date: Date = Date(), label: String, scenario: Scenario, input: ClinicalInput) {
        self.id = id
        self.date = date
        self.label = label
        self.scenario = scenario
        self.input = input
    }
}

/// Persists saved cases **on the device only** (no cloud, no login). The file is
/// written with complete file protection (encrypted at rest while the device is
/// locked). Nothing leaves the device.
final class CaseHistoryStore: ObservableObject {
    @Published private(set) var cases: [SavedCase] = []

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.fileURL = dir.appendingPathComponent("case_history.json")
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    func add(label: String, scenario: Scenario, input: ClinicalInput) {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        cases.insert(SavedCase(label: trimmed, scenario: scenario, input: input), at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        cases.remove(atOffsets: offsets)
        save()
    }

    func deleteAll() {
        cases.removeAll()
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        cases = (try? decoder.decode([SavedCase].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? encoder.encode(cases) else { return }
        try? data.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }
}

extension InputDraft {
    /// Rebuilds an editable draft from a saved (de-identified) clinical input.
    init(from input: ClinicalInput) {
        self.init()
        func s(_ d: Double?) -> String {
            guard let d else { return "" }
            return d == d.rounded() ? String(Int(d)) : String(d)
        }
        lvef = s(input.lvef)
        nyha = input.nyha
        systolicBP = s(input.systolicBP)
        heartRate = s(input.heartRate)
        rhythm = input.rhythm
        egfr = s(input.egfr)
        potassium = s(input.potassium)
        creatinine = s(input.creatinine)
        congestion = input.congestion
        hypoperfusion = input.hypoperfusion
        priorDiureticUse = input.priorDiureticUse
        currentLoopAgentId = input.currentLoopAgentId
        currentLoopOralDose = s(input.currentLoopOralDailyDoseMg)
        historyOfAngioedema = input.historyOfAngioedema
        age = s(input.age)
        symptomsSignsHF = input.symptomsSignsHF
        obesity = input.obesity
        hypertension = input.hypertension
        antihypertensives2plus = input.antihypertensives2plus
        atrialFibrillation = input.atrialFibrillation
        diabetes = input.diabetes
        ckd = input.ckd
        coronaryDisease = input.coronaryDisease
        sleepApnea = input.sleepApnea
        suspectedInfiltrative = input.suspectedInfiltrative
        valvularDisease = input.valvularDisease
        pulmonaryDisease = input.pulmonaryDisease
        anemia = input.anemia
        nonCardiacEdema = input.nonCardiacEdema
        paspOver35 = input.paspOver35
        eOverEprimeOver9 = input.eOverEprimeOver9
        lactate = s(input.lactate)
        oliguria = input.oliguria
        alteredMentation = input.alteredMentation
    }
}
