import SwiftUI

enum Tab: String, CaseIterable {
    case home, alarm, bedtime, settings
    var title: String {
        switch self {
        case .home: return "Home"
        case .alarm: return "Alarm"
        case .bedtime: return "Bedtime"
        case .settings: return "Settings"
        }
    }
}

/// Full-screen overlays (design `view` state).
enum Overlay {
    case history, windDown, newAlarm, editBedtime, achievements, streak, reason, signature
}

/// Sheets stacked on top of newAlarm / editBedtime (design `sub` state).
enum Sub {
    case time, sound, challenge, blocking
}

final class AppState: ObservableObject {
    @Published var tab: Tab = .home
    @Published var view: Overlay? = nil
    @Published var sub: Sub? = nil

    // Navigation actions (mirrors renderVals in the design)
    func go(_ t: Tab) { tab = t }
    func open(_ v: Overlay) { view = v }
    func back() { view = nil; sub = nil }
    func backSub() { sub = nil }
    func openSub(_ s: Sub) { sub = s }

    /// "Add alarm" opens the New alarm sheet — or Edit bedtime when on the Bedtime tab.
    func openNewAlarm() { view = tab == .bedtime ? .editBedtime : .newAlarm }

    /// True when a `view` overlay fully covers the tab bar (everything except History).
    var overlayCoversChrome: Bool {
        guard let v = view else { return false }
        return v != .history
    }
}
