import AppIntents

/// The widget's settings panel (right-click → "Edit Widget").
/// macOS renders the form automatically from the parameters.
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

/// Display language. Deliberately no "system language" option: the string
/// table below covers exactly these languages, so a system language outside
/// the list would produce a half-translated widget. English is therefore
/// the default, and the list only grows together with the table.
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
            night: "night", nights: "nights", today: "Today")
        case .swedish: WidgetStrings(
            weekLabel: "v.", days: "dagar", daysShort: "dgr",
            night: "natt", nights: "nätter", today: "Idag")
        case .spanish: WidgetStrings(
            weekLabel: "sem.", days: "días", daysShort: "d",
            night: "noche", nights: "noches", today: "Hoy")
        }
    }
}

/// The hard-coded UI strings — everything else that is language-dependent
/// (month names, weekdays, date formats) comes from `Locale` via the
/// system formatters.
struct WidgetStrings {
    let weekLabel: String
    let days: String
    let daysShort: String
    let night: String
    let nights: String
    let today: String
}
