import SwiftUI
import SwiftData

enum StepKind {
    case welcome
    case question(title: String, options: [String])
    case sources
    case chart
    case compare(filled: Bool)
    case info(art: String, title: String, body: String, cta: String)
    case picker(title: String, subtitle: String, hour: Int, minute: Int, cta: String)
    case statement
    case trust
    case missions
    case why
    case days
    case bars
    case referral
    case notify
    case sign
    case loading
    case summary
    case signin
    case paywall
}

struct WheelValue: Identifiable {
    let id = UUID(); let v: String; let size: CGFloat; let color: Color
}

final class OnboardingState: ObservableObject {
    @Published var step = 0
    @Published var answers: [Int: Int] = [1: 0, 2: 0, 6: 1, 11: 0, 18: 0]
    @Published var mission = 2
    @Published var days = [true, true, true, true, true, false, false]
    /// Times chosen on the picker steps, keyed by step index.
    @Published var pickedTimes: [Int: DateComponents] = [:]

    /// The alarm the user actually committed to (step 24), falling back to
    /// their stated ideal wake time, then 6:30.
    var committedTime: (hour: Int, minute: Int) {
        for step in [24, 16] {
            if let c = pickedTimes[step], let h = c.hour, let m = c.minute { return (h, m) }
        }
        return (6, 30)
    }

    let steps: [StepKind] = [
        .welcome,                                                                                   // 0
        .question(title: "What is your gender?", options: ["Male", "Female", "Prefer not to say"]), // 1
        .question(title: "Do you consider yourself a morning person?", options: ["Yes", "No"]),     // 2
        .sources,                                                                                   // 3
        .question(title: "What is your biggest obstacle to getting out of bed?",
                  options: ["I scroll on my phone", "I hit snooze repeatedly",
                            "I sleep through my alarms", "None of the above"]),                      // 4
        .chart,                                                                                     // 5
        .question(title: "How many alarms do you usually set?",
                  options: ["Just one", "2 or 3", "4 or more"]),                                    // 6
        .question(title: "Do you trust yourself to wake up after the first alarm?",
                  options: ["Yes, always", "Sometimes, it's a gamble", "No, never"]),               // 7
        .question(title: "Do you ever turn off your alarm and go back to sleep?",
                  options: ["Yes, it happens often", "Sometimes",
                            "No, but I worry I might", "No, never"]),                                // 8
        .compare(filled: false),                                                                    // 9
        .compare(filled: true),                                                                     // 10
        .question(title: "How do you usually feel when you set your alarm at night?",
                  options: ["Motivated and ready", "Anxious about sleep",
                            "Defeated, I know I'll snooze", "Neutral"]),                             // 11
        .question(title: "When the alarm rings, what is your immediate thought?",
                  options: ["I\u{2019}m up!", "I'll get up after the next alarm",
                            "Just 5 more minutes...", "Why did I set this?"]),                       // 12
        .question(title: "Do you negotiate with yourself to stay in bed?",
                  options: ["Yes, I make deals with myself", "No, I get right up"]),                 // 13
        .info(art: "brain illustration", title: "It's not a discipline problem",
              body: "You aren't lazy. You are fighting biology. When the alarm rings, your brain's prefrontal cortex (the self-control part) is offline. This sleep inertia makes snoozing feel like the only decision.",
              cta: "Continue"),                                                                      // 14
        .picker(title: "What time do you usually get out of bed?",
                subtitle: "Be honest - we won't judge", hour: 8, minute: 0, cta: "Continue"),       // 15
        .picker(title: "What time would you like to get out of bed?",
                subtitle: "The time you wish you could wake up every day",
                hour: 6, minute: 30, cta: "Continue"),                                              // 16
        .statement,                                                                                 // 17
        .question(title: "How do you feel immediately after waking up?",
                  options: ["Ready to go", "Still sleepy", "Anxious or stressed", "None of the above"]), // 18
        .question(title: "How long does it usually take you to feel fully awake?",
                  options: ["Instantly", "10-15 minutes", "30 minutes or more"]),                   // 19
        .question(title: "What do you currently rely on to clear that brain fog?",
                  options: ["Coffee or caffeine", "Scrolling social media", "Showering",
                            "Sheer willpower", "Something else"]),                                   // 20
        .info(art: "push-up illustration", title: "Wake the body to wake the mind",
              body: "Physical movement spikes cortisol (the wake-up hormone) and clears sleep inertia instantly. By the time the alarm is off, you are fully awake.",
              cta: "Continue"),                                                                      // 21
        .trust,                                                                                     // 22
        .info(art: "sunrise illustration", title: "Let's build your wake up protocol",
              body: "We will now calibrate Erly to your physical ability and sleep depth.",
              cta: "Build my protocol"),                                                            // 23
        .picker(title: "You set a goal. Now set the alarm.",
                subtitle: "Earlier, you identified 6:30 AM as your ideal wake up time. Let's set your first alarm for this time.",
                hour: 6, minute: 30, cta: "Commit to 6:30 AM"),                                     // 24
        .missions,                                                                                  // 25
        .why,                                                                                       // 26
        .days,                                                                                      // 27
        .bars,                                                                                      // 28
        .referral,                                                                                  // 29
        .notify,                                                                                    // 30
        .sign,                                                                                      // 31
        .loading,                                                                                   // 32
        .summary,                                                                                   // 33
        .signin,                                                                                    // 34
        .paywall                                                                                    // 35
    ]

