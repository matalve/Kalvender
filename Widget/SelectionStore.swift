import Foundation

/// The selected date or date range, hotel-booking style.
///
/// Stored, like `MonthOffsetStore`, in the widget process's own
/// `UserDefaults`. The selection deliberately survives midnight — it is
/// only cleared by the user.
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

    /// First tap sets the start, a second tap on a later date sets the end,
    /// tapping the start date again clears, an earlier date moves the start,
    /// and a tap while the range is complete starts over.
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
