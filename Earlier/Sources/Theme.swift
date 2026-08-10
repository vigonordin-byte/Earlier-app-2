import SwiftUI

// MARK: - Color from hex
extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255
            a = Double(v & 0xFF) / 255
        } else {
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Palette (from the design)
enum C {
    static let canvas       = Color(hex: "EFEEE9")
    static let phoneBg      = Color(hex: "F2F1ED")
    static let sheetBg      = Color(hex: "F0EFEA")
    static let card         = Color.white
    static let ink          = Color(hex: "000000")
    static let inputField   = Color(hex: "F7F6F2")

    static let muted        = Color(hex: "8C887F")
    static let muted2       = Color(hex: "9C988F")
    static let muted3       = Color(hex: "A8A49C")
    static let muted4       = Color(hex: "A29E96")
    static let placeholder  = Color(hex: "B4B0A8")
    static let chevron      = Color(hex: "9C988F")

    static let divider      = Color(hex: "EDEBE4")
    static let divider2     = Color(hex: "E7E5DE")
    static let barTrack     = Color(hex: "E6E4DD")
    static let pill         = Color(hex: "E4E2DA")
    static let chip         = Color(hex: "EDEBE4")
    static let toggleOff    = Color(hex: "CFCBC2")
    static let dayOffBorder = Color(hex: "E0DDD5")

    static let orange       = Color(hex: "FF7A00")
    static let orangeStreak = Color(hex: "FF6A00")
    static let red          = Color(hex: "F03A2F")
    static let redSoftBg    = Color(hex: "FBDDDB")
    static let gold         = Color(hex: "B08A2E")
    static let purple       = Color(hex: "8B7BE8")

    static let disabledBtn  = Color(hex: "CFCBC2")
    static let disabledInk  = Color(hex: "EFEEE9")

    // Onboarding
    static let inkMuted     = Color(hex: "4E4B46")
    static let progressTrk  = Color(hex: "C8C5BE")
    static let greenSel     = Color(hex: "4CD268")
    static let green2       = Color(hex: "34C759")
    static let chartBg      = Color(hex: "E9E7E1")
    static let ctaOff       = Color(hex: "B4B0A8")
    static let ctaOffInk    = Color(hex: "DDDAD3")
    static let orangeSoft   = Color(hex: "E09A5F")
    static let orangePay    = Color(hex: "F58220")
}

// MARK: - Plus Jakarta Sans font helper
enum JK {
    static func font(_ size: CGFloat, _ weight: Int = 400) -> Font {
        let name: String
        switch weight {
        case 800: name = "PlusJakartaSans-ExtraBold"
        case 700: name = "PlusJakartaSans-Bold"
        case 600: name = "PlusJakartaSans-SemiBold"
        case 500: name = "PlusJakartaSans-Medium"
        default:  name = "PlusJakartaSans-Regular"
        }
        return .custom(name, size: size)
    }
}

extension View {
    /// Plus Jakarta Sans with a numeric weight matching the CSS design tokens.
    func jk(_ size: CGFloat, _ weight: Int = 400, tracking: CGFloat = 0) -> some View {
        self.font(JK.font(size, weight)).tracking(tracking)
    }
    /// Soft card shadow used throughout the design (0 2px 12px rgba(0,0,0,0.03)).
    func cardShadow(y: CGFloat = 2, blur: CGFloat = 12, opacity: Double = 0.03) -> some View {
        self.shadow(color: .black.opacity(opacity), radius: blur / 2, x: 0, y: y)
    }
    func softShadow() -> some View { cardShadow(y: 2, blur: 10, opacity: 0.04) }
}
