import SwiftUI

/// Derives the streak and charts from the real `WakeLog` records.
enum Stats {
    private static var cal: Calendar { Calendar.current }

    static func completedDays(_ logs: [WakeLog]) -> Set<Date> {
        Set(logs.filter(\.completed).map { cal.startOfDay(for: $0.date) })
    }

    /// Consecutive completed days ending today (or yesterday, since today's
    /// alarm may not have rung yet).
    static func streak(_ logs: [WakeLog], now: Date = .now) -> Int {
        let days = completedDays(logs)
        var cursor = cal.startOfDay(for: now)
        if !days.contains(cursor) {
            guard let y = cal.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = y
        }
        var count = 0
        while days.contains(cursor) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }

    static func bestStreak(_ logs: [WakeLog]) -> Int {
        let days = completedDays(logs).sorted()
        guard !days.isEmpty else { return 0 }
        var best = 1, run = 1
        for i in 1..<days.count {
            if let next = cal.date(byAdding: .day, value: 1, to: days[i - 1]), next == days[i] {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
        }
        return best
    }

    /// Last 7 days, oldest first — one bar per day.
    static func lastSevenDays(_ logs: [WakeLog], now: Date = .now) -> [DayBar] {
        let days = completedDays(logs)
        let f = DateFormatter(); f.dateFormat = "EEEEE"   // single-letter weekday
        return (0..<7).reversed().compactMap { offset in
            guard let d = cal.date(byAdding: .day, value: -offset,
                                   to: cal.startOfDay(for: now)) else { return nil }
            return DayBar(label: f.string(from: d),
                          color: days.contains(d) ? C.orange : C.barTrack)
        }
    }

    /// Wake-ups per week for the last 4 weeks, most recent first.
    static func lastFourWeeks(_ logs: [WakeLog], now: Date = .now) -> [WeekRow] {
        let days = completedDays(logs)
        let today = cal.startOfDay(for: now)
        let labels = ["This week", "1 wk ago", "2 wks ago", "3 wks ago"]
        return (0..<4).map { w in
            var hits = 0
            for d in 0..<7 {
                let offset = -(w * 7 + d)
                if let day = cal.date(byAdding: .day, value: offset, to: today),
                   days.contains(day) { hits += 1 }
            }
            return WeekRow(label: labels[w],
                           pct: CGFloat(hits) / 7.0,
                           count: "\(hits)/7",
                           color: hits >= 7 ? C.orange : C.toggleOff)
        }
    }

    /// Average rise time across logged wake-ups, e.g. "7:17". Nil when no data.
    static func averageRise(_ logs: [WakeLog]) -> String? {
        let done = logs.filter(\.completed)
        guard !done.isEmpty else { return nil }
        let minutes = done.map { log -> Int in
            let c = cal.dateComponents([.hour, .minute], from: log.date)
            return (c.hour ?? 0) * 60 + (c.minute ?? 0)
        }
        let avg = minutes.reduce(0, +) / minutes.count
        return String(format: "%d:%02d", avg / 60, avg % 60)
    }
}
