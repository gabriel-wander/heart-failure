import Foundation

/// A single item of the post-decompensation discharge checklist.
///
/// Content lives in `discharge_checklist_<lang>.json` so it can be edited and
/// translated without code changes. The app tracks check state only in memory
/// (nothing is persisted, no patient data).
public struct ChecklistItem: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public let text: String
    /// Optional hint shown under the item.
    public let detail: String?

    public init(id: String, text: String, detail: String? = nil) {
        self.id = id
        self.text = text
        self.detail = detail
    }
}
