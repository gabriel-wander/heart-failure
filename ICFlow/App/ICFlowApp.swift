import SwiftUI
import ICFlowCore

/// IC Flow — protótipo educacional de apoio à decisão clínica em insuficiência
/// cardíaca. Funciona totalmente offline e não armazena dados de pacientes.
@main
struct ICFlowApp: App {
    @StateObject private var viewModel: AssessmentViewModel

    init() {
        // Load the bundled clinical content at startup. If decoding fails, the
        // view model carries the error and the UI shows a recovery screen.
        do {
            let repository = try ContentRepository.load()
            _viewModel = StateObject(wrappedValue: AssessmentViewModel(repository: repository))
        } catch {
            _viewModel = StateObject(wrappedValue: AssessmentViewModel(loadError: error))
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
        }
    }
}
