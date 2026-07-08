# Kalvender

En enkel kalender-widget för macOS: månadsvy med svenska veckonummer, inget annat.

Ingen integration mot händelser eller kalenderkonton — widgeten är ren kalendermatematik
för att snabbt se vilken veckodag ett datum infaller på och vilket veckonummer det är.

```
  ◀      Juli 2026      ▶
  v.  M   T   O   T   F   L   S
  27          1   2   3   4   5
  28  6   7   8   9  10  11  12
  29 13  14  15  16  17  18  19
  30 20  21  22  23  24  25  26
  31 27  28  29  30  31
```

## Funktioner

- **Månadsvy** med dagens datum markerat med en fylld cirkel i accentfärgen.
- **Veckonummer** enligt ISO 8601 (svenska veckonummer, måndag som första veckodag).
- **Bläddra mellan månader** direkt i widgeten med ◀ / ▶ — tryck på månadstiteln
  för att hoppa tillbaka till innevarande månad. Titeln visas i accentfärg när
  du inte är på dagens månad.
- **Markera datum eller intervall**, hotellboknings-stil: tryck på en dag för att
  markera den (raden under kalendern visar veckodag och veckonummer), tryck på en
  senare dag för att markera hela intervallet (visar antal dagar och nätter).
  Tryck på ✕ eller på startdatumet igen för att rensa. Intervall kan sträcka sig
  över månadsgränser. Dagens datum visas som en ring; fylld cirkel är markeringen.
- **Röda dagar för 13 länder** (inställning per widget): Sverige (standard),
  Danmark, Finland, Norge, Frankrike, Italien, Nederländerna, Peru, Portugal,
  Spanien, Storbritannien, Tyskland och USA — eller inga alls. Helgdagar i rött
  (söndagar alltid röda), de facto-aftnar i orange (t.ex. julafton, Heiligabend,
  Nochebuena, Grundlovsdag). Allt beräknas lokalt (påsken via computus,
  ”n:te veckodagen”-regler m.m.); ingen kalenderdata hämtas. Endast
  landsomfattande helgdagar — regionala dagar och ”observed”-flyttar (USA/UK)
  ingår inte; Storbritannien följer England & Wales. Markerar man en helgdag
  visas namnet i raden under kalendern, t.ex. ”Lördag 20 juni · v. 25 ·
  Midsommardagen”. Namnen står på landets eget språk.
- Bläddringen nollställs automatiskt vid midnatt, så widgeten vaknar alltid på rätt månad.
- **Språkinställning per widget**: högerklicka på widgeten → *Redigera widget* →
  välj English (standard), Svenska eller Español. Styr månadsnamn,
  veckodagsbokstäver, datumformat och etiketter ("v."/"wk"/"sem."). Veckonumren
  är ISO 8601 oavsett språk. Språk och helgdagsland är oberoende inställningar —
  svenska + amerikanska helgdagar är en giltig kombination.
- Stödjer widgetstorlekarna medium och stor, ljust/mörkt läge och systemets tonade widgetlägen.
- Inga behörigheter, ingen nätverksåtkomst, inga händelser.

## Bygga och installera

Kräver Xcode 16 eller senare.

1. Öppna `Kalvender.xcodeproj` i Xcode.
2. Välj ditt utvecklarteam under **Signing & Capabilities** för båda targets
   (`Kalvender` och `KalvenderWidget`). Ett gratis Apple-ID räcker för att köra lokalt.
3. Kör appen en gång (⌘R). Det registrerar widgeten hos systemet.
4. Högerklicka på skrivbordet → **Redigera widgetar…** → sök efter **Kalvender**
   och lägg till den (finns i medium och stor storlek).

## Arkitektur

- **SwiftUI + WidgetKit.** Appen (`App/`) är bara en minimal container med en
  förhandsvisning — allt intressant bor i widget-extensionen (`Widget/`).
- **Inställningar via `AppIntentConfiguration`.** `ConfigurationIntent` deklarerar
  parametrarna (idag: språk) och macOS renderar panelen automatiskt. Ingen
  "systemspråk"-option — strängtabellen i `ConfigurationIntent.swift` täcker exakt
  de språk som erbjuds, så ett systemspråk utanför listan kan aldrig ge en
  halvöversatt widget. En framtida regioninställning för helgdagar hakar i här.
- **Interaktivitet via App Intents.** Knapparna ◀ / ▶ kör `ChangeMonthIntent` och
  varje dagcell kör `SelectDayIntent` direkt i widget-processen; WidgetKit laddar
  om vyn automatiskt efteråt. Att dagarna är knappar gör också att tryck i
  kalendern inte öppnar appen (det gör bara tryck på ytor utanför knapparna —
  ett WidgetKit-beteende som inte går att stänga av).
- **Tillstånd** (månads-offset och markering) sparas i widget-processens egna
  `UserDefaults` — ingen App Group behövs eftersom intents och timeline-providern
  kör i samma process. Månadsbläddringen nollställs vid midnatt; markeringen
  ligger kvar tills den rensas.
- **Timeline:** en enda entry med uppdatering vid nästa midnatt (`.after`), då
  dagens-markeringen flyttas och eventuell bläddring nollställs.
- **Kalendermatematik** (`Shared/CalendarMath.swift`) använder `Calendar(identifier: .iso8601)`,
  vilket ger korrekta veckonummer även runt årsskiften (29–31 december kan vara
  vecka 1, och 1–3 januari vecka 52/53).

Projektfilen genereras med [XcodeGen](https://github.com/yonaskolb/XcodeGen) från
`project.yml`, men den genererade `Kalvender.xcodeproj` är incheckad så att det
räcker att öppna projektet. Efter ändringar i `project.yml`: kör `xcodegen generate`.

## Licens

[MIT](LICENSE)
