import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.safeInsets) private var insets

    var body: some View {
        ZStack {
            C.phoneBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Button { app.back() } label: {
                        HStack(spacing: 8) {
                            SVGIcon(Icons.chevronLeft, stroke: C.ink, lineWidth: 2, w: 10)
                            Text("Home").jk(18, 600)
                        }
                    }.buttonStyle(.plain).padding(.top, 8)

                    Text("History").jk(36, 800, tracking: -1.2).padding(.top, 5)
                    Text("Last 30 days").jk(16).foregroundColor(C.muted)

                    streakCard.padding(.top, 13)
                    weekCard.padding(.top, 17)
                    averages.padding(.top, 17)
                    fourWeeks.padding(.top, 17)
                }
                .padding(.horizontal, 22)
                .padding(.top, insets.top + 8)
                .padding(.bottom, tabBarHeight(insets) + 22)
            }
        }
    }

    private var streakCard: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text("1").jk(46, 800).foregroundColor(C.orangeStreak)
                Text("day streak").jk(16).foregroundColor(C.muted).padding(.top, 7)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text("21").jk(32, 800)
                Text("best ever").jk(16).foregroundColor(C.muted).padding(.top, 5)
            }
        }
        .padding(.horizontal, 21).padding(.vertical, 19)
        .card(25)
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Wake-ups this week").jk(20, 800, tracking: -0.5)
            Spacer(minLength: 20)
            HStack(alignment: .bottom, spacing: 7) {
                ForEach(Mock.week) { d in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 5).fill(d.color).frame(height: 9)
                        Text(d.label).jk(13, 500).foregroundColor(C.muted2)
                    }.frame(maxWidth: .infinity)
                }
            }
        }
        .padding(19)
        .frame(height: 169)
        .frame(maxWidth: .infinity)
        .card(25)
    }

    private var averages: some View {
        HStack(spacing: 13) {
            statTile("7:17", "Average rise")
            statTile("10:30", "Average bedtime")
        }
    }

    private func statTile(_ big: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(big).jk(29, 800, tracking: -1)
            Text(sub).jk(15).foregroundColor(C.muted).padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .card(22)
    }

    private var fourWeeks: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Last 4 weeks").jk(20, 800, tracking: -0.5)
            VStack(spacing: 15) {
                ForEach(Mock.weeks) { w in
                    HStack(spacing: 12) {
                        Text(w.label).jk(15).foregroundColor(C.muted)
                            .lineLimit(1).fixedSize()
                            .frame(width: 66, alignment: .leading)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6).fill(C.divider).frame(height: 11)
                                RoundedRectangle(cornerRadius: 6).fill(w.color)
                                    .frame(width: max(0, geo.size.width * w.pct), height: 11)
                            }
                        }.frame(height: 11)
                        Text(w.count).jk(15, 700).frame(width: 29, alignment: .trailing)
                    }
                }
            }.padding(.top, 17)
        }
        .padding(19)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(25)
    }
}
