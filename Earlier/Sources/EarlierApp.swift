import SwiftUI
import SwiftData

@main
struct EarlierApp: App {
    @AppStorage("hasOnboarded") private var onboarded = false
    private let container = Persistence.makeContainer()

    var body: some Scene {
        WindowGroup {
            Group {
                if onboarded {
                    RootView().transition(.opacity)
                } else {
                    OnboardingFlow(onFinish: {
                        withAnimation(.easeInOut(duration: 0.35)) { onboarded = true }
                    })
                    .transition(.opacity)
                }
            }
            .onAppear { Persistence.seedIfEmpty(container.mainContext) }
        }
        .modelContainer(container)
    }
}
