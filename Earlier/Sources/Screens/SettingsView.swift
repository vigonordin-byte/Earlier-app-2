import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var app: AppState
    @AppStorage("hasOnboarded") private var onboarded = false
    @AppStorage("wakeReason") private var wakeReason = ""
    @AppStorage("signatureStrokes") private var signatureStrokes = ""
    @Environment(\.modelContext) private var ctx
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @Query private var alarms: [AlarmModel]
    @Query private var bedtimes: [BedtimeModel]
    @StateObject private var blocking = BlockingStore.shared

    @State private var confirmingWipe = false

    private var bedtimeLabel: String {
        (bedtimes.first(where: \.enabled) ?? bedtimes.first)?.timeLabel ?? "Not set"
    }

    var body: some View {
        ScreenScaffold(topGap: 6) {
            Text("Settings").jk(32, 800, tracking: -1)
                .padding(.horizontal, 22).padding(.top, 6)

            accountCard.padding(.horizontal, 22).padding(.top, 13)

            sectionLabel("Preferences")
            SettingsCard {
                row(Icons.clock, "Alarm settings",
                    trailing: "\(alarms.count)") { app.go(.alarm) }
                HDivider()
                row(Icons.moon, "Bedtime", trailing: bedtimeLabel) { app.go(.bedtime) }
                HDivider()
                row(Icons.lock, "App blocking",
                    trailing: blocking.displayedSummary, trailingMax: 93) { app.openSub(.blocking) }
                HDivider()
                row(Icons.bell, "Notifications") { openSystemSettings() }
            }

            sectionLabel("Support & legal")
            SettingsCard {
                row(Icons.question, "Support") { openURL(AppLinks.supportMail) }
                HDivider()
                row(Icons.star, "Leave a review") { requestReview() }
                HDivider()
                row(Icons.doc, "Terms of service") { openURL(AppLinks.terms) }
                HDivider()
                row(Icons.lock, "Privacy policy") { openURL(AppLinks.privacy) }
            }

            sectionLabel("Account")
            SettingsCard {
                row(Icons.creditCard, "Manage subscription") {
                    openURL(AppLinks.manageSubscriptions)
                }
                HDivider()
                // Honest until sign-in exists: nothing to log out of yet.
                SettingsRow(icon: Icons.logout, title: "Log out",
                            trailing: "Not signed in", dimmed: true)
                HDivider()
                row(Icons.deleteUser, "Delete account & data", titleColor: C.red) {
                    confirmingWipe = true
                }
            }

            sectionLabel("Developer")
            SettingsCard {
                row(Icons.clock, "Test alarm (10s)") { testAlarm() }
                HDivider()
                row(Icons.clock, "Real alarm in 1 min",
                    trailing: AlarmKitScheduler.shared.isAuthorized ? "AlarmKit" : "fallback") {
                    scheduleRealAlarmSoon()
                }
                HDivider()
                row(Icons.chart, "Replay onboarding") { onboarded = false }
            }

            Text("Version 1.0.0").jk(16).foregroundColor(C.muted2)
                .frame(maxWidth: .infinity).padding(.top, 22)
        }
        .alert("Delete everything?", isPresented: $confirmingWipe) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { wipeAllData() }
        } message: {
            Text("This removes your alarms, bedtimes, streak history, reason and signature from this device. It can't be undone.")
        }
    }

    // MARK: - Row helper
    private func row(_ icon: Ico, _ title: String, trailing: String? = nil,
                     trailingMax: CGFloat? = nil, titleColor: Color = C.ink,
                     _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            SettingsRow(icon: icon, title: title, trailing: trailing,
                        trailingMax: trailingMax, titleColor: titleColor)
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
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

    // MARK: - Actions
    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
    }

    private func testAlarm() {
        let candidates = alarms.filter(\.enabled).isEmpty ? alarms : alarms.filter(\.enabled)
        let id = candidates.max(by: { $0.updatedAt < $1.updatedAt })?.id
        Task {
            _ = await AlarmCenter.shared.requestAllPermissions()
            AlarmCenter.shared.scheduleTest(alarmID: id)
        }
    }

    /// Dev helper: a genuine one-shot alarm a minute from now.
    private func scheduleRealAlarmSoon() {
        Task {
            _ = await AlarmCenter.shared.requestAllPermissions()
            let fire = Date().addingTimeInterval(60)
            let c = Calendar.current.dateComponents([.hour, .minute], from: fire)
            ctx.insert(AlarmModel(name: "Test wake-up",
                                  hour: c.hour ?? 0, minute: c.minute ?? 0,
                                  repeatMask: 0, soundName: "Default",
                                  challengeName: "Math problem", enabled: true))
            try? ctx.save()
            AlarmCenter.shared.rescheduleAll(ctx)
        }
    }

    /// Full local wipe. Also the thing Apple requires once accounts exist —
    /// the server-side delete hooks in here when auth lands.
    private func wipeAllData() {
        for a in alarms { ctx.delete(a) }
        for b in bedtimes { ctx.delete(b) }
        if let logs = try? ctx.fetch(FetchDescriptor<WakeLog>()) {
            for l in logs { ctx.delete(l) }
        }
        try? ctx.save()
        wakeReason = ""
        signatureStrokes = ""
        AlarmKitScheduler.shared.cancelAll()
        AlarmCenter.shared.rescheduleAll(ctx)
        onboarded = false
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
    /// Shown but inert — used where a feature genuinely isn't available yet.
    var dimmed: Bool = false

    var body: some View {
        HStack(spacing: 15) {
            SVGIcon(icon, stroke: dimmed ? C.placeholder : C.ink, lineWidth: 1.7, w: 22)
                .frame(width: 22, height: 22)
            Text(title).jk(17, 700)
                .foregroundColor(dimmed ? C.placeholder : titleColor)
                .fixedSize(horizontal: true, vertical: false)
            Spacer(minLength: 8)
            if let trailing {
                Text(trailing).jk(16).foregroundColor(C.muted)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: trailingMax, alignment: .trailing)
            }
            if !dimmed {
                SVGIcon(Icons.chevronRight, stroke: C.chevron, lineWidth: 2, w: 9)
            }
        }
        .padding(.horizontal, 17).padding(.vertical, 14)
    }
}
