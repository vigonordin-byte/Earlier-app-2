import SwiftUI

// MARK: - SVG primitive elements
enum SVGPrim {
    case path(String)
    case circle(Double, Double, Double)                 // cx, cy, r
    case rect(Double, Double, Double, Double, Double)    // x, y, w, h, rx
}

// MARK: - Minimal SVG-path -> Path builder (viewBox coordinate space)
private struct SVGTokenizer {
    let chars: [Character]
    var i = 0
    init(_ s: String) { chars = Array(s) }

    mutating func nextCommand() -> Character? {
        skipSep()
        guard i < chars.count else { return nil }
        let c = chars[i]
        if c.isLetter { i += 1; return c }
        return nil
    }

    mutating func peekIsCommand() -> Bool {
        skipSep()
        guard i < chars.count else { return false }
        return chars[i].isLetter
    }

    mutating func number() -> Double? {
        skipSep()
        var str = ""
        var seenDot = false
        var seenExp = false
        while i < chars.count {
            let c = chars[i]
            if c == "-" || c == "+" {
                if str.isEmpty || str.last == "e" || str.last == "E" { str.append(c); i += 1; continue }
                else { break }
            }
            if c == "." {
                if seenDot { break }
                seenDot = true; str.append(c); i += 1; continue
            }
            if c == "e" || c == "E" {
                if seenExp { break }
                seenExp = true; str.append(c); i += 1; continue
            }
            if c.isNumber { str.append(c); i += 1; continue }
            break
        }
        return Double(str)
    }

    mutating func flag() -> Double? {
        // arc flags are single 0/1 digits, possibly not separated
        skipSep()
        guard i < chars.count else { return nil }
        let c = chars[i]
        if c == "0" || c == "1" { i += 1; return c == "1" ? 1 : 0 }
        return number()
    }

    mutating func moreParams() -> Bool {
        skipSep()
        guard i < chars.count else { return false }
        let c = chars[i]
        return c.isNumber || c == "-" || c == "+" || c == "."
    }

    mutating func skipSep() {
        while i < chars.count {
            let c = chars[i]
            if c == " " || c == "," || c == "\n" || c == "\t" || c == "\r" { i += 1 } else { break }
        }
    }
}

private func appendArc(_ path: inout Path, from p0: CGPoint, rx: Double, ry: Double,
                       xAxisRotation: Double, largeArc: Bool, sweep: Bool, to p1: CGPoint) {
    // Endpoint -> center parameterization (SVG spec F.6)
    var rx = abs(rx), ry = abs(ry)
    if rx == 0 || ry == 0 { path.addLine(to: p1); return }
    let phi = xAxisRotation * .pi / 180
    let cosPhi = cos(phi), sinPhi = sin(phi)
    let dx = (Double(p0.x) - Double(p1.x)) / 2
    let dy = (Double(p0.y) - Double(p1.y)) / 2
    let x1p = cosPhi * dx + sinPhi * dy
    let y1p = -sinPhi * dx + cosPhi * dy

    var rxs = rx * rx, rys = ry * ry
    let x1ps = x1p * x1p, y1ps = y1p * y1p
    let lambda = x1ps / rxs + y1ps / rys
    if lambda > 1 {
        let s = sqrt(lambda)
        rx *= s; ry *= s; rxs = rx * rx; rys = ry * ry
    }
    var num = rxs * rys - rxs * y1ps - rys * x1ps
    let den = rxs * y1ps + rys * x1ps
    if num < 0 { num = 0 }
    var co = sqrt(num / den)
    if largeArc == sweep { co = -co }
    let cxp = co * (rx * y1p / ry)
    let cyp = co * -(ry * x1p / rx)
    let cx = cosPhi * cxp - sinPhi * cyp + (Double(p0.x) + Double(p1.x)) / 2
    let cy = sinPhi * cxp + cosPhi * cyp + (Double(p0.y) + Double(p1.y)) / 2

    func angle(_ ux: Double, _ uy: Double, _ vx: Double, _ vy: Double) -> Double {
        let dot = ux * vx + uy * vy
        let len = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
        var a = acos(max(-1, min(1, dot / len)))
        if ux * vy - uy * vx < 0 { a = -a }
        return a
    }
    let theta1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    var dTheta = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if !sweep && dTheta > 0 { dTheta -= 2 * .pi }
    if sweep && dTheta < 0 { dTheta += 2 * .pi }

    // Approximate the arc with small line segments (fine for icon sizes).
    let segs = max(2, Int(ceil(abs(dTheta) / (.pi / 30))))
    for s in 1...segs {
        let t = theta1 + dTheta * Double(s) / Double(segs)
        let x = cosPhi * (rx * cos(t)) - sinPhi * (ry * sin(t)) + cx
        let y = sinPhi * (rx * cos(t)) + cosPhi * (ry * sin(t)) + cy
        path.addLine(to: CGPoint(x: x, y: y))
    }
}

