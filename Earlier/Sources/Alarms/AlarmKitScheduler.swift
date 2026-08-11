import Foundation
import SwiftUI
import SwiftData
import AlarmKit
import AppIntents
import ActivityKit

/// Metadata carried alongside each system alarm.
struct EarlierAlarmMetadata: AlarmMetadata {
    var challenge: String = ""
    var label: String = ""
}

/// Tapping the alarm's secondary button opens Earlier straight into the
/// challenge for that alarm.
struct OpenChallengeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Open Earlier"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Alarm")
    var alarmID: String

    init() { alarmID = "" }
    init(alarmID: String) { self.alarmID = alarmID }

    func perform() async throws -> some IntentResult {
        let id = UUID(uuidString: alarmID)
        await MainActor.run {
            AlarmCenter.shared.beginRinging(id)
        }
        return .result()
    }
}

/// The real alarm engine: Apple's **AlarmKit**. These are system alarms — they
/// ring through silent mode and Focus with the same presentation as the
/// built-in Clock app, which local notifications cannot do.
///
/// `AlarmModel.id` is reused as the AlarmKit alarm id so the two stay in sync.
@MainActor
final class AlarmKitScheduler {
    static let shared = AlarmKitScheduler()
    private var watching = false
    private init() {}

    var authorizationState: AlarmManager.AuthorizationState {
        AlarmManager.shared.authorizationState
    }
    var isAuthorized: Bool { authorizationState == .authorized }

    @discardableResult
    func requestAuthorization() async -> Bool {
        if isAuthorized { startWatching(); return true }
        do {
            let granted = try await AlarmManager.shared.requestAuthorization() == .authorized
            if granted { startWatching() }
            return granted
        } catch {
            return false
        }
    }

    /// Mon-first bitmask -> AlarmKit weekdays.
    private static func weekdays(_ mask: Int) -> [Locale.Weekday] {
        let all: [Locale.Weekday] = [.monday, .tuesday, .wednesday, .thursday,
                                     .friday, .saturday, .sunday]
        return (0..<7).compactMap { mask & (1 << $0) != 0 ? all[$0] : nil }
    }

    private func presentation(for a: AlarmModel) -> AlarmPresentation {
        let secondary = AlarmButton(text: "Wake up",
                                    textColor: .white,
                                    systemImageName: "figure.strengthtraining.functional")
        let title = LocalizedStringResource(stringLiteral: a.name)
        let alert: AlarmPresentation.Alert
        if #available(iOS 26.1, *) {
            alert = .init(title: title,
                          secondaryButton: secondary,
                          secondaryButtonBehavior: .custom)
        } else {
            alert = .init(title: title,
                          stopButton: AlarmButton(text: "Stop", textColor: .white,
                                                  systemImageName: "stop.fill"),
                          secondaryButton: secondary,
                          secondaryButtonBehavior: .custom)
        }
        return AlarmPresentation(alert: alert)
    }

    /// Replace the scheduled system alarms with the current enabled set.
    func sync(_ alarms: [AlarmModel]) async {
        guard isAuthorized else { return }

        let wanted = alarms.filter(\.enabled)
        let wantedIDs = Set(wanted.map(\.id))

        // Cancel anything the store no longer wants.
        if let existing = try? AlarmManager.shared.alarms {
            for alarm in existing where !wantedIDs.contains(alarm.id) {
                try? AlarmManager.shared.cancel(id: alarm.id)
            }
        }

        for a in wanted {
            let time = Alarm.Schedule.Relative.Time(hour: a.hour, minute: a.minute)
            let days = Self.weekdays(a.repeatMask)
            let relative = Alarm.Schedule.Relative(
                time: time,
                repeats: days.isEmpty ? .never : .weekly(days))

            let attributes = AlarmAttributes(
                presentation: presentation(for: a),
                metadata: EarlierAlarmMetadata(challenge: a.challengeName, label: a.name),
                tintColor: Color.white)

            let config = AlarmManager.AlarmConfiguration.alarm(
                schedule: .relative(relative),
                attributes: attributes,
                secondaryIntent: OpenChallengeIntent(alarmID: a.id.uuidString),
                sound: .default)

            do {
                _ = try await AlarmManager.shared.schedule(id: a.id, configuration: config)
            } catch {
                print("[AlarmKit] schedule failed for \(a.name): \(error)")
            }
        }
    }

    /// Stop a currently-alerting system alarm (called once the challenge is done).
    func stop(_ id: UUID) {
        try? AlarmManager.shared.stop(id: id)
    }

    func cancelAll() {
        if let existing = try? AlarmManager.shared.alarms {
            for alarm in existing { try? AlarmManager.shared.cancel(id: alarm.id) }
        }
    }

    /// Watch system alarm state; when one starts alerting, raise our challenge UI.
    /// Only once authorized — touching AlarmKit while the permission is still
    /// undetermined re-triggers the system prompt.
    func startWatching() {
        guard !watching, isAuthorized else { return }
        watching = true
        Task { [weak self] in
            for await alarms in AlarmManager.shared.alarmUpdates {
                guard self != nil else { return }
                if let alerting = alarms.first(where: { $0.state == .alerting }) {
                    AlarmCenter.shared.beginRinging(alerting.id)
                }
            }
        }
    }
}
