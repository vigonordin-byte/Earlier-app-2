import SwiftUI

// MARK: - Progress header (back arrow + bar)
struct OBHeader: View {
    @EnvironmentObject var state: OnboardingState
    var body: some View {
        HStack(spacing: 13) {
            Button { state.prev() } label: {
                SVGIcon(OB.backArrow, stroke: C.ink, lineWidth: 2, w: 22).frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }.buttonStyle(.plain)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(C.progressTrk)
                    Capsule().fill(C.ink).frame(width: max(0, geo.size.width * state.progress))
                }
            }
            .frame(height: 5)
        }
        .padding(.horizontal, 22).padding(.top, 13)
    }
}

// MARK: - Bottom CTA (with top divider)
struct OBFooter: View {
    @Environment(\.safeInsets) private var insets
    var label: String = "Continue"
    var bg: Color = C.ink
    var ink: Color = .white
    var action: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color(hex: "E4E2DA")).frame(height: 1)
            Button(action: action) {
                Text(label).jk(17, 700).foregroundColor(ink)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(bg))
                    .contentShape(Rectangle())
            }.buttonStyle(.plain)
            .padding(.horizontal, 22).padding(.top, 14)
            .padding(.bottom, insets.bottom > 0 ? insets.bottom + 6 : 20)
        }
    }
}

// MARK: - Standard onboarding screen scaffold (opaque bg + header + content + optional footer)
struct OBScaffold<Content: View, Footer: View>: View {
    @Environment(\.safeInsets) private var insets
    var showHeader: Bool = true
    @ViewBuilder var content: Content
    @ViewBuilder var footer: Footer

    var body: some View {
        ZStack {
            C.phoneBg.ignoresSafeArea()
            VStack(spacing: 0) {
                if showHeader {
                    OBHeader().padding(.top, insets.top + 6)
                }
                VStack(spacing: 0) { content }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                footer
            }
        }
    }
}

extension OBScaffold where Footer == EmptyView {
    init(showHeader: Bool = true, @ViewBuilder content: () -> Content) {
        self.init(showHeader: showHeader, content: content, footer: { EmptyView() })
    }
}

// MARK: - Title / subtitle
struct OBTitle: View {
    let text: String
    var body: some View {
        Text(text).jk(27, 800, tracking: -0.9).lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22).padding(.top, 14)
    }
}

struct OBSubtitle: View {
    let text: String
    var body: some View {
        Text(text).jk(17).foregroundColor(C.inkMuted).lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22).padding(.top, 11)
    }
}

// MARK: - Answer option row (question + sources)
struct OptionRow: View {
    let label: String
    let badge: String
    var mono: Bool = false
    let selected: Bool
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(selected ? C.greenSel : C.chip).frame(width: 31, height: 31)
                    if selected {
                        SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 17)
                    } else {
                        Text(badge)
                            .font(mono ? .system(size: 13, weight: .semibold, design: .monospaced) : JK.font(14, 600))
                            .foregroundColor(Color(hex: "6E6A62"))
                    }
                }
                Text(label).jk(17, 500)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(C.card)
            .clipShape(RoundedRectangle(cornerRadius: 23, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous)
                .stroke(selected ? C.greenSel : .clear, lineWidth: 1.5))
            .cardShadow(y: 2, blur: 9, opacity: 0.03)
            .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

// MARK: - Time wheel (onboarding pickers)
struct OBTimeWheel: View {
    let hours: [WheelValue]
    let minutes: [WheelValue]
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 116)
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(C.pill).frame(height: 40)
                Spacer()
            }
            HStack(spacing: 0) {
                column(hours)
                column(minutes)
            }
        }
        .frame(width: 300, height: 273)
    }
    private func column(_ vals: [WheelValue]) -> some View {
        VStack(spacing: 0) {
            ForEach(vals) { v in
                Text(v.v).font(JK.font(v.size, 600)).foregroundColor(v.color)
                    .frame(height: 39).frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Striped placeholder art
struct StripedArt: View {
    let label: String
    let w: CGFloat
    let h: CGFloat
    var body: some View {
        ZStack {
            C.phoneBg
            Stripes().stroke(Color(hex: "E7E4DD"), lineWidth: 5)
            Text(label).font(.system(size: 10, design: .monospaced))
                .foregroundColor(C.muted).multilineTextAlignment(.center).padding(4)
        }
        .frame(width: w, height: h)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
