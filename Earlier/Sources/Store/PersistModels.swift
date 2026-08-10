import Foundation
import SwiftData

// MARK: - Weekday helpers
// repeatMask: bit i set = active, where bit 0 = Monday … bit 6 = Sunday.
enum Weekdays {
    static let shortMonFirst = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    static func label(_ mask: Int) -> String {
        let active = (0..<7).filter { mask & (1 << $0) != 0 }
        if active.count == 7 { return "Every day" }
        if active == [0, 1, 2, 3, 4] { return "Weekdays" }
        if active == [5, 6] { return "Weekends" }
        if active.isEmpty { return "Once" }
        return active.map { shortMonFirst[$0] }.joined(separator: ", ")
    }

    /// Picker order is Sun-first (S M T W T F S). Convert a 7-bool picker
    /// selection into a Mon-first bitmask.
    static func maskFromPicker(_ picker: [Bool]) -> Int {
        var mask = 0
        for (i, on) in picker.enumerated() where on {
            let bit = i == 0 ? 6 : i - 1   // Sun -> bit 6, Mon..Sat -> 0..5
            mask |= (1 << bit)
        }
        return mask
    }

    /// Mon-first bitmask -> Sun-first 7-bool picker selection.
    static func pickerFromMask(_ mask: Int) -> [Bool] {
        (0..<7).map { i in
            let bit = i == 0 ? 6 : i - 1
            return mask & (1 << bit) != 0
        }
    }
}

private func timeString(hour: Int, minute: Int) -> String {
    var c = DateComponents(); c.hour = hour; c.minute = minute
    let date = Calendar.current.date(from: c) ?? Date()
    let f = DateFormatter(); f.dateFormat = "h:mm a"
    return f.string(from: date)
}

// MARK: - Models (sync-ready: stable UUID + updatedAt)
@Model
final class AlarmModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var hour: Int
    var minute: Int
    var repeatMask: Int
    var soundName: String
    var challengeName: String
    var enabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, hour: Int, minute: Int, repeatMask: Int,
         soundName: String = "Default", challengeName: String = "Push ups",
         enabled: Bool = true, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id; self.name = name; self.hour = hour; self.minute = minute
        self.repeatMask = repeatMask; self.soundName = soundName
        self.challengeName = challengeName; self.enabled = enabled
        self.createdAt = createdAt; self.updatedAt = updatedAt
    }

    var timeLabel: String { timeString(hour: hour, minute: minute) }
    var daysLabel: String { Weekdays.label(repeatMask) }
    func touch() { updatedAt = .now }
}

@Model
final class BedtimeModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var hour: Int
    var minute: Int
    var repeatMask: Int
    var enabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, hour: Int, minute: Int, repeatMask: Int,
         enabled: Bool = true, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id; self.name = name; self.hour = hour; self.minute = minute
        self.repeatMask = repeatMask; self.enabled = enabled
        self.createdAt = createdAt; self.updatedAt = updatedAt
    }

    var timeLabel: String { timeString(hour: hour, minute: minute) }
    var daysLabel: String { Weekdays.label(repeatMask) }
    func touch() { updatedAt = .now }
}

/// A completed (or missed) wake-up — drives streak / history in a later phase.
@Model
final class WakeLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var completed: Bool
    var alarmId: UUID?
    var updatedAt: Date

    init(id: UUID = UUID(), date: Date = .now, completed: Bool = true,
         alarmId: UUID? = nil, updatedAt: Date = .now) {
        self.id = id; self.date = date; self.completed = completed
        self.alarmId = alarmId; self.updatedAt = updatedAt
    }
}

// MARK: - Container + seeding
enum Persistence {
    static let models: [any PersistentModel.Type] = [AlarmModel.self, BedtimeModel.self, WakeLog.self]

    static func makeContainer() -> ModelContainer {
        let schema = Schema(models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fall back to in-memory so the app still runs if the on-disk store
            // can't be opened (e.g. a schema change during development).
            let mem = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [mem])
        }
    }

    /// Insert sensible defaults the first time the app runs with an empty store.
    static func seedIfEmpty(_ context: ModelContext) {
        let alarmCount = (try? context.fetchCount(FetchDescriptor<AlarmModel>())) ?? 0
        if alarmCount == 0 {
            context.insert(AlarmModel(name: "First alarm", hour: 6, minute: 30,
                                      repeatMask: 0b0011111, soundName: "Birds",
                                      challengeName: "Push ups"))
        }
        let bedtimeCount = (try? context.fetchCount(FetchDescriptor<BedtimeModel>())) ?? 0
        if bedtimeCount == 0 {
            context.insert(BedtimeModel(name: "Bedtime", hour: 22, minute: 30,
                                        repeatMask: 0b0011111, enabled: true))
        }
        try? context.save()
    }
}
