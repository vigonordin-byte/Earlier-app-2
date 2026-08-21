import SwiftUI

struct RootView: View {
    @StateObject private var app = AppState()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                C.phoneBg.ignoresSafeArea()

                // Main tab content
                Group {
                    switch app.tab {
                    case .home:     HomeView()
                    case .alarm:    AlarmView()
                    case .bedtime:  BedtimeView()
                    case .settings: SettingsView()
                    }
                }

                // Floating add button (Alarm / Bedtime), above content, below tab bar
                if (app.tab == .alarm || app.tab == .bedtime) && app.view == nil {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Fab { app.openAddForCurrentTab() }
                                .padding(.trailing, 22)
                                .padding(.bottom, tabBarHeight(geo.safeAreaInsets) + 17)
                        }
                    }
                    .ignoresSafeArea()
                }

                // History overlay sits above content but below the tab bar
                if app.view == .history {
                    HistoryView().transition(.opacity)
                }

                // Custom tab bar
                if !app.overlayCoversChrome {
                    VStack(spacing: 0) {
                        Spacer()
                        TabBar()
                    }
                    .ignoresSafeArea()
                }

                // Full-screen overlays covering the chrome
                overlays

                // Sub-sheets (time / sound / challenge / blocking)
                subSheets

                // Friction screen — sits above everything.
                if let g = app.guardAction {
                    BedtimeGuardView(action: g)
                        .transition(.opacity)
                        .zIndex(20)
                }
            }
            .environment(\.safeInsets, geo.safeAreaInsets)
            .environmentObject(app)
            .preferredColorScheme(app.view == .streak ? .dark : .light)
            .animation(.easeOut(duration: 0.22), value: app.view != nil)
            .animation(.easeOut(duration: 0.25), value: app.guardAction)
            .animation(.easeOut(duration: 0.2), value: app.sub != nil)
            .animation(.easeInOut(duration: 0.18), value: app.tab)
        }
    }

    @ViewBuilder private var overlays: some View {
        switch app.view {
        case .windDown:    WindDownView().transition(.opacity)
        case .alarmEditor:   AlarmEditorView().transition(.move(edge: .bottom))
        case .bedtimeEditor: BedtimeEditorView().transition(.move(edge: .bottom))
        case .achievements: AchievementsView().transition(.opacity)
        case .streak:      StreakView().transition(.opacity)
        case .reason:      ReasonView().transition(.opacity)
        case .signature:   SignatureView().transition(.opacity)
        default:           EmptyView()
        }
    }

    @ViewBuilder private var subSheets: some View {
        switch app.sub {
        case .time:      TimeSheet().transition(.move(edge: .bottom))
        case .sound:     SoundSheet().transition(.move(edge: .bottom))
        case .challenge: ChallengeSheet().transition(.move(edge: .bottom))
        case .blocking:  BlockingSheet().transition(.move(edge: .bottom))
        default:         EmptyView()
        }
    }
}

#Preview {
    RootView()
}
