import SwiftUI

// MARK: - Safe-area insets passed down from the root
private struct SafeInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets(top: 59, leading: 0, bottom: 34, trailing: 0)
}
extension EnvironmentValues {
    var safeInsets: EdgeInsets {
        get { self[SafeInsetsKey.self] }
        set { self[SafeInsetsKey.self] = newValue }
    }
}

func tabBarHeight(_ insets: EdgeInsets) -> CGFloat { 60 + insets.bottom }

// MARK: - Card styling
extension View {
    func card(_ radius: CGFloat = 22) -> some View {
        self.background(C.card)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .cardShadow()
    }
    func fill(_ color: Color, _ radius: CGFloat) -> some View {
        self.background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

// MARK: - List row chevron
struct RowChevron: View {
    var w: CGFloat = 9
    var body: some View {
        SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: w)
    }
}

struct HDivider: View {
    var color: Color = C.divider
    var body: some View { Rectangle().fill(color).frame(height: 1) }
}

// MARK: - Scrollable screen with status-bar + tab-bar clearance
struct ScreenScaffold<Content: View>: View {
    @Environment(\.safeInsets) private var insets
    var topGap: CGFloat = 6
    @ViewBuilder var content: Content
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, insets.top + topGap)
            .padding(.bottom, tabBarHeight(insets) + 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Custom bottom tab bar (matches the design's pill highlight)
struct TabBar: View {
    @EnvironmentObject var app: AppState
    @Environment(\.safeInsets) private var insets

    private func ico(_ t: Tab) -> Ico {
        switch t {
        case .home: return Icons.tabHome
        case .alarm: return Icons.tabAlarm
        case .bedtime: return Icons.tabBed
        case .settings: return Icons.tabGear
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { t in
                let selected = app.tab == t && app.view == nil
                Button {
                    app.go(t)
                    app.back()
                } label: {
                    VStack(spacing: 5) {
                        SVGIcon(ico(t), stroke: selected ? C.ink : C.muted2, lineWidth: 1.9, w: 27)
                            .frame(height: 27)
                        Text(t.title).jk(13, 600)
                            .foregroundColor(selected ? C.ink : C.muted2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 19, style: .continuous)
                            .fill(selected ? C.pill : .clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 7)
        .padding(.bottom, insets.bottom > 0 ? insets.bottom : 10)
        .background(C.phoneBg)
    }
}

// MARK: - Floating action button (Alarm / Bedtime tabs)
struct Fab: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            SVGIcon(Icons.plus, stroke: .white, lineWidth: 2.4, w: 22)
                .frame(width: 51, height: 51)
                .background(Circle().fill(C.ink))
                .shadow(color: .black.opacity(0.25), radius: 8.5, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toggle pill (static, on/off visual only)
struct TogglePill: View {
    var on: Bool = false
    var body: some View {
        ZStack(alignment: on ? .trailing : .leading) {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(on ? C.ink : C.toggleOff)
                .frame(width: 46, height: 26)
            Circle().fill(.white)
                .frame(width: 23, height: 23)
                .padding(.horizontal, 2)
                .shadow(color: .black.opacity(0.2), radius: 1.5, x: 0, y: 1)
        }
        .frame(width: 46, height: 26)
    }
}
