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
    /// Challenge/sound picked in the New-alarm flow (the sub-sheets write these).
    @Published var draftChallenge = "Push ups"
    @Published var draftSound = "Default"
    /// When set, the Challenge/Sound sheets edit this existing alarm instead of
    /// the new-alarm draft.
    @Published var editingAlarmID: UUID? = nil
    /// Non-nil while the "Wait a minute." friction screen is up.
    @Published var guardAction: GuardAction? = nil

    /// Open a picker sheet against an existing alarm.
    func editAlarm(_ id: UUID, _ s: Sub) {
        editingAlarmID = id
        sub = s
    }

    // Navigation actions (mirrors renderVals in the design)
    func go(_ t: Tab) { tab = t }
    func open(_ v: Overlay) { view = v }
    func back() { view = nil; sub = nil; editingAlarmID = nil }
    func backSub() { sub = nil; editingAlarmID = nil }
    func openSub(_ s: Sub) { sub = s }

    /// "Add alarm" opens the New alarm sheet — or Edit bedtime when on the Bedtime tab.
    func openNewAlarm() {
        draftChallenge = "Push ups"
        draftSound = "Default"
        editingAlarmID = nil
        view = tab == .bedtime ? .editBedtime : .newAlarm
    }

    /// True when a `view` overlay fully covers the tab bar (everything except History).
    var overlayCoversChrome: Bool {
        guard let v = view else { return false }
        return v != .history
    }
}
