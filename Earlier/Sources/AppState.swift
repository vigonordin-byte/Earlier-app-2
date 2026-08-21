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
    case history, windDown, alarmEditor, bedtimeEditor, achievements, streak, reason, signature
}

/// Sheets stacked on top of the editors (design `sub` state).
enum Sub {
    case time, sound, challenge, blocking
}

/// Everything the alarm/bedtime editors edit. Populated from an existing
/// record when editing, or with sensible defaults when creating.
struct AlarmDraft {
    var name = ""
    var hour = 7
    var minute = 0
    /// Sun-first, matching the on-screen day picker.
    var days = [false, true, true, true, true, true, false]
    var sound = "Default"
    var challenge = "Push ups"

    var timeLabel: String { timeString(hour: hour, minute: minute) }
}

final class AppState: ObservableObject {
    @Published var tab: Tab = .home
    @Published var view: Overlay? = nil
    @Published var sub: Sub? = nil

    /// What the open editor is working on.
    @Published var draft = AlarmDraft()
    /// Set while the alarm editor is editing an existing alarm (nil = creating).
    @Published var editingAlarmID: UUID? = nil
    /// Set while the bedtime editor is editing an existing bedtime (nil = creating).
    @Published var editingBedtimeID: UUID? = nil
    /// Set when a sheet was opened straight from the Home card to change one
    /// field on an existing alarm, bypassing the editor.
    @Published var quickEditAlarmID: UUID? = nil

    /// Non-nil while the "Wait a minute." friction screen is up.
    @Published var guardAction: GuardAction? = nil

    // MARK: - Navigation
    func go(_ t: Tab) { tab = t }
    func open(_ v: Overlay) { view = v }
    func back() { view = nil; sub = nil; quickEditAlarmID = nil }
    func backSub() { sub = nil; quickEditAlarmID = nil }
    func openSub(_ s: Sub) { sub = s }

    /// Quick-change one field of an existing alarm from the Home card.
    func quickEdit(_ id: UUID, _ s: Sub) {
        quickEditAlarmID = id
        sub = s
    }

    // MARK: - Editors
    func openNewAlarm() {
        draft = AlarmDraft(hour: 7, minute: 0)
        editingAlarmID = nil
        quickEditAlarmID = nil
        view = .alarmEditor
    }

    func openEditAlarm(_ a: AlarmModel) {
        draft = AlarmDraft(name: a.name, hour: a.hour, minute: a.minute,
                           days: Weekdays.pickerFromMask(a.repeatMask),
                           sound: a.soundName, challenge: a.challengeName)
        editingAlarmID = a.id
        quickEditAlarmID = nil
        view = .alarmEditor
    }

    func openNewBedtime() {
        draft = AlarmDraft(hour: 22, minute: 30)
        editingBedtimeID = nil
        view = .bedtimeEditor
    }

    func openEditBedtime(_ b: BedtimeModel) {
        draft = AlarmDraft(name: b.name, hour: b.hour, minute: b.minute,
                           days: Weekdays.pickerFromMask(b.repeatMask))
        editingBedtimeID = b.id
        view = .bedtimeEditor
    }

    /// The "+" button: context-sensitive to the current tab.
    func openAddForCurrentTab() {
        if tab == .bedtime { openNewBedtime() } else { openNewAlarm() }
    }

    /// True when a `view` overlay fully covers the tab bar (everything except History).
    var overlayCoversChrome: Bool {
        guard let v = view else { return false }
        return v != .history
    }
}
