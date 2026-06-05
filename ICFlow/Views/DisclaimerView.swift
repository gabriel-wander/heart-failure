import SwiftUI

/// Tela 1 — Disclaimer inicial. O usuário deve concordar antes de prosseguir.
struct DisclaimerView: View {
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                CardView {
                    CardSectionHeader(title: "Aviso importante", systemImage: "exclamationmark.shield.fill")
                    BulletList(items: [
                        "Ferramenta educacional destinada a médicos. Não substitui o julgamento clínico individual.",
                        "As recomendações e doses são exemplos (mock) e devem ser confirmadas com diretrizes atuais, bulas e o contexto do paciente.",
                        "Não armazena dados identificáveis de pacientes. Insira apenas parâmetros clínicos de forma anônima.",
                        "Funciona totalmente offline. Não há login, banco de dados remoto nem integração externa.",
                        "Escopo do MVP: ICFEr crônica e IC aguda congesta sem choque cardiogênico."
                    ], systemImage: "circle.fill", tint: .blue)
                }

                Button(action: onContinue) {
                    Text("Li e concordo — continuar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)

                Text("Ao continuar, você reconhece a natureza educacional desta ferramenta.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .navigationTitle("IC Flow")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)
                VStack(alignment: .leading) {
                    Text("IC Flow")
                        .font(.largeTitle.bold())
                    Text("Apoio à decisão em insuficiência cardíaca")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        DisclaimerView(onContinue: {})
    }
}
