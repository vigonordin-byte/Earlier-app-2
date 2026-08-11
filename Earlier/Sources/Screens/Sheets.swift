import SwiftUI
import SwiftData

/// Shared plumbing for the Challenge/Sound pickers: they either edit an
/// existing alarm (when `app.editingAlarmID` is set) or the new-alarm draft.
@MainActor
private struct PickerTarget {
    let ctx: ModelContext
    let app: AppState
    let alarms: [AlarmModel]

    var editing: AlarmModel? {
        guard let id = app.editingAlarmID else { return nil }
        return alarms.first { $0.id == id }
    }
    var currentChallenge: String { editing?.challengeName ?? app.draftChallenge }
    var currentSound: String { editing?.soundName ?? app.draftSound }

    func setChallenge(_ name: String) {
        if let a = editing {
            a.challengeName = name; a.touch(); try? ctx.save()
            AlarmCenter.shared.rescheduleAll(ctx)
        } else {
            app.draftChallenge = name
        }
    }
    func setSound(_ name: String) {
        if let a = editing {
            a.soundName = name; a.touch(); try? ctx.save()
            AlarmCenter.shared.rescheduleAll(ctx)
        } else {
            app.draftSound = name
        }
    }
}

// MARK: - Time picker sheet
struct TimeSheet: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        SheetContainer(bg: C.sheetBg, scroll: false, onScrim: { app.backSub() }) {
            SheetHeader(title: "Alarm time", trailingInset: 17) {
                CircleBackButton { app.backSub() }
            }.padding(.top, 17)

            Text("Scroll to pick your wake-up time").jk(18).foregroundColor(C.muted)
                .frame(maxWidth: .infinity).multilineTextAlignment(.center).padding(.top, 19)

            ZStack {
                VStack(spacing: 0) {
                    Spacer().frame(height: 81)
                    RoundedRectangle(cornerRadius: 24, style: .continuous).fill(C.pill).frame(height: 47)
                    Spacer()
                }
                HStack(spacing: 0) {
                    pickerColumn(Mock.hours)
                    pickerColumn(Mock.minutes)
                }
            }
            .frame(height: 228).padding(.top, 22)

