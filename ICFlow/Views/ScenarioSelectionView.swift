import SwiftUI
import ICFlowCore

/// Tela 2 — Escolha do cenário clínico.
struct ScenarioSelectionView: View {
    @EnvironmentObject private var app: AppModel
    let onSelect: (Scenario) -> Void

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
