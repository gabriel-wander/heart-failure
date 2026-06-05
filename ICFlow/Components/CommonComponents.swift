import SwiftUI
import ICFlowCore

/// Small status pill for a recommendation status (Considerar / Cautela /
/// Contraindicado / Dados insuficientes / Avaliação urgente …).
struct StatusBadge: View {
    @EnvironmentObject private var app: AppModel
    let status: RecommendationStatus

    var body: some View {
        Label(app.name(status), systemImage: status.systemImage)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(status.color.opacity(0.15), in: Capsule())
            .foregroundStyle(status.color)
    }
}

/// Severity pill for safety alerts.
struct SeverityBadge: View {
    @EnvironmentObject private var app: AppModel
    let severity: AlertSeverity

    var body: some View {
        Label(app.name(severity), systemImage: severity.systemImage)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(severity.color.opacity(0.15), in: Capsule())
            .foregroundStyle(severity.color)
    }
}

/// In-app language switcher (globe menu).
struct LanguageMenu: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        Menu {
            ForEach(AppLanguage.allCases) { lang in
                Button {
                    app.setLanguage(lang)
                } label: {
                    if lang == app.language {
                        Label(lang.nativeName, systemImage: "checkmark")
                    } else {
                        Text(lang.nativeName)
                    }
                }
            }
        } label: {
            Label(app.language.shortTag, systemImage: "globe")
        }
    }
}

/// Generic titled card used across screens.
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

/// A labeled section header inside a card.
struct CardSectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.bold())
            .foregroundStyle(.secondary)
    }
}

/// A vertical list of bullet items.
struct BulletList: View {
    let items: [String]
    var systemImage: String = "circle.fill"
    var tint: Color = .secondary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 6))
                        .padding(.top, 6)
                        .foregroundStyle(tint)
                        .accessibilityHidden(true)
                    Text(item)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

/// Disclaimer banner reused on results screens.
struct DisclaimerBanner: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)
            Text(app.t(.disclaimerBanner))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

/// Banner shown while the clinical content is under validation (v0.2).
struct ContentValidationBanner: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        if !app.isContentValidated {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "checkmark.shield")
                    .foregroundStyle(.orange)
                Text(app.t(.contentValidationBanner))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

/// Card listing the essential inputs missing for the current assessment.
struct MissingDataCard: View {
    @EnvironmentObject private var app: AppModel
    let fields: [ClinicalField]

    var body: some View {
        if !fields.isEmpty {
            CardView {
                CardSectionHeader(title: app.t(.missingDataTitle), systemImage: "questionmark.circle")
                BulletList(items: fields.map { app.name($0) }, tint: .gray)
            }
        }
    }
}

/// Placeholder shown if a results tab is opened without a computed result.
struct EmptyResultView: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        ContentUnavailableViewCompat(
            title: app.t(.emptyResultTitle),
            systemImage: "doc.text.magnifyingglass",
            description: app.t(.emptyResultDesc)
        )
    }
}

/// Lightweight stand-in compatible with iOS 16 (ContentUnavailableView is iOS 17+).
struct ContentUnavailableViewCompat: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
