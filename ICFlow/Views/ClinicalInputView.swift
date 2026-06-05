import SwiftUI
import ICFlowCore

/// Tela 3 — Entrada de dados clínicos (anônimos). Compartilhada pelos fluxos.
struct ClinicalInputView: View {
    @EnvironmentObject private var app: AppModel
    let onGenerate: () -> Void

    private var missingEssential: [ClinicalField] {
        app.draft.missingEssential(scenario: app.scenario)
    }

    /// Fields considered essential for the current scenario (for the marker).
    private var essentialFields: [ClinicalField] {
        switch app.scenario {
        case .chronicHFrEF: return [.lvef, .systolicBP, .heartRate, .egfr, .potassium]
        case .acuteCongestion: return [.systolicBP, .egfr, .potassium]
        case .hfpefHFmrEF: return [.lvef]
        case .cardiogenicShock: return [.systolicBP]
        }
    }

    var body: some View {
        Form {
            Section {
                Label(app.name(app.scenario), systemImage: app.scenario.systemImage)
                    .font(.subheadline.bold())
            } footer: {
                Text(app.t(.inputScenarioFooter) + "\n" + app.t(.essentialLegend))
            }

            Section(app.t(.sectionVentricular)) {
                NumericRow(title: app.t(.fieldLVEF), unit: app.t(.unitPercent), text: $app.draft.lvef, essential: essentialFields.contains(.lvef))
                Picker(app.t(.fieldNYHA), selection: $app.draft.nyha) {
                    Text(app.t(.nyhaNone)).tag(NYHAClass?.none)
                    ForEach(NYHAClass.allCases) { nyha in
                        Text(app.name(nyha)).tag(NYHAClass?.some(nyha))
                    }
                }
                NumericRow(title: app.t(.fieldSBP), unit: app.t(.unitMmHg), text: $app.draft.systolicBP, essential: essentialFields.contains(.systolicBP))
                NumericRow(title: app.t(.fieldHR), unit: app.t(.unitBpm), text: $app.draft.heartRate, essential: essentialFields.contains(.heartRate))
                Picker(app.t(.fieldRhythm), selection: $app.draft.rhythm) {
                    ForEach(Rhythm.allCases) { rhythm in
                        Text(app.name(rhythm)).tag(rhythm)
                    }
                }
            }

            Section(app.t(.sectionLab)) {
                NumericRow(title: app.t(.fieldEGFR), unit: app.t(.unitEgfr), text: $app.draft.egfr, essential: essentialFields.contains(.egfr))
                NumericRow(title: app.t(.fieldPotassium), unit: app.t(.unitMmolL), text: $app.draft.potassium, essential: essentialFields.contains(.potassium))
                NumericRow(title: app.t(.fieldCreatinine), unit: app.t(.unitMgdl), text: $app.draft.creatinine)
            }

            Section(app.t(.sectionClinical)) {
                Toggle(app.t(.toggleCongestion), isOn: $app.draft.congestion)
                Toggle(app.t(.toggleHypoperfusion), isOn: $app.draft.hypoperfusion)
                if app.scenario == .chronicHFrEF {
                    Toggle(app.t(.toggleAngioedema), isOn: $app.draft.historyOfAngioedema)
                }
                Toggle(app.t(.togglePriorDiuretic), isOn: $app.draft.priorDiureticUse)

                if app.draft.priorDiureticUse {
                    Picker(app.t(.fieldLoopAgent), selection: loopAgentBinding) {
                        ForEach(app.loopAgents) { agent in
                            Text(agent.genericName).tag(agent.id)
                        }
                    }
                    NumericRow(title: app.t(.fieldOralDose), unit: app.t(.unitMg), text: $app.draft.currentLoopOralDose)
                }
            }

            if app.scenario == .hfpefHFmrEF {
                hfpefSection
            }

            if app.scenario == .cardiogenicShock {
                Section(app.t(.sectionShock)) {
                    NumericRow(title: app.t(.fieldLactate), unit: app.t(.unitMmolL), text: $app.draft.lactate)
                    Toggle(app.t(.toggleOliguria), isOn: $app.draft.oliguria)
                    Toggle(app.t(.toggleAlteredMentation), isOn: $app.draft.alteredMentation)
                }
            }

            if !missingEssential.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(app.t(.essentialMissingWarning), systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                        Text(missingEssential.map { app.name($0) }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button(action: onGenerate) {
                    Label(app.t(.generateButton), systemImage: "wand.and.stars")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } footer: {
                if app.scenario == .acuteCongestion {
                    Text(app.t(.inputAcuteFooter))
                }
            }
        }
        .navigationTitle(app.t(.navClinicalData))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LanguageMenu()
            }
        }
    }

    @ViewBuilder
    private var hfpefSection: some View {
        Section(app.t(.sectionHFpEF)) {
            NumericRow(title: app.t(.fieldAge), unit: app.t(.unitYears), text: $app.draft.age)
            Toggle(app.t(.toggleSymptomsHF), isOn: $app.draft.symptomsSignsHF)
            Toggle(app.t(.toggleObesity), isOn: $app.draft.obesity)
            Toggle(app.t(.toggleHypertension), isOn: $app.draft.hypertension)
            Toggle(app.t(.toggleAntihtn2), isOn: $app.draft.antihypertensives2plus)
            Toggle(app.t(.toggleAtrialFib), isOn: $app.draft.atrialFibrillation)
            Toggle(app.t(.toggleDiabetes), isOn: $app.draft.diabetes)
            Toggle(app.t(.toggleCKD), isOn: $app.draft.ckd)
            Toggle(app.t(.toggleCoronary), isOn: $app.draft.coronaryDisease)
            Toggle(app.t(.toggleSleepApnea), isOn: $app.draft.sleepApnea)
        }
        Section {
            TriStatePicker(title: app.t(.fieldPASP), selection: $app.draft.paspOver35)
            TriStatePicker(title: app.t(.fieldEoverE), selection: $app.draft.eOverEprimeOver9)
            Toggle(app.t(.toggleInfiltrative), isOn: $app.draft.suspectedInfiltrative)
            Toggle(app.t(.toggleValvular), isOn: $app.draft.valvularDisease)
            Toggle(app.t(.togglePulmonary), isOn: $app.draft.pulmonaryDisease)
            Toggle(app.t(.toggleAnemia), isOn: $app.draft.anemia)
            Toggle(app.t(.toggleNonCardiacEdema), isOn: $app.draft.nonCardiacEdema)
        }
    }

    /// Picker binding that defaults to furosemide when nothing was chosen yet.
    private var loopAgentBinding: Binding<String> {
        Binding(
            get: { app.draft.currentLoopAgentId ?? "furosemide" },
            set: { app.draft.currentLoopAgentId = $0 }
        )
    }
}

/// Three-state picker (Not assessed / Yes / No) bound to an optional Bool.
private struct TriStatePicker: View {
    @EnvironmentObject private var app: AppModel
    let title: String
    @Binding var selection: Bool?

    var body: some View {
        Picker(title, selection: $selection) {
            Text(app.t(.triNotAssessed)).tag(Bool?.none)
            Text(app.t(.yes)).tag(Bool?.some(true))
            Text(app.t(.no)).tag(Bool?.some(false))
        }
    }
}

/// One labeled numeric field with a trailing unit and an optional essential marker.
private struct NumericRow: View {
    let title: String
    let unit: String
    @Binding var text: String
    var essential: Bool = false

    var body: some View {
        HStack {
            if essential {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 6, height: 6)
            }
            Text(title)
            Spacer()
            TextField("—", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 110)
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 96, alignment: .leading)
        }
    }
}
