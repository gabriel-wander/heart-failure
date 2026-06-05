import SwiftUI
import ICFlowCore

/// Container das telas de resultado (abas): Recomendações, Alertas, Resumo e
/// Referências. Telas 4 a 7 do MVP.
struct ResultsView: View {
    @EnvironmentObject private var app: AppModel
    let onRestart: () -> Void

    var body: some View {
        Group {
            if let result = app.result {
                TabView {
                    RecommendationsView(result: result)
                        .tabItem { Label(app.t(.tabRecommendations), systemImage: "list.bullet.clipboard") }

                    SafetyAlertsView(alerts: result.safetyAlerts)
                        .tabItem { Label(app.t(.tabAlerts), systemImage: "exclamationmark.triangle") }

                    SummaryView(result: result, draft: app.draft)
                        .tabItem { Label(app.t(.tabSummary), systemImage: "doc.text") }

                    ReferencesView(
                        usedReferences: result.references,
                        allReferences: app.repository?.references ?? []
                    )
                    .tabItem { Label(app.t(.tabReferences), systemImage: "books.vertical") }
                }
            } else {
                EmptyResultView()
            }
        }
        .navigationTitle(app.t(.navResult))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                LanguageMenu()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(app.t(.newAssessment), action: onRestart)
            }
        }
    }
}
