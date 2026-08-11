import Foundation
import SwiftUI

/// The app categories Earlier can block at bedtime.
enum BlockCategory: String, CaseIterable, Identifiable {
    case social = "Social"
    case video = "Video"
    case games = "Games"
    case news = "News"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case music = "Music"
    case reading = "Reading"
    case productivity = "Productivity"
    case travel = "Travel"
    case other = "Other"

    var id: String { rawValue }
}

/// Blocking configuration with **deferred loosening**.
///
/// Tightening (blocking more) applies immediately. Loosening — unblocking a
/// category so you can scroll tonight — does not: it is staged and only takes
/// effect at the next alarm. That removes the "just unblock it for a second"
/// escape hatch, the same way the bedtime guard removes the quick toggle-off.
@MainActor
final class BlockingStore: ObservableObject {
    static let shared = BlockingStore()

    private let d = UserDefaults.standard
    private let activeKey = "blocking.active"
    private let pendingKey = "blocking.pending"
    private let enabledKey = "blocking.enabled"

    @Published private(set) var active: Set<String>
    /// Staged selection that becomes active at the next alarm (nil = no change staged).
    @Published private(set) var pending: Set<String>?
    @Published private(set) var isOn: Bool

    private init() {
        active = Set(d.stringArray(forKey: activeKey) ?? BlockCategory.allCases.map(\.rawValue))
        if let p = d.stringArray(forKey: pendingKey) { pending = Set(p) } else { pending = nil }
        isOn = d.object(forKey: enabledKey) as? Bool ?? true
    }

    /// What the user sees as "selected" — the staged set when one exists.
    var displayed: Set<String> { pending ?? active }

    var activeSummary: String { "0 apps · \(active.count) categories" }
    var displayedSummary: String { "0 apps · \(displayed.count) categories" }
    var hasPendingChange: Bool { pending != nil && pending != active }

    /// Toggle a category. Adding more restriction lands now; removing one is
    /// staged for the next alarm.
    func toggle(_ category: BlockCategory) {
        var next = displayed
        let removing = next.contains(category.rawValue)
        if removing { next.remove(category.rawValue) } else { next.insert(category.rawValue) }

        if removing {
            pending = next
            d.set(Array(next), forKey: pendingKey)
        } else {
            // Tightening is allowed immediately; keep any other staged edits.
            active.insert(category.rawValue)
            d.set(Array(active), forKey: activeKey)
            if pending != nil {
                pending = next
                d.set(Array(next), forKey: pendingKey)
            }
        }
        objectWillChange.send()
    }

    /// Promote staged changes — called when an alarm fires.
    func applyPendingIfAny() {
        guard let p = pending else { return }
        active = p
        pending = nil
        d.set(Array(active), forKey: activeKey)
        d.removeObject(forKey: pendingKey)
    }

    func turnOff() {
        isOn = false
        d.set(false, forKey: enabledKey)
    }

    func turnOn() {
        isOn = true
        d.set(true, forKey: enabledKey)
    }
}
