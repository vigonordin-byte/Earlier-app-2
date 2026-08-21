import SwiftUI

struct PaywallScreen: View {
    @EnvironmentObject var s: OnboardingState
    @Environment(\.safeInsets) private var insets
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            C.phoneBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button { s.prev() } label: {
                            SVGIcon(Icons.chevronLeft, stroke: C.ctaOff, lineWidth: 2, w: 18)
                                .frame(width: 18, height: 18).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                        Spacer()
                    }.padding(.top, 11)

                    Text("Everything's unlocked while we're in beta.")
                        .jk(28, 800, tracking: -0.9).multilineTextAlignment(.center).lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity).padding(.top, 31)

                    VStack(alignment: .leading, spacing: 0) {
                        timelineRow(icon: OB.lockOpen, iconW: 20, circleBg: C.orangePay,
                                    barColor: Color(hex: "F9CB9C"), barHeight: 58,
                                    title: "Every feature, unlocked",
                                    body: "No-snooze alarms, challenges, streaks and bedtime — all of it.")
                        timelineRow(icon: Icons.bell, iconW: 20, circleBg: C.orangePay,
                                    barColor: Color(hex: "F9CB9C"), barHeight: 58,
                                    title: "Nothing to cancel",
                                    body: "No card, no trial timer, no charge. Just use it.")
                        timelineRow(icon: OB.starFill, iconW: 20, circleBg: .black, iconFill: true,
                                    barColor: Color(hex: "8C887F"), barHeight: 47,
                                    title: "Subscriptions later",
                                    body: "When paid plans arrive you'll be asked first — never billed by surprise.")
                    }
                    .padding(.top, 32)

                    HStack(spacing: 13) {
                        planCard(title: "Weekly", price: "Coming soon", selected: false)
                        planCard(title: "Yearly", price: "Coming soon", selected: false)
                    }
                    .padding(.top, 23)

                    HStack(spacing: 9) {
                        SVGIcon(Icons.check, stroke: .black, lineWidth: 2.4, w: 18)
                        Text("No payment, no card").jk(18, 700)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 18)

                    Button(action: onFinish) {
                        Text("Start using Earlier").jk(19, 800).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(C.ink))
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain).padding(.top, 14)

                    Text("Free while in beta — we'll ask before anything costs money.")
                        .jk(15).foregroundColor(C.muted).frame(maxWidth: .infinity)
                        .padding(.top, 13).padding(.bottom, 22)
                }
                .padding(.horizontal, 20)
                .padding(.top, insets.top)
                .padding(.bottom, insets.bottom)
            }
        }
    }

    private func timelineRow(icon: Ico, iconW: CGFloat, circleBg: Color, iconFill: Bool = false,
                             barColor: Color, barHeight: CGFloat, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(circleBg).frame(width: 40, height: 40)
                    if iconFill {
                        SVGIcon(icon, fill: .white, w: iconW)
                    } else {
                        SVGIcon(icon, stroke: .white, lineWidth: 2, w: iconW)
                    }
                }
                Rectangle().fill(barColor).frame(width: 11, height: barHeight)
            }
            .frame(width: 40)
            VStack(alignment: .leading, spacing: 0) {
                Text(title).jk(19, 800)
                Text(body).jk(16).foregroundColor(C.muted).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 4)
            }
            .padding(.top, 4)
            Spacer(minLength: 0)
        }
    }

    private func planCard(title: String, price: String, selected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(title).jk(17, 700)
                Text(price).jk(17).padding(.top, 2)
            }
            Spacer()
            if selected {
                ZStack {
                    Circle().fill(C.ink).frame(width: 25, height: 25)
                    SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 14)
                }
            } else {
                Circle().stroke(Color(hex: "C8C5BE"), lineWidth: 1.5).frame(width: 25, height: 25)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(C.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(selected ? Color.black : Color(hex: "C8C5BE"), lineWidth: selected ? 2 : 1.5))
        .opacity(0.55)
    }
}
