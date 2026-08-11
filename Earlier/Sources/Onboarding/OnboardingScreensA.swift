import SwiftUI

// MARK: - Welcome
struct WelcomeScreen: View {
    @EnvironmentObject var s: OnboardingState
    @Environment(\.safeInsets) private var insets
    /// Returning users skip the questionnaire.
    var onSignIn: () -> Void = {}
    var body: some View {
        ZStack {
            C.phoneBg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0).frame(maxHeight: .infinity).layoutPriority(0.55)
                Text("Welcome!").jk(47, 800, tracking: -1.8)
                Text("Let's start by understanding your wake up habits and routines")
                    .jk(21).foregroundColor(C.inkMuted).lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 13)
                HStack(spacing: 5) {
                    Text("🌿").font(.system(size: 23))
                    Text("★★★★★").jk(20).foregroundColor(Color(hex: "E8720C")).tracking(-1)
                    Text("🌿").font(.system(size: 23)).scaleEffect(x: -1, y: 1)
                }.padding(.top, 31)
                Spacer(minLength: 0).frame(maxHeight: .infinity)
                Button { s.next() } label: {
                    Text("Get Started").jk(18, 700).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.ink))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
                Button(action: onSignIn) {
                    (Text("Already have an account? ").foregroundColor(C.inkMuted)
                     + Text("Sign in").foregroundColor(.black).font(JK.font(14, 800)))
                        .jk(14)
                        .frame(maxWidth: .infinity, minHeight: 44)   // 44pt tap target
                        .contentShape(Rectangle())
                }.buttonStyle(.plain).padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.top, insets.top + 6)
            .padding(.bottom, insets.bottom > 0 ? insets.bottom + 6 : 23)
        }
    }
}

// MARK: - Question
struct QuestionScreen: View {
    @EnvironmentObject var s: OnboardingState
    let title: String
    let options: [String]

    var body: some View {
        let ans = s.answers[s.step]
        let center = options.count > 3
        OBScaffold(content: {
            OBTitle(text: title)
            VStack(spacing: 0) {
                Spacer(minLength: 14)
                VStack(spacing: 13) {
                    ForEach(Array(options.enumerated()), id: \.offset) { i, o in
                        OptionRow(label: o, badge: String(i + 1), selected: ans == i) { s.pick(i) }
                    }
                }
                .padding(.horizontal, 22)
                if center { Spacer(minLength: 14) } else { Color.clear.frame(height: 11) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }, footer: {
            OBFooter(bg: s.answeredCurrent ? C.ink : C.ctaOff,
                     ink: s.answeredCurrent ? .white : C.ctaOffInk) { s.next() }
        })
    }
}

// MARK: - Sources
struct SourcesScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        let ans = s.answers[s.step]
        OBScaffold(content: {
            OBTitle(text: "Where did you hear about us?")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 13) {
                    ForEach(Array(onboardingSources.enumerated()), id: \.offset) { i, src in
                        OptionRow(label: src, badge: String(src.prefix(1)), mono: true, selected: ans == i) { s.pick(i) }
                    }
                }
                .padding(.horizontal, 22).padding(.top, 16).padding(.bottom, 11)
            }
        }, footer: {
            OBFooter(bg: s.answeredCurrent ? C.ink : C.ctaOff,
                     ink: s.answeredCurrent ? .white : C.ctaOffInk) { s.next() }
        })
    }
}

// MARK: - Chart (snoozing over time)
struct ChartScreen: View {
    @EnvironmentObject var s: OnboardingState

