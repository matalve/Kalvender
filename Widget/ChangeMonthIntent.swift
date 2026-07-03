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
