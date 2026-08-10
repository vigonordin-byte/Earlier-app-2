import SwiftUI

@main
struct EarlierApp: App {
    @State private var onboarded = false
    var body: some Scene {
        WindowGroup {
            if onboarded {
                RootView().transition(.opacity)
            } else {
                OnboardingFlow(onFinish: { withAnimation(.easeInOut(duration: 0.35)) { onboarded = true } })
                    .transition(.opacity)
            }
        }
    }
}
