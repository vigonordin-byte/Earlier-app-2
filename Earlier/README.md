# Earlier — iOS app

Native **SwiftUI** implementation of the *Earlier* wake-up / alarm app, built from the
Claude Design imports (`Earlier Onboarding.dc.html` + `Earlier App.dc.html`). The app
launches into the **onboarding flow** (36 steps), then transitions into the **main app**.

**App icon (done):** `Resources/Assets.xcassets/AppIcon.appiconset` — a cream sunrise on
black, drawn to stay legible at home-screen size. Opaque RGB, as the App Store requires.

**Nothing claims to be what it isn't (done):**
- The **paywall** is non-transactional: no trial countdown, no billing dates, no prices.
  Plans show as a dimmed "Coming soon" preview, the CTA is "Start using Earlier", and
  "Restore" is gone (there are no purchases to restore). Settings says *"Free while in
  beta"* instead of unconditionally calling everyone Premium.
- The onboarding **loading screen** used to animate a hardcoded 28% and claim it was
  "calibrating motion detection". It now performs the real setup — writing the alarm from
  the user's answers and arming the schedule — and reports actual progress against it.
- **Onboarding time pickers are real** (`DatePicker` wheels). The time chosen on "Now set
  the alarm" is the time the first alarm is created with, and the commitment, statement and
  summary screens all quote that time back instead of a hardcoded 6:30 AM.

**Editing is real (done):** alarms and bedtimes are created *and edited* through a shared
draft (`AlarmDraft` in `AppState`). The alarm-time wheel is a native `DatePicker` — real
scrolling, snapping, haptics, and 12h/24h + locale handled by the system. The pencil on an
alarm card opens the editor (name, time, repeat days, sound, challenge, delete); the pencil
on a bedtime card edits that bedtime **in place** (it used to silently create a duplicate).
"Scheduled" vs "One time" now actually switches between repeating and single-fire. All
displayed times use the device's clock format instead of a hardcoded US `h:mm a`.

**Bedtimes actually fire (done):** enabled bedtimes schedule two local notifications per
active night — a heads-up 15 minutes before and the bedtime itself — rebuilt on every
change (`scheduleBedtimes` in `AlarmCenter`). Bedtime notifications never raise the alarm
challenge. Wind-down shows the real time until your next alarm, and "5 more minutes" is a
genuine, per-night-limited delay that re-nudges you; "Good night" clears the nudge and
re-arms tomorrow.

**Settings do things (done):** every row is wired — Alarm settings / Bedtime / App blocking
navigate, Notifications opens iOS Settings, Support opens mail, Leave a review uses the
system review prompt, Terms/Privacy open `AppLinks` URLs, Manage subscription opens Apple's
subscriptions page, and *Delete account & data* wipes local data behind a confirmation.
"Log out" is shown but dimmed with "Not signed in" — honest until auth exists.

> ⚠️ `Sources/Store/AppLinks.swift` holds **placeholder** Terms/Privacy URLs. They must
> point at real published pages before submission — Apple rejects builds with dead legal
> links, and the privacy policy URL is a required App Store Connect field.

**Achievements are earned (done):** unlock state is computed from real `WakeLog` streaks
against day thresholds (1/3/7/10/14/21) instead of hardcoded flags.

**App blocking is honest (done):** enforcement needs Apple's Family Controls entitlement
(paid Developer Program + separate approval), so `BlockingStore.isEnforceable` is `false`
and the UI says "App blocking needs Screen Time access — coming soon" rather than claiming
apps are blocked. The category selection and deferred-unblocking rules are real and ready
for the day the entitlement lands.

