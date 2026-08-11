import SwiftUI

struct ReadAloudChallengeView: View {
    let name: String            // "Bible verse" / "Devotional"
    let onComplete: () -> Void

    private var isVerse: Bool { name.lowercased().contains("bible") }

    private var passage: (text: String, source: String) {
        if isVerse {
            return ("“This is the day which the LORD hath made; we will rejoice and be glad in it.”",
                    "Psalm 118:24")
        }
        return ("“The morning does not ask if you feel ready. It only asks that you show up. Rise, breathe, and take the first small step — the rest of the day will follow you out of bed.”",
                "Morning devotional")
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeTitle(title: "Read it out loud",
                           subtitle: "Speak the words to start your day")
            Spacer()
            VStack(spacing: 14) {
                Text(passage.text).jk(21, 600).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                Text(passage.source).jk(15).foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 34)
            Spacer()
            HoldToConfirmButton(label: "Hold — I read it aloud", onComplete: onComplete)
                .padding(.horizontal, 46)
        }
    }
}

struct FindItemChallengeView: View {
    let name: String            // "Item scan" / "Item search"
    let onComplete: () -> Void

    private var prompt: String {
        if name.lowercased().contains("scan") { return "Go scan your chosen item — like your toothbrush." }
        let items = ["a spoon", "your toothbrush", "a book", "a shoe", "a glass of water"]
        return "Find \(items.randomElement()!) and hold it in your hand."
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeTitle(title: "Get up and find it",
                           subtitle: "Camera verification comes in a later update")
            Spacer()
            Text("🔍").font(.system(size: 56))
            Text(prompt).jk(21, 600).foregroundColor(.white)
                .multilineTextAlignment(.center).lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40).padding(.top, 18)
            Spacer()
            HoldToConfirmButton(label: "Hold — I've got it", onComplete: onComplete)
                .padding(.horizontal, 46)
        }
    }
}
