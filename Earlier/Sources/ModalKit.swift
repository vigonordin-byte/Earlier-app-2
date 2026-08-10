import SwiftUI

// MARK: - Slide-up sheet (scrim + rounded-top panel starting below the status bar)
struct SheetContainer<Content: View>: View {
    @Environment(\.safeInsets) private var insets
    var bg: Color = C.phoneBg
    var scroll: Bool = true
    var onScrim: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { onScrim() }

            panel
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(bg)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12, style: .continuous))
                .padding(.top, insets.top)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder private var panel: some View {
        if scroll {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 22)
                    .padding(.bottom, insets.bottom + 25)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) { content }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.bottom, insets.bottom + 25)
        }
    }
}

// MARK: - Full-screen overlay (opaque, own top/bottom padding)
struct FullOverlay<Content: View>: View {
    @Environment(\.safeInsets) private var insets
    var bg: Color = C.phoneBg
    var scroll: Bool = false
    var topPad: CGFloat = 12
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            if scroll {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) { content }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 22)
                        .padding(.top, insets.top + topPad)
                        .padding(.bottom, insets.bottom + 25)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) { content }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 22)
                    .padding(.top, insets.top + topPad)
                    .padding(.bottom, insets.bottom + 25)
            }
        }
    }
}

// MARK: - Round back button used by sub-sheets
struct CircleBackButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            SVGIcon(Icons.chevronLeft, stroke: C.ink, lineWidth: 2.2, w: 11)
                .frame(width: 36, height: 36)
                .background(Circle().fill(C.card))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }.buttonStyle(.plain)
    }
}

// MARK: - Centered sheet header with a leading control
struct SheetHeader<Leading: View>: View {
    var title: String
    var trailingInset: CGFloat
    @ViewBuilder var leading: Leading
    var body: some View {
        ZStack {
            HStack { leading; Spacer() }
            Text(title).jk(22, 800)
                .frame(maxWidth: .infinity)
                .padding(.trailing, trailingInset)
        }
    }
}

// MARK: - Buttons
struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).jk(20, 800).foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.ink))
        }.buttonStyle(.plain)
    }
}

// MARK: - Weekday selector (New alarm / Edit bedtime)
struct DayCircles: View {
    var days: [DayToggle] = Mock.days
    var body: some View {
        HStack(spacing: 5) {
            ForEach(days) { d in
                Text(d.label).jk(14, 600)
                    .foregroundColor(d.on ? .white : C.placeholder)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Circle().fill(d.on ? C.ink : .clear))
                    .overlay(Circle().stroke(d.on ? C.ink : C.dayOffBorder, lineWidth: 1))
            }
        }
    }
}

// MARK: - White field placeholder row
struct FieldPlaceholder: View {
    var text: String
    var body: some View {
        Text(text).jk(18).foregroundColor(C.placeholder)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 19).padding(.vertical, 17)
            .card(22)
    }
}
