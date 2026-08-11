import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @StateObject private var state = OnboardingState()
    @Environment(\.modelContext) private var ctx
    var onFinish: () -> Void

    /// Apply the user's onboarding choices to their first alarm (6:30 AM,
    /// chosen mission + repeat days), creating it if the store is empty.
    private func applyOnboarding() {
        var mask = 0
        for (i, on) in state.days.enumerated() where on { mask |= (1 << i) }  // state.days is Mon-first
        let mission = onboardingMissions.indices.contains(state.mission)
            ? onboardingMissions[state.mission].name : "Push ups"
        let existing = try? ctx.fetch(FetchDescriptor<AlarmModel>())
        if let alarm = existing?.first {
            alarm.hour = 6; alarm.minute = 30; alarm.repeatMask = mask
            alarm.challengeName = mission; alarm.enabled = true; alarm.touch()
        } else {
            ctx.insert(AlarmModel(name: "First alarm", hour: 6, minute: 30,
                                  repeatMask: mask, soundName: "Birds",
                                  challengeName: mission, enabled: true))
        }
        try? ctx.save()
        AlarmCenter.shared.rescheduleAll(ctx)
    }

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
            WelcomeScreen(onSignIn: onFinish)
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
            PaywallScreen(onFinish: { applyOnboarding(); onFinish() })
        }
    }
}