    private let grayArea = Ico([.path("M12 30 C 90 30, 110 20, 160 70 C 210 120, 240 128, 308 128 L308 128 L12 128 Z")], box: CGSize(width: 320, height: 150))
    private let redArea  = Ico([.path("M12 40 C 70 45, 90 92, 130 96 C 190 100, 220 34, 308 14 L308 128 L12 128 Z")], box: CGSize(width: 320, height: 150))
    private let blackCurve = Ico([.path("M12 30 C 90 30, 110 20, 160 70 C 210 120, 240 128, 308 128")], box: CGSize(width: 320, height: 150))
    private let redCurve   = Ico([.path("M12 40 C 70 45, 90 92, 130 96 C 190 100, 220 34, 308 14")], box: CGSize(width: 320, height: 150))
    private let baseline   = Ico([.path("M12 128L308 128")], box: CGSize(width: 320, height: 150))

    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Erly prevents you from snoozing")
            VStack {
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Time spent snoozing").jk(18, 500).padding(.leading, 5)
                    chart.padding(.top, 13)
                    HStack {
                        Text("Day 1").jk(14); Spacer(); Text("Day 30").jk(14)
                    }.padding(.horizontal, 7).padding(.top, 2)
                    Text("84% of users report becoming a morning person after just 2 weeks.")
                        .jk(15).foregroundColor(C.muted).multilineTextAlignment(.center).lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity).padding(.top, 16)
                }
                .padding(EdgeInsets(top: 18, leading: 14, bottom: 16, trailing: 14))
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(C.chartBg))
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter { s.next() }
        })
    }

    private var chart: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let scale = min(w / 320, 1)
            let tx = (w - 320 * scale) / 2
            let ty = (150 - 150 * scale) / 2
            let P = { (x: CGFloat, y: CGFloat) in CGPoint(x: tx + x * scale, y: ty + y * scale) }
            ZStack(alignment: .topLeading) {
                SVGIcon(grayArea, fill: Color(hex: "DCD9D2").opacity(0.75), w: w, h: 150)
                SVGIcon(redArea, fill: Color(hex: "E4645E").opacity(0.12), w: w, h: 150)
                SVGIcon(blackCurve, stroke: .black, lineWidth: 3.5, w: w, h: 150)
                SVGIcon(redCurve, stroke: Color(hex: "E4645E"), lineWidth: 3.5, w: w, h: 150)
                SVGIcon(baseline, stroke: .black, lineWidth: 2, w: w, h: 150)

                dashed(P(10, 30), P(310, 30))
                dashed(P(10, 82), P(310, 82))
                dot(at: P(14, 30)); dot(at: P(306, 128))

                Text("Traditional alarm").jk(13, 600).fixedSize().position(P(272, 42))
                Text("With Erly").jk(13, 700).fixedSize().position(P(62, 116))
                Text("⏰").font(.system(size: 12)).position(P(30, 112))
            }
            .frame(width: w, height: 150)
        }
        .frame(height: 150)
    }

    private func dashed(_ a: CGPoint, _ b: CGPoint) -> some View {
        Path { p in p.move(to: a); p.addLine(to: b) }
            .stroke(Color(hex: "C6C3BC"), style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
    }
    private func dot(at p: CGPoint) -> some View {
        Circle().fill(.white).overlay(Circle().stroke(.black, lineWidth: 3))
            .frame(width: 14, height: 14).position(p)
    }
}

