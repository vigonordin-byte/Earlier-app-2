import SwiftUI
import SwiftData

/// Creates a new alarm, or edits an existing one when `app.editingAlarmID` is set.
struct AlarmEditorView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.modelContext) private var ctx
    @Query private var alarms: [AlarmModel]

    private var editing: AlarmModel? {
        guard let id = app.editingAlarmID else { return nil }
        return alarms.first { $0.id == id }
    }
    private var isEditing: Bool { editing != nil }

    var body: some View {
        SheetContainer(bg: C.phoneBg, onScrim: { app.back() }) {
            header.padding(.top, 17)

            segmented.padding(.top, 19)

            TextField("Alarm name", text: $app.draft.name)
                .font(JK.font(18, 500)).foregroundColor(C.ink).tint(C.ink)
                .padding(.horizontal, 19).padding(.vertical, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .card(22).padding(.top, 13)

            Button { app.openSub(.time) } label: {
                HStack {
                    Text("Alarm time").jk(18, 700)
                    Spacer()
                    Text(app.draft.timeLabel).jk(18).foregroundColor(C.muted)
                    SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 8).padding(.leading, 8)
                }
                .padding(.horizontal, 19).padding(.vertical, 16)
                .card(22)
                .contentShape(Rectangle())
            }.buttonStyle(.plain).padding(.top, 13)

            daysCard.padding(.top, 13)
            optionsCard.padding(.top, 13)

            if isEditing {
                Button { deleteAlarm() } label: {
                    Text("Delete alarm").jk(19, 800).foregroundColor(C.red)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.redSoftBg))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain).padding(.top, 15)
            }

            PrimaryButton(title: isEditing ? "Save changes" : "Save alarm") { save() }
                .padding(.top, isEditing ? 12 : 15)
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                Button { app.back() } label: {
                    Text("Cancel").jk(18, 600)
                        .padding(.horizontal, 21).padding(.vertical, 9)
                        .background(C.card)
                        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                        .softShadow()
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
                Spacer()
            }
            Text(isEditing ? "Edit alarm" : "New alarm").jk(20, 800).padding(.trailing, 59)
        }
    }

    /// Scheduled = repeats on the chosen days. One time = fires once, then disarms.
    private var segmented: some View {
        let scheduled = app.draft.days.contains(true)
        return HStack(spacing: 0) {
            Button { if !scheduled { app.draft.days = [false, true, true, true, true, true, false] } } label: {
                Text("Scheduled").jk(17, scheduled ? 600 : 500)
                    .foregroundColor(scheduled ? C.ink : C.muted)
                    .frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .fill(scheduled ? C.card : .clear))
                    .contentShape(Rectangle())
            }.buttonStyle(.plain)
            Button { app.draft.days = Array(repeating: false, count: 7) } label: {
                Text("One time").jk(17, scheduled ? 500 : 600)
                    .foregroundColor(scheduled ? C.muted : C.ink)
                    .frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .fill(scheduled ? .clear : C.card))
                    .contentShape(Rectangle())
            }.buttonStyle(.plain)
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(C.pill))
    }

    private var daysCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("On these days:").jk(16).foregroundColor(Color(hex: "6E6A62"))
            DayPicker(selected: $app.draft.days).padding(.top, 12)
            if !app.draft.days.contains(true) {
                Text("Rings once, then turns itself off.")
                    .jk(14).foregroundColor(C.muted).padding(.top, 10)
            }
        }
        .padding(.horizontal, 17).padding(.top, 15).padding(.bottom, 19)
        .card(22)
    }

    private var optionsCard: some View {
        VStack(spacing: 0) {
            Button { app.openSub(.sound) } label: {
                optionRow(leading: AnyView(SVGIcon(Icons.speakerSmall, stroke: C.ink, lineWidth: 1.8, w: 21).frame(width: 21, height: 21)),
                          title: "Sound", value: app.draft.sound)
            }.buttonStyle(.plain)
            HDivider()
            Button { app.openSub(.challenge) } label: {
                optionRow(leading: AnyView(Text(ChallengeGlyph.emoji(app.draft.challenge)).font(.system(size: 17)).frame(width: 21)),
                          title: "Challenge", value: app.draft.challenge)
            }.buttonStyle(.plain)
            HDivider()
            Button { app.openSub(.blocking) } label: {
                optionRow(leading: AnyView(SVGIcon(Icons.lock, stroke: C.ink, lineWidth: 1.8, w: 21).frame(width: 21, height: 21)),
                          title: "App blocking", value: BlockingStore.shared.displayedSummary, showChevron: false)
            }.buttonStyle(.plain)
        }
        .card(22)
    }

    private func optionRow(leading: AnyView, title: String, value: String, showChevron: Bool = true) -> some View {
        HStack(spacing: 13) {
            leading
            Text(title).jk(18, 700).fixedSize()
            Spacer(minLength: 8)
            Text(value).jk(showChevron ? 18 : 17).foregroundColor(C.muted).lineLimit(1)
            if showChevron {
                SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 8)
            }
        }
        .padding(.horizontal, 17).padding(.vertical, 13)
        .contentShape(Rectangle())
    }

    // MARK: - Persistence
    private func save() {
        let d = app.draft
        let name = d.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Alarm" : d.name
        if let a = editing {
            a.name = name; a.hour = d.hour; a.minute = d.minute
            a.repeatMask = Weekdays.maskFromPicker(d.days)
            a.soundName = d.sound; a.challengeName = d.challenge
            a.enabled = true
            a.touch()
        } else {
            ctx.insert(AlarmModel(name: name, hour: d.hour, minute: d.minute,
                                  repeatMask: Weekdays.maskFromPicker(d.days),
                                  soundName: d.sound, challengeName: d.challenge,
                                  enabled: true))
        }
        try? ctx.save()
        AlarmCenter.shared.rescheduleAll(ctx)
        app.editingAlarmID = nil
        app.back()
    }

    private func deleteAlarm() {
        if let a = editing { ctx.delete(a); try? ctx.save() }
        AlarmCenter.shared.rescheduleAll(ctx)
        app.editingAlarmID = nil
        app.back()
    }
}
