import SwiftUI
import ICFlowCore

/// Tela 5 — Alertas de segurança agregados, agrupados por severidade.
struct SafetyAlertsView: View {
    @EnvironmentObject private var app: AppModel
    let alerts: [SafetyAlert]

    private var grouped: [(severity: AlertSeverity, alerts: [SafetyAlert])] {
        let order: [AlertSeverity] = [.critical, .warning, .info]
        return order.compactMap { severity in
            let matching = alerts.filter { $0.severity == severity }
            return matching.isEmpty ? nil : (severity, matching)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if alerts.isEmpty {
                    ContentUnavailableViewCompat(
                        title: app.t(.alertsNoneTitle),
                        systemImage: "checkmark.shield",
                        description: app.t(.alertsNoneDesc)
                    )
                    .padding(.top, 40)
                } else {
                    ForEach(grouped, id: \.severity) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                SeverityBadge(severity: group.severity)
                                Spacer()
                                Text("\(group.alerts.count)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(group.alerts) { alert in
                                AlertCard(alert: alert)
                            }
                        }
                    }
                }

                DisclaimerBanner()
            }
            .padding()
        }
        .navigationTitle(app.t(.tabAlerts))
    }
}

private struct AlertCard: View {
    @EnvironmentObject private var app: AppModel
    let alert: SafetyAlert

    var body: some View {
        CardView {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: alert.severity.systemImage)
                    .foregroundStyle(alert.severity.color)
                Text(alert.title)
                    .font(.headline)
            }
            Text(alert.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if !alert.referenceIds.isEmpty {
                Text(app.t(.refPrefix) + alert.referenceIds.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
