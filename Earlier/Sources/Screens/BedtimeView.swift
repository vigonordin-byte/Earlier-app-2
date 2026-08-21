import SwiftUI
import SwiftData

struct BedtimeView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.modelContext) private var ctx
    @Query(sort: [SortDescriptor(\BedtimeModel.hour), SortDescriptor(\BedtimeModel.minute)])
    private var bedtimes: [BedtimeModel]

    @Query private var alarms: [AlarmModel]

    /// Soonest upcoming bedtime, not just the first in the list.
    private var next: (bedtime: BedtimeModel, date: Date)? {
        var best: (bedtime: BedtimeModel, date: Date)?
        for b in bedtimes where b.enabled {
            guard let d = AlarmCenter.nextBedtimeDate(b) else { continue }
            if best == nil || d < best!.date { best = (b, d) }
        }
        return best
    }
    private var nextDayLabel: String {
        guard let d = next?.date else { return "" }
        if Calendar.current.isDateInToday(d) { return "Tonight" }
        if Calendar.current.isDateInTomorrow(d) { return "Tomorrow" }
        let f = DateFormatter(); f.dateFormat = "EEEE"
        return f.string(from: d)
    }
    private var nextAlarmLabel: String {
        var best: (a: AlarmModel, d: Date)?
        for a in alarms where a.enabled {
            guard let d = AlarmCenter.nextFireDate(a) else { continue }
            if best == nil || d < best!.d { best = (a, d) }
        }
        return best?.a.timeLabel ?? "your alarm"
    }

    var body: some View {
        ScreenScaffold(topGap: 6) {
            Text("Bedtime").jk(32, 800, tracking: -1)
                .padding(.horizontal, 22).padding(.top, 6)

            nextBedtimeCard.padding(.horizontal, 22).padding(.top, 19)

            VStack(spacing: 21) {
                ForEach(bedtimes) { b in
                    bedtimeCard(b)
                }
            }
            .padding(.horizontal, 22).padding(.top, 21)
        }
    }

    private var nextBedtimeCard: some View {
        VStack(spacing: 0) {
            Text("NEXT BEDTIME").jk(11, 600, tracking: 3.2).foregroundColor(C.muted3)
            Text(next?.bedtime.timeLabel ?? "Not set").jk(46, 800, tracking: -2).padding(.top, 5)
            Text(nextDayLabel).jk(16).foregroundColor(C.muted)
            HDivider(color: C.divider2).padding(.horizontal, 17).padding(.vertical, 17)
            HStack(spacing: 15) {
                SVGIcon(Icons.moon, stroke: C.ink, lineWidth: 1.8, w: 24).frame(width: 24, height: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(BlockingStore.isEnforceable
                         ? "Apps block at this time"
                         : "You'll be reminded at this time").jk(16, 700)
                    Text(BlockingStore.isEnforceable
                         ? "Blocked until your \(nextAlarmLabel) alarm"
                         : "App blocking needs Screen Time access — coming soon")
                        .jk(14).foregroundColor(C.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 5).padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 19).padding(.vertical, 21)
        .card(25)
    }

    private func bedtimeCard(_ b: BedtimeModel) -> some View {
        VStack(spacing: 0) {
            Button { app.openEditBedtime(b) } label: {
                HStack {
                    Text(b.name).jk(17, 700)
                    Spacer()
                    SVGIcon(Icons.pencil, stroke: C.muted, lineWidth: 1.7, w: 22).frame(width: 22, height: 22)
                }
                .padding(.horizontal, 17).padding(.vertical, 15)
                .contentShape(Rectangle())
            }.buttonStyle(.plain)

            HDivider()

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(b.daysLabel).jk(15, 500).foregroundColor(C.muted2)
                    Text(b.timeLabel).jk(34, 800, tracking: -1.4).padding(.top, 2)
                }
                Spacer()
                Button {
                    // Switching a bedtime OFF goes through the friction screen;
                    // switching it back on is instant.
                    if b.enabled {
                        app.guardAction = .disableBedtime(b.id)
                    } else {
                        b.enabled = true; b.touch(); try? ctx.save()
                    }
                } label: {
                    TogglePill(on: b.enabled).padding(.bottom, 5)
                }.buttonStyle(.plain)
            }
            .padding(EdgeInsets(top: 13, leading: 17, bottom: 17, trailing: 17))
        }
        .card(24)
        .contextMenu {
            Button(role: .destructive) {
                ctx.delete(b); try? ctx.save()
            } label: { Label("Delete bedtime", systemImage: "trash") }
        }
    }
}
