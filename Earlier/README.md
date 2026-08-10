# Earlier — iOS app

Native **SwiftUI** implementation of the *Earlier* wake-up / alarm app, built from the
Claude Design imports (`Earlier Onboarding.dc.html` + `Earlier App.dc.html`). The app
launches into the **onboarding flow** (36 steps), then transitions into the **main app**.

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
