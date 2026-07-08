import Foundation

/// A precomputed month view: six week rows with ISO 8601 week numbers.
///
/// The ISO 8601 calendar gives Monday as the first weekday and the week
/// numbers used in most of Europe (the first Thursday determines week 1),
/// including the year-boundary edge cases where Dec 29–31 can be week 1
/// and Jan 1–3 week 52/53.
struct MonthGrid {
    struct Day: Hashable, Identifiable {
        let date: Date
        let number: Int
        let isInMonth: Bool
        let isToday: Bool
        /// Start/end point of a selected range (a single selected date is
        /// just a start point).
        let isSelectionEdge: Bool
        /// Falls within a complete selected range, endpoints included.
        let isInSelection: Bool
        /// Red day: a Sunday or a public holiday.
        let isRedDay: Bool
        /// De facto eve (Christmas Eve, New Year's Eve, Midsummer Eve, …).
        let isEve: Bool
        /// Name of the holiday or eve, if the day has one.
        let holidayName: String?
        var id: Date { date }
    }

    struct Week: Hashable, Identifiable {
        let number: Int
        let days: [Day]
        let containsCurrentMonth: Bool
        var id: Date { days[0].date }
    }

    /// E.g. "July 2026".
    let title: String
    /// Weekday letters in display order, Monday first.
    let weekdaySymbols: [String]
    /// Always six rows, so the layout doesn't jump between months.
    let weeks: [Week]
    let isCurrentMonth: Bool

    /// Calendar with the system locale — sufficient for pure date math
    /// (same-day comparisons etc.), which is locale-independent.
    static var calendar: Calendar {
        calendar(for: .autoupdatingCurrent)
    }

    /// Calendar for display: the locale drives month names, weekday letters
    /// and date formats. Week rules are always ISO 8601 regardless of locale.
    static func calendar(for locale: Locale) -> Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = locale
        return calendar
    }

    init(monthOffset: Int, today: Date = .now,
         selectionStart: Date? = nil, selectionEnd: Date? = nil,
         locale: Locale = .autoupdatingCurrent,
         region: HolidayRegion = .noHolidays) {
        let calendar = Self.calendar(for: locale)
        let startOfToday = calendar.startOfDay(for: today)
        let selStart = selectionStart.map { calendar.startOfDay(for: $0) }
        let selEnd = selectionEnd.map { calendar.startOfDay(for: $0) }
        let currentMonthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: startOfToday))!
        let monthStart = calendar.date(
            byAdding: .month, value: monthOffset, to: currentMonthStart)!

        isCurrentMonth = monthOffset == 0

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        title = formatter.string(from: monthStart).localizedCapitalized

        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstWeekday = calendar.firstWeekday
        weekdaySymbols = (0..<7).map { symbols[(firstWeekday - 1 + $0) % 7] }

        let weekdayOfFirst = calendar.component(.weekday, from: monthStart)
        let leadingDays = (weekdayOfFirst - firstWeekday + 7) % 7
        var cursor = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart)!

        // The grid can span a year boundary, so look up holidays for both
        // years it touches.
        var redDays: [Date: String] = [:]
        var eves: [Date: String] = [:]
        let lastDay = calendar.date(byAdding: .day, value: 41, to: cursor)!
        for year in Set([calendar.component(.year, from: cursor),
                         calendar.component(.year, from: lastDay)]) {
            redDays.merge(region.redDays(year: year, calendar: calendar)) { a, _ in a }
            eves.merge(region.eves(year: year, calendar: calendar)) { a, _ in a }
        }

        var weeks: [Week] = []
        for _ in 0..<6 {
            let weekNumber = calendar.component(.weekOfYear, from: cursor)
            var days: [Day] = []
            for _ in 0..<7 {
                let isEdge = [selStart, selEnd].contains { edge in
                    edge.map { calendar.isDate(cursor, inSameDayAs: $0) } ?? false
                }
                let isInSelection: Bool
                if let selStart, let selEnd {
                    isInSelection = cursor >= selStart && cursor <= selEnd
                } else {
                    isInSelection = false
                }
                let redName = redDays[cursor]
                let eveName = eves[cursor]
                days.append(Day(
                    date: cursor,
                    number: calendar.component(.day, from: cursor),
                    isInMonth: calendar.isDate(cursor, equalTo: monthStart, toGranularity: .month),
                    isToday: calendar.isDate(cursor, inSameDayAs: startOfToday),
                    isSelectionEdge: isEdge,
                    isInSelection: isInSelection,
                    isRedDay: redName != nil || calendar.component(.weekday, from: cursor) == 1,
                    isEve: eveName != nil,
                    holidayName: redName ?? eveName))
                cursor = calendar.date(byAdding: .day, value: 1, to: cursor)!
            }
            weeks.append(Week(
                number: weekNumber,
                days: days,
                containsCurrentMonth: days.contains { $0.isInMonth }))
        }
        self.weeks = weeks
    }
}
