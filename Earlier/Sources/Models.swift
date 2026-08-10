import SwiftUI

struct DayBar: Identifiable { let id = UUID(); let label: String; let color: Color }
struct WeekRow: Identifiable { let id = UUID(); let label: String; let pct: CGFloat; let count: String; let color: Color }
struct AlarmItem: Identifiable { let id = UUID(); let name: String; let time: String }
struct BedtimeItem: Identifiable { let id = UUID(); let name: String; let days: String; let time: String }
struct Challenge: Identifiable { let id = UUID(); let emoji: String; let name: String; let desc: String; let sel: Bool }
struct SoundOption: Identifiable { let id = UUID(); let name: String; let icon: Ico; let sel: Bool }
struct Achievement: Identifiable { let id = UUID(); let name: String; let streak: String; let desc: String; let on: Bool }
struct DayToggle: Identifiable { let id = UUID(); let label: String; let on: Bool }
struct PickerValue: Identifiable { let id = UUID(); let v: String; let on: Bool }

enum Mock {
    static let week: [DayBar] = [
        .init(label: "T", color: C.barTrack), .init(label: "W", color: C.barTrack),
        .init(label: "T", color: C.barTrack), .init(label: "F", color: C.barTrack),
        .init(label: "S", color: C.barTrack), .init(label: "S", color: C.barTrack),
        .init(label: "M", color: C.orange)
    ]

    static let weeks: [WeekRow] = [
        .init(label: "This week", pct: 0.00, count: "0/7", color: C.toggleOff),
        .init(label: "1 wk ago",  pct: 0.28, count: "2/7", color: C.toggleOff),
        .init(label: "2 wks ago", pct: 1.00, count: "7/7", color: C.orange),
        .init(label: "3 wks ago", pct: 0.57, count: "4/7", color: C.toggleOff)
    ]

    static let alarms: [AlarmItem] = [
        .init(name: "First alarm", time: "6:30 AM"),
        .init(name: "Honung", time: "4:15 PM"),
        .init(name: "Try3", time: "6:25 AM"),
        .init(name: "Try3", time: "7:00 AM")
    ]

    static let bedtimes: [BedtimeItem] = [
        .init(name: "Try1", days: "Weekdays", time: "6:20 PM"),
        .init(name: "Try 2", days: "Wed", time: "8:30 PM"),
        .init(name: "Try", days: "Weekdays", time: "9:45 PM")
    ]

    static let challenges: [Challenge] = [
        .init(emoji: "🪥", name: "Item scan", desc: "Scan a chosen item — like your toothbrush", sel: false),
        .init(emoji: "🏋️", name: "Push ups", desc: "Complete push-ups to start your day strong", sel: true),
        .init(emoji: "🔍", name: "Item search", desc: "Find and photograph a random item", sel: false),
        .init(emoji: "🧮", name: "Math problem", desc: "Solve a problem to prove your brain is on", sel: false),
        .init(emoji: "📖", name: "Bible verse", desc: "Read a verse aloud to start your day", sel: false),
        .init(emoji: "🏃", name: "Squats", desc: "Complete squats to get your blood moving", sel: false)
    ]

    static let sounds: [SoundOption] = [
        .init(name: "Default", icon: Icons.soundDefault, sel: false),
        .init(name: "Birds", icon: Icons.soundBirds, sel: true),
        .init(name: "Peaceful", icon: Icons.soundPeaceful, sel: false),
        .init(name: "Piano", icon: Icons.soundPiano, sel: false),
        .init(name: "Ambient", icon: Icons.soundAmbient, sel: false),
        .init(name: "Guitar", icon: Icons.soundGuitar, sel: false),
        .init(name: "Mayhem", icon: Icons.soundMayhem, sel: false)
    ]

    static let achievements: [Achievement] = [
        .init(name: "Early Riser", streak: "1 day streak", desc: "The journey of a thousand mornings begins with a single sunrise.", on: true),
        .init(name: "Dawn Seeker", streak: "3 day streak", desc: "You've discovered the magic of the early hours.", on: false),
        .init(name: "Early Bird", streak: "7 day streak", desc: "A full week of committing to your mornings.", on: false),
        .init(name: "Routine Builder", streak: "10 day streak", desc: "Double digits. Discipline outweighs the desire for sleep.", on: false),
        .init(name: "Morning Person", streak: "14 day streak", desc: "The hard part is over — you are now a morning person.", on: false),
        .init(name: "Ritualist", streak: "21 day streak", desc: "Three weeks in. This is who you are now.", on: false)
    ]

    // Weekday selection pattern used by New alarm / Edit bedtime.
    static let days: [DayToggle] = [
        .init(label: "S", on: false), .init(label: "M", on: true), .init(label: "T", on: true),
        .init(label: "W", on: true),  .init(label: "T", on: true), .init(label: "F", on: true),
        .init(label: "S", on: false)
    ]

    static let hours: [PickerValue] = [
        .init(v: "04", on: false), .init(v: "05", on: false), .init(v: "06", on: true),
        .init(v: "07", on: false), .init(v: "08", on: false)
    ]
    static let minutes: [PickerValue] = [
        .init(v: "20", on: false), .init(v: "25", on: false), .init(v: "30", on: true),
        .init(v: "35", on: false), .init(v: "40", on: false)
    ]
}
