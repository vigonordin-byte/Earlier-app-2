import SwiftUI

// MARK: - Achievements (full screen)
struct AchievementsView: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        FullOverlay(bg: C.phoneBg, scroll: true, topPad: 12) {
            ZStack {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: C.ink, lineWidth: 2, w: 24).frame(width: 24, height: 24)
                    }.buttonStyle(.plain).frame(width: 29, alignment: .leading)
                    Spacer()
                }
                Text("Achievements").jk(23, 800).frame(maxWidth: .infinity).padding(.trailing, 17)
            }

            VStack(spacing: 22) {
                ForEach(Mock.achievements) { a in
                    HStack(alignment: .top, spacing: 17) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .fill(a.on ? C.ink : Color(hex: "E8E6DF"))
                                .frame(width: 53, height: 53)
                            if a.on {
                                Text("🔥").font(.system(size: 26))
                            } else {
                                SVGIcon(Icons.lockRounded, stroke: Color(hex: "C4C0B8"), lineWidth: 1.8, w: 28)
                                    .frame(width: 28, height: 28)
                            }
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(a.name).jk(19, 800, tracking: -0.3)
                            Text(a.streak).jk(16, 600).foregroundColor(C.muted)
                            Text(a.desc).jk(16).foregroundColor(C.muted4).lineSpacing(3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(a.on ? 1 : 0.42)
                }
            }.padding(.top, 25)
        }
    }
}

// MARK: - Streak (blurred overlay)
struct StreakView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.safeInsets) private var insets
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            Color(hex: "605E5A").opacity(0.4).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: .white, lineWidth: 2, w: 25).frame(width: 25, height: 25)
                    }.buttonStyle(.plain)
                    Spacer()
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("1").jk(81, 800).foregroundColor(.white)
                    Text("day streak").jk(29, 800).foregroundColor(.white).padding(.top, 12)
                    Text("Keep it alive — complete tomorrow's challenge to reach 2 days.")
                        .jk(18).foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center).lineSpacing(4)
                        .frame(maxWidth: 300).padding(.top, 17)
                }
                .padding(.bottom, 34)
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, insets.top + 12)
        }
    }
}

// MARK: - Wake-up reason (full screen)
struct ReasonView: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        FullOverlay(bg: C.phoneBg, topPad: 12) {
            ZStack {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: Color(hex: "6E6A62"), lineWidth: 2, w: 22).frame(width: 22, height: 22)
                    }.buttonStyle(.plain).frame(width: 29, alignment: .leading)
                    Spacer()
                }
                Text("Wake-up reason").jk(22, 800).frame(maxWidth: .infinity).padding(.leading, -29)
            }

            Text("Why are you committed to waking up early? What do you plan to do first thing in the morning?")
                .jk(18).foregroundColor(C.placeholder).lineSpacing(5)
                .frame(maxWidth: .infinity, minHeight: 178, alignment: .topLeading)
                .padding(19)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(C.inputField))
                .padding(.top, 22)

            Text("Save").jk(19, 700).foregroundColor(C.disabledInk)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.disabledBtn))
                .padding(.top, 15)
        }
    }
}

// MARK: - Sign your commitment (full screen)
struct SignatureView: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        FullOverlay(bg: C.phoneBg, topPad: 12) {
            ZStack {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: Color(hex: "6E6A62"), lineWidth: 2, w: 22).frame(width: 22, height: 22)
                    }.buttonStyle(.plain).frame(width: 29, alignment: .leading)
                    Spacer()
                }
                Text("Sign your commitment").jk(22, 800).frame(maxWidth: .infinity).padding(.leading, 5)
            }

            (Text("I commit to waking up at ").foregroundColor(C.muted)
             + Text("6:30 AM").foregroundColor(C.ink).font(JK.font(18, 800)))
                .jk(18).multilineTextAlignment(.center)
                .frame(maxWidth: .infinity).padding(.top, 17)

            Text("Draw your signature").jk(18).foregroundColor(C.muted3)
                .frame(maxWidth: .infinity, minHeight: 227)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(C.inputField))
                .padding(.top, 19)

            GeometryReader { geo in
                let gap: CGFloat = 12
                let clearW = (geo.size.width - gap) / 3.4   // Save : Clear = 2.4 : 1
                HStack(spacing: gap) {
                    Text("Save").jk(19, 700).foregroundColor(C.disabledInk)
                        .frame(width: geo.size.width - gap - clearW).padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.disabledBtn))
                    Text("Clear").jk(19, 600).foregroundColor(Color(hex: "6E6A62"))
                        .frame(width: clearW).padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.chip))
                }
            }
            .frame(height: 55)
            .padding(.top, 17)
        }
    }
}
