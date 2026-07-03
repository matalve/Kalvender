import Foundation

/// Vald månad som offset från innevarande månad.
///
/// Lagras i widget-processens egna `UserDefaults` — både knapparnas intents
/// och timeline-providern kör i widget-extensionens process, så ingen
/// App Group behövs (och därmed ingen extra signeringskonfiguration).
enum MonthOffsetStore {
    private static let offsetKey = "monthOffset"
    private static let changedAtKey = "monthOffsetChangedAt"
    private static var defaults: UserDefaults { .standard }

    static func set(_ offset: Int) {
        defaults.set(offset, forKey: offsetKey)
        defaults.set(Date.now.timeIntervalSinceReferenceDate, forKey: changedAtKey)
    }

    /// Nollställs automatiskt vid dygnsskifte, så att widgeten alltid visar
    /// dagens månad på morgonen även om man bläddrade iväg kvällen innan.
    static func currentOffset(today: Date = .now) -> Int {
        let offset = defaults.integer(forKey: offsetKey)
        guard offset != 0 else { return 0 }
        let changedAt = Date(
            timeIntervalSinceReferenceDate: defaults.double(forKey: changedAtKey))
        guard MonthGrid.calendar.isDate(changedAt, inSameDayAs: today) else {
            set(0)
            return 0
        }
        return offset
    }
}
