import SwiftUI
import SwiftData

struct AlarmView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.modelContext) private var ctx
    @Query(sort: [SortDescriptor(\AlarmModel.hour), SortDescriptor(\AlarmModel.minute)])
    private var alarms: [AlarmModel]

    var body: some View {
        ScreenScaffold(topGap: 6) {
            Text("Alarms").jk(32, 800, tracking: -1)
                .padding(.horizontal, 22).padding(.top, 6)

            VStack(spacing: 21) {
                ForEach(alarms) { a in
                    alarmCard(a)
                }
            }
            .padding(.horizontal, 22).padding(.top, 21)
        }
    }

    private func alarmCard(_ a: AlarmModel) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(a.name).jk(17, 700).fixedSize()
                HStack(spacing: 8) {
                    Text(ChallengeGlyph.emoji(a.challengeName)).font(.system(size: 14))
                    Text(a.challengeName).jk(15, 600).foregroundColor(Color(hex: "6E6A62")).fixedSize()
                }
                .padding(.horizontal, 15).padding(.vertical, 8)
                .fill(C.chip, 19)
                Spacer(minLength: 0)
                Button { app.openEditAlarm(a) } label: {
                    SVGIcon(Icons.pencil, stroke: C.muted, lineWidth: 1.7, w: 22)
                        .frame(width: 44, height: 44)          // 44pt tap target
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
            }
            .padding(.leading, 17).padding(.trailing, 6).padding(.vertical, 4)

            HDivider()

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(a.daysLabel).jk(15, 500).foregroundColor(C.muted2)
                    Text(a.timeLabel).jk(34, 800, tracking: -1.4).padding(.top, 2)
                }
                Spacer()
                Button {
                    a.enabled.toggle(); a.touch(); try? ctx.save()
                    AlarmCenter.shared.rescheduleAll(ctx)
                } label: {
                    TogglePill(on: a.enabled).padding(.bottom, 5)
                }.buttonStyle(.plain)
            }
            .padding(EdgeInsets(top: 13, leading: 17, bottom: 17, trailing: 17))
        }
        .card(24)
        .contextMenu {
            Button(role: .destructive) {
                ctx.delete(a); try? ctx.save()
                AlarmCenter.shared.rescheduleAll(ctx)
            } label: { Label("Delete alarm", systemImage: "trash") }
        }
    }
}