    var current: StepKind { steps[step] }
    var progress: CGFloat { CGFloat(step) / CGFloat(steps.count - 1) }
    var isLast: Bool { step == steps.count - 1 }
    var answeredCurrent: Bool { answers[step] != nil }

    func next() { step = min(step + 1, steps.count - 1) }

    /// The real setup work, run while the "setting everything up" screen is
    /// on screen — so that progress bar reflects something actually happening.
    @MainActor
    func applySetup(_ ctx: ModelContext) {
        var mask = 0
        for (i, on) in days.enumerated() where on { mask |= (1 << i) }   // days is Mon-first
        let missionName = onboardingMissions.indices.contains(mission)
            ? onboardingMissions[mission].name : "Push ups"
        let t = committedTime

        let existing = try? ctx.fetch(FetchDescriptor<AlarmModel>())
        if let alarm = existing?.first {
            alarm.hour = t.hour; alarm.minute = t.minute; alarm.repeatMask = mask
            alarm.challengeName = missionName; alarm.enabled = true; alarm.touch()
        } else {
            ctx.insert(AlarmModel(name: "First alarm", hour: t.hour, minute: t.minute,
                                  repeatMask: mask, soundName: "Birds",
                                  challengeName: missionName, enabled: true))
        }
        try? ctx.save()
    }
    func prev() { step = max(step - 1, 0) }
    func pick(_ i: Int) { answers[step] = i }
    func toggleDay(_ i: Int) { days[i].toggle() }

    /// 7-value wheel centered on `center`, wrapping mod `mod`, zero-padded.
    func wheel(center: Int, mod: Int) -> [WheelValue] {
        (-3...3).map { d in
            let v = ((center + d) % mod + mod) % mod
            let a = abs(d)
            let color: Color = a == 0 ? C.ink : a == 1 ? Color(hex: "B4B0A8")
                : a == 2 ? Color(hex: "CFCBC4") : Color(hex: "E2DFD8")
            return WheelValue(v: String(format: "%02d", v), size: a == 0 ? 23 : 22, color: color)
        }
    }
}

let onboardingSources = ["YouTube", "TikTok", "Instagram", "App Store", "Facebook", "Google", "X"]

struct OnboardingMission {
    let emoji: String; let name: String; let desc: String
}
let onboardingMissions: [OnboardingMission] = [
    .init(emoji: "🔍", name: "Item Search", desc: "Find and photograph a random item"),
    .init(emoji: "🏋️", name: "Push Ups", desc: "Complete push-ups to start your day strong"),
    .init(emoji: "🏃", name: "Squats", desc: "Complete squats to start your day strong"),
    .init(emoji: "📖", name: "Bible Verse", desc: "Read a Bible verse out loud to begin your morning"),
    .init(emoji: "🕊️", name: "Devotional", desc: "Read a short devotional to center your day")
]
