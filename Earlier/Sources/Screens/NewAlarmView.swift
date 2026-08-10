import SwiftUI
import SwiftData

struct NewAlarmView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.modelContext) private var ctx
    @State private var name = ""
    @State private var days = [false, true, true, true, true, true, false]  // Mon–Fri

    var body: some View {
        SheetContainer(bg: C.phoneBg, onScrim: { app.back() }) {
            header.padding(.top, 17)

            segmented.padding(.top, 19)

            TextField("Alarm name", text: $name)
                .font(JK.font(18, 500)).foregroundColor(C.ink).tint(C.ink)
                .padding(.horizontal, 19).padding(.vertical, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .card(22).padding(.top, 13)

            Button { app.openSub(.time) } label: {
                HStack {
                    Text("Alarm time").jk(18, 700)
                    Spacer()
                    Text("6:30 AM").jk(18).foregroundColor(C.muted)
                    SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 8).padding(.leading, 8)
                }
                .padding(.horizontal, 19).padding(.vertical, 16)
                .card(22)
                .contentShape(Rectangle())
            }.buttonStyle(.plain).padding(.top, 13)

            daysCard.padding(.top, 13)
            optionsCard.padding(.top, 13)

            PrimaryButton(title: "Save alarm") { saveAlarm() }.padding(.top, 15)
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                Button { app.back() } label: {
                    Text("Cancel").jk(18, 600)
                        .padding(.horizontal, 21).padding(.vertical, 9)
                        .background(C.card)
                        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                        .softShadow()
                }.buttonStyle(.plain)
                Spacer()
            }
            Text("New alarm").jk(20, 800).padding(.trailing, 59)
        }
    }

    private var segmented: some View {
        HStack(spacing: 0) {
            Text("Scheduled").jk(17, 600)
                .frame(maxWidth: .infinity).padding(.vertical, 11)
                .background(C.card)
                .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
            Text("One time").jk(17, 500).foregroundColor(C.muted)
                .frame(maxWidth: .infinity).padding(.vertical, 11)
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(C.pill))
    }

    private var daysCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("On these days:").jk(16).foregroundColor(Color(hex: "6E6A62"))
            DayPicker(selected: $days).padding(.top, 12)
        }
        .padding(.horizontal, 17).padding(.top, 15).padding(.bottom, 19)
        .card(22)
    }

    private func saveAlarm() {
        let alarm = AlarmModel(
            name: name.trimmingCharacters(in: .whitespaces).isEmpty ? "Alarm" : name,
            hour: 6, minute: 30,
            repeatMask: Weekdays.maskFromPicker(days),
            soundName: "Default", challengeName: "Push ups", enabled: true)
        ctx.insert(alarm)
        try? ctx.save()
        app.back()
    }

    private var optionsCard: some View {
        VStack(spacing: 0) {
            Button { app.openSub(.sound) } label: {
                optionRow(leading: AnyView(SVGIcon(Icons.speakerSmall, stroke: C.ink, lineWidth: 1.8, w: 21).frame(width: 21, height: 21)),
                          title: "Sound", value: "Default")
            }.buttonStyle(.plain)
            HDivider()
            Button { app.openSub(.challenge) } label: {
                optionRow(leading: AnyView(Text("🏋️").font(.system(size: 17)).frame(width: 21)),
                          title: "Challenge", value: "Push ups")
            }.buttonStyle(.plain)
            HDivider()
            Button { app.openSub(.blocking) } label: {
                optionRow(leading: AnyView(SVGIcon(Icons.lock, stroke: C.ink, lineWidth: 1.8, w: 21).frame(width: 21, height: 21)),
                          title: "App blocking", value: "0 apps · 11 categories", showChevron: false)
            }.buttonStyle(.plain)
        }
        .card(22)
    }

    private func optionRow(leading: AnyView, title: String, value: String, showChevron: Bool = true) -> some View {
        HStack(spacing: 13) {
            leading
            Text(title).jk(18, 700).fixedSize()
            Spacer(minLength: 8)
            Text(value).jk(showChevron ? 18 : 17).foregroundColor(C.muted).lineLimit(1)
            if showChevron {
                SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 8)
            }
        }
        .padding(.horizontal, 17).padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}
