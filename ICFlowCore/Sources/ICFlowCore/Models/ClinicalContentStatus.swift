import Foundation

/// Validation state of the bundled clinical content.
///
/// While the medical content is being reviewed, this flag stays `false` so the
/// interface can surface a clear "content under validation" notice. It is a
/// build-time constant (no persistence, no network).
public enum ClinicalContent {
    /// `false` until the clinical content has been formally reviewed and signed
    /// off (see `VALIDATION_PLAN.md` / `CLINICAL_CONTENT_STATUS.md`).
    public static let isClinicalContentValidated = false

    /// Human-readable content version, bumped when the JSON content changes.
    /// Note: this versions the content for traceability; clinical validation is
    /// tracked separately by `isClinicalContentValidated` (still `false`).
    public static let contentVersion = "1.0.0"
}
