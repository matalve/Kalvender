<p align="center">
  <img src="Shared/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" width="128" alt="Kalvender icon">
</p>

# Kalvender

A simple macOS calendar widget: month view with ISO week numbers and public
holidays — no events, no permissions, no network access.

Kalvender answers questions like *"what weekday is the 24th?"*, *"which week
number is that?"* and *"how many nights is July 17–19?"* — right on your
desktop, without involving calendar accounts or events.

```
  ◀      July 2026      ▶
  wk  M   T   W   T   F   S   S
  27          1   2   3   4   5
  28  6   7   8   9  10  11  12
  29 13  14  15 (16) 17  18  19
  30 20  21  22  23  24  25  26
  31 27  28  29  30  31
      Thu 16 July · wk 29    ✕
```

## Features

- **Month view** with today marked by a ring in the accent color.
- **Week numbers** per ISO 8601 (Monday first, "first Thursday" rule) —
  correct even across year boundaries, where Dec 29–31 can be week 1 and
  Jan 1–3 week 52/53.
- **Step between months** with ◀ / ▶. Tap the month title to jump back to
  today; the title turns accent-colored when you're on another month.
  Browsing resets automatically at midnight.
- **Select a date or a range**, hotel-booking style: tap a day to select it —
  the row below the calendar shows its weekday, week number and any holiday.
  Tap a later day to select the whole range (shows the number of days and
  nights). Tap ✕, or the start date again, to clear. Ranges may span month
  boundaries and persist until cleared.
- **Public holidays for 13 countries**: holidays and Sundays in red, de facto
  eves (Christmas Eve, Heiligabend, Nochebuena, Grundlovsdag, Midsummer Eve
  and friends) in orange.
- **Two per-widget settings** (right-click → *Edit "Kalvender"*):
  - **Language:** English (default), Svenska or Español — controls month
    names, weekday letters, date formats and labels ("wk"/"v."/"sem.").
  - **Holidays:** None (default), or Sweden, Denmark, Finland, Norway,
    France, Germany, Italy, Netherlands, Peru, Portugal, Spain, United
    Kingdom, United States. Independent of the language setting — Swedish
    with US holidays is a valid combination.
- Medium and large widget sizes, light/dark mode, and the system's tinted
  widget rendering modes.
- Multiple widgets can have different settings (e.g. one Swedish, one Spanish).

## Installation

Requires macOS 15 or later, and Xcode 16 or later to build.

1. Open `Kalvender.xcodeproj` in Xcode.
2. Select your development team under **Signing & Capabilities** for both
   targets (`Kalvender` and `KalvenderWidget`). A free Apple ID is enough
   for local use.
3. Run the app once (⌘R) — this registers the widget with the system.
4. Right-click the desktop → **Edit Widgets…** → search for **Kalvender**
   and add it.

Or from the terminal:

```sh
xcodebuild -project Kalvender.xcodeproj -scheme Kalvender \
  -configuration Debug -derivedDataPath build/DerivedData build
cp -R build/DerivedData/Build/Products/Debug/Kalvender.app /Applications/
open /Applications/Kalvender.app
```

## Architecture

SwiftUI + WidgetKit. The app (`App/`) is just a minimal container with a
preview — everything interesting lives in the widget extension (`Widget/`)
and the shared logic (`Shared/`).

- **Pure calendar math.** `Shared/CalendarMath.swift` builds the month grid
  with `Calendar(identifier: .iso8601)`. `Shared/Holidays.swift` computes
  every country's holidays locally: Easter-based ones via computus (the
  anonymous Gregorian algorithm), weekday-ruled ones via "nth weekday of the
  month" rules, the rest fixed dates. No calendar data is ever fetched.
  Nationwide holidays only — regional days and "observed" shifts (US/UK) are
  not included; the United Kingdom follows England & Wales.
- **Interactivity via App Intents.** The ◀ / ▶ buttons run `ChangeMonthIntent`
  and every day cell runs `SelectDayIntent`, directly in the widget process.
  This also means taps inside the calendar don't open the app — only taps
  outside the buttons do (a WidgetKit behavior that cannot be disabled).
- **Settings via `AppIntentConfiguration`.** `ConfigurationIntent` declares
  the parameters; macOS renders the panel automatically. There is
  deliberately no "system language" option: the string table covers exactly
  the languages offered, so a system language outside the list can never
  produce a half-translated widget.
- **State** (month offset and selection) lives in the widget process's own
  `UserDefaults` — no App Group is needed since the intents and the timeline
  provider run in the same process. State is shared between widget instances.
- **Timeline:** a single entry refreshed at the next midnight, which moves
  the today marker and resets month browsing.

### Development notes

The Xcode project is generated with
[XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`; the
generated `Kalvender.xcodeproj` is checked in, so just opening the project
works. After changing `project.yml` — and whenever **new source files** are
added (they are listed explicitly in the project file) — run
`xcodegen generate`.

When the widget's configuration schema changes (new settings, changed enum
cases): bump `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` in `project.yml`
and restart the widget service (`killall chronod`), otherwise placed widgets
may freeze on a cached descriptor of the old schema.

The app icon is generated programmatically; the master image is
`Shared/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png` (1024×1024)
and the other sizes are downscales of it.

## License

[MIT](LICENSE) — in short: anyone may use, copy, modify and redistribute the
code, commercially too, as long as the copyright and license text are
preserved. The software is provided as-is, with no warranty and no liability
for the author.
