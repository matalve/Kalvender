import AppIntents

/// Stegar månadsvyn framåt/bakåt, eller hoppar till innevarande månad (steg 0).
/// WidgetKit laddar om widgetens timeline automatiskt efter `perform()`.
struct ChangeMonthIntent: AppIntent {
    static var title: LocalizedStringResource = "Byt månad"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Steg")
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

/// Markerar ett datum, hotellboknings-stil: start → slut → rensa/börja om.
struct SelectDayIntent: AppIntent {
    static var title: LocalizedStringResource = "Markera datum"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Datum")
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
    static var title: LocalizedStringResource = "Rensa markering"
    static var isDiscoverable: Bool = false

    init() {}

    func perform() async throws -> some IntentResult {
        SelectionStore.clear()
        return .result()
    }
}
