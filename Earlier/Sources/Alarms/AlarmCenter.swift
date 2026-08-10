import Foundation
import UserNotifications
import SwiftData

/// Schedules alarm notifications from the persisted `AlarmModel` records and
/// surfaces "an alarm is ringing" state to the UI.
///
/// Baseline implementation uses `UserNotifications` (works on a free Apple ID
/// and in the Simulator). The scheduling surface is kept small so an AlarmKit
/// backend (iOS 26, true ring-through) can replace it later without touching
/// the views.
@MainActor
final class AlarmCenter: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = AlarmCenter()
    private override init() { super.init() }

    /// Non-nil while an alarm is ringing; drives the full-screen ringing view.
    @Published var ringingAlarmID: UUID?
    @Published var authorized = false

    // MARK: - Lifecycle / permission
    func activate() {
        UNUserNotificationCenter.current().delegate = self
        refreshAuthorization()
    }

    func refreshAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.authorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestPermission(_ completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                Task { @MainActor in
                    self.authorized = granted
                    completion?(granted)
                }
            }
    }

    // MARK: - Scheduling
    /// Replace all pending alarm notifications with the current enabled set.
    func reschedule(_ alarms: [AlarmModel]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for a in alarms where a.enabled {
            let content = notificationContent(for: a)
            if a.repeatMask == 0 {
                // One-time: next occurrence of hour:minute, non-repeating.
                var comps = DateComponents()
                comps.hour = a.hour; comps.minute = a.minute
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                center.add(UNNotificationRequest(identifier: "alarm-\(a.id)-once",
                                                 content: content, trigger: trigger))
            } else {
                // One repeating request per active weekday.
                for bit in 0..<7 where a.repeatMask & (1 << bit) != 0 {
                    var comps = DateComponents()
                    comps.weekday = Self.gregorianWeekday(bit: bit)
                    comps.hour = a.hour; comps.minute = a.minute
                    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                    center.add(UNNotificationRequest(identifier: "alarm-\(a.id)-d\(bit)",
                                                     content: content, trigger: trigger))
                }
            }
        }
    }

    func rescheduleAll(_ ctx: ModelContext) {
        let all = (try? ctx.fetch(FetchDescriptor<AlarmModel>())) ?? []
        reschedule(all)
    }

    /// Developer helper: fire a one-shot alarm notification in `seconds`.
    func scheduleTest(alarmID: UUID?, in seconds: TimeInterval = 10) {
        let content = UNMutableNotificationContent()
        content.title = "Test alarm"
        content.body = "Your alarm is ringing"
        content.sound = .default
        if let alarmID { content.userInfo = ["alarmId": alarmID.uuidString] }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: "alarm-test", content: content, trigger: trigger))
    }

    private func notificationContent(for a: AlarmModel) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = a.name
        content.body = "Complete \(a.challengeName) to turn off your alarm"
        content.sound = .default
        content.userInfo = ["alarmId": a.id.uuidString]
        return content
    }

    // MARK: - Next occurrence (drives the Home card)
    /// Mon-first bit index -> Gregorian weekday (1 = Sunday … 7 = Saturday).
    static func gregorianWeekday(bit: Int) -> Int { bit == 6 ? 1 : bit + 2 }

    static func nextFireDate(_ a: AlarmModel, from now: Date = .now) -> Date? {
        let cal = Calendar.current
        if a.repeatMask == 0 {
            var c = DateComponents(); c.hour = a.hour; c.minute = a.minute
            return cal.nextDate(after: now, matching: c, matchingPolicy: .nextTime)
        }
        var best: Date?
        for bit in 0..<7 where a.repeatMask & (1 << bit) != 0 {
            var c = DateComponents()
            c.weekday = gregorianWeekday(bit: bit)
            c.hour = a.hour; c.minute = a.minute
            if let d = cal.nextDate(after: now, matching: c, matchingPolicy: .nextTime),
               best == nil || d < best! {
                best = d
            }
        }
        return best
    }

    // MARK: - UNUserNotificationCenterDelegate
    private func openRinging(from userInfo: [AnyHashable: Any]) {
        if let s = userInfo["alarmId"] as? String, let id = UUID(uuidString: s) {
            ringingAlarmID = id
        } else {
            ringingAlarmID = UUID()  // unknown alarm — still show the ringing screen
        }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler:
                                            @escaping (UNNotificationPresentationOptions) -> Void) {
        let info = notification.request.content.userInfo
        Task { @MainActor in self.openRinging(from: info) }
        completionHandler([.sound])  // we present our own full-screen UI in the foreground
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse,
                                            withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        Task { @MainActor in self.openRinging(from: info) }
        completionHandler()
    }
}
