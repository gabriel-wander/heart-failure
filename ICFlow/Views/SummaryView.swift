import SwiftUI
import UIKit
import ICFlowCore

/// Tela 6 — Resumo final consolidado do caso (anônimo).
struct SummaryView: View {
    let result: AssessmentResult
    let draft: InputDraft

    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardView {
                    CardSectionHeader(title: "Cenário", systemImage: result.scenario.systemImage)
                    Text(result.scenario.displayName).font(.title3.bold())
                    if let profile = result.congestionProfile {
                        Text(profile.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                CardView {
                    CardSectionHeader(title: "Dados inseridos", systemImage: "list.clipboard")
                    let entries = inputEntries
                    if entries.isEmpty {
                        Text("Nenhum dado numérico informado.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(entries, id: \.0) { entry in
                                HStack {
                                    Text(entry.0).foregroundStyle(.secondary)
                                    Spacer()
                                    Text(entry.1).fontWeight(.medium)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                }

                CardView {
                    CardSectionHeader(title: "Síntese das recomendações", systemImage: "checklist")
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(result.recommendations) { rec in
                            HStack(alignment: .top) {
                                Text(rec.title)
                                    .font(.subheadline)
                                Spacer()
                                StatusBadge(status: rec.status)
                            }
                        }
                    }
                }

                if let plan = result.diureticPlan {
                    CardView {
                        CardSectionHeader(title: "Diurético IV (estimativa)", systemImage: "drop.fill")
                        Text("\(plan.perDoseMg.cleanString) mg IV \(plan.dosesPerDay)×/dia (≈ \(plan.totalDailyIVFurosemideMg.cleanString) mg/dia de furosemida).")
                            .font(.subheadline)
                    }
                }

                CardView {
                    HStack {
                        CardSectionHeader(title: "Alertas", systemImage: "exclamationmark.triangle")
                        Spacer()
                        Text("\(result.safetyAlerts.count)")
                            .font(.headline)
                            .foregroundStyle(result.safetyAlerts.contains { $0.severity == .critical } ? .red : .orange)
                    }
                    if let critical = result.safetyAlerts.first(where: { $0.severity == .critical }) {
                        Text("Crítico: \(critical.title)")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }

                Button {
                    UIPasteboard.general.string = plainTextSummary
                    copied = true
                } label: {
                    Label(copied ? "Resumo copiado" : "Copiar resumo (texto)", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                DisclaimerBanner()
            }
            .padding()
        }
        .navigationTitle("Resumo")
    }

    /// Numeric/clinical fields actually filled in, for the recap card.
    private var inputEntries: [(String, String)] {
        var entries: [(String, String)] = []
        func add(_ label: String, _ value: String, unit: String = "") {
            let trimmed = value.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return }
            entries.append((label, unit.isEmpty ? trimmed : "\(trimmed) \(unit)"))
        }
        add("FEVE", draft.lvef, unit: "%")
        if let nyha = draft.nyha { entries.append(("NYHA", nyha.rawValue)) }
        add("PA sistólica", draft.systolicBP, unit: "mmHg")
        add("FC", draft.heartRate, unit: "bpm")
        entries.append(("Ritmo", draft.rhythm.displayName))
        add("TFGe", draft.egfr, unit: "mL/min/1,73m²")
        add("Potássio", draft.potassium, unit: "mmol/L")
        add("Creatinina", draft.creatinine, unit: "mg/dL")
        entries.append(("Congestão", draft.congestion ? "Sim" : "Não"))
        entries.append(("Hipoperfusão", draft.hypoperfusion ? "Sim" : "Não"))
        entries.append(("Uso prévio de diurético", draft.priorDiureticUse ? "Sim" : "Não"))
        return entries
    }

    private var plainTextSummary: String {
        var lines = ["IC Flow — resumo (educacional, dados anônimos)"]
        lines.append("Cenário: \(result.scenario.displayName)")
        if let profile = result.congestionProfile {
            lines.append("Perfil: \(profile.displayName)")
        }
        lines.append("")
        lines.append("Dados: " + inputEntries.map { "\($0.0)=\($0.1)" }.joined(separator: "; "))
        lines.append("")
        lines.append("Recomendações:")
        for rec in result.recommendations {
            lines.append("- \(rec.title): \(rec.status.displayName)")
        }
        if let plan = result.diureticPlan {
            lines.append("Diurético IV: \(plan.perDoseMg.cleanString) mg \(plan.dosesPerDay)x/dia")
        }
        lines.append("")
        lines.append("Alertas: \(result.safetyAlerts.count)")
        lines.append("")
        lines.append("Ferramenta educacional — não substitui o julgamento clínico.")
        return lines.joined(separator: "\n")
    }
}
