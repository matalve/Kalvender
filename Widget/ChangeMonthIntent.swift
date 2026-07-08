import AppIntents

/// Steps the month view forward/backward, or jumps to the current month
/// (step 0). WidgetKit reloads the widget's timeline automatically after
/// `perform()`.
struct ChangeMonthIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Month"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Step")
    var step: Int

    init() {}

    init(step: Int) {
        self.step = step
    }

    func perform() async throws -> some IntentResult {
        if step == 0 {
            MonthOffsetStore.set(0)
        } else {
            MonthOffsetStore.set(MonthOffsetStore.currentOffset() + step)
        }
        return .result()
    }
}

/// Selects a date, hotel-booking style: start → end → clear/start over.
struct SelectDayIntent: AppIntent {
    static var title: LocalizedStringResource = "Select Date"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Date")
    var date: Date

    init() {}

    init(date: Date) {
        self.date = date
    }

    func perform() async throws -> some IntentResult {
        SelectionStore.handleTap(on: date)
        return .result()
    }
}

struct ClearSelectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Clear Selection"
    static var isDiscoverable: Bool = false

    init() {}

    func perform() async throws -> some IntentResult {
        SelectionStore.clear()
        return .result()
    }
}