private func buildPathString(_ d: String, into path: inout Path) {
    var t = SVGTokenizer(d)
    var current = CGPoint.zero
    var start = CGPoint.zero
    var lastCtrl: CGPoint? = nil
    var lastBase: Character = " "

    func pt(_ x: Double, _ y: Double, rel: Bool) -> CGPoint {
        rel ? CGPoint(x: Double(current.x) + x, y: Double(current.y) + y) : CGPoint(x: x, y: y)
    }

    while let cmdLetter = t.nextCommand() {
        let rel = cmdLetter.isLowercase
        let declared = cmdLetter.lowercased().first!
        var firstIteration = true

        repeat {
            // After the first coordinate pair, an "m"/"M" behaves like line-to.
            let base: Character = (declared == "m" && !firstIteration) ? "l" : declared
            firstIteration = false

            switch base {
            case "m":
                guard let x = t.number(), let y = t.number() else { return }
                current = pt(x, y, rel: rel); start = current
                path.move(to: current)
            case "l":
                guard let x = t.number(), let y = t.number() else { return }
                current = pt(x, y, rel: rel); path.addLine(to: current)
            case "h":
                guard let x = t.number() else { return }
                current = CGPoint(x: rel ? Double(current.x) + x : x, y: Double(current.y)); path.addLine(to: current)
            case "v":
                guard let y = t.number() else { return }
                current = CGPoint(x: Double(current.x), y: rel ? Double(current.y) + y : y); path.addLine(to: current)
            case "c":
                guard let x1 = t.number(), let y1 = t.number(), let x2 = t.number(), let y2 = t.number(),
                      let x = t.number(), let y = t.number() else { return }
                let c1 = pt(x1, y1, rel: rel), c2 = pt(x2, y2, rel: rel), end = pt(x, y, rel: rel)
                path.addCurve(to: end, control1: c1, control2: c2)
                lastCtrl = c2; current = end
            case "s":
                guard let x2 = t.number(), let y2 = t.number(), let x = t.number(), let y = t.number() else { return }
                let c2 = pt(x2, y2, rel: rel), end = pt(x, y, rel: rel)
                let c1: CGPoint
                if (lastBase == "c" || lastBase == "s"), let lc = lastCtrl {
                    c1 = CGPoint(x: 2 * Double(current.x) - Double(lc.x), y: 2 * Double(current.y) - Double(lc.y))
                } else { c1 = current }
                path.addCurve(to: end, control1: c1, control2: c2)
                lastCtrl = c2; current = end
            case "q":
                guard let x1 = t.number(), let y1 = t.number(), let x = t.number(), let y = t.number() else { return }
                let c = pt(x1, y1, rel: rel), end = pt(x, y, rel: rel)
                path.addQuadCurve(to: end, control: c)
                lastCtrl = c; current = end
            case "t":
                guard let x = t.number(), let y = t.number() else { return }
                let end = pt(x, y, rel: rel)
                let c: CGPoint
                if (lastBase == "q" || lastBase == "t"), let lc = lastCtrl {
                    c = CGPoint(x: 2 * Double(current.x) - Double(lc.x), y: 2 * Double(current.y) - Double(lc.y))
                } else { c = current }
                path.addQuadCurve(to: end, control: c)
                lastCtrl = c; current = end
            case "a":
                guard let rx = t.number(), let ry = t.number(), let rot = t.number(),
                      let laf = t.flag(), let sf = t.flag(), let x = t.number(), let y = t.number() else { return }
                let end = pt(x, y, rel: rel)
                appendArc(&path, from: current, rx: rx, ry: ry, xAxisRotation: rot,
                          largeArc: laf != 0, sweep: sf != 0, to: end)
                current = end
            case "z":
                path.closeSubpath(); current = start
            default:
                return
            }

            if base != "c" && base != "s" && base != "q" && base != "t" { lastCtrl = nil }
            lastBase = base
        } while declared != "z" && t.moreParams()
    }
}

func buildRawPath(_ prims: [SVGPrim]) -> Path {
    var path = Path()
    for p in prims {
        switch p {
        case .path(let d):
            buildPathString(d, into: &path)
        case .circle(let cx, let cy, let r):
            path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r))
        case .rect(let x, let y, let w, let h, let rx):
            if rx > 0 {
                path.addRoundedRect(in: CGRect(x: x, y: y, width: w, height: h),
                                    cornerSize: CGSize(width: rx, height: rx))
            } else {
                path.addRect(CGRect(x: x, y: y, width: w, height: h))
            }
        }
    }
    return path
}

// MARK: - Shape that scales a viewBox-space path to fit its frame
struct SVGShape: Shape {
    let prims: [SVGPrim]
    var box: CGSize = CGSize(width: 24, height: 24)

    func path(in rect: CGRect) -> Path {
        let raw = buildRawPath(prims)
        let s = min(rect.width / box.width, rect.height / box.height)
        let tx = (rect.width - box.width * s) / 2
        let ty = (rect.height - box.height * s) / 2
        return raw.applying(CGAffineTransform(scaleX: s, y: s)
            .concatenating(CGAffineTransform(translationX: tx, y: ty)))
    }
}

// MARK: - Icon view (stroke and/or fill)
struct SVGIcon: View {
    var _prims: [SVGPrim]
    var box: CGSize = CGSize(width: 24, height: 24)
    var fill: Color? = nil
    var stroke: Color? = nil
    var lineWidth: CGFloat = 1.7
    var w: CGFloat
    var h: CGFloat? = nil

    init(_ prims: [SVGPrim], box: CGSize = CGSize(width: 24, height: 24),
         fill: Color? = nil, stroke: Color? = nil, lineWidth: CGFloat = 1.7,
         w: CGFloat, h: CGFloat? = nil) {
        self._prims = prims; self.box = box; self.fill = fill
        self.stroke = stroke; self.lineWidth = lineWidth; self.w = w; self.h = h
    }

    var body: some View {
        let height = h ?? (w * box.height / box.width)
        let strokeScale = w / box.width
        ZStack {
            if let f = fill {
                SVGShape(prims: _prims, box: box).fill(f)
            }
            if let s = stroke {
                SVGShape(prims: _prims, box: box)
                    .stroke(s, style: StrokeStyle(lineWidth: lineWidth * strokeScale,
                                                  lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: w, height: height)
    }
}
