import SwiftUI
import ICFlowCore

/// Tela 7 — Referências. Lista as fontes do caso e todas as referências do app,
/// com busca local (offline). Mostra metadados (ano, tipo, nível de evidência)
/// quando disponíveis.
struct ReferencesView: View {
    @EnvironmentObject private var app: AppModel
    let usedReferences: [Reference]
    let allReferences: [Reference]

    @State private var searchText = ""

    private var usedIds: Set<String> { Set(usedReferences.map(\.id)) }

    private func matches(_ reference: Reference) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return true }
        let haystack = "\(reference.title) \(reference.authors) \(reference.source) \(reference.year)".lowercased()
        return haystack.contains(query)
    }

    private var filteredUsed: [Reference] { usedReferences.filter(matches) }
    private var filteredOthers: [Reference] {
        allReferences.filter { !usedIds.contains($0.id) && matches($0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                searchField

                if !filteredUsed.isEmpty {
                    sectionTitle(app.t(.refsThisCase))
                    ForEach(filteredUsed) { ReferenceCard(reference: $0, highlighted: true) }
                }
                if !filteredOthers.isEmpty {
                    sectionTitle(filteredUsed.isEmpty ? app.t(.refsAll) : app.t(.refsOthers))
                    ForEach(filteredOthers) { ReferenceCard(reference: $0, highlighted: false) }
                }
                if filteredUsed.isEmpty && filteredOthers.isEmpty {
                    Text(app.t(.referencesNoResults))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(app.t(.referencesFootnote))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle(app.t(.tabReferences))
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(app.t(.referencesSearch), text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .accessibilityLabel(app.t(.cancel))
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ReferenceCard: View {
    let reference: Reference
    let highlighted: Bool

    private var meta: String {
        var parts = [String(reference.year)]
        if let type = reference.guidelineOrStudy, !type.isEmpty { parts.append(type) }
        if let evidence = reference.evidenceLevel, !evidence.isEmpty { parts.append(evidence) }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        CardView {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "doc.richtext")
                    .foregroundStyle(highlighted ? .blue : .secondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(reference.title)
                        .font(.subheadline.bold())
                    Text(reference.authors)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(reference.source)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(meta)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