**Native alarms via AlarmKit (done):** alarms are scheduled with Apple's **AlarmKit**
(`Sources/Alarms/AlarmKitScheduler.swift`) — real system alarms that ring through silent
mode and Focus with Apple's own presentation, the same mechanism the built-in Clock app
uses. Requires only `NSAlarmKitUsageDescription` (no paid entitlement). `AlarmModel.id`
doubles as the AlarmKit alarm id. The alert's secondary button runs `OpenChallengeIntent`,
opening Earlier straight into the challenge; `alarmUpdates` is observed so an `.alerting`
alarm raises the challenge UI. Completing the challenge calls `AlarmManager.stop(id:)`.
Local notifications remain as an automatic **fallback** only when AlarmKit is not
authorized — the two never run at once.

> Note: `startWatching()` is gated on `isAuthorized`; touching AlarmKit while the
> permission is undetermined re-triggers the system prompt in a loop.

**Home is live (done):** the next-alarm card computes the real next occurrence (with a
"Create an alarm" empty state), and its Challenge and Sound tiles open the pickers for
that alarm and save the change. Get started reflects real state (alarm exists / reason
written / signature drawn) with a real progress bar; Wake-up reason is a working
TextEditor and Sign your commitment is a real drawing pad, both persisted. Streak, Past 7
days, History and the streak overlay are computed from `WakeLog` records via
`Sources/Store/Stats.swift`.

**Bedtime can't be quit on impulse (done):** switching a bedtime off — or turning off app
blocking — routes through a full-screen **"Wait a minute."** guard
(`Sources/Screens/BedtimeGuardView.swift`): the streak at stake, a 60-second circular
countdown, "Keep my bedtime" as the primary action, and the destructive option greyed out
and non-tappable until the countdown ends. Switching a bedtime back **on** is instant —
friction only ever guards the protective direction.

**Unblocking is deferred (done):** `Sources/Store/BlockingStore.swift` splits the blocked
category set into `active` and `pending`. *Tightening* (blocking more) applies right away;
*loosening* — unblocking a category so you can scroll tonight — is staged and only becomes
active when the next alarm fires (`applyPendingIfAny()` runs from `beginRinging`). The
sheet shows the staged selection with a "takes effect at your next alarm — not tonight"
notice, so the "just unblock it for a second" escape hatch is closed.

