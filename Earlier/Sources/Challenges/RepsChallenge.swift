import SwiftUI
import CoreMotion

/// Counts reps from accelerometer peaks (hysteresis threshold). On devices
/// without motion hardware (Simulator) `motionAvailable` is false and the
/// view offers a manual tap-per-rep fallback.
final class RepCounter: ObservableObject {
    @Published var reps = 0
    let motionAvailable: Bool
    private let manager = CMMotionManager()
    private var armed = true

    init() { motionAvailable = manager.isDeviceMotionAvailable }

    func start() {
        guard motionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 50.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let a = motion?.userAcceleration else { return }
            let magnitude = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
            if self.armed, magnitude > 0.45 {
                self.armed = false
                self.reps += 1
            } else if !self.armed, magnitude < 0.12 {
                self.armed = true
            }
        }
    }

    func stop() { manager.stopDeviceMotionUpdates() }
    func manualRep() { reps += 1 }
}

struct RepsChallengeView: View {
    let name: String            // "Push ups" / "Squats"
    var target = 10
    let onComplete: () -> Void
    @StateObject private var counter = RepCounter()

    var body: some View {
        VStack(spacing: 0) {
            ChallengeTitle(title: "\(target) \(name.lowercased())",
                           subtitle: counter.motionAvailable
                               ? "Hold your phone — we count the movement"
                               : "No motion sensor here — tap after each rep")
            Spacer()
            Text("\(counter.reps)").jk(96, 800, tracking: -3)
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.2), value: counter.reps)
            Text("of \(target)").jk(18).foregroundColor(.white.opacity(0.55))
            Spacer()
            if !counter.motionAvailable {
                Button { counter.manualRep() } label: {
                    Text("+1 rep").jk(20, 800).foregroundColor(C.ink)
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(.white))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
                .padding(.horizontal, 46)
            }
        }
        .onAppear { counter.start() }
        .onDisappear { counter.stop() }
        .onChange(of: counter.reps) { _, reps in
            if reps >= target { onComplete() }
        }
    }
}
