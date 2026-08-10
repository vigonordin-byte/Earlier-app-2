import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var app: AppState
    @Query private var alarms: [AlarmModel]

    private var nextAlarm: (alarm: AlarmModel, date: Date)? {
        alarms.filter(\.enabled)
            .compactMap { a in AlarmCenter.nextFireDate(a).map { (a, $0) } }
            .min { $0.1 < $1.1 }
    }
    private var nextDayLabel: String {
        guard let d = nextAlarm?.date else { return "No alarm set" }
        if Calendar.current.isDateInToday(d) { return "Today" }
        if Calendar.current.isDateInTomorrow(d) { return "Tomorrow" }
        let f = DateFormatter(); f.dateFormat = "EEEE"
        return f.string(from: d)
    }

    var body: some View {
        ScreenScaffold(topGap: 6) {
            header.padding(.horizontal, 22).padding(.top, 6)
            nextAlarmCard.padding(.horizontal, 22).padding(.top, 10)
            quickActions.padding(.horizontal, 34).padding(.top, 22)
            getStartedCard.padding(.horizontal, 22).padding(.top, 22)

            Text("Stay committed").jk(22, 800, tracking: -0.6)
                .padding(.horizontal, 22).padding(.top, 27)
            committedCard.padding(.horizontal, 22).padding(.top, 13)

            Text("Past 7 days").jk(22, 800, tracking: -0.6)
                .padding(.horizontal, 22).padding(.top, 25)
            weekCard.padding(.horizontal, 22).padding(.top, 13)
        }
    }

    private var header: some View {
        HStack {
            Text("EARLIER").jk(28, 800, tracking: -0.5)
            Spacer()
            HStack(spacing: 8) {
                Button { app.open(.streak) } label: {
                    HStack(spacing: 8) {
                        Text("🔥").font(.system(size: 16))
                        Text("1").jk(16, 700)
                    }
                }.buttonStyle(.plain)
                Button { app.open(.achievements) } label: {
                    SVGIcon(Icons.trophy, stroke: C.ink, lineWidth: 1.7, w: 23)
                }.buttonStyle(.plain)
            }
        }
    }

    private var nextAlarmCard: some View {
        let a = nextAlarm?.alarm
        return VStack(spacing: 0) {
            Text("NEXT ALARM").jk(11, 600, tracking: 3.2).foregroundColor(C.muted3)
            Text(a?.timeLabel ?? "—").jk(47, 800, tracking: -2).padding(.top, 7)
            Text(nextDayLabel).jk(16).foregroundColor(C.muted).padding(.top, 2)
            HDivider(color: C.divider2).padding(.horizontal, 17).padding(.top, 19)
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(ChallengeGlyph.emoji(a?.challengeName ?? "Push ups")).font(.system(size: 22))
                    Text(a?.challengeName ?? "Push ups").jk(16, 700).padding(.top, 13)
                    Text("Challenge").jk(14).foregroundColor(C.muted).padding(.top, 4)
                }.frame(maxWidth: .infinity)
                Rectangle().fill(C.divider2).frame(width: 1, height: 74)
                VStack(spacing: 0) {
                    SVGIcon(Icons.speakerBirds, stroke: C.ink, lineWidth: 1.9, w: 24).frame(height: 24)
                    Text(a?.soundName ?? "Default").jk(16, 700).padding(.top, 10)
                    Text("Sound").jk(14).foregroundColor(C.muted).padding(.top, 4)
                }.frame(maxWidth: .infinity)
            }
            .padding(.top, 17)
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 22, leading: 19, bottom: 21, trailing: 19))
        .card(25)
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            quickAction(Icons.moon, "Wind down") { app.open(.windDown) }
            quickAction(Icons.bell, "Add alarm") { app.open(.newAlarm) }
            quickAction(Icons.chart, "History") { app.open(.history) }
        }
    }

    private func quickAction(_ ico: Ico, _ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                SVGIcon(ico, stroke: C.ink, lineWidth: 1.9, w: 25).frame(height: 25)
                    .frame(width: 66, height: 66)
                    .background(C.card)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .softShadow()
                Text(label).jk(14, 600)
            }.frame(maxWidth: .infinity).contentShape(Rectangle())
        }.buttonStyle(.plain)
    }

    private var getStartedCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Get started").jk(22, 800, tracking: -0.6)
                Spacer()
                Text("3/3").jk(15, 500).foregroundColor(C.muted)
            }
            RoundedRectangle(cornerRadius: 3).fill(C.ink).frame(height: 5).padding(.top, 13)
            VStack(alignment: .leading, spacing: 17) {
                checklistRow("Set your first alarm", "Your challenge is ready")
                checklistRow("Write your wake-up reason", "What gets you out of bed?")
                checklistRow("Sign your commitment", "Seal it with a signature")
            }.padding(.top, 21)
        }
        .padding(EdgeInsets(top: 21, leading: 19, bottom: 22, trailing: 19))
        .card(25)
    }

    private func checklistRow(_ title: String, _ sub: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            ZStack {
                Circle().fill(C.ink).frame(width: 24, height: 24)
                SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 13).frame(height: 13)
            }.padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).strikethrough().jk(15, 700).foregroundColor(C.muted)
                Text(sub).jk(14).foregroundColor(C.muted)
            }
        }
    }

    private var committedCard: some View {
        VStack(spacing: 0) {
            committedRow(Icons.pencil, "My reason", "Why you get up early") { app.open(.reason) }
            HDivider()
            committedRow(Icons.signaturePen, "Goal committed", "Your signed commitment") { app.open(.signature) }
        }
        .card(22)
    }

    private func committedRow(_ ico: Ico, _ title: String, _ sub: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                SVGIcon(ico, stroke: C.ink, lineWidth: 1.7, w: 25).frame(width: 25, height: 25)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).jk(16, 700)
                    Text(sub).jk(14).foregroundColor(C.muted)
                }
                Spacer()
                RowChevron(w: 10)
            }
            .padding(.horizontal, 19).padding(.vertical, 15)
            .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }

    private var weekCard: some View {
        HStack(alignment: .bottom, spacing: 7) {
            ForEach(Mock.week) { d in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 5).fill(d.color).frame(height: 9)
                    Text(d.label).jk(13, 500).foregroundColor(C.muted2)
                }.frame(maxWidth: .infinity)
            }
        }
        .padding(19)
        .frame(maxWidth: .infinity, minHeight: 152, alignment: .bottom)
        .card(25)
    }
}
