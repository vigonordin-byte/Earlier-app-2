import SwiftUI

/// An icon = its primitive elements plus the SVG viewBox they were authored in.
struct Ico {
    let prims: [SVGPrim]
    let box: CGSize
    init(_ prims: [SVGPrim], box: CGSize = CGSize(width: 24, height: 24)) {
        self.prims = prims; self.box = box
    }
}

extension SVGIcon {
    init(_ ico: Ico, fill: Color? = nil, stroke: Color? = nil,
         lineWidth: CGFloat = 1.7, w: CGFloat, h: CGFloat? = nil) {
        self.init(ico.prims, box: ico.box, fill: fill, stroke: stroke,
                  lineWidth: lineWidth, w: w, h: h)
    }
}

enum Icons {
    // Chevrons (viewBox 12x20)
    static let chevronRight = Ico([.path("M2 2l7 8-7 8")], box: CGSize(width: 12, height: 20))
    static let chevronLeft  = Ico([.path("M9 2l-7 8 7 8")], box: CGSize(width: 12, height: 20))

    // Tab bar
    static let tabHome  = Ico([.path("M4 10.5L12 4l8 6.5V20a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1z"),
                               .path("M9.5 21v-6h5v6")])
    static let tabAlarm = Ico([.circle(12, 13.5, 7.5), .path("M12 10v3.5l2.5 2"),
                               .path("M5 3.5L2.5 6"), .path("M19 3.5L21.5 6")])
    static let tabBed   = Ico([.path("M3 6v13"), .path("M3 16h18v3"),
                               .path("M6.5 11.5h8a6 6 0 0 1 6 4.5H6.5z")])
    static let tabGear  = Ico([.circle(12, 12, 3.2),
        .path("M19.4 14.5a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-1.8-.3 1.6 1.6 0 0 0-1 1.5v.2a2 2 0 1 1-4 0v-.1a1.6 1.6 0 0 0-1-1.5 1.6 1.6 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.6 1.6 0 0 0 .3-1.8 1.6 1.6 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.6 1.6 0 0 0 1.5-1 1.6 1.6 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.6 1.6 0 0 0 1.8.3H9a1.6 1.6 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.6 1.6 0 0 0 1 1.5 1.6 1.6 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0-.3 1.8V9a1.6 1.6 0 0 0 1.5 1h.2a2 2 0 1 1 0 4h-.1a1.6 1.6 0 0 0-1.5 1z")])

    // Common glyphs
    static let moon    = Ico([.path("M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z")])
    static let trophy  = Ico([.path("M6 4h12v5a6 6 0 0 1-12 0V4z"),
                              .path("M18 5h2.5a2.5 2.5 0 0 1-2.5 4.5"),
                              .path("M6 5H3.5A2.5 2.5 0 0 0 6 9.5"),
                              .path("M12 15v3"), .path("M8.5 20h7")])
    static let bell    = Ico([.path("M18 8a6 6 0 1 0-12 0c0 6-3 7-3 7h18s-3-1-3-7z"),
                              .path("M10.3 20a2 2 0 0 0 3.4 0")])
    static let chart   = Ico([.path("M4 4v16h16"), .path("M7 15l3.5-4 3 2.5L18 8")])
    static let check   = Ico([.path("M5 12.5l4.5 4.5L19 7")])
    static let pencil  = Ico([.path("M4 20h6"), .path("M15.5 3.5a2.1 2.1 0 0 1 3 3L8 17l-4 1 1-4z")])
    static let signaturePen = Ico([.path("M2 12l4-4 4 2 3-2 5 4-4 5-3-2-2 2-3-1z"), .path("M13 8l3-2 5 4")])
    static let plus    = Ico([.path("M12 5v14"), .path("M5 12h14")])
    static let closeX  = Ico([.path("M5 5l14 14"), .path("M19 5L5 19")])
    static let speakerBirds = Ico([.path("M11 5 6 9H3v6h3l5 4V5z"),
                                   .path("M15.5 8.5a5 5 0 0 1 0 7"),
                                   .path("M18.5 6a8 8 0 0 1 0 12")])

