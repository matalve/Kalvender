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
            // Ett tryck på titeln hoppar tillbaka till innevarande månad.
            // Accentfärgen på titeln signalerar att man inte är "hemma".
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
                Text("v.")
                    .font(labelFont)
                    .foregroundStyle(.tertiary)
                ForEach(entry.grid.weekdaySymbols.indices, id: \.self) { index in
                    Text(entry.grid.weekdaySymbols[index])
                        .font(labelFont)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
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

    // Varje dag är en knapp: tryck markerar datum i stället för att öppna
    // appen. Markeringens ändpunkter är fyllda cirklar, intervallet ett tonat
    // band, och dagens datum en ring (fylld cirkel är reserverad för valet).
    private func dayCell(_ day: MonthGrid.Day) -> some View {
        Button(intent: SelectDayIntent(date: day.date)) {
            Text("\(day.number)")
                .font(dayFont)
                .monospacedDigit()
                .fontWeight(day.isToday || day.isSelectionEdge ? .bold : .regular)
                .foregroundStyle(day.isSelectionEdge
                    ? AnyShapeStyle(.white)
                    : day.isToday
                        ? AnyShapeStyle(.tint)
                        : day.isInMonth
                            ? AnyShapeStyle(.primary)
                            : AnyShapeStyle(.tertiary))
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

    // Sammanfattning av markeringen: veckodag + veckonummer för ett enskilt
    // datum, längd i dagar/nätter för ett intervall. Fast höjd (osynlig text
    // när inget är markerat) så att kalendern inte hoppar.
    private var footer: some View {
        HStack(spacing: 4) {
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
        let calendar = MonthGrid.calendar
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
                return "\(range) · \(days) dagar, \(nights) \(nights == 1 ? "natt" : "nätter")"
            }
            return "\(range) · \(days) dgr"
        }
        formatter.setLocalizedDateFormatFromTemplate(
            family == .systemLarge ? "EEEE d MMMM" : "EEE d MMM")
        let week = calendar.component(.weekOfYear, from: start)
        return "\(formatter.string(from: start).localizedCapitalized) · v. \(week)"
    }

    private var labelFont: Font {
        family == .systemLarge ? .caption : .caption2
    }

    private var dayFont: Font {
        family == .systemLarge ? .callout : .caption
    }
}
