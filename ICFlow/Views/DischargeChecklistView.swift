import SwiftUI
import ICFlowCore

/// Optional post-decompensation discharge checklist (educational).
/// Check state lives only in memory — nothing is persisted.
struct DischargeChecklistView: View {
    @EnvironmentObject private var app: AppModel
    @State private var checked: Set<String> = []

    private var items: [ChecklistItem] { app.repository?.dischargeChecklist ?? [] }

    var body: some View {
        Form {
            Section {
                ProgressView(value: Double(checked.count), total: Double(max(items.count, 1))) {
                    Text("\(checked.count)/\(items.count)")
                        .font(.subheadline.bold())
                }
            } footer: {
                Text(app.t(.checklistFootnote))
            }

            Section {
                ForEach(items) { item in
                    Button {
                        toggle(item.id)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: checked.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(checked.contains(item.id) ? .green : .secondary)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.text)
                                    .foregroundStyle(.primary)
                                if let detail = item.detail {
                                    Text(detail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(app.t(.checklistNavTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LanguageMenu()
            }
        }
    }

    private func toggle(_ id: String) {
        if checked.contains(id) { checked.remove(id) } else { checked.insert(id) }
    }
}
