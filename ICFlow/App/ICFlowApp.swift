import SwiftUI
import ICFlowCore

/// IC Flow — protótipo educacional de apoio à decisão clínica em insuficiência
/// cardíaca. Funciona totalmente offline e não armazena dados de pacientes.
/// Suporta português e inglês, com troca de idioma dentro do app.
@main
struct ICFlowApp: App {
    @StateObject private var app = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
        }
    }
}
