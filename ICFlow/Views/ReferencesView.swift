import SwiftUI
import ICFlowCore

/// Tela 7 — Referências. Lista as fontes utilizadas no caso e todas as
/// referências disponíveis no app.
struct ReferencesView: View {
    let usedReferences: [Reference]
    let allReferences: [Reference]

    private var usedIds: Set<String> { Set(usedReferences.map(\.id)) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !usedReferences.isEmpty {
                    sectionTitle("Referências deste caso")
                    ForEach(usedReferences) { reference in
                        ReferenceCard(reference: reference, highlighted: true)
                    }
                }

                let others = allReferences.filter { !usedIds.contains($0.id) }
                if !others.isEmpty {
                    sectionTitle(usedReferences.isEmpty ? "Referências" : "Outras referências")
                    ForEach(others) { reference in
                        ReferenceCard(reference: reference, highlighted: false)
                    }
                }

                Text("Conteúdo clínico baseado nas fontes acima. As referências são fornecidas para fins educacionais; consulte sempre as versões completas e as diretrizes vigentes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle("Referências")
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

    var body: some View {
        CardView {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "doc.richtext")
                    .foregroundStyle(highlighted ? .blue : .secondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text(reference.title)
                        .font(.subheadline.bold())
                    Text(reference.authors)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(reference.source)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
