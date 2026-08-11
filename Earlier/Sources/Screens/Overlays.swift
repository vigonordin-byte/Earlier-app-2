import SwiftUI
import SwiftData

// MARK: - Achievements (full screen)
struct AchievementsView: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        FullOverlay(bg: C.phoneBg, scroll: true, topPad: 12) {
            ZStack {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: C.ink, lineWidth: 2, w: 24).frame(width: 24, height: 24)
                    }.buttonStyle(.plain).frame(width: 29, alignment: .leading)
                    Spacer()
                }
                Text("Achievements").jk(23, 800).frame(maxWidth: .infinity).padding(.trailing, 17)
            }

            VStack(spacing: 22) {
                ForEach(Mock.achievements) { a in
                    HStack(alignment: .top, spacing: 17) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .fill(a.on ? C.ink : Color(hex: "E8E6DF"))
                                .frame(width: 53, height: 53)
                            if a.on {
                                Text("🔥").font(.system(size: 26))
                            } else {
                                SVGIcon(Icons.lockRounded, stroke: Color(hex: "C4C0B8"), lineWidth: 1.8, w: 28)
                                    .frame(width: 28, height: 28)
                            }
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(a.name).jk(19, 800, tracking: -0.3)
                            Text(a.streak).jk(16, 600).foregroundColor(C.muted)
                            Text(a.desc).jk(16).foregroundColor(C.muted4).lineSpacing(3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(a.on ? 1 : 0.42)
                }
            }.padding(.top, 25)
        }
    }
}

// MARK: - Streak (blurred overlay)
struct StreakView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.safeInsets) private var insets
    @Query private var logs: [WakeLog]
    private var streak: Int { Stats.streak(logs) }
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            Color(hex: "605E5A").opacity(0.4).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: .white, lineWidth: 2, w: 25).frame(width: 25, height: 25)
                    }.buttonStyle(.plain)
                    Spacer()
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("\(streak)").jk(81, 800).foregroundColor(.white)
                    Text(streak == 1 ? "day streak" : "day streak").jk(29, 800)
                        .foregroundColor(.white).padding(.top, 12)
                    Text(streak == 0
                         ? "Complete your first challenge to start a streak."
                         : "Keep it alive — complete tomorrow's challenge to reach \(streak + 1) days.")
                        .jk(18).foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center).lineSpacing(4)
                        .frame(maxWidth: 300).padding(.top, 17)
                }
                .padding(.bottom, 34)
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, insets.top + 12)
        }
    }
}

// MARK: - Wake-up reason (full screen)
struct ReasonView: View {
    @EnvironmentObject var app: AppState
    @AppStorage("wakeReason") private var saved = ""
    @State private var text = ""
    @FocusState private var focused: Bool

    private var canSave: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        FullOverlay(bg: C.phoneBg, topPad: 12) {
            ZStack {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: Color(hex: "6E6A62"), lineWidth: 2, w: 22).frame(width: 22, height: 22)
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain).frame(width: 29, alignment: .leading)
                    Spacer()
                }
                Text("Wake-up reason").jk(22, 800).frame(maxWidth: .infinity).padding(.leading, -29)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Why are you committed to waking up early? What do you plan to do first thing in the morning?")
                        .jk(18).foregroundColor(C.placeholder).lineSpacing(5)
                        .padding(.horizontal, 23).padding(.vertical, 27)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .focused($focused)
                    .font(JK.font(18, 500)).tint(C.ink)
                    .scrollContentBackground(.hidden)
                    .padding(15)
            }
            .frame(maxWidth: .infinity, minHeight: 178, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(C.inputField))
            .padding(.top, 22)

            Button {
                saved = text.trimmingCharacters(in: .whitespacesAndNewlines)
                app.back()
            } label: {
                Text("Save").jk(19, 700).foregroundColor(canSave ? .white : C.disabledInk)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 27, style: .continuous)
                        .fill(canSave ? C.ink : C.disabledBtn))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain).disabled(!canSave).padding(.top, 15)
        }
        .onAppear { text = saved }
    }
}

// MARK: - Signature pad
struct SignaturePad: View {
    @Binding var strokes: [[CGPoint]]
    @State private var current: [CGPoint] = []

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(C.inputField)
            if strokes.isEmpty && current.isEmpty {
                Text("Draw your signature").jk(18).foregroundColor(C.muted3)
            }
            Canvas { ctx, _ in
                for stroke in strokes + (current.isEmpty ? [] : [current]) {
                    guard let first = stroke.first else { continue }
                    var path = Path()
                    path.move(to: first)
                    for p in stroke.dropFirst() { path.addLine(to: p) }
                    ctx.stroke(path, with: .color(C.ink),
                               style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { current.append($0.location) }
                    .onEnded { _ in
                        if current.count > 1 { strokes.append(current) }
                        current = []
                    }
            )
        }
        .frame(height: 227)
    }
}

// MARK: - Sign your commitment (full screen)
struct SignatureView: View {
    @EnvironmentObject var app: AppState
    @Query private var alarms: [AlarmModel]
    @AppStorage("signatureStrokes") private var savedStrokes = ""
    @State private var strokes: [[CGPoint]] = []

    private var commitTime: String {
        var best: (alarm: AlarmModel, date: Date)?
        for a in alarms where a.enabled {
            guard let d = AlarmCenter.nextFireDate(a) else { continue }
            if best == nil || d < best!.date { best = (a, d) }
        }
        return best?.alarm.timeLabel ?? "your alarm"
    }
    private var canSave: Bool { !strokes.isEmpty }

    var body: some View {
        FullOverlay(bg: C.phoneBg, topPad: 12) {
            ZStack {
                HStack {
                    Button { app.back() } label: {
                        SVGIcon(Icons.closeX, stroke: Color(hex: "6E6A62"), lineWidth: 2, w: 22).frame(width: 22, height: 22)
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain).frame(width: 29, alignment: .leading)
                    Spacer()
                }
                Text("Sign your commitment").jk(22, 800).frame(maxWidth: .infinity).padding(.leading, 5)
            }

            (Text("I commit to waking up at ").foregroundColor(C.muted)
             + Text(commitTime).foregroundColor(C.ink).font(JK.font(18, 800)))
                .jk(18).multilineTextAlignment(.center)
                .frame(maxWidth: .infinity).padding(.top, 17)

            SignaturePad(strokes: $strokes).padding(.top, 19)

            GeometryReader { geo in
                let gap: CGFloat = 12
                let clearW = (geo.size.width - gap) / 3.4   // Save : Clear = 2.4 : 1
                HStack(spacing: gap) {
                    Button { save() } label: {
                        Text("Save").jk(19, 700).foregroundColor(canSave ? .white : C.disabledInk)
                            .frame(width: geo.size.width - gap - clearW).padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 27, style: .continuous)
                                .fill(canSave ? C.ink : C.disabledBtn))
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain).disabled(!canSave)
                    Button { strokes = [] } label: {
                        Text("Clear").jk(19, 600).foregroundColor(Color(hex: "6E6A62"))
                            .frame(width: clearW).padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.chip))
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
            }
            .frame(height: 55)
            .padding(.top, 17)
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let data = savedStrokes.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([[CGPoint]].self, from: data) else { return }
        strokes = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(strokes),
           let json = String(data: data, encoding: .utf8) {
            savedStrokes = json
        }
        app.back()
    }
}
