import Foundation

/// Helgdagar per land, helt beräknade — ingen kalenderdata hämtas.
///
/// Endast landsomfattande helgdagar ingår; regionala (tyska delstaters,
/// spanska regioners, Skottlands/Nordirlands avvikande bank holidays)
/// utelämnas. "Observed"-flyttar (USA/UK när dagen faller på helg)
/// markeras inte — kalendern visar faktiska datum. Helgdagsnamnen står
/// på landets eget språk; de är egennamn.
enum HolidayRegion: String, CaseIterable, Sendable {
    case sweden
    case denmark
    case finland
    case france
    case germany
    case italy
    case netherlands
    case norway
    case peru
    case portugal
    case spain
    case unitedKingdom
    case unitedStates
    case noHolidays
}

extension HolidayRegion {
    /// Årets helgdagar (röda dagar), datum → namn.
    func redDays(year: Int, calendar: Calendar) -> [Date: String] {
        var days: [Date: String] = [:]
        let easter = Self.easterSunday(year: year, calendar: calendar)
        func fix(_ month: Int, _ day: Int, _ name: String) {
            days[Self.date(year, month, day, calendar)] = name
        }
        func easterRel(_ offset: Int, _ name: String) {
            days[Self.adding(offset, to: easter, calendar)] = name
        }

        switch self {
        case .sweden:
            fix(1, 1, "Nyårsdagen")
            fix(1, 6, "Trettondedag jul")
            easterRel(-2, "Långfredagen")
            easterRel(0, "Påskdagen")
            easterRel(1, "Annandag påsk")
            fix(5, 1, "Första maj")
            easterRel(39, "Kristi himmelsfärdsdag")
            easterRel(49, "Pingstdagen")
            fix(6, 6, "Sveriges nationaldag")
            days[Self.saturday(onOrAfter: Self.date(year, 6, 20, calendar), calendar)] = "Midsommardagen"
            days[Self.saturday(onOrAfter: Self.date(year, 10, 31, calendar), calendar)] = "Alla helgons dag"
            fix(12, 25, "Juldagen")
            fix(12, 26, "Annandag jul")

        case .denmark:
            // Store bededag avskaffades som helgdag 2024.
            fix(1, 1, "Nytårsdag")
            easterRel(-3, "Skærtorsdag")
            easterRel(-2, "Langfredag")
            easterRel(0, "Påskedag")
            easterRel(1, "2. påskedag")
            easterRel(39, "Kristi himmelfartsdag")
            easterRel(49, "Pinsedag")
            easterRel(50, "2. pinsedag")
            fix(12, 25, "Juledag")
            fix(12, 26, "2. juledag")

        case .finland:
            fix(1, 1, "Uudenvuodenpäivä")
            fix(1, 6, "Loppiainen")
            easterRel(-2, "Pitkäperjantai")
            easterRel(0, "Pääsiäispäivä")
            easterRel(1, "Toinen pääsiäispäivä")
            fix(5, 1, "Vappu")
            easterRel(39, "Helatorstai")
            easterRel(49, "Helluntaipäivä")
            days[Self.saturday(onOrAfter: Self.date(year, 6, 20, calendar), calendar)] = "Juhannuspäivä"
            days[Self.saturday(onOrAfter: Self.date(year, 10, 31, calendar), calendar)] = "Pyhäinpäivä"
            fix(12, 6, "Itsenäisyyspäivä")
            fix(12, 25, "Joulupäivä")
            fix(12, 26, "Tapaninpäivä")

        case .france:
            fix(1, 1, "Jour de l'an")
            easterRel(1, "Lundi de Pâques")
            fix(5, 1, "Fête du Travail")
            fix(5, 8, "Victoire 1945")
            easterRel(39, "Ascension")
            easterRel(50, "Lundi de Pentecôte")
            fix(7, 14, "Fête nationale")
            fix(8, 15, "Assomption")
            fix(11, 1, "Toussaint")
            fix(11, 11, "Armistice 1918")
            fix(12, 25, "Noël")

        case .germany:
            fix(1, 1, "Neujahr")
            easterRel(-2, "Karfreitag")
            easterRel(1, "Ostermontag")
            fix(5, 1, "Tag der Arbeit")
            easterRel(39, "Christi Himmelfahrt")
            easterRel(50, "Pfingstmontag")
            fix(10, 3, "Tag der Deutschen Einheit")
            fix(12, 25, "1. Weihnachtstag")
            fix(12, 26, "2. Weihnachtstag")

        case .italy:
            fix(1, 1, "Capodanno")
            fix(1, 6, "Epifania")
            easterRel(0, "Pasqua")
            easterRel(1, "Lunedì dell'Angelo")
            fix(4, 25, "Festa della Liberazione")
            fix(5, 1, "Festa del Lavoro")
            fix(6, 2, "Festa della Repubblica")
            fix(8, 15, "Ferragosto")
            fix(11, 1, "Tutti i santi")
            fix(12, 8, "Immacolata Concezione")
            fix(12, 25, "Natale")
            fix(12, 26, "Santo Stefano")

        case .netherlands:
            fix(1, 1, "Nieuwjaarsdag")
            easterRel(-2, "Goede Vrijdag")
            easterRel(0, "Eerste paasdag")
            easterRel(1, "Tweede paasdag")
            // Koningsdag firas 26 april när 27 april är en söndag.
            var kingsDay = Self.date(year, 4, 27, calendar)
            if calendar.component(.weekday, from: kingsDay) == 1 {
                kingsDay = Self.adding(-1, to: kingsDay, calendar)
            }
            days[kingsDay] = "Koningsdag"
            fix(5, 5, "Bevrijdingsdag")
            easterRel(39, "Hemelvaartsdag")
            easterRel(49, "Eerste pinksterdag")
            easterRel(50, "Tweede pinksterdag")
            fix(12, 25, "Eerste kerstdag")
            fix(12, 26, "Tweede kerstdag")

        case .norway:
            fix(1, 1, "Første nyttårsdag")
            easterRel(-3, "Skjærtorsdag")
            easterRel(-2, "Langfredag")
            easterRel(0, "Første påskedag")
            easterRel(1, "Andre påskedag")
            fix(5, 1, "Arbeidernes dag")
            fix(5, 17, "Grunnlovsdagen")
            easterRel(39, "Kristi himmelfartsdag")
            easterRel(49, "Første pinsedag")
            easterRel(50, "Andre pinsedag")
            fix(12, 25, "Første juledag")
            fix(12, 26, "Andre juledag")

        case .peru:
            fix(1, 1, "Año Nuevo")
            easterRel(-3, "Jueves Santo")
            easterRel(-2, "Viernes Santo")
            easterRel(0, "Domingo de Resurrección")
            fix(5, 1, "Día del Trabajo")
            fix(6, 7, "Batalla de Arica y Día de la Bandera")
            fix(6, 29, "San Pedro y San Pablo")
            fix(7, 23, "Día de la Fuerza Aérea del Perú")
            fix(7, 28, "Fiestas Patrias")
            fix(7, 29, "Fiestas Patrias")
            fix(8, 6, "Batalla de Junín")
            fix(8, 30, "Santa Rosa de Lima")
            fix(10, 8, "Combate de Angamos")
            fix(11, 1, "Todos los Santos")
            fix(12, 8, "Inmaculada Concepción")
            fix(12, 9, "Batalla de Ayacucho")
            fix(12, 25, "Navidad")

        case .portugal:
            fix(1, 1, "Ano Novo")
            easterRel(-2, "Sexta-feira Santa")
            easterRel(0, "Domingo de Páscoa")
            fix(4, 25, "Dia da Liberdade")
            fix(5, 1, "Dia do Trabalhador")
            easterRel(60, "Corpo de Deus")
            fix(6, 10, "Dia de Portugal")
            fix(8, 15, "Assunção de Nossa Senhora")
            fix(10, 5, "Implantação da República")
            fix(11, 1, "Dia de Todos os Santos")
            fix(12, 1, "Restauração da Independência")
            fix(12, 8, "Imaculada Conceição")
            fix(12, 25, "Natal")

        case .spain:
            fix(1, 1, "Año Nuevo")
            fix(1, 6, "Epifanía del Señor")
            easterRel(-2, "Viernes Santo")
            fix(5, 1, "Fiesta del Trabajo")
            fix(8, 15, "Asunción de la Virgen")
            fix(10, 12, "Fiesta Nacional de España")
            fix(11, 1, "Todos los Santos")
            fix(12, 6, "Día de la Constitución")
            fix(12, 8, "Inmaculada Concepción")
            fix(12, 25, "Navidad")

        case .unitedKingdom:
            // England & Wales bank holidays.
            fix(1, 1, "New Year's Day")
            easterRel(-2, "Good Friday")
            easterRel(1, "Easter Monday")
            days[Self.nthWeekday(1, weekday: 2, month: 5, year: year, calendar)] = "Early May Bank Holiday"
            days[Self.lastWeekday(2, month: 5, year: year, calendar)] = "Spring Bank Holiday"
            days[Self.lastWeekday(2, month: 8, year: year, calendar)] = "Summer Bank Holiday"
            fix(12, 25, "Christmas Day")
            fix(12, 26, "Boxing Day")

        case .unitedStates:
            fix(1, 1, "New Year's Day")
            days[Self.nthWeekday(3, weekday: 2, month: 1, year: year, calendar)] = "Martin Luther King Jr. Day"
            days[Self.nthWeekday(3, weekday: 2, month: 2, year: year, calendar)] = "Presidents' Day"
            days[Self.lastWeekday(2, month: 5, year: year, calendar)] = "Memorial Day"
            fix(6, 19, "Juneteenth")
            fix(7, 4, "Independence Day")
            days[Self.nthWeekday(1, weekday: 2, month: 9, year: year, calendar)] = "Labor Day"
            days[Self.nthWeekday(2, weekday: 2, month: 10, year: year, calendar)] = "Columbus Day"
            fix(11, 11, "Veterans Day")
            days[Self.nthWeekday(4, weekday: 5, month: 11, year: year, calendar)] = "Thanksgiving"
            fix(12, 25, "Christmas Day")

        case .noHolidays:
            break
        }
        return days
    }