    // Settings
    static let userFill = Ico([.circle(12, 8, 4), .path("M4 21a8 8 0 0 1 16 0z")])
    static let premium  = Ico([.path("M2 4l5 5 5-7 5 7 5-5-2 12H4z")], box: CGSize(width: 24, height: 20))
    static let clock    = Ico([.circle(12, 13, 8), .path("M12 9v4l2.5 2"),
                               .path("M5 3L2.5 5.5"), .path("M19 3l2.5 2.5")])
    static let lock     = Ico([.rect(4, 10, 16, 11, 3), .path("M8 10V7a4 4 0 0 1 8 0v3")])
    static let question = Ico([.circle(12, 12, 9),
                               .path("M9.5 9.5a2.6 2.6 0 1 1 3.4 2.5c-.6.2-.9.8-.9 1.4v.4"),
                               .circle(12, 17, 0.6)])
    static let star     = Ico([.path("M12 3.5l2.6 5.4 5.9.8-4.3 4.1 1.1 5.9-5.3-2.9-5.3 2.9 1.1-5.9L3.5 9.7l5.9-.8z")])
    static let doc      = Ico([.path("M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"),
                               .path("M14 3v5h5")])
    static let creditCard = Ico([.rect(3, 5, 18, 14, 3), .path("M3 10h18")])
    static let logout   = Ico([.path("M4 4v16"), .path("M9 12h11"), .path("M16 8l4 4-4 4")])
    static let deleteUser = Ico([.circle(9, 8, 4), .path("M2 21a7 7 0 0 1 13-3.5"),
                                 .path("M17 13l5 5"), .path("M22 13l-5 5")])

    // Wind-down "apps resting"
    static let restRefresh = Ico([.path("M21 12a8 8 0 1 1-3.2-6.4"), .path("M4 20l1.5-4"), .circle(12, 12, 8)])
    static let restMail    = Ico([.rect(3, 8, 18, 12, 2), .path("M8 4l4 4 4-4")])
    static let restPlay    = Ico([.path("M8 5l11 7-11 7z")])

    // New alarm
    static let speakerSmall = Ico([.path("M11 5 6 9H3v6h3l5 4V5z"), .path("M15.5 9.5a4 4 0 0 1 0 5")])

    // Achievements locked
    static let lockRounded = Ico([.rect(5, 10, 14, 10, 3), .path("M8.5 10V7.5a3.5 3.5 0 0 1 7 0V10")])

    // Blocking sheet
    static let blockRefresh = Ico([.path("M20 12a8 8 0 1 1-3.4-6.5"), .circle(12, 12, 8)])
    static let clockSimple  = Ico([.circle(12, 12, 9), .path("M12 7v5l3 2")])
    static let grid = Ico([.rect(3, 3, 7.5, 7.5, 1.5), .rect(13.5, 3, 7.5, 7.5, 1.5),
                           .rect(3, 13.5, 7.5, 7.5, 1.5), .rect(13.5, 13.5, 7.5, 7.5, 1.5)])

    // Sound options (sIcon, viewBox 24, stroke currentColor 1.7)
    static let soundDefault  = Ico([.path("M11 5 6 9H3v6h3l5 4V5z")])
    static let soundBirds    = Ico([.path("M8 8a4 4 0 0 1 8 0v3a4 4 0 0 1-4 4H8z"), .path("M8 15l-2 3")])
    static let soundPeaceful = Ico([.path("M3 19l6-11 4 7 2-3 6 7z")])
    static let soundPiano    = Ico([.path("M4 5h16v14H4z"), .path("M9 5v9"), .path("M15 5v9")])
    static let soundAmbient  = Ico([.path("M3 9h11a3 3 0 1 0-3-3"), .path("M3 14h14a3 3 0 1 1-3 3")])
    static let soundGuitar   = Ico([.path("M14 4l6 6"), .path("M13 9l-4 4"),
                                    .path("M9 13a3 3 0 1 0-3 3 3 3 0 0 0 3-3z")])
    static let soundMayhem   = Ico([.path("M13 2L4 14h7l-1 8 9-12h-7z")])
}
