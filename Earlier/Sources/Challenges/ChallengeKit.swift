import SwiftUI

/// Which challenge mechanic a challenge name maps to.
enum ChallengeKind {
    case math
    case reps(String)      // "Push ups" / "Squats"
    case readAloud(String) // "Bible verse" / "Devotional"
    case findItem(String)  // "Item scan" / "Item search"

    static func from(_ name: String) -> ChallengeKind {
        let n = name.lowercased()
        if n.contains("math") { return .math }
        if n.contains("push") || n.contains("squat") { return .reps(name) }
        if n.contains("bible") || n.contains("devotional") { return .readAloud(name) }
        return .findItem(name)
    }
}

/// Root challenge container shown on the ringing screen (dark theme).
struct ChallengeHostView: View {
    let challengeName: String
    let onComplete: () -> Void

    var body: some View {
        switch ChallengeKind.from(challengeName) {
        case .math:
            MathChallengeView(onComplete: onComplete)
        case .reps(let name):
            RepsChallengeView(name: name, onComplete: onComplete)
        case .readAloud(let name):
            ReadAloudChallengeView(name: name, onComplete: onComplete)
        case .findItem(let name):
            FindItemChallengeView(name: name, onComplete: onComplete)
        }
    }
}

// MARK: - Shared dark-theme pieces
struct ChallengeTitle: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 8) {
            Text(title).jk(27, 800, tracking: -0.9).foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text(subtitle).jk(16).foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
    }
}

/// Press and hold for `seconds` to confirm — the fill shows progress.
struct HoldToConfirmButton: View {
    var label: String
    var seconds: Double = 3
    var onComplete: () -> Void
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 27, style: .continuous)
                .fill(.white.opacity(0.14))
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 27, style: .continuous)
                    .fill(.white)
                    .frame(width: geo.size.width * progress)
            }
            Text(label).jk(19, 800)
                .foregroundColor(progress > 0.45 ? C.ink : .white)
        }
        .frame(height: 58)
        .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: seconds, pressing: { pressing in
            withAnimation(pressing ? .linear(duration: seconds) : .easeOut(duration: 0.25)) {
                progress = pressing ? 1 : 0
            }
        }, perform: onComplete)
    }
}
