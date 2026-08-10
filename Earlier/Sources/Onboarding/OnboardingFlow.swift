import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var state = OnboardingState()
    var onFinish: () -> Void

    var body: some View {
        GeometryReader { geo in
            screen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(state)
                .environment(\.safeInsets, geo.safeAreaInsets)
                .preferredColorScheme(.light)
                .animation(.easeOut(duration: 0.22), value: state.step)
        }
    }

    @ViewBuilder private var screen: some View {
        switch state.current {
        case .welcome:
            WelcomeScreen()
        case let .question(title, options):
            QuestionScreen(title: title, options: options)
        case .sources:
            SourcesScreen()
        case .chart:
            ChartScreen()
        case let .compare(filled):
            CompareScreen(filled: filled)
        case let .info(art, title, body, cta):
            InfoScreen(art: art, title: title, body: body, cta: cta)
        case let .picker(title, subtitle, hour, minute, cta):
            PickerScreen(title: title, subtitle: subtitle, hour: hour, minute: minute, cta: cta)
        case .statement:
            StatementScreen()
        case .trust:
            TrustScreen()
        case .missions:
            MissionsScreen()
        case .why:
            WhyScreen()
        case .days:
            DaysScreen()
        case .bars:
            BarsScreen()
        case .referral:
            ReferralScreen()
        case .notify:
            NotifyScreen()
        case .sign:
            SignScreen()
        case .loading:
            LoadingScreen()
        case .summary:
            SummaryScreen()
        case .signin:
            SignInScreen()
        case .paywall:
            PaywallScreen(onFinish: onFinish)
        }
    }
}
