import SwiftUI

// MARK: - Trust
struct TrustScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ZStack {
                    Circle().fill(Color(hex: "E7E5DF")).frame(width: 128, height: 128)
                    ZStack {
                        SVGIcon(OB.shieldLockBody, fill: .black, w: 47)
                        SVGIcon(OB.shieldLock, stroke: .black, lineWidth: 1.9, w: 47)
                    }.frame(width: 47, height: 47)
                }.frame(maxWidth: .infinity)
                Text("Thank you for trusting us").jk(27, 800, tracking: -0.9)
                    .multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity).padding(.top, 29)
                Text("Now let's personalize Erly for you...").jk(17).foregroundColor(C.muted)
                    .frame(maxWidth: .infinity).padding(.top, 13)
                VStack(spacing: 0) {
                    Text("✋").font(.system(size: 20))
                    Text("Your privacy and security matter to us.").jk(17, 800).lineSpacing(3)
                        .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 9)
                    Text("We promise to always keep your personal information private and secure.")
                        .jk(15).foregroundColor(C.muted).multilineTextAlignment(.center).lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true).padding(.top, 7)
                }
                .frame(maxWidth: .infinity).padding(18)
                .background(C.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .cardShadow(y: 2, blur: 9, opacity: 0.03)
                .padding(.top, 29)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter(bg: C.ctaOff, ink: C.ctaOffInk) { s.next() }
        })
    }
}

// MARK: - Missions
struct MissionsScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Set your wake-up challenge")
            OBSubtitle(text: "Complete this to dismiss your alarm")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 13) {
                    ForEach(Array(onboardingMissions.enumerated()), id: \.offset) { i, m in
                        Button { s.mission = i } label: { missionRow(m, selected: s.mission == i) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22).padding(.top, 14).padding(.bottom, 11)
            }
        }, footer: {
            OBFooter { s.next() }
        })
    }

    private func missionRow(_ m: OnboardingMission, selected: Bool) -> some View {
        HStack(spacing: 13) {
            Text(m.emoji).font(.system(size: 27)).frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(m.name).jk(18, 800, tracking: -0.3)
                Text(m.desc).jk(15).foregroundColor(C.muted).lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 6)
            ZStack {
                Circle().fill(selected ? C.green2 : C.chip).frame(width: 31, height: 31)
                if selected {
                    SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 18)
                } else {
                    ZStack {
                        SVGIcon(OB.eye, stroke: C.muted, lineWidth: 1.9, w: 18)
                        SVGIcon(OB.eyePupil, fill: C.muted, w: 18)
                    }.frame(width: 18, height: 18)
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(C.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(selected ? Color(hex: "D8D5CE") : .clear, lineWidth: 1.5))
        .cardShadow(y: 2, blur: 9, opacity: 0.03)
        .contentShape(Rectangle())
    }
}

// MARK: - Why
struct WhyScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Why squats wake you up")
            OBSubtitle(text: "Once you're out of bed, you're up.")
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                StripedArt(label: "squat illustration", w: 135, h: 135)
                Text("This mission forces you out from under the covers and gets your body moving. Once you're on your feet, sleep loses its grip — motion beats willpower every time.")
                    .jk(15).foregroundColor(C.inkMuted).multilineTextAlignment(.center).lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity).padding(.top, 32)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter { s.next() }
        })
    }
}

// MARK: - Days
struct DaysScreen: View {
    @EnvironmentObject var s: OnboardingState
    private let names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Which days should your alarm repeat?")
            OBSubtitle(text: "Select at least one day")
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { i in
                        Button { s.toggleDay(i) } label: {
                            HStack {
                                Text(names[i]).jk(18, 500)
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .fill(s.days[i] ? C.ink : .clear)
                                        .frame(width: 27, height: 27)
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .stroke(s.days[i] ? C.ink : Color(hex: "D4D1CA"), lineWidth: 1.5)
                                        .frame(width: 27, height: 27)
                                    if s.days[i] { SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 17) }
                                }
                            }
                            .padding(.vertical, 11)
                            .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 5)
                .background(C.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .cardShadow(y: 2, blur: 9, opacity: 0.03)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22).padding(.top, 16)
        }, footer: {
            OBFooter { s.next() }
        })
    }
}

