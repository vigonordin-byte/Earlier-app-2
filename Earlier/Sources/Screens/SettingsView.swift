import SwiftUI

struct SettingsView: View {
    @AppStorage("hasOnboarded") private var onboarded = false
    var body: some View {
        ScreenScaffold(topGap: 6) {
            Text("Settings").jk(32, 800, tracking: -1)
                .padding(.horizontal, 22).padding(.top, 6)

            accountCard.padding(.horizontal, 22).padding(.top, 13)

            sectionLabel("Preferences")
            SettingsCard {
                SettingsRow(icon: Icons.clock, title: "Alarm settings")
                HDivider()
                SettingsRow(icon: Icons.moon, title: "Bedtime", trailing: "10:30 PM")
                HDivider()
                SettingsRow(icon: Icons.lock, title: "App blocking", trailing: "0 apps · 11 categories", trailingMax: 93)
                HDivider()
                SettingsRow(icon: Icons.bell, title: "Notifications")
            }

            sectionLabel("Support & legal")
            SettingsCard {
                SettingsRow(icon: Icons.question, title: "Support")
                HDivider()
                SettingsRow(icon: Icons.star, title: "Leave a review")
                HDivider()
                SettingsRow(icon: Icons.doc, title: "Terms of service")
                HDivider()
                SettingsRow(icon: Icons.lock, title: "Privacy policy")
            }

            sectionLabel("Account")
            SettingsCard {
                SettingsRow(icon: Icons.creditCard, title: "Manage subscription")
                HDivider()
                SettingsRow(icon: Icons.logout, title: "Log out")
                HDivider()
                SettingsRow(icon: Icons.deleteUser, title: "Delete account", titleColor: C.red)
            }

            sectionLabel("Developer")
            SettingsCard {
                Button { onboarded = false } label: {
                    SettingsRow(icon: Icons.chart, title: "Replay onboarding")
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
            }

            Text("Version 1.0.0").jk(16).foregroundColor(C.muted2)
                .frame(maxWidth: .infinity).padding(.top, 22)
        }
    }

    private func sectionLabel(_ t: String) -> some View {
        Text(t).jk(15, 500).foregroundColor(C.muted)
            .padding(.top, 22).padding(.leading, 25).padding(.bottom, 8).padding(.trailing, 22)
    }

    private var accountCard: some View {
        HStack(spacing: 15) {
            SVGIcon(Icons.userFill, fill: .white, w: 25).frame(width: 25, height: 25)
                .frame(width: 47, height: 47)
                .background(Circle().fill(C.ink))
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    SVGIcon(Icons.premium, fill: C.gold, w: 14).frame(width: 14, height: 12)
                    Text("Premium").jk(14, 700).foregroundColor(C.gold)
                }
                Text("Your account").jk(20, 800, tracking: -0.5)
            }
            Spacer()
            RowChevron(w: 10)
        }
        .padding(.horizontal, 17).padding(.vertical, 13)
        .card(22)
    }
}

struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .card(22)
            .padding(.horizontal, 22)
    }
}

struct SettingsRow: View {
    var icon: Ico
    var title: String
    var trailing: String? = nil
    var trailingMax: CGFloat? = nil
    var titleColor: Color = C.ink

    var body: some View {
        HStack(spacing: 15) {
            SVGIcon(icon, stroke: C.ink, lineWidth: 1.7, w: 22).frame(width: 22, height: 22)
            Text(title).jk(17, 700).foregroundColor(titleColor).fixedSize(horizontal: true, vertical: false)
            Spacer(minLength: 8)
            if let trailing {
                Text(trailing).jk(16).foregroundColor(C.muted)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: trailingMax, alignment: .trailing)
            }
            SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 9)
        }
        .padding(.horizontal, 17).padding(.vertical, 14)
    }
}
