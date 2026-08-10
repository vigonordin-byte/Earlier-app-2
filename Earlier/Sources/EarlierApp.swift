import SwiftUI
import SwiftData

@main
struct EarlierApp: App {
    @AppStorage("hasOnboarded") private var onboarded = false
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var alarmCenter = AlarmCenter.shared
    private let container = Persistence.makeContainer()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if onboarded {
                    RootView().transition(.opacity)
                } else {
                    OnboardingFlow(onFinish: {
                        withAnimation(.easeInOut(duration: 0.35)) { onboarded = true }
                    })
                    .transition(.opacity)
                }

                // Ringing takes over everything while an alarm fires.
                if alarmCenter.ringingAlarmID != nil {
                    AlarmRingingView(alarmID: alarmCenter.ringingAlarmID)
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .animation(.easeOut(duration: 0.25), value: alarmCenter.ringingAlarmID != nil)
            .onAppear {
                Persistence.seedIfEmpty(container.mainContext)
                AlarmCenter.shared.activate()
                AlarmCenter.shared.rescheduleAll(container.mainContext)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    AlarmCenter.shared.refreshAuthorization()
                    AlarmCenter.shared.rescheduleAll(container.mainContext)
                }
            }
        }
        .modelContainer(container)
    }
}