// MARK: - Compare (Set Only One Alarm)
struct CompareScreen: View {
    @EnvironmentObject var s: OnboardingState
    let filled: Bool
    private let tradAlarms: [(String, String)] = [
        ("First alarm", "6:00 AM"), ("Second alarm", "6:02 AM"),
        ("Third alarm", "6:05 AM"), ("Fourth alarm", "6:10 AM")
    ]

    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Set Only One Alarm")
            VStack {
                Spacer(minLength: 0)
                ZStack {
                    HStack(alignment: .top, spacing: 14) {
                        traditionalCard
                        erlyCard
                    }
                    if filled {
                        ZStack {
                            Circle().fill(Color(hex: "FF2D18")).frame(width: 56, height: 56)
                            SVGIcon(Icons.closeX, stroke: .white, lineWidth: 3.4, w: 27)
                        }
                        .offset(x: 0, y: -12)
                    }
                }
                Text("Stop setting backup alarms. Erly guarantees you wake up by demanding physical proof that you are out of bed.")
                    .jk(15).foregroundColor(Color(hex: "6E6A62")).multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity).padding(.top, 36)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter { s.next() }
        })
    }

    private var traditionalCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Traditional Alarm").jk(14, 800)
            if filled {
                VStack(spacing: 8) {
                    ForEach(Array(tradAlarms.enumerated()), id: \.offset) { _, a in
                        miniAlarm(a.0, a.1)
                    }
                }.padding(.top, 11)
            }
            Spacer(minLength: 0)
        }
        .padding(13).frame(maxWidth: .infinity, minHeight: 243, maxHeight: 243, alignment: .topLeading)
        .background(C.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .cardShadow(y: 2, blur: 9, opacity: 0.04)
    }

    private var erlyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Erly").jk(14, 800)
            if filled {
                miniAlarm("Alarm · Push ups", "6:00 AM").padding(.top, 11)
                HStack {
                    Spacer()
                    ZStack {
                        Circle().fill(C.green2).frame(width: 68, height: 68)
                        SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 36)
                    }
                    Spacer()
                }.padding(.top, 27)
            }
            Spacer(minLength: 0)
        }
        .padding(13).frame(maxWidth: .infinity, minHeight: 243, maxHeight: 243, alignment: .topLeading)
        .background(C.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .cardShadow(y: 2, blur: 9, opacity: 0.04)
    }

    private func miniAlarm(_ name: String, _ time: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(name).jk(11, 500).foregroundColor(C.muted)
                Text(time).jk(15, 800, tracking: -0.5)
            }
            Spacer()
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 11, style: .continuous).fill(C.green2).frame(width: 34, height: 20)
                Circle().fill(.white).frame(width: 16, height: 16).padding(.trailing, 2)
            }.frame(width: 34, height: 20)
        }
        .padding(.horizontal, 9).padding(.vertical, 7)
        .background(C.phoneBg).clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}

// MARK: - Info (art + title + body)
struct InfoScreen: View {
    @EnvironmentObject var s: OnboardingState
    let art: String
    let title: String
    let body_: String
    let cta: String
    init(art: String, title: String, body: String, cta: String) {
        self.art = art; self.title = title; self.body_ = body; self.cta = cta
    }
    var body: some View {
        OBScaffold(content: {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                StripedArt(label: art, w: 153, h: 108)
                Text(title).jk(27, 800, tracking: -0.9).multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity).padding(.top, 40)
                Text(body_).jk(15).foregroundColor(C.inkMuted).multilineTextAlignment(.center).lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity).padding(.top, 16)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter(label: cta) { s.next() }
        })
    }
}

// MARK: - Picker (time wheel)
struct PickerScreen: View {
    @EnvironmentObject var s: OnboardingState
    let title: String
    let subtitle: String
    let hour: Int
    let minute: Int
    let cta: String
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: title)
            if !subtitle.isEmpty { OBSubtitle(text: subtitle) }
            VStack {
                Spacer(minLength: 0)
                OBTimeWheel(hours: s.wheel(center: hour, mod: 24),
                            minutes: s.wheel(center: minute, mod: 60))
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }, footer: {
            OBFooter(label: cta) { s.next() }
        })
    }
}

// MARK: - Statement
struct StatementScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                (Text("Waking up at ") + Text("6:30 AM").foregroundColor(C.orangeSoft)
                 + Text(" is a realistic target. It's not hard at all!"))
                    .jk(27, 800, tracking: -0.9).multilineTextAlignment(.center).lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                Text("90% of users say that they wake up on time after using Erly.")
                    .jk(15).foregroundColor(C.inkMuted).multilineTextAlignment(.center).lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity).padding(.top, 22)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter { s.next() }
        })
    }
}
