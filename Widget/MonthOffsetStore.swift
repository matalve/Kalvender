import Foundation

/// The displayed month as an offset from the current month.
///
/// Stored in the widget process's own `UserDefaults` — both the button
/// intents and the timeline provider run in the widget extension's process,
/// so no App Group is needed (and thus no extra signing configuration).
enum MonthOffsetStore {
    private static let offsetKey = "monthOffset"
    private static let changedAtKey = "monthOffsetChangedAt"
    private static var defaults: UserDefaults { .standard }

    static func set(_ offset: Int) {
        defaults.set(offset, forKey: offsetKey)
        defaults.set(Date.now.timeIntervalSinceReferenceDate, forKey: changedAtKey)
    }

    /// Resets automatically at midnight, so the widget always wakes up on
    /// the current month even if you browsed away the night before.
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
