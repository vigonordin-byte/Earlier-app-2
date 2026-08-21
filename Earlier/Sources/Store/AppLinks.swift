import Foundation

/// Outward-facing URLs.
///
/// ⚠️ These are placeholders. Terms and Privacy must point at real, published
/// pages before submitting to the App Store — Apple rejects builds whose legal
/// links 404, and the privacy policy URL is a required App Store Connect field.
enum AppLinks {
    static let supportEmail = "support@earlier.app"
    static let terms = URL(string: "https://earlier.app/terms")!
    static let privacy = URL(string: "https://earlier.app/privacy")!
    /// Apple's own subscription management screen — no app ID needed.
    static let manageSubscriptions = URL(string: "https://apps.apple.com/account/subscriptions")!

    static var supportMail: URL {
        URL(string: "mailto:\(supportEmail)?subject=Earlier%20support")!
    }
}
