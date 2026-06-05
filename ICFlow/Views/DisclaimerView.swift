import SwiftUI

/// Tela 1 — Disclaimer inicial. O usuário deve concordar antes de prosseguir.
struct DisclaimerView: View {
    @EnvironmentObject private var app: AppModel
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                CardView {
                    CardSectionHeader(title: app.t(.disclaimerWarningTitle), systemImage: "exclamationmark.shield.fill")
                    BulletList(items: [
                        app.t(.disclaimerBullet1),
                        app.t(.disclaimerBullet2),
                        app.t(.disclaimerBullet3),
                        app.t(.disclaimerBullet4),
                        app.t(.disclaimerBullet5)
                    ], systemImage: "circle.fill", tint: .blue)
                }

                Button(action: onContinue) {
                    Text(app.t(.disclaimerAgree))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)

                Text(app.t(.disclaimerFootnote))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .navigationTitle("IC Flow")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LanguageMenu()
            }
        }
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
                    Text(app.t(.appSubtitle))
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
            .environmentObject(AppModel())
    }
}
