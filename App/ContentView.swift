import SwiftUI

/// The container app's only window: a live preview of the calendar and an
/// instruction for adding the widget. Everything interesting lives in the
/// widget extension.
struct ContentView: View {
    @State private var monthOffset = 0

    var body: some View {
        VStack(spacing: 20) {
            monthPreview
            Divider()
            Text("Add the widget: right-click the desktop, choose “Edit Widgets…”, then search for Kalvender.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
        }
        .padding(28)
    }

    private var monthPreview: some View {
        let grid = MonthGrid(monthOffset: monthOffset)
        return VStack(spacing: 10) {
            HStack {
                Button {
                    monthOffset -= 1
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Button {
                    monthOffset = 0
                } label: {
                    Text(grid.title)
                        .font(.headline)
                        .foregroundStyle(grid.isCurrentMonth
                            ? AnyShapeStyle(.primary)
                            : AnyShapeStyle(.tint))
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    monthOffset += 1
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                GridRow {
                    Text("v.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    ForEach(grid.weekdaySymbols.indices, id: \.self) { index in
                        Text(grid.weekdaySymbols[index])
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                ForEach(grid.weeks) { week in
                    GridRow {
                        Text("\(week.number)")
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.tertiary)
                            .opacity(week.containsCurrentMonth ? 1 : 0.4)
                        ForEach(week.days) { day in
                            Text("\(day.number)")
                                .monospacedDigit()
                                .fontWeight(day.isToday ? .bold : .regular)
                                .foregroundStyle(day.isToday
                                    ? AnyShapeStyle(.white)
                                    : day.isRedDay
                                        ? AnyShapeStyle(.red.opacity(day.isInMonth ? 1 : 0.35))
                                        : day.isEve
                                            ? AnyShapeStyle(.orange.opacity(day.isInMonth ? 1 : 0.35))
                                            : day.isInMonth
                                                ? AnyShapeStyle(.primary)
                                                : AnyShapeStyle(.tertiary))
                                .frame(width: 30, height: 30)
                                .background {
                                    if day.isToday {
                                        Circle().fill(.tint)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .frame(width: 320)
    }
}
