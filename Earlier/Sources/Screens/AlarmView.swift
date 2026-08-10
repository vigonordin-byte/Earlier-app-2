import SwiftUI

struct AlarmView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        ScreenScaffold(topGap: 6) {
            Text("Alarms").jk(32, 800, tracking: -1)
                .padding(.horizontal, 22).padding(.top, 6)

            VStack(spacing: 21) {
                ForEach(Mock.alarms) { a in
                    alarmCard(a)
                }
            }
            .padding(.horizontal, 22).padding(.top, 21)
        }
    }

    private func alarmCard(_ a: AlarmItem) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(a.name).jk(17, 700).fixedSize()
                HStack(spacing: 8) {
                    Text("🏋️").font(.system(size: 14))
                    Text("Push ups").jk(15, 600).foregroundColor(Color(hex: "6E6A62")).fixedSize()
                }
                .padding(.horizontal, 15).padding(.vertical, 8)
                .fill(C.chip, 19)
                Spacer(minLength: 0)
                SVGIcon(Icons.pencil, stroke: C.muted, lineWidth: 1.7, w: 22).frame(width: 22, height: 22)
            }
            .padding(.horizontal, 17).padding(.vertical, 13)

            HDivider()

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Weekdays").jk(15, 500).foregroundColor(C.muted2)
                    Text(a.time).jk(34, 800, tracking: -1.4).padding(.top, 2)
                }
                Spacer()
                TogglePill(on: false).padding(.bottom, 5)
            }
            .padding(EdgeInsets(top: 13, leading: 17, bottom: 17, trailing: 17))
        }
        .card(24)
    }
}
