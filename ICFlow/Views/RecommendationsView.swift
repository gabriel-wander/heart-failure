import SwiftUI
import ICFlowCore

/// Tela 4 — Recomendações. Mostra os quatro pilares (ICFEr) ou a estratégia de
/// diurético IV / encaminhamento (IC aguda).
struct RecommendationsView: View {
    let result: AssessmentResult

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let profile = result.congestionProfile {
                    profileBanner(profile)
                }

                if let plan = result.diureticPlan {
                    diureticPlanCard(plan)
                }

                ForEach(result.recommendations) { rec in
                    RecommendationCard(recommendation: rec)
                }

                if !result.generalNotes.isEmpty {
                    CardView {
                        CardSectionHeader(title: "Notas gerais", systemImage: "note.text")
                        BulletList(items: result.generalNotes, tint: .secondary)
                    }
                }

                DisclaimerBanner()
            }
            .padding()
        }
        .navigationTitle("Recomendações")
    }

    private func profileBanner(_ profile: CongestionProfile) -> some View {
        CardView {
            CardSectionHeader(title: "Perfil hemodinâmico", systemImage: "waveform.path.ecg")
            Text(profile.displayName)
                .font(.title3.bold())
            Text(profile.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func diureticPlanCard(_ plan: DiureticPlan) -> some View {
        CardView {
            HStack {
                CardSectionHeader(title: "Estimativa de diurético IV", systemImage: "drop.fill")
                Spacer()
                if plan.highDoseCaution {
                    SeverityBadge(severity: .warning)
                }
            }
            HStack(spacing: 16) {
                metric(value: "\(plan.perDoseMg.cleanString) mg", label: "por dose")
                metric(value: "\(plan.dosesPerDay)×/dia", label: "frequência")
                metric(value: "\(plan.totalDailyIVFurosemideMg.cleanString) mg", label: "total/dia")
            }
            Text(plan.strategy.displayName)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(plan.description)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func metric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Card de uma recomendação (classe de medicamento ou ação).
struct RecommendationCard: View {
    let recommendation: Recommendation

    var body: some View {
        CardView {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(recommendation.title)
                        .font(.headline)
                    if let drug = recommendation.displayDrug {
                        Text(drug)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                StatusBadge(status: recommendation.status)
            }

            if !recommendation.justifications.isEmpty {
                section(title: "Justificativa", icon: "text.alignleft") {
                    BulletList(items: recommendation.justifications, tint: recommendation.status.color)
                }
            }

            if recommendation.startingDose != nil || recommendation.targetDose != nil {
                doseSection
            }

            if !recommendation.monitoring.isEmpty {
                section(title: "Monitoramento", icon: "stethoscope") {
                    BulletList(items: recommendation.monitoring, tint: .teal)
                }
            }

            if !recommendation.safetyAlerts.isEmpty {
                section(title: "Alertas de segurança", icon: "exclamationmark.triangle") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(recommendation.safetyAlerts) { alert in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: alert.severity.systemImage)
                                    .foregroundStyle(alert.severity.color)
                                    .font(.caption)
                                    .padding(.top, 2)
                                Text(alert.title)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }

            if !recommendation.notes.isEmpty {
                section(title: "Observações", icon: "note.text") {
                    BulletList(items: recommendation.notes, tint: .secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var doseSection: some View {
        section(title: "Doses (exemplo)", icon: "pills.fill") {
            VStack(alignment: .leading, spacing: 6) {
                if let start = recommendation.startingDose {
                    doseRow(label: "Inicial", value: start)
                }
                if let target = recommendation.targetDose {
                    doseRow(label: "Alvo", value: target)
                }
            }
        }
    }

    private func doseRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption.bold()).foregroundStyle(.secondary)
            Text(value).font(.subheadline).fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Divider()
        VStack(alignment: .leading, spacing: 8) {
            CardSectionHeader(title: title, systemImage: icon)
            content()
        }
    }
}
