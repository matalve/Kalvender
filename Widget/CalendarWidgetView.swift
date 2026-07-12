import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(spacing: family == .systemLarge ? 6 : 3) {
            header
            monthGrid
            footer
        }
        .containerBackground(for: .widget) { Color.clear }
    }

    private var header: some View {
        HStack {
            stepButton(step: -1, symbol: "chevron.left")
            Spacer()
            // Tapping the title jumps back to the current month. The accent
            // color on the title signals that you're not "home".
            Button(intent: ChangeMonthIntent(step: 0)) {
                Text(entry.grid.title)
                    .font(family == .systemLarge ? .headline : .subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(entry.grid.isCurrentMonth
                        ? AnyShapeStyle(.primary)
                        : AnyShapeStyle(.tint))
            }
            .buttonStyle(.plain)
            Spacer()
            stepButton(step: 1, symbol: "chevron.right")
        }
    }

    private func stepButton(step: Int, symbol: String) -> some View {
        Button(intent: ChangeMonthIntent(step: step)) {
            Image(systemName: symbol)
                .font(family == .systemLarge ? .body : .caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var monthGrid: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                Text(entry.language.strings.weekLabel)
                    .font(labelFont)
                    .foregroundStyle(.tertiary)
                ForEach(entry.grid.weekdaySymbols.indices, id: \.self) { index in
                    // The last column is Sunday (ISO 8601: Monday first).
                    Text(entry.grid.weekdaySymbols[index])
                        .font(labelFont)
                        .fontWeight(.medium)
                        .foregroundStyle(index == 6
                            ? AnyShapeStyle(.red.opacity(0.8))
                            : AnyShapeStyle(.secondary))
                        .frame(maxWidth: .infinity)
                }
            }
            ForEach(entry.grid.weeks) { week in
                GridRow {
                    Text("\(week.number)")
                        .font(labelFont)
                        .monospacedDigit()
                        .foregroundStyle(.tertiary)
                        .opacity(week.containsCurrentMonth ? 1 : 0.4)
                    ForEach(week.days) { day in
                        dayCell(day)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Every day is a button: a tap selects the date instead of opening the
    // app. The selection endpoints are filled circles, the range a tinted
    // band, and today a ring (the filled circle is reserved for selection).
    private func dayCell(_ day: MonthGrid.Day) -> some View {
        Button(intent: SelectDayIntent(date: day.date)) {
            Text("\(day.number)")
                .font(dayFont)
                .monospacedDigit()
                .fontWeight(day.isToday || day.isSelectionEdge ? .bold : .regular)
                .foregroundStyle(textStyle(for: day))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    ZStack {
                        if day.isInSelection && !day.isSelectionEdge {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.tint)
                                .opacity(0.22)
                        }
                        if day.isSelectionEdge {
                            Circle()
                                .fill(.tint)
                                .aspectRatio(1, contentMode: .fit)
                        } else if day.isToday {
                            Circle()
                                .strokeBorder(.tint, lineWidth: 1.5)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // Color priority: selection endpoint (white on accent) > red day >
    // eve (orange) > today (accent) > regular. Days outside the month get
    // dimmed variants of the same colors.
    private func textStyle(for day: MonthGrid.Day) -> AnyShapeStyle {
        if day.isSelectionEdge {
            return AnyShapeStyle(.white)
        }
        if day.isRedDay {
            return AnyShapeStyle(.red.opacity(day.isInMonth ? 1 : 0.35))
        }
        if day.isEve {
            return AnyShapeStyle(.orange.opacity(day.isInMonth ? 1 : 0.35))
        }
        if day.isToday {
            return AnyShapeStyle(.tint)
        }
        return day.isInMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }

    // Footer row. Leading: a "Today" button, shown only when browsing away
    // from the current month (tapping the title does the same, but a visible
    // button is discoverable). Trailing: the selection summary — weekday +
    // week number for a single date, length in days/nights for a range.
    // Fixed height (invisible text when empty) so the calendar doesn't jump.
    private var footer: some View {
        HStack(spacing: 4) {
            if !entry.grid.isCurrentMonth {
                Button(intent: ChangeMonthIntent(step: 0)) {
                    Text(entry.language.strings.today)
                        .font(labelFont)
                        .fontWeight(.medium)
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 8)
            Text(selectionSummary ?? " ")
                .font(labelFont)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if selectionSummary != nil {
                Button(intent: ClearSelectionIntent()) {
                    Image(systemName: "xmark.circle.fill")
                        .font(labelFont)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var selectionSummary: String? {
        guard let start = entry.selectionStart else { return nil }
        let strings = entry.language.strings
        let calendar = MonthGrid.calendar(for: entry.language.locale)
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        if let end = entry.selectionEnd {
            formatter.setLocalizedDateFormatFromTemplate(
                family == .systemLarge ? "d MMMM" : "d MMM")
            let days = calendar.dateComponents(
                [.day], from: calendar.startOfDay(for: start),
                to: calendar.startOfDay(for: end)).day! + 1
            let nights = days - 1
            let range = "\(formatter.string(from: start)) – \(formatter.string(from: end))"
            if family == .systemLarge {
                let nightsWord = nights == 1 ? strings.night : strings.nights
                return "\(range) · \(days) \(strings.days), \(nights) \(nightsWord)"
            }
            return "\(range) · \(days) \(strings.daysShort)"
        }
        formatter.setLocalizedDateFormatFromTemplate(
            family == .systemLarge ? "EEEE d MMMM" : "EEE d MMM")
        let week = calendar.component(.weekOfYear, from: start)
        var summary = "\(formatter.string(from: start).localizedCapitalized) · \(strings.weekLabel) \(week)"
        if let holiday = entry.region.name(for: start, calendar: calendar) {
            summary += " · \(holiday)"
        }
        return summary
    }

    private var labelFont: Font {
        family == .systemLarge ? .caption : .caption2
    }

    private var dayFont: Font {
        family == .systemLarge ? .callout : .caption
    }
}
