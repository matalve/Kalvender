import Foundation

/// En färdigberäknad månadsvy: sex veckorader med ISO 8601-veckonummer.
///
/// ISO 8601-kalendern ger måndag som första veckodag och de veckonummer
/// som används i Sverige (första torsdagen avgör vecka 1), inklusive
/// kantfallen runt årsskiften där 29–31 december kan vara vecka 1 och
/// 1–3 januari vecka 52/53.
struct MonthGrid {
    struct Day: Hashable, Identifiable {
        let date: Date
        let number: Int
        let isInMonth: Bool
        let isToday: Bool
        /// Start-/slutpunkt för markerat intervall (ett ensamt markerat
        /// datum är enbart startpunkt).
        let isSelectionEdge: Bool
        /// Ligger inom ett komplett markerat intervall, inklusive kanterna.
        let isInSelection: Bool
        var id: Date { date }
    }

    struct Week: Hashable, Identifiable {
        let number: Int
        let days: [Day]
        let containsCurrentMonth: Bool
        var id: Date { days[0].date }
    }

    /// T.ex. "Juli 2026".
    let title: String
    /// Veckodagsbokstäver i visningsordning, måndag först.
    let weekdaySymbols: [String]
    /// Alltid sex rader, så att layouten inte hoppar mellan månader.
    let weeks: [Week]
    let isCurrentMonth: Bool

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = .autoupdatingCurrent
        return calendar
    }

    init(monthOffset: Int, today: Date = .now,
         selectionStart: Date? = nil, selectionEnd: Date? = nil) {
        let calendar = Self.calendar
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
                days.append(Day(
                    date: cursor,
                    number: calendar.component(.day, from: cursor),
                    isInMonth: calendar.isDate(cursor, equalTo: monthStart, toGranularity: .month),
                    isToday: calendar.isDate(cursor, inSameDayAs: startOfToday),
                    isSelectionEdge: isEdge,
                    isInSelection: isInSelection))
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
