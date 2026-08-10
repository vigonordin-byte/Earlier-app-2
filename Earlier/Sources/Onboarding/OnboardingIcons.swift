import SwiftUI

enum OB {
    static let backArrow = Ico([.path("M20 12H4"), .path("M10 6l-6 6 6 6")])
    static let shieldLock = Ico([
        .path("M12 2.5l8 3v6c0 5-3.4 8.6-8 10-4.6-1.4-8-5-8-10v-6z"),
        .path("M10 11V9.6a2 2 0 0 1 4 0V11")
    ])
    // Filled keep of the shield's lock body (drawn separately so it can be a solid fill)
    static let shieldLockBody = Ico([.rect(9, 11, 6, 5.4, 1.2)])

    static let eye = Ico([.path("M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6z")])
    static let eyePupil = Ico([.circle(12, 12, 2.6)])

    static let squatPerson = Ico([
        .circle(12, 5, 2), .path("M12 8v5"), .path("M8 10h8"),
        .path("M10 13v6"), .path("M14 13v6")
    ])
    static let sun = Ico([
        .circle(12, 12, 4), .path("M12 2v2.5"), .path("M12 19.5V22"),
        .path("M2 12h2.5"), .path("M19.5 12H22"), .path("M5 5l1.8 1.8"),
        .path("M17.2 17.2L19 19"), .path("M19 5l-1.8 1.8"), .path("M6.8 17.2L5 19")
    ])
    static let lockOpen = Ico([
        .rect(5, 11, 14, 10, 2.5), .path("M9 11V7.5a3.5 3.5 0 0 1 6.8-1.2")
    ])
    static let starFill = Ico([.path("M2 4l5 5 5-7 5 7 5-5-2 12H4z")], box: CGSize(width: 24, height: 20))
    static let alarmClock = Ico([
        .circle(12, 13.5, 7.5), .path("M12 10v3.5l2.5 2"),
        .path("M5 3.5L2.5 6"), .path("M19 3.5L21.5 6")
    ])
}
