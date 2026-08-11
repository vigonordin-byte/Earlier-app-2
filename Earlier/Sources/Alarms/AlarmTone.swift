import AVFoundation

/// Loops the bundled alarm tone while the ringing screen is up, so the alarm
/// keeps sounding in-app until the challenge is completed.
final class AlarmTone {
    private var player: AVAudioPlayer?

    func start() {
        guard player == nil else { return }
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "caf") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
