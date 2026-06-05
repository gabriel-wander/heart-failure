import SwiftUI
import ICFlowCore

/// Hosts the navigation stack and drives the linear MVP flow:
/// Disclaimer → Cenário → Entrada de dados → Resultado (abas).
struct RootView: View {
    @EnvironmentObject private var app: AppModel
    @State private var path: [Route] = []

    var body: some View {
        if let loadError = app.loadError {
            ContentLoadErrorView(message: loadError)
        } else {
            NavigationStack(path: $path) {
                DisclaimerView(onContinue: { path.append(.scenarioSelection) })
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .scenarioSelection:
            ScenarioSelectionView(
                onSelect: { scenario in
                    app.startNewAssessment(scenario: scenario)
                    path.append(.clinicalInput)
                },
                onOpenChecklist: { path.append(.dischargeChecklist) },
                onOpenCalculators: { path.append(.calculators) }
            )
        case .dischargeChecklist:
            DischargeChecklistView()
        case .calculators:
            CalculatorsView()
        case .clinicalInput:
            ClinicalInputView {
                app.generate()
                path.append(.results)
            }
        case .results:
            ResultsView {
                app.reset()
                path = [.scenarioSelection]
            }
        }
    }
}

/// Shown only if the bundled JSON content cannot be decoded.
struct ContentLoadErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
            Text("Não foi possível carregar o conteúdo clínico / Could not load clinical content")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
