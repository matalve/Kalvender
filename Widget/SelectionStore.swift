import Foundation

/// Markerat datum eller datumintervall, hotellboknings-stil.
///
/// Lagras liksom `MonthOffsetStore` i widget-processens egna `UserDefaults`.
/// Markeringen är avsiktligt beständig över dygnsskiften — den rensas bara
/// av användaren.
enum SelectionStore {
    private static let startKey = "selectionStart"
    private static let endKey = "selectionEnd"
    private static var defaults: UserDefaults { .standard }

    static var start: Date? {
        read(startKey)
    }

    static var end: Date? {
        read(endKey)
    }

    /// Första trycket sätter start, andra trycket på ett senare datum sätter
    /// slut, tryck på startdatumet igen rensar, ett tidigare datum flyttar
    /// starten, och ett tryck när intervallet är komplett börjar om.
    static func handleTap(on date: Date) {
        let calendar = MonthGrid.calendar
        let day = calendar.startOfDay(for: date)
        switch (start, end) {
        case (nil, _):
            write(startKey, day)
            write(endKey, nil)
        case (let currentStart?, nil):
            if calendar.isDate(day, inSameDayAs: currentStart) {
                clear()
            } else if day < currentStart {
                write(startKey, day)
            } else {
                write(endKey, day)
            }
        case (.some, .some):
            write(startKey, day)
            write(endKey, nil)
        }
    }

    static func clear() {
        write(startKey, nil)
        write(endKey, nil)
    }

    private static func read(_ key: String) -> Date? {
        let value = defaults.double(forKey: key)
        return value == 0 ? nil : Date(timeIntervalSinceReferenceDate: value)
    }

    private static func write(_ key: String, _ date: Date?) {
        if let date {
            defaults.set(date.timeIntervalSinceReferenceDate, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}