    /// De facto-aftnar (visas i annan färg): inte formella helgdagar men
    /// dagar då det mesta stänger tidigt eller helt.
    func eves(year: Int, calendar: Calendar) -> [Date: String] {
        var days: [Date: String] = [:]
        func fix(_ month: Int, _ day: Int, _ name: String) {
            days[Self.date(year, month, day, calendar)] = name
        }

        switch self {
        case .sweden:
            days[Self.adding(-1, to: Self.saturday(
                onOrAfter: Self.date(year, 6, 20, calendar), calendar), calendar)] = "Midsommarafton"
            fix(12, 24, "Julafton")
            fix(12, 31, "Nyårsafton")
        case .finland:
            days[Self.adding(-1, to: Self.saturday(
                onOrAfter: Self.date(year, 6, 20, calendar), calendar), calendar)] = "Juhannusaatto"
            fix(12, 24, "Jouluaatto")
            fix(12, 31, "Uudenvuodenaatto")
        case .denmark:
            // Grundlovsdag är formellt halvdag men de facto ledig.
            fix(6, 5, "Grundlovsdag")
            fix(12, 24, "Juleaften")
            fix(12, 31, "Nytårsaften")
        case .norway:
            fix(12, 24, "Julaften")
            fix(12, 31, "Nyttårsaften")
        case .germany:
            fix(12, 24, "Heiligabend")
            fix(12, 31, "Silvester")
        case .netherlands:
            fix(12, 24, "Kerstavond")
            fix(12, 31, "Oudejaarsavond")
        case .france:
            fix(12, 24, "Réveillon de Noël")
            fix(12, 31, "Saint-Sylvestre")
        case .italy:
            fix(12, 24, "Vigilia di Natale")
            fix(12, 31, "San Silvestro")
        case .spain, .peru:
            fix(12, 24, "Nochebuena")
            fix(12, 31, "Nochevieja")
        case .portugal:
            fix(12, 24, "Véspera de Natal")
            fix(12, 31, "Véspera de Ano Novo")
        case .unitedKingdom, .unitedStates:
            fix(12, 24, "Christmas Eve")
            fix(12, 31, "New Year's Eve")
        case .noHolidays:
            break
        }
        return days
    }

