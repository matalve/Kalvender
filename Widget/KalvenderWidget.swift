import WidgetKit
import SwiftUI

struct CalendarEntry: TimelineEntry {
    let date: Date
    let grid: MonthGrid
    var selectionStart: Date?
    var selectionEnd: Date?
    var language: WidgetLanguage = .english
    var region: HolidayRegion = .sweden
}

struct CalendarProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: .now, grid: MonthGrid(monthOffset: 0))
    }

    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> CalendarEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<CalendarEntry> {
        // Inget ändras förrän datumet slår över, så en enda entry räcker;
        // vid midnatt begärs en ny timeline och dagens-markeringen flyttas.
        let calendar = MonthGrid.calendar
        let nextMidnight = calendar.date(
            byAdding: .day, value: 1, to: calendar.startOfDay(for: .now))!
        return Timeline(entries: [entry(for: configuration)], policy: .after(nextMidnight))
    }

    private func entry(for configuration: ConfigurationIntent) -> CalendarEntry {
        let now = Date.now
        return CalendarEntry(
            date: now,
            grid: MonthGrid(
                monthOffset: MonthOffsetStore.currentOffset(today: now), today: now,
                selectionStart: SelectionStore.start, selectionEnd: SelectionStore.end,
                locale: configuration.language.locale,
                region: configuration.holidayRegion),
            selectionStart: SelectionStore.start,
            selectionEnd: SelectionStore.end,
            language: configuration.language,
            region: configuration.holidayRegion)
    }
}

struct KalvenderWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "KalvenderWidget",
            intent: ConfigurationIntent.self,
            provider: CalendarProvider()
        ) { entry in
            CalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("Kalvender")
        .description("Månadsvy med veckonummer — inga händelser, bara kalendern.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