// MARK: - Bars (5x faster)
struct BarsScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Get out of bed 5x faster with Erly vs on your own")
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    HStack(alignment: .bottom, spacing: 18) {
                        barCard(title: "Without Erly", height: 41, bg: Color(hex: "CFCBC4"),
                                label: "20%", labelColor: .black, labelBottom: false)
                        barCard(title: "With Erly", height: 137, bg: .black,
                                label: "5x", labelColor: .white, labelBottom: true)
                    }
                    Text("Erly makes it easy and holds you accountable.")
                        .jk(15).foregroundColor(C.muted).multilineTextAlignment(.center).lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity).padding(.top, 16)
                }
                .padding(EdgeInsets(top: 22, leading: 23, bottom: 20, trailing: 23))
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(C.chartBg))
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter { s.next() }
        })
    }

    private func barCard(title: String, height: CGFloat, bg: Color, label: String, labelColor: Color, labelBottom: Bool) -> some View {
        ZStack(alignment: .top) {
            Color.clear
            Text(title).jk(14, 700).padding(.top, 13)
            VStack {
                Spacer()
                ZStack(alignment: labelBottom ? .bottom : .center) {
                    RoundedRectangle(cornerRadius: 13, style: .continuous).fill(bg).frame(height: height)
                    Text(label).jk(15, 600).foregroundColor(labelColor)
                        .padding(.bottom, labelBottom ? 13 : 0)
                }
            }
        }
        .frame(height: 189)
        .frame(maxWidth: .infinity)
        .background(C.card).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

// MARK: - Referral
struct ReferralScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Have a referral code?")
            OBSubtitle(text: "Enter it below or skip this step")
            VStack {
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    Text("Referral Code").jk(17).foregroundColor(C.placeholder).padding(.leading, 20)
                    Spacer()
                    Text("Submit").jk(17, 600).foregroundColor(Color(hex: "EDEBE5"))
                        .padding(.horizontal, 23).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 23, style: .continuous).fill(C.ctaOff))
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(Color(hex: "EDEBE5")))
                .overlay(RoundedRectangle(cornerRadius: 27, style: .continuous).stroke(Color(hex: "E2DFD8"), lineWidth: 1))
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter { s.next() }
        })
    }
}

// MARK: - Notify
struct NotifyScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("Reach your goals with notifications").jk(27, 800, tracking: -0.9)
                    .multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity)
                VStack(spacing: 0) {
                    Text("Erly would like to send you notifications").jk(17).lineSpacing(3)
                        .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 22).padding(.top, 20).padding(.bottom, 18)
                    Rectangle().fill(Color(hex: "CBC8C1")).frame(height: 1)
                    HStack(spacing: 0) {
                        Text("Don't Allow").jk(17).frame(maxWidth: .infinity).padding(.vertical, 14)
                        Button {
                            // Real system alarm (AlarmKit) + notification permission.
                            Task {
                                _ = await AlarmCenter.shared.requestAllPermissions()
                                s.next()
                            }
                        } label: {
                            Text("Allow").jk(17).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .background(C.ink).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
                .background(Color(hex: "DEDBD4"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.top, 32)
                Text("👆").font(.system(size: 23))
                    .frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 67).padding(.top, 7)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        })
    }
}

// MARK: - Sign commitment
struct SignScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Sign your commitment")
            (Text("Promise yourself that you will wake up tomorrow at ").foregroundColor(C.inkMuted)
             + Text("6:30 AM").foregroundColor(.black).font(JK.font(17, 800))
             + Text(", when your alarm goes off.").foregroundColor(C.inkMuted))
                .jk(17).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22).padding(.top, 11)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("Sign to make it official").jk(17).foregroundColor(C.muted).frame(maxWidth: .infinity)
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(hex: "E7E5DF"))
                    .frame(height: 180).padding(.top, 13)
                Text("Signed on August 10, 2026").jk(15).foregroundColor(C.muted)
                    .frame(maxWidth: .infinity).padding(.top, 14)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter(bg: C.ctaOff, ink: C.ctaOffInk) { s.next() }
        })
    }
}

// MARK: - Loading
struct LoadingScreen: View {
    @EnvironmentObject var s: OnboardingState
    @Environment(\.safeInsets) private var insets
    var body: some View {
        ZStack {
            C.phoneBg.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("We're setting everything up for you").jk(31, 800, tracking: -1)
                    .multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity)
                Text("28%").jk(40, 800, tracking: -1.4).frame(maxWidth: .infinity).padding(.top, 31)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "DCD9D2")).frame(height: 7)
                    GeometryReader { g in
                        Capsule().fill(C.ink).frame(width: g.size.width * 0.28, height: 7)
                    }.frame(height: 7)
                }.padding(.top, 14)
                Text("Calibrating motion detection").jk(17).foregroundColor(C.muted)
                    .frame(maxWidth: .infinity).padding(.top, 13)
                HStack(spacing: 13) {
                    SVGIcon(Icons.check, stroke: .black, lineWidth: 2.2, w: 18)
                    Text("Eliminate Snoozing").jk(18, 500)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 20).padding(.top, 32)
            }
            .padding(.horizontal, 22)
        }
        .contentShape(Rectangle())
        .onTapGesture { s.next() }
        .onAppear {
            let captured = s.step
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if s.step == captured { s.next() }
            }
        }
    }
}

