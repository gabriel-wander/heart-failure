import SwiftUI
import ICFlowCore

/// Tela 3 — Entrada de dados clínicos (anônimos). Compartilhada pelos dois fluxos.
struct ClinicalInputView: View {
    @EnvironmentObject private var app: AppModel
    let onGenerate: () -> Void

    var body: some View {
        Form {
            Section {
                Label(app.name(app.scenario), systemImage: app.scenario.systemImage)
                    .font(.subheadline.bold())
            } footer: {
                Text(app.t(.inputScenarioFooter))
            }

            Section(app.t(.sectionVentricular)) {
                NumericRow(title: app.t(.fieldLVEF), unit: app.t(.unitPercent), text: $app.draft.lvef)
                Picker(app.t(.fieldNYHA), selection: $app.draft.nyha) {
                    Text(app.t(.nyhaNone)).tag(NYHAClass?.none)
                    ForEach(NYHAClass.allCases) { nyha in
                        Text(app.name(nyha)).tag(NYHAClass?.some(nyha))
                    }
                }
                NumericRow(title: app.t(.fieldSBP), unit: app.t(.unitMmHg), text: $app.draft.systolicBP)
                NumericRow(title: app.t(.fieldHR), unit: app.t(.unitBpm), text: $app.draft.heartRate)
                Picker(app.t(.fieldRhythm), selection: $app.draft.rhythm) {
                    ForEach(Rhythm.allCases) { rhythm in
                        Text(app.name(rhythm)).tag(rhythm)
                    }
                }
            }

            Section(app.t(.sectionLab)) {
                NumericRow(title: app.t(.fieldEGFR), unit: app.t(.unitEgfr), text: $app.draft.egfr)
                NumericRow(title: app.t(.fieldPotassium), unit: app.t(.unitMmolL), text: $app.draft.potassium)
                NumericRow(title: app.t(.fieldCreatinine), unit: app.t(.unitMgdl), text: $app.draft.creatinine)
            }

            Section(app.t(.sectionClinical)) {
                Toggle(app.t(.toggleCongestion), isOn: $app.draft.congestion)
                Toggle(app.t(.toggleHypoperfusion), isOn: $app.draft.hypoperfusion)
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

    /// Picker binding that defaults to furosemide when nothing was chosen yet.
    private var loopAgentBinding: Binding<String> {
        Binding(
            get: { app.draft.currentLoopAgentId ?? "furosemide" },
            set: { app.draft.currentLoopAgentId = $0 }
        )
    }
}

/// One labeled numeric field with a trailing unit.
private struct NumericRow: View {
    let title: String
    let unit: String
    @Binding var text: String

    var body: some View {
        HStack {
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
