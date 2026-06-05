import Foundation
import UIKit
import CoreText
import ICFlowCore

/// Builds an **anonymous** export of an assessment (plain text and a paginated
/// PDF). Contains only the de-identified clinical parameters and the generated
/// recommendation — never patient identifiers.
struct AssessmentExport {
    let app: AppModel
    let result: AssessmentResult
    let draft: InputDraft

    // MARK: - Plain text

    func plainText() -> String {
        var lines: [String] = []
        func t(_ k: UIString) -> String { app.t(k) }

        lines.append(t(.txtHeader))
        if !app.isContentValidated { lines.append("⚠︎ " + t(.contentValidationBanner)) }
        lines.append("")

        lines.append("\(t(.sumScenario)): \(app.name(result.scenario))")
        if let profile = result.congestionProfile {
            lines.append("\(t(.sumProfile)): \(app.name(profile))")
        }
        if let score = result.h2fpef {
            lines.append("\(t(.h2fpefTitle)): \(score.points) \(t(.h2fpefPointsLabel)) — \(app.name(score.category))")
        }
        lines.append("")

        let entries = inputEntries()
        lines.append(t(.sumInputData) + ":")
        if entries.isEmpty {
            lines.append("  —")
        } else {
            for e in entries { lines.append("  • \(e.0): \(e.1)") }
        }
        lines.append("")

        lines.append(t(.sumRecsTitle) + ":")
        for rec in result.recommendations {
            var head = "• [\(app.name(rec.status))] \(rec.title)"
            if let drug = rec.displayDrug { head += " — \(drug)" }
            lines.append(head)
            for j in rec.justifications { lines.append("    – \(j)") }
            if let s = rec.startingDose { lines.append("    \(t(.doseInitial)): \(s)") }
            if let target = rec.targetDose { lines.append("    \(t(.doseTarget)): \(target)") }
            if !rec.safetyAlerts.isEmpty {
                lines.append("    \(t(.secSafetyAlerts)): " + rec.safetyAlerts.map { $0.title }.joined(separator: "; "))
            }
            if !rec.missingData.isEmpty {
                lines.append("    \(t(.missingDataTitle)): " + rec.missingData.map { app.name($0) }.joined(separator: ", "))
            }
        }
        lines.append("")

        if let plan = result.diureticPlan {
            lines.append("\(t(.diureticEstimateTitle)): \(app.format(plan.perDoseMg)) mg × \(plan.dosesPerDay) (\(app.format(plan.totalDailyIVFurosemideMg)) mg/dia)")
            lines.append("")
        }

        if !result.missingEssentialData.isEmpty {
            lines.append(t(.missingDataTitle) + ": " + result.missingEssentialData.map { app.name($0) }.joined(separator: ", "))
            lines.append("")
        }

        if !result.safetyAlerts.isEmpty {
            lines.append(t(.sumAlertsTitle) + ":")
            for a in result.safetyAlerts { lines.append("  • [\(app.name(a.severity))] \(a.title)") }
            lines.append("")
        }

        if !result.references.isEmpty {
            lines.append(t(.refsThisCase) + ":")
            for r in result.references { lines.append("  • \(r.citation)") }
            lines.append("")
        }

        lines.append(t(.txtDisclaimer))
        lines.append("IC Flow • \(ClinicalContent.contentVersion)")
        return lines.joined(separator: "\n")
    }

    // MARK: - PDF

    /// Renders the plain-text export to a paginated PDF and returns a temp URL.
    func makePDFURL() -> URL? {
        let data = makePDFData(text: plainText())
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("IC_Flow_resumo.pdf")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private func makePDFData(text: String) -> Data {
        let pageWidth: CGFloat = 595.2   // A4 @ 72 dpi
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 36
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .paragraphStyle: paragraph
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)
        let textRect = CGRect(x: margin, y: margin, width: pageWidth - 2 * margin, height: pageHeight - 2 * margin)

        return renderer.pdfData { ctx in
            var currentRange = CFRange(location: 0, length: 0)
            var done = false
            while !done {
                ctx.beginPage()
                let cg = ctx.cgContext
                cg.textMatrix = .identity
                cg.translateBy(x: 0, y: pageHeight)
                cg.scaleBy(x: 1, y: -1)

                let path = CGPath(rect: textRect, transform: nil)
                let frame = CTFramesetterCreateFrame(framesetter, currentRange, path, nil)
                CTFrameDraw(frame, cg)

                let visibleRange = CTFrameGetVisibleStringRange(frame)
                currentRange.location += visibleRange.length
                if visibleRange.length == 0 || currentRange.location >= attributed.length {
                    done = true
                }
            }
        }
    }

    // MARK: - Helpers

    private func inputEntries() -> [(String, String)] {
        var entries: [(String, String)] = []
        func add(_ label: String, _ value: String, unit: String = "") {
            let trimmed = value.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return }
            entries.append((label, unit.isEmpty ? trimmed : "\(trimmed) \(unit)"))
        }
        add(app.t(.fieldLVEF), draft.lvef, unit: app.t(.unitPercent))
        if let nyha = draft.nyha { entries.append((app.t(.fieldNYHA), nyha.rawValue)) }
        add(app.t(.fieldSBP), draft.systolicBP, unit: app.t(.unitMmHg))
        add(app.t(.fieldHR), draft.heartRate, unit: app.t(.unitBpm))
        entries.append((app.t(.fieldRhythm), app.name(draft.rhythm)))
        add(app.t(.fieldEGFR), draft.egfr, unit: app.t(.unitEgfr))
        add(app.t(.fieldPotassium), draft.potassium, unit: app.t(.unitMmolL))
        add(app.t(.fieldCreatinine), draft.creatinine, unit: app.t(.unitMgdl))
        add(app.t(.fieldAge), draft.age, unit: app.t(.unitYears))
        entries.append((app.t(.sumCongestion), draft.congestion ? app.t(.yes) : app.t(.no)))
        entries.append((app.t(.sumHypoperfusion), draft.hypoperfusion ? app.t(.yes) : app.t(.no)))
        entries.append((app.t(.sumPriorDiuretic), draft.priorDiureticUse ? app.t(.yes) : app.t(.no)))
        return entries
    }
}
