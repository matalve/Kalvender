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
- **Svenska röda dagar** visas i rött (söndagar och helgdagar) och de facto-aftnarna
  — midsommar-, jul- och nyårsafton — i orange. Allt beräknas lokalt (påsken via
  computus, midsommar/alla helgons dag via veckodagsregler); ingen kalenderdata
  hämtas. Markerar man en helgdag visas namnet i raden under kalendern, t.ex.
  ”Lördag 20 juni · v. 25 · Midsommardagen”.
- Bläddringen nollställs automatiskt vid midnatt, så widgeten vaknar alltid på rätt månad.
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
