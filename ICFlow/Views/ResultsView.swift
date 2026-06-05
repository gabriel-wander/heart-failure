import SwiftUI
import ICFlowCore

/// Container das telas de resultado (abas): Recomendações, Alertas, Resumo e
/// Referências. Telas 4 a 7 do MVP.
struct ResultsView: View {
    @EnvironmentObject private var viewModel: AssessmentViewModel
    let onRestart: () -> Void

    var body: some View {
        Group {
            if let result = viewModel.result {
                TabView {
                    RecommendationsView(result: result)
                        .tabItem { Label("Recomendações", systemImage: "list.bullet.clipboard") }

                    SafetyAlertsView(alerts: result.safetyAlerts)
                        .tabItem { Label("Alertas", systemImage: "exclamationmark.triangle") }

                    SummaryView(result: result, draft: viewModel.draft)
                        .tabItem { Label("Resumo", systemImage: "doc.text") }

                    ReferencesView(
                        usedReferences: result.references,
                        allReferences: viewModel.repository?.references ?? []
                    )
                    .tabItem { Label("Referências", systemImage: "books.vertical") }
                }
            } else {
                EmptyResultView()
            }
        }
        .navigationTitle("Resultado")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Nova avaliação", action: onRestart)
            }
        }
    }
}
