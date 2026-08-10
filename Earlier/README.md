# Earlier — iOS app

Native **SwiftUI** implementation of the *Earlier* wake-up / alarm app, built from the
Claude Design import (`Earlier App.dc.html`). This target covers **all screens and
navigation** using the design's mock data (no alarm scheduling / persistence yet).

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
│  └─ Screens/                 # one file (or a few) per screen
└─ Resources/Fonts/            # Plus Jakarta Sans (400–800), bundled via UIAppFonts
```

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
