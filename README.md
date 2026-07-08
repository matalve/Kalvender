# Kalvender

En enkel kalender-widget för macOS: månadsvy med veckonummer och röda dagar —
inga händelser, inga behörigheter, ingen nätverksåtkomst.

Kalvender svarar på frågor som *"vilken veckodag är den 24:e?"*, *"vilket
veckonummer är det då?"* och *"hur många nätter blir det 17–19 juli?"* — direkt
på skrivbordet, utan att blanda in kalenderkonton eller händelser.

```
  ◀      Juli 2026      ▶
  v.  M   T   O   T   F   L   S
  27          1   2   3   4   5
  28  6   7   8   9  10  11  12
  29 13  14  15 (16) 17  18  19
  30 20  21  22  23  24  25  26
  31 27  28  29  30  31
      Tor 16 juli · v. 29    ✕
```

## Funktioner

- **Månadsvy** med dagens datum markerat med en ring i accentfärgen.
- **Veckonummer** enligt ISO 8601 (måndag första veckodag, "första torsdagen"-
  regeln) — korrekta även runt årsskiften, där 29–31 december kan vara vecka 1
  och 1–3 januari vecka 52/53.
- **Bläddra mellan månader** med ◀ / ▶. Tryck på månadstiteln för att hoppa
  tillbaka till idag; titeln visas i accentfärg när du är på en annan månad.
  Bläddringen nollställs automatiskt vid midnatt.
- **Markera datum eller intervall**, hotellboknings-stil: tryck på en dag för
  att markera den — raden under kalendern visar veckodag, veckonummer och
  eventuell helgdag. Tryck på en senare dag för att markera intervallet (visar
  antal dagar och nätter). Tryck på ✕ eller startdatumet igen för att rensa.
  Intervall kan sträcka sig över månadsgränser och ligger kvar tills de rensas.
- **Röda dagar för 13 länder**: helgdagar och söndagar i rött, de facto-aftnar
  (julafton, Heiligabend, Nochebuena, Grundlovsdag m.fl.) i orange.
- **Två inställningar per widget** (högerklick → *Redigera "Kalvender"*):
  - **Language:** English (standard), Svenska eller Español — styr månadsnamn,
    veckodagsbokstäver, datumformat och etiketter ("wk"/"v."/"sem.").
  - **Holidays:** Sverige (standard), Danmark, Finland, Norge, Frankrike,
    Italien, Nederländerna, Peru, Portugal, Spanien, Storbritannien, Tyskland,
    USA — eller None. Oberoende av språket: svenska + amerikanska helgdagar
    är en giltig kombination.
- Storlekarna medium och stor, ljust/mörkt läge, systemets tonade widgetlägen.
- Två widgets kan ha olika inställningar (t.ex. en svensk och en spansk).

## Installation

Kräver macOS 15 eller senare samt Xcode 16 eller senare för att bygga.

1. Öppna `Kalvender.xcodeproj` i Xcode.
2. Välj ditt utvecklarteam under **Signing & Capabilities** för båda targets
   (`Kalvender` och `KalvenderWidget`). Ett gratis Apple-ID räcker lokalt.
3. Kör appen en gång (⌘R) — det registrerar widgeten hos systemet.
4. Högerklicka på skrivbordet → **Redigera widgetar…** → sök efter
   **Kalvender** och lägg till.

Eller från terminalen:

```sh
xcodebuild -project Kalvender.xcodeproj -scheme Kalvender \
  -configuration Debug -derivedDataPath build/DerivedData build
cp -R build/DerivedData/Build/Products/Debug/Kalvender.app /Applications/
open /Applications/Kalvender.app
```

## Arkitektur

SwiftUI + WidgetKit. Appen (`App/`) är bara en minimal container med en
förhandsvisning — allt intressant bor i widget-extensionen (`Widget/`) och
den delade logiken (`Shared/`).

- **Ren kalendermatematik.** `Shared/CalendarMath.swift` bygger månadsgridden
  med `Calendar(identifier: .iso8601)`. `Shared/Holidays.swift` beräknar alla
  länders helgdagar lokalt: påskbaserade via computus (den anonyma gregorianska
  algoritmen), veckodagsstyrda via "n:te veckodagen"-regler, resten fasta
  datum. Ingen kalenderdata hämtas någonsin. Endast landsomfattande helgdagar;
  regionala dagar och "observed"-flyttar (USA/UK) ingår inte; Storbritannien
  följer England & Wales.
- **Interaktivitet via App Intents.** Knapparna ◀ / ▶ kör `ChangeMonthIntent`
  och varje dagcell `SelectDayIntent`, direkt i widget-processen. Det gör
  också att tryck i kalendern inte öppnar appen — bara tryck på ytor utanför
  knapparna gör det (ett WidgetKit-beteende som inte går att stänga av).
- **Inställningar via `AppIntentConfiguration`.** `ConfigurationIntent`
  deklarerar parametrarna; macOS renderar panelen automatiskt. Ingen
  "systemspråk"-option med avsikt: strängtabellen täcker exakt de språk som
  erbjuds, så ett systemspråk utanför listan kan aldrig ge en halvöversatt
  widget.
- **Tillstånd** (månadsoffset och markering) ligger i widget-processens egna
  `UserDefaults` — ingen App Group behövs eftersom intents och timeline-
  providern kör i samma process. Tillståndet delas mellan widget-instanser.
- **Timeline:** en enda entry med uppdatering vid nästa midnatt, då
  dagens-markeringen flyttas och månadsbläddringen nollställs.

### Utveckling

Projektfilen genereras med [XcodeGen](https://github.com/yonaskolb/XcodeGen)
från `project.yml`; den genererade `Kalvender.xcodeproj` är incheckad så det
räcker att öppna projektet. Efter ändringar i `project.yml` — och när
**nya källfiler** läggs till (de listas explicit i projektfilen): kör
`xcodegen generate`.

Vid ändringar i widgetens konfigurationsschema (nya inställningar, ändrade
enum-fall): bumpa `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` i `project.yml`
och starta om widgettjänsten (`killall chronod`), annars kan placerade widgets
frysa på en cachad beskrivning av det gamla schemat.

Appikonen genereras programmatiskt; masterbilden är
`Shared/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png` (1024×1024)
och övriga storlekar är nedskalningar av den.

## Licens

[MIT](LICENSE) — kort sammanfattat: vem som helst får använda, kopiera,
ändra och vidaredistribuera koden, även kommersiellt, så länge licens- och
upphovsrättstexten följer med. Programvaran levereras i befintligt skick,
utan garantier och utan ansvar för upphovspersonen.
