import WidgetKit
import SwiftUI

struct CalendarEntry: TimelineEntry {
    let date: Date
    let grid: MonthGrid
}

struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: .now, grid: MonthGrid(monthOffset: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: .now, grid: MonthGrid(monthOffset: 0)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let now = Date.now
        let entry = CalendarEntry(
            date: now,
            grid: MonthGrid(monthOffset: MonthOffsetStore.currentOffset(today: now), today: now))

        // Inget ändras förrän datumet slår över, så en enda entry räcker;
        // vid midnatt begärs en ny timeline och dagens-markeringen flyttas.
        let calendar = MonthGrid.calendar
        let nextMidnight = calendar.date(
            byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

struct KalvenderWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KalvenderWidget", provider: CalendarProvider()) { entry in
            CalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("Kalvender")
        .description("Månadsvy med veckonummer — inga händelser, bara kalendern.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
