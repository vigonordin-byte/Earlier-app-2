import SwiftUI

struct NewAlarmView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        SheetContainer(bg: C.phoneBg, onScrim: { app.back() }) {
            header.padding(.top, 17)

            segmented.padding(.top, 19)

            FieldPlaceholder(text: "Alarm name").padding(.top, 13)

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

            PrimaryButton(title: "Save alarm") { app.back() }.padding(.top, 15)
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
            DayCircles().padding(.top, 12)
        }
        .padding(.horizontal, 17).padding(.top, 15).padding(.bottom, 19)
        .card(22)
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
