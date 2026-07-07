import Foundation

/// Svenska röda dagar och de facto-aftnar, helt beräknade — ingen
/// kalenderintegration behövs. Alla datum returneras som lokal midnatt,
/// samma form som `MonthGrid` använder för sina dagar.
enum SwedishHolidays {
    /// Årets helgdagar (röda dagar), datum → namn.
    static func redDays(year: Int, calendar: Calendar) -> [Date: String] {
        let easter = easterSunday(year: year, calendar: calendar)
        var days: [Date: String] = [
            date(year, 1, 1, calendar): "Nyårsdagen",
            date(year, 1, 6, calendar): "Trettondedag jul",
            adding(-2, to: easter, calendar): "Långfredagen",
            easter: "Påskdagen",
            adding(1, to: easter, calendar): "Annandag påsk",
            date(year, 5, 1, calendar): "Första maj",
            adding(39, to: easter, calendar): "Kristi himmelsfärdsdag",
            adding(49, to: easter, calendar): "Pingstdagen",
            date(year, 6, 6, calendar): "Sveriges nationaldag",
            date(year, 12, 25, calendar): "Juldagen",
            date(year, 12, 26, calendar): "Annandag jul",
        ]
        days[midsummerDay(year: year, calendar: calendar)] = "Midsommardagen"
        days[saturday(onOrAfter: date(year, 10, 31, calendar), calendar)] = "Alla helgons dag"
        return days
    }

    /// Aftnar som inte är formella helgdagar men som de flesta är lediga:
    /// midsommarafton, julafton och nyårsafton. (Påsk- och pingstafton
    /// utelämnas — de infaller alltid på lördagar.)
    static func eves(year: Int, calendar: Calendar) -> [Date: String] {
        [
            adding(-1, to: midsummerDay(year: year, calendar: calendar), calendar): "Midsommarafton",
            date(year, 12, 24, calendar): "Julafton",
            date(year, 12, 31, calendar): "Nyårsafton",
        ]
    }

    /// Namnet på helgdagen eller aftonen ett visst datum, annars nil.
    static func name(for date: Date, calendar: Calendar) -> String? {
        let day = calendar.startOfDay(for: date)
        let year = calendar.component(.year, from: day)
        return redDays(year: year, calendar: calendar)[day]
            ?? eves(year: year, calendar: calendar)[day]
    }

    /// Påskdagen enligt den anonyma gregorianska algoritmen (computus).
    static func easterSunday(year: Int, calendar: Calendar) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = (h + l - 7 * m + 114) % 31 + 1
        return date(year, month, day, calendar)
    }

    /// Lördagen 20–26 juni.
    private static func midsummerDay(year: Int, calendar: Calendar) -> Date {
        saturday(onOrAfter: date(year, 6, 20, calendar), calendar)
    }

    private static func saturday(onOrAfter start: Date, _ calendar: Calendar) -> Date {
        var day = start
        while calendar.component(.weekday, from: day) != 7 {
            day = adding(1, to: day, calendar)
        }
        return day
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int, _ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private static func adding(_ days: Int, to date: Date, _ calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: days, to: date)!
    }
}
