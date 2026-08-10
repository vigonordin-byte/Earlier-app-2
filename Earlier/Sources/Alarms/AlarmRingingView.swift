import SwiftUI
import SwiftData

/// Full-screen takeover while an alarm is ringing. Dismissing logs a WakeLog;
/// Phase 2 replaces the "I'm up" button with the alarm's challenge.
struct AlarmRingingView: View {
    let alarmID: UUID?
    @Environment(\.modelContext) private var ctx
    @Query private var alarms: [AlarmModel]

    private var alarm: AlarmModel? { alarms.first { $0.id == alarmID } }

    var body: some View {
        ZStack {
            C.ink.ignoresSafeArea()
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
                    Text(ChallengeGlyph.emoji(alarm?.challengeName ?? "Push ups"))
                        .font(.system(size: 15))
                    Text(alarm?.challengeName ?? "Push ups").jk(15, 600).foregroundColor(.white)
                }
                .padding(.horizontal, 15).padding(.vertical, 9)
                .background(Capsule().fill(.white.opacity(0.14)))
                .padding(.top, 21)
                Spacer()
                Text("Challenges arrive in the next phase — for now, promise you're up.")
                    .jk(14).foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
                Button { dismiss() } label: {
                    Text("I'm up").jk(20, 800).foregroundColor(C.ink)
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(.white))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
                .padding(.horizontal, 22).padding(.top, 14).padding(.bottom, 30)
            }
        }
    }

    private func clockString(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "h:mm"
        return f.string(from: d)
    }

    private func dismiss() {
        if let a = alarm {
            ctx.insert(WakeLog(completed: true, alarmId: a.id))
            if a.repeatMask == 0 { a.enabled = false; a.touch() }  // one-shots disarm
            try? ctx.save()
            AlarmCenter.shared.rescheduleAll(ctx)
        }
        AlarmCenter.shared.ringingAlarmID = nil
    }
}
