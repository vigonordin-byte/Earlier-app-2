import SwiftUI
import SwiftData

/// Creates a new bedtime, or edits an existing one when `app.editingBedtimeID` is set.
struct BedtimeEditorView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.modelContext) private var ctx
    @Query private var bedtimes: [BedtimeModel]

    private var editing: BedtimeModel? {
        guard let id = app.editingBedtimeID else { return nil }
        return bedtimes.first { $0.id == id }
    }
    private var isEditing: Bool { editing != nil }

    var body: some View {
        SheetContainer(bg: C.sheetBg, onScrim: { app.back() }) {
            header.padding(.top, 13)

            TextField("Bedtime name", text: $app.draft.name)
                .font(JK.font(18, 500)).foregroundColor(C.ink).tint(C.ink)
                .padding(.horizontal, 19).padding(.vertical, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .card(22).padding(.top, 19)

            Button { app.openSub(.time) } label: {
                HStack {
                    Text("Bedtime").jk(18, 700)
                    Spacer()
                    Text(app.draft.timeLabel).jk(18).foregroundColor(C.muted)
                    SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 8).padding(.leading, 8)
                }
                .padding(.horizontal, 19).padding(.vertical, 16)
                .card(22)
                .contentShape(Rectangle())
            }.buttonStyle(.plain).padding(.top, 13)

            daysCard.padding(.top, 13)

            Button { app.openSub(.blocking) } label: {
                HStack(spacing: 13) {
                    SVGIcon(Icons.lock, stroke: C.ink, lineWidth: 1.8, w: 21).frame(width: 21, height: 21)
                    Text("App blocking").jk(18, 700).fixedSize()
                    Spacer(minLength: 8)
                    Text(BlockingStore.shared.displayedSummary).jk(17).foregroundColor(C.muted).lineLimit(1)
                }
                .padding(.horizontal, 17).padding(.vertical, 14)
                .card(22)
                .contentShape(Rectangle())
            }.buttonStyle(.plain).padding(.top, 13)

            if isEditing {
                Button { deleteBedtime() } label: {
                    Text("Delete bedtime").jk(19, 800).foregroundColor(C.red)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.redSoftBg))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain).padding(.top, 19)
            }

            PrimaryButton(title: isEditing ? "Save changes" : "Save bedtime") { save() }
                .padding(.top, 12)
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
            Text(isEditing ? "Edit bedtime" : "New bedtime").jk(20, 800).padding(.trailing, 59)
        }
    }

    private var daysCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("On these nights:").jk(16).foregroundColor(Color(hex: "6E6A62"))
            DayPicker(selected: $app.draft.days).padding(.top, 12)
        }
        .padding(.horizontal, 17).padding(.top, 15).padding(.bottom, 19)
        .card(22)
    }

    private func save() {
        let d = app.draft
        let name = d.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Bedtime" : d.name
        if let b = editing {
            b.name = name; b.hour = d.hour; b.minute = d.minute
            b.repeatMask = Weekdays.maskFromPicker(d.days)
            b.enabled = true
            b.touch()
        } else {
            ctx.insert(BedtimeModel(name: name, hour: d.hour, minute: d.minute,
                                    repeatMask: Weekdays.maskFromPicker(d.days),
                                    enabled: true))
        }
        try? ctx.save()
        AlarmCenter.shared.rescheduleAll(ctx)
        app.editingBedtimeID = nil
        app.back()
    }

    private func deleteBedtime() {
        if let b = editing { ctx.delete(b); try? ctx.save() }
        AlarmCenter.shared.rescheduleAll(ctx)
        app.editingBedtimeID = nil
        app.back()
    }
}
