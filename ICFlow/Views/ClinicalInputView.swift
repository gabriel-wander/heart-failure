import SwiftUI
import ICFlowCore

/// Tela 3 — Entrada de dados clínicos (anônimos). Compartilhada pelos dois fluxos.
struct ClinicalInputView: View {
    @EnvironmentObject private var viewModel: AssessmentViewModel
    let onGenerate: () -> Void

    var body: some View {
        Form {
            Section {
                Label(viewModel.scenario.displayName, systemImage: viewModel.scenario.systemImage)
                    .font(.subheadline.bold())
            } footer: {
                Text("Insira apenas dados clínicos anônimos. Campos em branco não são avaliados pelas regras.")
            }

            Section("Função ventricular e hemodinâmica") {
                NumericRow(title: "FEVE", unit: "%", text: $viewModel.draft.lvef)
                Picker("NYHA", selection: $viewModel.draft.nyha) {
                    Text("—").tag(NYHAClass?.none)
                    ForEach(NYHAClass.allCases) { nyha in
                        Text(nyha.displayName).tag(NYHAClass?.some(nyha))
                    }
                }
                NumericRow(title: "PA sistólica", unit: "mmHg", text: $viewModel.draft.systolicBP)
                NumericRow(title: "Frequência cardíaca", unit: "bpm", text: $viewModel.draft.heartRate)
                Picker("Ritmo", selection: $viewModel.draft.rhythm) {
                    ForEach(Rhythm.allCases) { rhythm in
                        Text(rhythm.displayName).tag(rhythm)
                    }
                }
            }

            Section("Laboratório") {
                NumericRow(title: "TFGe", unit: "mL/min/1,73m²", text: $viewModel.draft.egfr)
                NumericRow(title: "Potássio", unit: "mmol/L", text: $viewModel.draft.potassium)
                NumericRow(title: "Creatinina", unit: "mg/dL", text: $viewModel.draft.creatinine)
            }

            Section("Estado clínico") {
                Toggle("Sinais de congestão", isOn: $viewModel.draft.congestion)
                Toggle("Sinais de hipoperfusão", isOn: $viewModel.draft.hypoperfusion)
                Toggle("Uso prévio de diurético", isOn: $viewModel.draft.priorDiureticUse)

                if viewModel.draft.priorDiureticUse {
                    Picker("Diurético em uso", selection: loopAgentBinding) {
                        ForEach(viewModel.loopAgents) { agent in
                            Text(agent.genericName).tag(agent.id)
                        }
                    }
                    NumericRow(title: "Dose oral total/dia", unit: "mg", text: $viewModel.draft.currentLoopOralDose)
                }
            }

            Section {
                Button(action: onGenerate) {
                    Label("Gerar recomendações", systemImage: "wand.and.stars")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } footer: {
                if viewModel.scenario == .acuteCongestion {
                    Text("No fluxo agudo, a dose IV de diurético é estimada a partir do uso prévio (≈ 2,5× a dose oral domiciliar) ou de uma dose inicial padrão se virgem de diurético.")
                }
            }
        }
        .navigationTitle("Dados clínicos")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Picker binding that defaults to furosemide when nothing was chosen yet.
    private var loopAgentBinding: Binding<String> {
        Binding(
            get: { viewModel.draft.currentLoopAgentId ?? "furosemide" },
            set: { viewModel.draft.currentLoopAgentId = $0 }
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
