import SwiftUI
import ICFlowCore

/// Tela 2 — Escolha do cenário clínico.
struct ScenarioSelectionView: View {
    @EnvironmentObject private var app: AppModel
    let onSelect: (Scenario) -> Void
    var onOpenChecklist: () -> Void = {}
    var onOpenCalculators: () -> Void = {}
    var onOpenHistory: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(app.t(.scenarioSelectTitle))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(Scenario.allCases) { scenario in
                    Button {
                        onSelect(scenario)
                    } label: {
                        scenarioCard(scenario)
                    }
                    .buttonStyle(.plain)
                }

                toolButton(icon: "checklist", title: app.t(.checklistNavTitle),
                           subtitle: app.t(.checklistSubtitle), action: onOpenChecklist)
                toolButton(icon: "function", title: app.t(.calcNavTitle),
                           subtitle: app.t(.calcSubtitle), action: onOpenCalculators)
                toolButton(icon: "clock.arrow.circlepath", title: app.t(.historyNavTitle),
                           subtitle: app.t(.historySubtitle), action: onOpenHistory)

                DisclaimerBanner()
            }
            .padding()
        }
        .navigationTitle(app.t(.navScenario))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LanguageMenu()
            }
        }
    }

    private func toolButton(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(.teal)
                    .frame(width: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func scenarioCard(_ scenario: Scenario) -> some View {
        CardView {
            HStack(spacing: 14) {
                Image(systemName: scenario.systemImage)
                    .font(.system(size: 30))
                    .foregroundStyle(.red)
                    .frame(width: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name(scenario))
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text(app.detail(scenario))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScenarioSelectionView(onSelect: { _ in })
            .environmentObject(AppModel())
    }
}
