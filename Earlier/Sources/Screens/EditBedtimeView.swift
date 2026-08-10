import SwiftUI

struct EditBedtimeView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        SheetContainer(bg: C.sheetBg, onScrim: { app.back() }) {
            header.padding(.top, 13)

            FieldPlaceholder(text: "Bedtime name").padding(.top, 19)

            HStack {
                Text("Bedtime").jk(18, 700)
                Spacer()
                Text("6:20 PM").jk(18).foregroundColor(C.muted)
                SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 8).padding(.leading, 8)
            }
            .padding(.horizontal, 19).padding(.vertical, 16)
            .card(22).padding(.top, 13)

            daysCard.padding(.top, 13)

            Button { app.openSub(.blocking) } label: {
                HStack(spacing: 13) {
                    SVGIcon(Icons.lock, stroke: C.ink, lineWidth: 1.8, w: 21).frame(width: 21, height: 21)
                    Text("App blocking").jk(18, 700).fixedSize()
                    Spacer(minLength: 8)
                    Text("0 apps · 11 categories").jk(17).foregroundColor(C.muted).lineLimit(1)
                }
                .padding(.horizontal, 17).padding(.vertical, 14)
                .card(22)
                .contentShape(Rectangle())
            }.buttonStyle(.plain).padding(.top, 13)

            Text("Delete bedtime").jk(19, 800).foregroundColor(C.red)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 27, style: .continuous).fill(C.redSoftBg))
                .padding(.top, 19)

            PrimaryButton(title: "Save changes") { app.back() }.padding(.top, 12)
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
                }.buttonStyle(.plain)
                Spacer()
            }
            Text("Edit bedtime").jk(20, 800).padding(.trailing, 59)
        }
    }

    private var daysCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("On these nights:").jk(16).foregroundColor(Color(hex: "6E6A62"))
            DayCircles().padding(.top, 12)
        }
        .padding(.horizontal, 17).padding(.top, 15).padding(.bottom, 19)
        .card(22)
    }
}
