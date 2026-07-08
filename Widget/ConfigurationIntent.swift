import AppIntents

/// Widgetens inställningspanel (högerklick → "Redigera widget").
/// macOS renderar formuläret automatiskt från parametrarna.
struct ConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Settings"
    static var description = IntentDescription("Calendar widget settings.")

    @Parameter(title: "Language", default: .english)
    var language: WidgetLanguage

    @Parameter(title: "Holidays", default: .noHolidays)
    var holidayRegion: HolidayRegion
}

extension HolidayRegion: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Holidays"
    static var caseDisplayRepresentations: [HolidayRegion: DisplayRepresentation] = [
        .sweden: "Sweden",
        .denmark: "Denmark",
        .finland: "Finland",
        .france: "France",
        .germany: "Germany",
        .italy: "Italy",
        .netherlands: "Netherlands",
        .norway: "Norway",
        .peru: "Peru",
        .portugal: "Portugal",
        .spain: "Spain",
        .unitedKingdom: "United Kingdom",
        .unitedStates: "United States",
        .noHolidays: "None",
    ]
}

/// Visningsspråk. Medvetet ingen "systemspråk"-option: strängtabellen
/// nedan täcker exakt dessa språk, så ett systemspråk utanför listan
/// (t.ex. spanska) skulle ge en halvöversatt widget. Engelska är därför
/// standard och listan utökas bara ihop med tabellen.
enum WidgetLanguage: String, AppEnum {
    case english
    case swedish
    case spanish

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Language"
    static var caseDisplayRepresentations: [WidgetLanguage: DisplayRepresentation] = [
        .english: "English",
        .swedish: "Svenska",
        .spanish: "Español",
    ]

    var locale: Locale {
        switch self {
        case .english: Locale(identifier: "en_GB")
        case .swedish: Locale(identifier: "sv_SE")
        case .spanish: Locale(identifier: "es_ES")
        }
    }

    var strings: WidgetStrings {
        switch self {
        case .english: WidgetStrings(
            weekLabel: "wk", days: "days", daysShort: "d",
            night: "night", nights: "nights")
        case .swedish: WidgetStrings(
            weekLabel: "v.", days: "dagar", daysShort: "dgr",
            night: "natt", nights: "nätter")
        case .spanish: WidgetStrings(
            weekLabel: "sem.", days: "días", daysShort: "d",
            night: "noche", nights: "noches")
        }
    }
}

/// De hårdkodade UI-strängarna — allt annat språkberoende (månadsnamn,
/// veckodagar, datumformat) kommer ur `Locale` via systemets formatterare.
struct WidgetStrings {
    let weekLabel: String
    let days: String
    let daysShort: String
    let night: String
    let nights: String
}
