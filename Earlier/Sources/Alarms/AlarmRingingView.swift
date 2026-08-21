import SwiftUI
import SwiftData

/// Full-screen takeover while an alarm is ringing. The alarm's challenge must
/// be completed to dismiss; completing it logs a WakeLog.
struct AlarmRingingView: View {
    let alarmID: UUID?
    @Environment(\.modelContext) private var ctx
    @Query private var alarms: [AlarmModel]
    @State private var inChallenge = false

    private var alarm: AlarmModel? { alarms.first { $0.id == alarmID } }
    private var challengeName: String { alarm?.challengeName ?? "Push ups" }

    var body: some View {
        ZStack {
            C.ink.ignoresSafeArea()
            if inChallenge {
                challengePhase.transition(.opacity)
            } else {
                ringingPhase.transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: inChallenge)
    }

    // MARK: - Phase 1: ringing
    private var ringingPhase: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("WAKE UP").jk(11, 600, tracking: 3.2)
                .foregroundColor(.white.opacity(0.55))
            TimelineView(.periodic(from: .now, by: 1)) { t in
                Text(clockString(t.date)).jk(64, 800, tracking: -2.5)
                    .foregroundColor(.white).padding(.top, 8)
            }
            Text(alarm?.name ?? "Alarm").jk(20, 600)
                .foregroundColor(.white.opacity(0.7)).padding(.top, 6)
            HStack(spacing: 8) {
                Text(ChallengeGlyph.emoji(challengeName)).font(.system(size: 15))
                Text(challengeName).jk(15, 600).foregroundColor(.white)
            }
            .padding(.horizontal, 15).padding(.vertical, 9)
            .background(Capsule().fill(.white.opacity(0.14)))
            .padding(.top, 21)
            Spacer()
            Text("No snoozing. Complete your challenge to turn it off.")
                .jk(14).foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            Button { inChallenge = true } label: {
                Text("Start challenge").jk(20, 800).foregroundColor(C.ink)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(.white))
                    .contentShape(Rectangle())
            }.buttonStyle(.plain)
            .padding(.horizontal, 22).padding(.top, 14).padding(.bottom, 30)
        }
    }

    // MARK: - Phase 2: challenge
    private var challengePhase: some View {
        VStack(spacing: 0) {
            HStack {
                Button { inChallenge = false } label: {
                    SVGIcon(Icons.chevronLeft, stroke: .white.opacity(0.6), lineWidth: 2, w: 10)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
                Spacer()
                Text(alarm?.name ?? "Alarm").jk(15, 600).foregroundColor(.white.opacity(0.5))
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16).padding(.top, 62)

            ChallengeHostView(challengeName: challengeName, onComplete: finish)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 10).padding(.bottom, 40)
        }
    }

    private func clockString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = DateFormatter.dateFormat(fromTemplate: "jm", options: 0,
                                                locale: .current) ?? "h:mm"
        return f.string(from: d)
    }

    private func finish() {
        if let a = alarm {
            ctx.insert(WakeLog(completed: true, alarmId: a.id))
            if a.repeatMask == 0 { a.enabled = false; a.touch() }  // one-shots disarm
            try? ctx.save()
        }
        // Stops the siren, cancels the remaining barrage, reschedules the future.
        AlarmCenter.shared.completeChallenge(ctx)
    }
}