**Anti-dismiss enforcement (done):** swiping the alarm notification away does NOT stop
the alarm — an Alarmy-style **barrage** stacks ~24 follow-up notifications 10s apart
(each playing the bundled 24s `alarm.caf` tone), so the phone keeps ringing until the
challenge is completed in the app. Opening the app "normally" is no escape either:
`checkMissedRing` forces the ringing screen if a recent alarm has no logged wake. While
ringing in-app, a looping siren plays via the audio session. Completing the challenge is
the only silence: it cancels the remaining barrage, clears delivered notifications, and
reschedules. (Hard ceiling of the notification approach: if the phone stays locked and
untouched, iOS won't ring literally forever — AlarmKit is the future upgrade for that.)

**Challenges dismiss the alarm (Phase 2, done):** the ringing screen now requires the
alarm's challenge (`Sources/Challenges/`): **Math problem** (generated problem + keypad),
**Push ups / Squats** (CoreMotion accelerometer rep counter; manual tap-per-rep fallback
where motion hardware is unavailable, e.g. Simulator), **Bible verse / Devotional**
(read-aloud with hold-to-confirm), **Item scan / search** (guided get-up-and-find-it with
hold-to-confirm — camera + Vision verification is a later upgrade). The New-alarm
Challenge sheet actually selects (stored per alarm). Completing the challenge writes the
WakeLog and disarms one-shots.

**Alarms fire (Phase 1, done):** enabled alarms are scheduled as local notifications
(`UserNotifications`, one repeating trigger per active weekday; one-shots disarm after
firing). The onboarding "Allow" screen requests the real system permission. When an alarm
fires, a full-screen ringing view takes over; dismissing writes a `WakeLog` (streak fuel
for Phase 3). Settings → Developer → *Test alarm (10s)* fires one on demand. The
scheduling surface (`Sources/Alarms/AlarmCenter.swift`) is kept small so an AlarmKit
backend (true lock-screen ring-through) can replace it later. Known limitation of the
notification baseline: on a locked/silenced device it plays the short notification sound
rather than ringing continuously.

**Data (Phase 0, done):** alarms and bedtimes are real, persisted **SwiftData** records
(create / toggle / delete, seeded from the onboarding choices). The app is **local-first**
so it works fully offline. Onboarding completion is persisted (`@AppStorage`), with a
*Replay onboarding* item under Settings → Developer. Minimum iOS is **26.0**.

**Backend (upcoming):** `Sources/Store/SupabaseConfig.swift` holds the Supabase project
URL + **anon (public)** key, ready for the auth + cloud-backup layer. SwiftData stays the
source of truth; Supabase only mirrors data for accounts/backup. Data is protected by
Row-Level Security policies (added when the tables are created).

## Requirements

- Xcode 16+ (built with Xcode 26)
- iOS 17+ deployment target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to (re)generate the project

## Build & run

```bash
cd Earlier
xcodegen generate          # writes Earlier.xcodeproj from project.yml
open Earlier.xcodeproj      # then ⌘R on an iPhone simulator
```

`Earlier.xcodeproj` is generated — edit `project.yml` and re-run `xcodegen generate`
rather than changing project settings in Xcode.

## Project layout

```
Earlier/
├─ project.yml                 # XcodeGen spec (bundle id, fonts, build settings)
├─ Sources/
│  ├─ EarlierApp.swift         # @main App entry
│  ├─ AppState.swift           # navigation model: tab / overlay / sub-sheet
│  ├─ RootView.swift           # ZStack layering of tabs, overlays, sheets, tab bar
│  ├─ Theme.swift              # color palette + Plus Jakarta Sans font helper
│  ├─ SVG.swift                # SVG path parser → SwiftUI Shape (icons)
│  ├─ Icons.swift              # the design's exact icon path data
│  ├─ Components.swift         # card style, custom TabBar, FAB, ScreenScaffold
│  ├─ ModalKit.swift           # sheet/overlay chrome, day picker, buttons
│  ├─ Models.swift             # mock data (alarms, bedtimes, challenges, …)
│  ├─ Screens/                 # main-app screens (one file or a few per screen)
│  └─ Onboarding/              # onboarding flow
│     ├─ OnboardingState.swift # 36-step model (step index, answers, mission, days)
│     ├─ OnboardingFlow.swift  # dispatches the current step to its screen
│     ├─ OnboardingChrome.swift# progress header, CTA footer, option row, time wheel
│     ├─ OnboardingScreensA/B  # the 20 screen types
│     └─ PaywallScreen.swift   # final step → enters the main app
└─ Resources/Fonts/            # Plus Jakarta Sans (400–800), bundled via UIAppFonts
```

The app entry (`EarlierApp.swift`) shows `OnboardingFlow` first; the paywall's CTA calls
`onFinish`, which swaps in `RootView` (the main app). `onboarded` is in-memory, so each
launch replays onboarding — handy for review.

## Notes on fidelity

- **Fonts:** Plus Jakarta Sans (Regular→ExtraBold) is bundled and mapped to the design's
  numeric weights via `JK.font(size, weight)`.
- **Icons:** the design uses inline SVGs. `SVG.swift` parses the original `d` path data
  (incl. elliptical arcs), so icons match the source rather than being approximated with
  SF Symbols.
- **Status bar:** this uses the real iOS system status bar (not the mocked one drawn in
  the web design). The Streak overlay flips it to light content via `preferredColorScheme`.
- **Screens:** Home, Alarm, Bedtime, Settings, plus overlays — History, Wind down,
  New alarm (+ Time / Sound / Challenge / App-blocking sub-sheets), Edit bedtime,
  Achievements, Streak, Wake-up reason, Sign your commitment.
```
