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

    private let tone = AlarmTone()
    private static let alarmSound = UNNotificationSound(named: UNNotificationSoundName("alarm.caf"))

    /// How many barrage shots follow the head notification, and how far apart.
    /// Swiping one notification away only silences that shot — the next fires
    /// seconds later. Only completing the challenge cancels the rest.
    private static let barrageCount = 23
    private static let barrageInterval: TimeInterval = 10

    // MARK: - Lifecycle / permission
    func activate() {
        UNUserNotificationCenter.current().delegate = self
        refreshAuthorization()
        AlarmKitScheduler.shared.startWatching()
    }

    /// Raise the full-screen challenge. When AlarmKit is driving the alarm the
    /// system is already playing the sound, so we don't layer our own tone on top.
    func beginRinging(_ id: UUID?) {
        if ringingAlarmID == nil { ringingAlarmID = id ?? UUID() }
        if !AlarmKitScheduler.shared.isAuthorized { tone.start() }
        // Staged unblocking only lands once the alarm has actually gone off.
        BlockingStore.shared.applyPendingIfAny()
    }

    /// Ask for the alarm permission that actually matters (AlarmKit), then the
    /// notification permission used as a fallback.
    func requestAllPermissions() async -> Bool {
        let alarmOK = await AlarmKitScheduler.shared.requestAuthorization()
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            requestPermission { _ in c.resume() }
        }
        return alarmOK
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
        scheduleBarrage(for: alarms)
    }

    /// Anti-dismiss barrage: for the next upcoming occurrence, stack follow-up
    /// notifications every few seconds so dismissing one doesn't stop the alarm.
    private func scheduleBarrage(for alarms: [AlarmModel]) {
        let next = alarms.filter(\.enabled)
            .compactMap { a in Self.nextFireDate(a).map { (a, $0) } }
            .min { $0.1 < $1.1 }
        guard let (alarm, fireDate) = next else { return }
        let center = UNUserNotificationCenter.current()
        let cal = Calendar.current
        for i in 1...Self.barrageCount {
            let shot = fireDate.addingTimeInterval(Double(i) * Self.barrageInterval)
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: shot)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            center.add(UNNotificationRequest(identifier: "barrage-\(i)",
                                             content: notificationContent(for: alarm),
                                             trigger: trigger))
        }
    }

    /// The only way to silence a ringing alarm: the challenge was completed.
    /// Cancels the remaining barrage, clears delivered shots, and rebuilds the
    /// schedule for future occurrences.
    func completeChallenge(_ ctx: ModelContext) {
        tone.stop()
        if let id = ringingAlarmID { AlarmKitScheduler.shared.stop(id) }
        ringingAlarmID = nil
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        rescheduleAll(ctx)
    }

    /// If an enabled alarm fired within the last few minutes and no wake was
    /// logged, force the ringing screen — opening the app "normally" is not an
    /// escape hatch.
    func checkMissedRing(_ ctx: ModelContext, window: TimeInterval = 300) {
        guard ringingAlarmID == nil else { return }
        let alarms = (try? ctx.fetch(FetchDescriptor<AlarmModel>())) ?? []
        for a in alarms {
            guard let fired = Self.recentOccurrence(a, within: window) else { continue }
            let logs = (try? ctx.fetch(FetchDescriptor<WakeLog>())) ?? []
            let done = logs.contains { $0.completed && $0.date >= fired }
            if !done {
                beginRinging(a.id)
                return
            }
        }
    }

    /// Most recent occurrence of this alarm within `seconds` before now, if any.
    static func recentOccurrence(_ a: AlarmModel, within seconds: TimeInterval, now: Date = .now) -> Date? {
        guard a.enabled else { return nil }
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = a.hour; comps.minute = a.minute
        guard let todayFire = cal.date(from: comps) else { return nil }
        let elapsed = now.timeIntervalSince(todayFire)
        guard elapsed >= 0, elapsed <= seconds else { return nil }
        if a.repeatMask == 0 { return todayFire }
        let weekday = cal.component(.weekday, from: now)          // 1 = Sunday
        let bit = weekday == 1 ? 6 : weekday - 2
        return a.repeatMask & (1 << bit) != 0 ? todayFire : nil
    }

    /// Single entry point. AlarmKit owns the ringing when it's authorized —
    /// those are real system alarms that break through silent mode and Focus.
    /// Local notifications are only a fallback for when it isn't.
    func rescheduleAll(_ ctx: ModelContext) {
        let all = (try? ctx.fetch(FetchDescriptor<AlarmModel>())) ?? []
        if AlarmKitScheduler.shared.isAuthorized {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            Task { await AlarmKitScheduler.shared.sync(all) }
        } else {
            AlarmKitScheduler.shared.cancelAll()
            reschedule(all)
        }
    }

    /// Developer helper: fire a test alarm in `seconds`, with a mini-barrage
    /// so the swipe-away behavior can be exercised too.
    func scheduleTest(alarmID: UUID?, in seconds: TimeInterval = 10) {
        let content = UNMutableNotificationContent()
        content.title = "Test alarm"
        content.body = "Your alarm is ringing"
        content.sound = Self.alarmSound
        if let alarmID { content.userInfo = ["alarmId": alarmID.uuidString] }
        let center = UNUserNotificationCenter.current()
        for i in 0..<4 {
            let delay = seconds + Double(i) * Self.barrageInterval
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            center.add(UNNotificationRequest(identifier: "alarm-test-\(i)",
                                             content: content, trigger: trigger))
        }
    }

    private func notificationContent(for a: AlarmModel) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = a.name
        content.body = "Complete \(a.challengeName) to turn off your alarm"
        content.sound = Self.alarmSound
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
        let id = (userInfo["alarmId"] as? String).flatMap(UUID.init(uuidString:))
        beginRinging(id)
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