// MARK: - Summary
struct SummaryScreen: View {
    @EnvironmentObject var s: OnboardingState
    private let streak: [(String, Bool)] = [("S", false), ("M", true), ("T", true), ("W", true), ("T", true), ("F", true), ("S", false)]
    var body: some View {
        OBScaffold(content: {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ZStack {
                    Circle().fill(C.ink).frame(width: 34, height: 34)
                    SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 18)
                }.frame(maxWidth: .infinity)
                Text("Tomorrow, you will wake up at").jk(19).foregroundColor(C.inkMuted)
                    .frame(maxWidth: .infinity).padding(.top, 20)
                Text("6:30 AM").jk(47, 800, tracking: -2).frame(maxWidth: .infinity).padding(.top, 9)
                HStack(alignment: .top, spacing: 11) {
                    flowStep(OB.alarmClock, 22, 1.8, "Alarm rings")
                    Text("→").jk(16).foregroundColor(C.muted).padding(.top, 13)
                    flowStep(OB.squatPerson, 20, 1.9, "Squats")
                    Text("→").jk(16).foregroundColor(C.muted).padding(.top, 13)
                    flowStep(OB.sun, 22, 1.9, "Alarm off")
                }
                .frame(maxWidth: .infinity).padding(.top, 23)
                Text("No snoozing. No backup alarms.").jk(18).frame(maxWidth: .infinity).padding(.top, 23)
                VStack(spacing: 0) {
                    Text("Your wake-up streak").jk(18, 800).frame(maxWidth: .infinity)
                    Text("Complete your mission on these days to build your streak")
                        .jk(15).foregroundColor(C.muted).multilineTextAlignment(.center).lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity).padding(.top, 5)
                    HStack(spacing: 5) {
                        ForEach(Array(streak.enumerated()), id: \.offset) { _, d in
                            Text(d.0).jk(14, 500)
                                .foregroundColor(d.1 ? .black : C.placeholder)
                                .frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
                                .background(Circle().fill(d.1 ? Color.white : C.chip))
                                .overlay(Circle().stroke(d.1 ? Color(hex: "E4DFE8") : .clear, lineWidth: 1))
                        }
                    }.padding(.top, 13)
                }
                .padding(EdgeInsets(top: 18, leading: 14, bottom: 18, trailing: 14))
                .background(C.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .cardShadow(y: 2, blur: 9, opacity: 0.03)
                .padding(.top, 20)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }, footer: {
            OBFooter { s.next() }
        })
    }

    private func flowStep(_ ico: Ico, _ w: CGFloat, _ lw: CGFloat, _ label: String) -> some View {
        VStack(spacing: 0) {
            SVGIcon(ico, stroke: .white, lineWidth: lw, w: w).frame(width: w, height: w)
                .frame(width: 41, height: 41).background(Circle().fill(C.ink))
            Text(label).jk(15).padding(.top, 7)
        }.frame(width: 70)
    }
}

// MARK: - Sign in
struct SignInScreen: View {
    @EnvironmentObject var s: OnboardingState
    var body: some View {
        OBScaffold(content: {
            OBTitle(text: "Save your progress")
            OBSubtitle(text: "Keep your alarms and streak safe")
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Button { s.next() } label: {
                    HStack(spacing: 11) {
                        Image(systemName: "apple.logo").font(.system(size: 18)).foregroundColor(.white)
                        Text("Sign in with Apple").jk(18, 700).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.ink))
                    .contentShape(Rectangle())
                }.buttonStyle(.plain)
                Button { s.next() } label: {
                    HStack(spacing: 11) {
                        Text("G").font(.system(size: 17, weight: .bold, design: .monospaced)).foregroundColor(C.muted)
                        Text("Sign in with Google").jk(18, 700)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(C.card).clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
                    .cardShadow(y: 2, blur: 9, opacity: 0.04)
                    .contentShape(Rectangle())
                }.buttonStyle(.plain).padding(.top, 13)
                Button { s.next() } label: {
                    (Text("Would you like to sign in later? ").foregroundColor(C.muted)
                     + Text("Skip").foregroundColor(.black).font(JK.font(16, 800)))
                        .jk(16).frame(maxWidth: .infinity).contentShape(Rectangle())
                }.buttonStyle(.plain).padding(.top, 18)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        })
    }
}
