import SwiftUI
import SwiftData

/// What the user is trying to switch off. Both routes are deliberately slow.
enum GuardAction: Equatable {
    case disableBedtime(UUID)
    case turnOffBlocking

    var title: String {
        switch self {
        case .disableBedtime: return "Keep my bedtime"
        case .turnOffBlocking: return "Keep apps blocked"
        }
    }
    var destructive: String {
        switch self {
        case .disableBedtime: return "Turn off and lose my streak"
        case .turnOffBlocking: return "Turn off and lose my streak"
        }
    }
}

/// Friction screen shown when someone tries to switch off the thing that
/// protects their morning. The escape hatch stays disabled until the
/// countdown runs out — long enough for the impulse to pass.
struct BedtimeGuardView: View {
    let action: GuardAction
    @EnvironmentObject var app: AppState
    @Environment(\.safeInsets) private var insets
    @Environment(\.modelContext) private var ctx
    @Query private var bedtimes: [BedtimeModel]
    @Query private var logs: [WakeLog]

    private static let total: Int = 60
    @State private var remaining = BedtimeGuardView.total

    private var elapsedFraction: CGFloat {
        CGFloat(Self.total - remaining) / CGFloat(Self.total)
    }
    private var unlocked: Bool { remaining <= 0 }
    private var streak: Int { Stats.streak(logs) }

    var body: some View {
        ZStack {
            C.phoneBg.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 0).frame(height: 24)

                SVGIcon(Icons.moon, stroke: C.ink, lineWidth: 1.9, w: 34)
                    .frame(width: 34, height: 34)

                Text("Wait a minute.").jk(40, 800, tracking: -1.4)
                    .padding(.top, 18)

                Text("Is it worth losing your streak and feeling tired tomorrow, just to scroll now?")
                    .jk(18).foregroundColor(C.muted)
                    .multilineTextAlignment(.center).lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)

                HStack(spacing: 14) {
                    Text("🔥").font(.system(size: 22))
                    Text(streak > 0
                         ? "Your \(streak)-day streak is on the line"
                         : "Tomorrow's fresh start is on the line")
                        .jk(17, 700)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 22).padding(.vertical, 20)
                .background(C.card)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .cardShadow(y: 2, blur: 12, opacity: 0.04)
                .padding(.top, 26)

                Spacer(minLength: 12)
                countdownRing
                Spacer(minLength: 12)

                Button { app.guardAction = nil } label: {
                    Text(action.title).jk(20, 800).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(C.ink))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)

                Button { performDestructive() } label: {
                    Text(unlocked ? action.destructive : "\(action.destructive) (\(remaining)s)")
                        .jk(19, 700)
                        .foregroundColor(unlocked ? C.red : C.red.opacity(0.28))
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!unlocked)
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.top, insets.top)
            .padding(.bottom, insets.bottom > 0 ? insets.bottom : 16)
        }
        .task { await runCountdown() }
    }

    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(C.divider2, lineWidth: 6)
            Circle()
                .trim(from: 0, to: max(0.001, elapsedFraction))
                .stroke(C.ink, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: elapsedFraction)
            Text("\(remaining)").jk(48, 800, tracking: -1.5)
        }
        .frame(width: 186, height: 186)
    }

    private func runCountdown() async {
        while remaining > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            remaining -= 1
        }
    }

    private func performDestructive() {
        switch action {
        case .disableBedtime(let id):
            if let b = bedtimes.first(where: { $0.id == id }) {
                b.enabled = false; b.touch(); try? ctx.save()
            }
        case .turnOffBlocking:
            BlockingStore.shared.turnOff()
        }
        app.guardAction = nil
    }
}
