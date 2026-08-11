import SwiftUI

struct MathProblem {
    let text: String
    let answer: Int

    static func random() -> MathProblem {
        switch Int.random(in: 0..<3) {
        case 0:
            let a = Int.random(in: 12...49), b = Int.random(in: 12...49)
            return MathProblem(text: "\(a) + \(b)", answer: a + b)
        case 1:
            let a = Int.random(in: 35...89), b = Int.random(in: 11...29)
            return MathProblem(text: "\(a) − \(b)", answer: a - b)
        default:
            let a = Int.random(in: 6...9), b = Int.random(in: 6...12)
            return MathProblem(text: "\(a) × \(b)", answer: a * b)
        }
    }
}

struct MathChallengeView: View {
    let onComplete: () -> Void
    @State private var problem = MathProblem.random()
    @State private var entry = ""
    @State private var wrong = false

    var body: some View {
        VStack(spacing: 0) {
            ChallengeTitle(title: "Solve to turn off",
                           subtitle: "Prove your brain is on")
            Text(problem.text).jk(44, 800, tracking: -1)
                .foregroundColor(.white).padding(.top, 26)
            Text(entry.isEmpty ? "?" : entry).jk(34, 800)
                .foregroundColor(wrong ? Color(hex: "FF6A5E") : .white.opacity(entry.isEmpty ? 0.35 : 1))
                .frame(height: 46).padding(.top, 6)
            keypad.padding(.top, 20).padding(.horizontal, 46)
        }
    }

    private var keypad: some View {
        let rows: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["⌫", "0", "OK"]]
        return VStack(spacing: 12) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button { press(key) } label: {
                            Text(key).jk(24, key == "OK" ? 800 : 600)
                                .foregroundColor(key == "OK" ? C.ink : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 62)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(key == "OK" ? Color.white : .white.opacity(0.12))
                                )
                                .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func press(_ key: String) {
        wrong = false
        switch key {
        case "⌫":
            if !entry.isEmpty { entry.removeLast() }
        case "OK":
            if Int(entry) == problem.answer {
                onComplete()
            } else {
                wrong = true
                entry = ""
            }
        default:
            if entry.count < 4 { entry += key }
        }
    }
}
