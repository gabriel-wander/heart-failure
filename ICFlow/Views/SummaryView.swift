import SwiftUI
import UIKit
import ICFlowCore

/// Tela 6 — Resumo final consolidado do caso (anônimo).
struct SummaryView: View {
    @EnvironmentObject private var app: AppModel
    let result: AssessmentResult
    let draft: InputDraft

    @EnvironmentObject private var history: CaseHistoryStore
    @State private var copied = false
    @State private var shareURL: URL?
    @State private var showShare = false
    @State private var showSaveDialog = false
    @State private var saveLabel = ""
    @State private var saved = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardView {
                    CardSectionHeader(title: app.t(.sumScenario), systemImage: result.scenario.systemImage)
                    Text(app.name(result.scenario)).font(.title3.bold())
                    if let profile = result.congestionProfile {
                        Text(app.name(profile))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                CardView {
                    CardSectionHeader(title: app.t(.sumInputData), systemImage: "list.clipboard")
                    let entries = inputEntries
                    if entries.isEmpty {
                        Text(app.t(.sumNoNumericData))
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
                    CardSectionHeader(title: app.t(.sumRecsTitle), systemImage: "checklist")
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
                        CardSectionHeader(title: app.t(.sumDiureticTitle), systemImage: "drop.fill")
                        Text(diureticLine(plan))
                            .font(.subheadline)
                    }
                }

                CardView {
                    HStack {
                        CardSectionHeader(title: app.t(.sumAlertsTitle), systemImage: "exclamationmark.triangle")
                        Spacer()
                        Text("\(result.safetyAlerts.count)")
                            .font(.headline)
                            .foregroundStyle(result.safetyAlerts.contains { $0.severity == .critical } ? .red : .orange)
                    }
                    if let critical = result.safetyAlerts.first(where: { $0.severity == .critical }) {
                        Text(app.t(.sumCriticalPrefix) + critical.title)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }

                Button {
                    UIPasteboard.general.string = plainTextSummary
                    copied = true
                } label: {
                    Label(copied ? app.t(.copiedButton) : app.t(.copyButton), systemImage: copied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    let exporter = AssessmentExport(app: app, result: result, draft: draft)
                    if let url = exporter.makePDFURL() {
                        shareURL = url
                        showShare = true
                    }
                } label: {
                    Label(app.t(.exportButton), systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    saveLabel = ""
                    showSaveDialog = true
                } label: {
                    Label(saved ? app.t(.historySaved) : app.t(.historySaveButton),
                          systemImage: saved ? "checkmark" : "tray.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                DisclaimerBanner()
            }
            .padding()
        }
        .navigationTitle(app.t(.tabSummary))
        .sheet(isPresented: $showShare) {
            if let url = shareURL {
                ActivityView(items: [url])
            }
        }
        .alert(app.t(.historySaveButton), isPresented: $showSaveDialog) {
            TextField(app.t(.historyLabelPlaceholder), text: $saveLabel)
            Button(app.t(.historySaveButton)) {
                history.add(label: saveLabel, scenario: app.scenario,
                            input: draft.toPatientInput(scenario: app.scenario))
                saved = true
            }
            Button(app.t(.cancel), role: .cancel) {}
        } message: {
            Text(app.t(.historySaveMessage))
        }
    }

    /// Numeric/clinical fields actually filled in, for the recap card.
    private var inputEntries: [(String, String)] {
        var entries: [(String, String)] = []
        func add(_ label: String, _ value: String, unit: String = "") {
            let trimmed = value.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return }
            entries.append((label, unit.isEmpty ? trimmed : "\(trimmed) \(unit)"))
        }
        add(app.t(.fieldLVEF), draft.lvef, unit: app.t(.unitPercent))
        if let nyha = draft.nyha { entries.append((app.t(.fieldNYHA), nyha.rawValue)) }
        add(app.t(.fieldSBP), draft.systolicBP, unit: app.t(.unitMmHg))
        add(app.t(.fieldHR), draft.heartRate, unit: app.t(.unitBpm))
        entries.append((app.t(.fieldRhythm), app.name(draft.rhythm)))
        add(app.t(.fieldEGFR), draft.egfr, unit: app.t(.unitEgfr))
        add(app.t(.fieldPotassium), draft.potassium, unit: app.t(.unitMmolL))
        add(app.t(.fieldCreatinine), draft.creatinine, unit: app.t(.unitMgdl))
        entries.append((app.t(.sumCongestion), draft.congestion ? app.t(.yes) : app.t(.no)))
        entries.append((app.t(.sumHypoperfusion), draft.hypoperfusion ? app.t(.yes) : app.t(.no)))
        entries.append((app.t(.sumPriorDiuretic), draft.priorDiureticUse ? app.t(.yes) : app.t(.no)))
        return entries
    }

    private func diureticLine(_ plan: DiureticPlan) -> String {
        let per = app.format(plan.perDoseMg)
        let total = app.format(plan.totalDailyIVFurosemideMg)
        let freq = "\(plan.dosesPerDay)\(app.t(.perDaySuffix))"
        switch app.language {
        case .pt: return "\(per) mg IV \(freq) (≈ \(total) mg/dia de furosemida)."
        case .en: return "\(per) mg IV \(freq) (≈ \(total) mg/day furosemide)."
        }
    }

    private var plainTextSummary: String {
        var lines = [app.t(.txtHeader)]
        lines.append("\(app.t(.sumScenario)): \(app.name(result.scenario))")
        if let profile = result.congestionProfile {
            lines.append("\(app.t(.sumProfile)): \(app.name(profile))")
        }
        lines.append("")
        lines.append(app.t(.txtData) + ": " + inputEntries.map { "\($0.0)=\($0.1)" }.joined(separator: "; "))
        lines.append("")
        lines.append(app.t(.txtRecommendations))
        for rec in result.recommendations {
            lines.append("- \(rec.title): \(app.name(rec.status))")
        }
        if let plan = result.diureticPlan {
            lines.append("\(app.t(.txtDiuretic)): \(diureticLine(plan))")
        }
        lines.append("")
        lines.append("\(app.t(.txtAlerts)): \(result.safetyAlerts.count)")
        lines.append("")
        lines.append(app.t(.txtDisclaimer))
        return lines.joined(separator: "\n")
    }
}