            PrimaryButton(title: "Set 6:30 AM") { app.backSub() }.padding(.top, 17)
        }
    }

    private func pickerColumn(_ vals: [PickerValue]) -> some View {
        VStack(spacing: 0) {
            ForEach(vals) { v in
                Text(v.v).jk(v.on ? 34 : 30, 800)
                    .foregroundColor(v.on ? C.ink : Color(hex: "DEDBD3"))
                    .frame(height: 46).frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Sound picker sheet
struct SoundSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.modelContext) private var ctx
    @Query private var alarms: [AlarmModel]
    private var target: PickerTarget { PickerTarget(ctx: ctx, app: app, alarms: alarms) }

    var body: some View {
        SheetContainer(bg: C.sheetBg, onScrim: { app.backSub() }) {
            SheetHeader(title: "Choose a sound", trailingInset: 17) {
                CircleBackButton { app.backSub() }
            }.padding(.top, 17)

            Text("Select the sound your alarm will play").jk(18).foregroundColor(C.muted)
                .frame(maxWidth: .infinity).multilineTextAlignment(.center).padding(.top, 19)

            VStack(spacing: 12) {
                ForEach(Mock.sounds) { s in
                    let selected = s.name == target.currentSound
                    Button { target.setSound(s.name) } label: {
                        HStack(spacing: 13) {
                            SVGIcon(s.icon, stroke: selected ? .white : C.muted2, lineWidth: 1.7, w: 20)
                                .frame(width: 39, height: 39)
                                .background(Circle().fill(selected ? C.ink : C.chip))
                            Text(s.name).jk(18, 800)
                            Spacer()
                            if selected {
                                ZStack {
                                    Circle().fill(C.ink).frame(width: 29, height: 29)
                                    SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 14)
                                }
                            }
                        }
                        .padding(.horizontal, 15).padding(.vertical, 12)
                        .background(C.card)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(selected ? C.ink : .clear, lineWidth: 2))
                        .cardShadow()
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
            }.padding(.top, 19)
        }
    }
}

// MARK: - Challenge picker sheet
struct ChallengeSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.modelContext) private var ctx
    @Query private var alarms: [AlarmModel]
    private var target: PickerTarget { PickerTarget(ctx: ctx, app: app, alarms: alarms) }
    private let cols = [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)]

    var body: some View {
        SheetContainer(bg: C.sheetBg, onScrim: { app.backSub() }) {
            SheetHeader(title: "Choose a challenge", trailingInset: 17) {
                CircleBackButton { app.backSub() }
            }.padding(.top, 17)

            Text("Complete it to turn off your alarm").jk(18).foregroundColor(C.muted)
                .frame(maxWidth: .infinity).multilineTextAlignment(.center).padding(.top, 19)

            LazyVGrid(columns: cols, spacing: 15) {
                ForEach(Mock.challenges) { c in
                    let selected = c.name == target.currentChallenge
                    Button { target.setChallenge(c.name) } label: {
                        VStack(spacing: 0) {
                            Text(c.emoji).font(.system(size: 38)).frame(height: 53)
                            Text(c.name).jk(18, 800).padding(.top, 12)
                            Text(c.desc).jk(14).foregroundColor(C.muted)
                                .multilineTextAlignment(.center).lineSpacing(2).padding(.top, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 13).padding(.top, 19).padding(.bottom, 17)
                        .background(C.card)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(selected ? C.ink : .clear, lineWidth: 2))
                        .cardShadow()
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
            }.padding(.top, 19)
        }
    }
}

// MARK: - App blocking sheet
struct BlockingSheet: View {
    @EnvironmentObject var app: AppState
    @StateObject private var blocking = BlockingStore.shared
    var body: some View {
        SheetContainer(bg: C.sheetBg, onScrim: { app.backSub() }) {
            SheetHeader(title: "App blocking", trailingInset: 17) {
                CircleBackButton { app.backSub() }
            }.padding(.top, 17)

            HStack(spacing: 12) {
                appTile(size: 55, radius: 19, bg: C.pill) {
                    SVGIcon(Icons.blockRefresh, stroke: C.placeholder, lineWidth: 1.8, w: 25).frame(width: 25, height: 25)
                }
                appTile(size: 71, radius: 22, bg: C.ink) {
                    SVGIcon(Icons.lock, stroke: .white, lineWidth: 1.7, w: 34).frame(width: 34, height: 34)
                }
                appTile(size: 55, radius: 19, bg: C.pill) {
                    SVGIcon(Icons.restMail, stroke: C.placeholder, lineWidth: 1.8, w: 25).frame(width: 25, height: 25)
                }
            }
            .frame(maxWidth: .infinity).padding(.top, 38)

            Text("Block addicting apps").jk(29, 800, tracking: -1)
                .frame(maxWidth: .infinity).multilineTextAlignment(.center).padding(.top, 29)
            Text("Your apps stay blocked from bedtime until you're up — no midnight scrolling, no snooze-and-scroll.")
                .jk(17).foregroundColor(C.muted).multilineTextAlignment(.center).lineSpacing(4)
                .frame(maxWidth: .infinity).padding(.top, 10)

            VStack(alignment: .leading, spacing: 12) {
                feature(AnyView(SVGIcon(Icons.moon, stroke: C.ink, lineWidth: 1.9, w: 21).frame(width: 21, height: 21)), "Starts at your bedtime")
                feature(AnyView(SVGIcon(Icons.clockSimple, stroke: C.ink, lineWidth: 1.9, w: 21).frame(width: 21, height: 21)), "Unlocks when you wake up")
                feature(AnyView(SVGIcon(Icons.grid, fill: C.ink, w: 21).frame(width: 21, height: 21)), "You choose which apps")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 29).padding(.top, 22)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 13) {
                    SVGIcon(Icons.grid, fill: C.ink, w: 21).frame(width: 21, height: 21)
                    Text("Blocked apps").jk(18, 800)
                    Spacer()
                    Text(blocking.displayedSummary).jk(17).foregroundColor(C.muted).lineLimit(1)
                }
                .padding(.horizontal, 19).padding(.top, 15).padding(.bottom, 13)

                HDivider()

                ForEach(Array(BlockCategory.allCases.enumerated()), id: \.element.id) { i, cat in
                    if i > 0 { HDivider() }
                    Button { blocking.toggle(cat) } label: {
                        HStack {
                            Text(cat.rawValue).jk(17, 500)
                            Spacer()
                            let on = blocking.displayed.contains(cat.rawValue)
                            ZStack {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(on ? C.ink : .clear).frame(width: 25, height: 25)
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(on ? C.ink : Color(hex: "D4D1CA"), lineWidth: 1.5)
                                    .frame(width: 25, height: 25)
                                if on { SVGIcon(Icons.check, stroke: .white, lineWidth: 3, w: 15) }
                            }
                        }
                        .padding(.horizontal, 19).padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
            }
            .card(25).padding(.top, 19)

            if blocking.hasPendingChange {
                HStack(alignment: .top, spacing: 10) {
                    Text("🌙").font(.system(size: 15))
                    Text("Unblocking takes effect at your next alarm — not tonight. Apps stay blocked until you're up.")
                        .jk(14).foregroundColor(Color(hex: "6E6A62")).lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 17).padding(.vertical, 13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(C.pill))
                .padding(.top, 12)
            }

            Button { app.guardAction = .turnOffBlocking } label: {
                Text("Turn off app blocking").jk(19, 700).foregroundColor(C.muted)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.divider2))
                    .contentShape(Rectangle())
            }.buttonStyle(.plain).padding(.top, 13)
        }
    }

    private func appTile<Content: View>(size: CGFloat, radius: CGFloat, bg: Color, @ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(bg))
    }

    private func feature(_ icon: AnyView, _ text: String) -> some View {
        HStack(spacing: 13) {
            icon
            Text(text).jk(18, 700)
        }
    }
}