    /// Namnet på helgdagen eller aftonen ett visst datum, annars nil.
    func name(for date: Date, calendar: Calendar) -> String? {
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

    /// N:te förekomsten av en veckodag i en månad (weekday: 1=sön…7=lör).
    static func nthWeekday(_ n: Int, weekday: Int, month: Int, year: Int, _ calendar: Calendar) -> Date {
        var day = date(year, month, 1, calendar)
        while calendar.component(.weekday, from: day) != weekday {
            day = adding(1, to: day, calendar)
        }
        return adding(7 * (n - 1), to: day, calendar)
    }

    /// Sista förekomsten av en veckodag i en månad.
    static func lastWeekday(_ weekday: Int, month: Int, year: Int, _ calendar: Calendar) -> Date {
        let firstOfNext = month == 12
            ? date(year + 1, 1, 1, calendar)
            : date(year, month + 1, 1, calendar)
        var day = adding(-1, to: firstOfNext, calendar)
        while calendar.component(.weekday, from: day) != weekday {
            day = adding(-1, to: day, calendar)
        }
        return day
    }

    static func saturday(onOrAfter start: Date, _ calendar: Calendar) -> Date {
        var day = start
        while calendar.component(.weekday, from: day) != 7 {
            day = adding(1, to: day, calendar)
        }
        return day
    }

    static func date(_ year: Int, _ month: Int, _ day: Int, _ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    static func adding(_ days: Int, to date: Date, _ calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: days, to: date)!
    }
}
