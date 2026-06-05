import SwiftUI
import ICFlowCore

/// Anonymous local case history. Stored only on the device; nothing identifiable.
struct HistoryView: View {
    @EnvironmentObject private var app: AppModel
    @EnvironmentObject private var history: CaseHistoryStore
    let onOpen: (SavedCase) -> Void

    @State private var showClearConfirm = false

    var body: some View {
        Group {
            if history.cases.isEmpty {
                ContentUnavailableViewCompat(
                    title: app.t(.historyEmptyTitle),
                    systemImage: "clock.arrow.circlepath",
                    description: app.t(.historyEmptyDesc)
                )
            } else {
                List {
                    Section {
                        ForEach(history.cases) { saved in
                            Button { onOpen(saved) } label: { row(saved) }
                                .buttonStyle(.plain)
                        }
                        .onDelete { history.delete(at: $0) }
                    } footer: {
                        Text(app.t(.historyFootnote))
                    }
                }
            }
        }
        .navigationTitle(app.t(.historyNavTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { LanguageMenu() }
            if !history.cases.isEmpty {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) { showClearConfirm = true } label: {
                        Text(app.t(.historyDeleteAll))
                    }
                }
            }
        }
        .confirmationDialog(app.t(.historyDeleteAll), isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button(app.t(.historyDeleteAll), role: .destructive) { history.deleteAll() }
            Button(app.t(.cancel), role: .cancel) {}
        }
    }

    private func row(_ saved: SavedCase) -> some View {
        HStack {
            Image(systemName: saved.scenario.systemImage).foregroundStyle(.red).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(saved.label.isEmpty ? app.name(saved.scenario) : saved.label)
                    .font(.subheadline.bold())
                Text("\(app.name(saved.scenario)) · \(saved.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
    }
}
