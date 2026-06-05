import SwiftUI
import ICFlowCore

/// Bedside calculators (anonymous, in-memory only). Each result updates live.
struct CalculatorsView: View {
    @EnvironmentObject private var app: AppModel

    // CHA₂DS₂-VASc
    @State private var hf = false
    @State private var htn = false
    @State private var dm = false
    @State private var stroke = false
    @State private var vascular = false
    @State private var chaFemale = false
    @State private var chaAge = ""

    // eGFR
    @State private var creatinine = ""
    @State private var egfrAge = ""
    @State private var egfrFemale = false

    // Ganzoni
    @State private var weight = ""
    @State private var hbCurrent = ""
    @State private var hbTarget = "15"

    // Sodium
    @State private var measuredNa = ""
    @State private var glucose = ""

    var body: some View {
        Form {
            cha2Section
            egfrSection
            ironSection
            sodiumSection
        }
        .navigationTitle(app.t(.calcNavTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { LanguageMenu() }
        }
    }

    // MARK: - Sections

    private var cha2Section: some View {
        Section(app.t(.calcCHA2Title)) {
            Toggle(app.t(.calcHF), isOn: $hf)
            Toggle(app.t(.toggleHypertension), isOn: $htn)
            numberField(app.t(.fieldAge), app.t(.unitYears), $chaAge)
            Toggle(app.t(.toggleDiabetes), isOn: $dm)
            Toggle(app.t(.calcStroke), isOn: $stroke)
            Toggle(app.t(.calcVascular), isOn: $vascular)
            Toggle(app.t(.calcFemale), isOn: $chaFemale)
            resultRow(app.t(.calcScoreLabel), "\(cha2Score)")
        }
    }

    private var egfrSection: some View {
        Section(app.t(.calcEGFRTitle)) {
            numberField(app.t(.fieldCreatinine), app.t(.unitMgdl), $creatinine)
            numberField(app.t(.fieldAge), app.t(.unitYears), $egfrAge)
            Toggle(app.t(.calcFemale), isOn: $egfrFemale)
            resultRow("TFGe", egfrText)
        }
    }

    private var ironSection: some View {
        Section(app.t(.calcIronTitle)) {
            numberField(app.t(.calcWeight), app.t(.unitKg), $weight)
            numberField(app.t(.calcHbCurrent), app.t(.unitGdl), $hbCurrent)
            numberField(app.t(.calcHbTarget), app.t(.unitGdl), $hbTarget)
            resultRow(app.t(.calcDeficitLabel), ironText)
        }
    }

    private var sodiumSection: some View {
        Section(app.t(.calcSodiumTitle)) {
            numberField(app.t(.calcNaMeasured), app.t(.unitMmolL), $measuredNa)
            numberField(app.t(.calcGlucose), app.t(.unitMgdl), $glucose)
            resultRow(app.t(.calcCorrectedLabel), sodiumText)
        }
    }

    // MARK: - Computed results

    private var cha2Score: Int {
        Calculators.cha2ds2vasc(
            heartFailure: hf, hypertension: htn, age: num(chaAge), diabetes: dm,
            strokeOrTIA: stroke, vascularDisease: vascular, female: chaFemale
        )
    }

    private var egfrText: String {
        guard let cr = num(creatinine), let age = num(egfrAge),
              let egfr = Calculators.ckdEpiEGFR(creatinineMgDl: cr, age: age, female: egfrFemale)
        else { return "—" }
        return "\(app.format((egfr * 10).rounded() / 10)) \(app.t(.unitEgfr))"
    }

    private var ironText: String {
        guard let w = num(weight), let cur = num(hbCurrent), let tgt = num(hbTarget),
              let deficit = Calculators.ganzoniIronDeficitMg(weightKg: w, currentHb: cur, targetHb: tgt)
        else { return "—" }
        return "\(app.format(deficit.rounded())) \(app.t(.unitMg))"
    }

    private var sodiumText: String {
        guard let na = num(measuredNa), let glu = num(glucose) else { return "—" }
        let corrected = Calculators.correctedSodium(measuredNa: na, glucoseMgDl: glu)
        return "\(app.format((corrected * 10).rounded() / 10)) \(app.t(.unitMmolL))"
    }

    // MARK: - Helpers

    private func num(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
    }

    private func numberField(_ title: String, _ unit: String, _ text: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("—", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 90)
            Text(unit).font(.caption).foregroundStyle(.secondary).frame(width: 70, alignment: .leading)
        }
    }

    private func resultRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.subheadline.bold())
            Spacer()
            Text(value).font(.headline).foregroundStyle(.teal)
        }
    }
}
