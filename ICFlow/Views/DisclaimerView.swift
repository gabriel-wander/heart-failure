import SwiftUI

/// Tela 1 — Disclaimer inicial. O usuário deve concordar antes de prosseguir.
struct DisclaimerView: View {
    @EnvironmentObject private var app: AppModel
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                ContentValidationBanner()

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
        VStack(spacing: 10) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white)
                .accessibilityHidden(true)
            Text("IC Flow")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text(app.t(.appSubtitle))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.37, blue: 0.38),
                         Color(red: 0.57, green: 0.07, blue: 0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }
}

#Preview {
    NavigationStack {
        DisclaimerView(onContinue: {})
            .environmentObject(AppModel())
    }
}
