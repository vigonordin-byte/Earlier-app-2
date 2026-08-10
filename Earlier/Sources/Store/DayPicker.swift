import SwiftUI

/// Challenge name → emoji, matching the design's challenge catalog.
enum ChallengeGlyph {
    static let emojiByName: [String: String] = [
        "Push ups": "🏋️", "Squats": "🏃", "Item Search": "🔍", "Item scan": "🪥",
        "Math problem": "🧮", "Bible Verse": "📖", "Bible verse": "📖", "Devotional": "🕊️"
    ]
    static func emoji(_ name: String) -> String { emojiByName[name] ?? "🏋️" }
}

/// Interactive weekday selector, Sun-first (S M T W T F S), bound to a 7-bool array.
struct DayPicker: View {
    @Binding var selected: [Bool]
    private let labels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<7, id: \.self) { i in
                let on = selected.indices.contains(i) && selected[i]
                Button {
                    if selected.indices.contains(i) { selected[i].toggle() }
                } label: {
                    Text(labels[i]).jk(14, 600)
                        .foregroundColor(on ? .white : C.placeholder)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(Circle().fill(on ? C.ink : .clear))
                        .overlay(Circle().stroke(on ? C.ink : C.dayOffBorder, lineWidth: 1))
                        .contentShape(Circle())
                }.buttonStyle(.plain)
            }
        }
    }
}
