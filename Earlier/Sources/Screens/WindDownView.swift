import SwiftUI

struct WindDownView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.safeInsets) private var insets

    var body: some View {
        ZStack {
            C.phoneBg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Spacer(minLength: 0).frame(maxHeight: .infinity).layoutPriority(0.9)
                bedIllustration
                Spacer(minLength: 0).frame(maxHeight: .infinity)
                Text("It's bedtime.").jk(39, 800, tracking: -1.6)
                    .frame(maxWidth: .infinity)
                Text("Lights out now and you get 8h 00m before your 6:30 AM alarm.")
                    .jk(18).foregroundColor(C.muted)
                    .multilineTextAlignment(.center).lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                appsResting.padding(.top, 22)
                Spacer(minLength: 0).frame(maxHeight: .infinity).layoutPriority(0.8)
                Text("5 more minutes · 1 left").jk(17, 600).foregroundColor(Color(hex: "6E6A62"))
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(C.pill))
                PrimaryButton(title: "Good night") { app.back() }.padding(.top, 10)
                Text("Screen dims in 20s").jk(15).foregroundColor(C.muted3)
                    .frame(maxWidth: .infinity).padding(.top, 12)
            }
            .padding(.horizontal, 22)
            .padding(.top, insets.top + 6)
            .padding(.bottom, insets.bottom + 18)
        }
    }

    private var header: some View {
        HStack {
            Button { app.back() } label: {
                Text("EARLIER").jk(28, 800, tracking: -0.5)
            }.buttonStyle(.plain)
            Spacer()
            HStack(spacing: 8) {
                SVGIcon(Icons.moon, fill: C.purple, w: 17).frame(width: 17, height: 17)
                Text("Bedtime").jk(17, 700)
            }
            .padding(.horizontal, 17).padding(.vertical, 9)
            .background(C.card)
            .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
            .softShadow()
        }
    }

    private var bedIllustration: some View {
        ZStack {
            C.phoneBg
            Stripes().stroke(Color(hex: "EAE7E0"), lineWidth: 5)
            Text("bed illustration").font(.system(size: 10, design: .monospaced)).foregroundColor(C.muted)
        }
        .frame(width: 152, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .frame(maxWidth: .infinity)
    }

    private var appsResting: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Apps are resting").jk(19, 800, tracking: -0.4)
                Spacer()
                Text("until 6:30 AM").jk(15).foregroundColor(C.muted)
            }
            HStack(spacing: 10) {
                restTile(Icons.restRefresh)
                restTile(Icons.restMail)
                restTile(Icons.restPlay, fill: true)
                Spacer()
                Text("+3").jk(17, 500).foregroundColor(C.muted)
            }.padding(.top, 13)
        }
        .padding(.horizontal, 19).padding(.vertical, 17)
        .card(22)
    }

    private func restTile(_ ico: Ico, fill: Bool = false) -> some View {
        Group {
            if fill {
                SVGIcon(ico, fill: C.placeholder, w: 22).frame(width: 22, height: 22)
            } else {
                SVGIcon(ico, stroke: C.placeholder, lineWidth: 1.8, w: 22).frame(width: 22, height: 22)
            }
        }
        .frame(width: 44, height: 44)
        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(C.chip))
    }
}

/// Diagonal stripe pattern used for the placeholder illustration.
struct Stripes: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let gap: CGFloat = 10
        var x: CGFloat = -rect.height
        while x < rect.width {
            p.move(to: CGPoint(x: x, y: rect.height))
            p.addLine(to: CGPoint(x: x + rect.height, y: 0))
            x += gap
        }
        return p
    }
}
