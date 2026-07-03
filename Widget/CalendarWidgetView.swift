import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(spacing: family == .systemLarge ? 8 : 4) {
            header
            monthGrid
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

    private func dayCell(_ day: MonthGrid.Day) -> some View {
        Text("\(day.number)")
            .font(dayFont)
            .monospacedDigit()
            .fontWeight(day.isToday ? .bold : .regular)
            .foregroundStyle(day.isToday
                ? AnyShapeStyle(.white)
                : day.isInMonth
                    ? AnyShapeStyle(.primary)
                    : AnyShapeStyle(.tertiary))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if day.isToday {
                    Circle()
                        .fill(.tint)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
    }

    private var labelFont: Font {
        family == .systemLarge ? .caption : .caption2
    }

    private var dayFont: Font {
        family == .systemLarge ? .callout : .caption
    }
}
