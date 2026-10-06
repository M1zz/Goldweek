//
//  WorldHolidays.swift
//  Goldweek
//
//  한·일·중·미·독·프 밖의 나라 공휴일과, 주·지역별 공휴일.
//
//  - 날짜 규칙(n번째 월요일, 부활절 기준, 음력)으로 계산하므로 연도 제한이 없다.
//    음력은 시스템 중국력(`Calendar(identifier: .chinese)`)으로 푼다 — 대만·홍콩과 같은 UTC+8 기준.
//  - 지역 공휴일은 **법정 공휴일** 기준이다. 회사 휴무와 다를 수 있어 사용자가
//    공휴일 관리에서 숨기거나 더할 수 있다. 스페인 자치주 공휴일은 해마다 관보로 바뀌므로
//    해마다 반복되는 날만 넣었다.
//

import Foundation

// MARK: - 이름표

/// 공휴일 이름 — 현재 앱 언어로 고르고, 없으면 영어, 그것도 없으면 현지 이름.
struct HolidayName {
    let names: [AppLanguage: String]

    init(ko: String, en: String, ja: String? = nil, zh: String? = nil, de: String? = nil, fr: String? = nil,
         es: String? = nil, it: String? = nil, pt: String? = nil, zht: String? = nil) {
        var n: [AppLanguage: String] = [.korean: ko, .english: en]
        n[.japanese] = ja; n[.chinese] = zh; n[.german] = de; n[.french] = fr
        n[.spanish] = es; n[.italian] = it; n[.portuguese] = pt; n[.chineseTraditional] = zht
        names = n
    }

    var text: String {
        names[AppLanguage.current] ?? names[.english]!
    }
}

private typealias N = HolidayName

// 여러 나라가 같이 쓰는 이름
private enum Common {
    static let newYear = N(ko: "신정", en: "New Year's Day", ja: "元日", zh: "元旦", de: "Neujahr", fr: "Jour de l’an",
                           es: "Año Nuevo", it: "Capodanno", pt: "Confraternização Universal", zht: "元旦")
    static let goodFriday = N(ko: "성금요일", en: "Good Friday", ja: "聖金曜日", zh: "耶稣受难日", de: "Karfreitag", fr: "Vendredi saint",
                              es: "Viernes Santo", it: "Venerdì Santo", pt: "Sexta-feira Santa", zht: "耶穌受難節")
    static let holySaturday = N(ko: "부활절 전 토요일", en: "Easter Saturday", ja: "聖土曜日", zh: "复活节前夕", de: "Karsamstag", fr: "Samedi saint",
                                es: "Sábado Santo", it: "Sabato Santo", pt: "Sábado de Aleluia", zht: "耶穌受難節翌日")
    static let easterMonday = N(ko: "부활절 월요일", en: "Easter Monday", ja: "イースターマンデー", zh: "复活节星期一", de: "Ostermontag", fr: "Lundi de Pâques",
                                es: "Lunes de Pascua", it: "Lunedì dell’Angelo", pt: "Segunda-feira de Páscoa", zht: "復活節星期一")
    static let labour = N(ko: "노동절", en: "Labour Day", ja: "メーデー", zh: "劳动节", de: "Tag der Arbeit", fr: "Fête du Travail",
                          es: "Día del Trabajador", it: "Festa dei Lavoratori", pt: "Dia do Trabalhador", zht: "勞動節")
    static let christmas = N(ko: "크리스마스", en: "Christmas Day", ja: "クリスマス", zh: "圣诞节", de: "1. Weihnachtstag", fr: "Noël",
                             es: "Navidad", it: "Natale", pt: "Natal", zht: "聖誕節")
    static let boxing = N(ko: "박싱 데이", en: "Boxing Day", ja: "ボクシング・デー", zh: "节礼日", de: "2. Weihnachtstag", fr: "Lendemain de Noël",
                          es: "San Esteban", it: "Santo Stefano", pt: "Boxing Day", zht: "節禮日")
    static let assumption = N(ko: "성모승천일", en: "Assumption Day", ja: "聖母被昇天祭", zh: "圣母升天节", de: "Mariä Himmelfahrt", fr: "Assomption",
                              es: "Asunción de la Virgen", it: "Ferragosto", pt: "Assunção de Nossa Senhora", zht: "聖母升天節")
    static let allSaints = N(ko: "만성절", en: "All Saints' Day", ja: "諸聖人の日", zh: "诸圣节", de: "Allerheiligen", fr: "Toussaint",
                             es: "Todos los Santos", it: "Ognissanti", pt: "Dia de Todos os Santos", zht: "諸聖節")
    static let epiphany = N(ko: "주현절", en: "Epiphany", ja: "公現祭", zh: "主显节", de: "Heilige Drei Könige", fr: "Épiphanie",
                            es: "Epifanía del Señor", it: "Epifania", pt: "Dia de Reis", zht: "主顯節")
    static let corpusChristi = N(ko: "성체 축일", en: "Corpus Christi", ja: "聖体の祝日", zh: "基督圣体节", de: "Fronleichnam", fr: "Fête-Dieu",
                                 es: "Corpus Christi", it: "Corpus Domini", pt: "Corpus Christi", zht: "基督聖體節")
    static let immaculate = N(ko: "원죄 없는 잉태 대축일", en: "Immaculate Conception", ja: "無原罪の聖母", zh: "圣母无原罪瞻礼", de: "Mariä Empfängnis", fr: "Immaculée Conception",
                              es: "Inmaculada Concepción", it: "Immacolata Concezione", pt: "Imaculada Conceição", zht: "聖母無原罪始胎節")
    static let stStephen = N(ko: "성 스테파노 축일", en: "St. Stephen's Day", ja: "聖ステファノの日", zh: "圣斯德望日", de: "Stephanstag", fr: "Saint-Étienne",
                             es: "Sant Esteve", it: "Santo Stefano", pt: "Dia de Santo Estêvão", zht: "聖斯德望日")
    static let stJohn = N(ko: "성 요한 축일", en: "St. John's Day", ja: "聖ヨハネの日", zh: "圣约翰节", de: "Johannistag", fr: "Saint-Jean",
                          es: "San Juan", it: "San Giovanni", pt: "Dia de São João", zht: "聖約翰節")
    static let stJoseph = N(ko: "성 요셉 축일", en: "St. Joseph's Day", ja: "聖ヨセフの日", zh: "圣若瑟节", de: "Josefstag", fr: "Saint-Joseph",
                            es: "San José", it: "San Giuseppe", pt: "Dia de São José", zht: "聖若瑟節")
    static let maundyThursday = N(ko: "성목요일", en: "Maundy Thursday", ja: "聖木曜日", zh: "濯足节", de: "Gründonnerstag", fr: "Jeudi saint",
                                  es: "Jueves Santo", it: "Giovedì Santo", pt: "Quinta-feira Santa", zht: "濯足節")
    static let thanksgiving = N(ko: "추수감사절", en: "Thanksgiving", ja: "感謝祭", zh: "感恩节", de: "Erntedankfest", fr: "Action de grâce",
                                es: "Acción de Gracias", it: "Ringraziamento", pt: "Ação de Graças", zht: "感恩節")
    static let remembrance = N(ko: "현충일", en: "Remembrance Day", ja: "リメンブランス・デー", zh: "阵亡将士纪念日", de: "Gedenktag", fr: "Jour du Souvenir",
                               es: "Día del Recuerdo", it: "Giorno del Ricordo", pt: "Dia da Lembrança", zht: "國殤紀念日")
    static let kingsBirthday = N(ko: "국왕 탄신일", en: "King's Birthday", ja: "国王誕生日", zh: "国王诞辰", de: "Geburtstag des Königs", fr: "Anniversaire du roi",
                                 es: "Cumpleaños del Rey", it: "Compleanno del Re", pt: "Aniversário do Rei", zht: "英王壽辰")
    static let dayAfterThanksgiving = N(ko: "추수감사절 다음 날", en: "Day after Thanksgiving", ja: "感謝祭翌日", zh: "感恩节翌日", de: "Tag nach Thanksgiving", fr: "Lendemain de Thanksgiving",
                                        es: "Día después de Acción de Gracias", it: "Giorno dopo il Ringraziamento", pt: "Dia após Ação de Graças", zht: "感恩節翌日")
    static let christmasEve = N(ko: "크리스마스 이브", en: "Christmas Eve", ja: "クリスマス・イブ", zh: "平安夜", de: "Heiligabend", fr: "Veille de Noël",
                                es: "Nochebuena", it: "Vigilia di Natale", pt: "Véspera de Natal", zht: "平安夜")
    static let nationalDay = N(ko: "국경일", en: "National Day", ja: "国慶節", zh: "国庆日", de: "Nationalfeiertag", fr: "Fête nationale",
                               es: "Fiesta Nacional", it: "Festa nazionale", pt: "Dia Nacional", zht: "國慶日")

    /// 대체 휴일 표기 — "Christmas Day (substitute day)"
    static var substitute: String {
        switch AppLanguage.current {
        case .korean: return "대체 휴일"
        case .english: return "substitute day"
        case .japanese: return "振替休日"
        case .chinese: return "补休"
        case .german: return "Ersatztag"
        case .french: return "jour de remplacement"
        case .spanish: return "trasladado"
        case .italian: return "sostitutivo"
        case .portuguese: return "transferido"
        case .chineseTraditional: return "補假"
        }
    }
}

extension HolidayService {

    // MARK: - 날짜 헬퍼

    fileprivate func day(_ year: Int, _ month: Int, _ day: Int) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    fileprivate func weekday(_ date: Date) -> Int {
        calendar.component(.weekday, from: date)
    }

    fileprivate func isWeekend(_ date: Date) -> Bool {
        let w = weekday(date)
        return w == 1 || w == 7
    }

    fileprivate func adding(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: date)!
    }

    /// 그 날짜 이전(당일 포함)의 가장 가까운 특정 요일 — 캐나다 빅토리아 데이(5/24 이전 월요일) 등
    fileprivate func weekday(_ target: Int, onOrBefore date: Date) -> Date {
        var offset = weekday(date) - target
        if offset < 0 { offset += 7 }
        return adding(-offset, to: date)
    }

    /// 그 날짜 이후(당일 포함)의 가장 가까운 특정 요일
    fileprivate func weekday(_ target: Int, onOrAfter date: Date) -> Date {
        var offset = target - weekday(date)
        if offset < 0 { offset += 7 }
        return adding(offset, to: date)
    }

    fileprivate func easter(_ year: Int) -> Date? {
        Self.easterSunday(year: year, calendar: calendar)
    }

    /// 음력 날짜 → 양력. 대만·홍콩 기준(UTC+8) 중국력으로 푼다.
    /// 음력 1~9월은 모두 같은 양력 해에 떨어진다(설날이 1~2월이므로).
    fileprivate func lunar(_ year: Int, month: Int, day: Int) -> Date? {
        var chinese = Calendar(identifier: .chinese)
        var gregorian = Calendar(identifier: .gregorian)
        guard let tz = TimeZone(identifier: "Asia/Hong_Kong") else { return nil }
        chinese.timeZone = tz
        gregorian.timeZone = tz
        guard let mid = gregorian.date(from: DateComponents(year: year, month: 7, day: 1)) else { return nil }
        var comps = chinese.dateComponents([.era, .year], from: mid)
        comps.month = month
        comps.day = day
        comps.isLeapMonth = false
        guard let date = chinese.date(from: comps) else { return nil }
        let g = gregorian.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: DateComponents(year: g.year, month: g.month, day: g.day))
    }

    /// 청명 (태양력 절기) — 21세기 근사식. 2024~2032 실제 날짜와 일치 확인.
    fileprivate func qingming(_ year: Int) -> Date? {
        let y = Double(year % 100)
        let d = Int(floor(y * 0.2422 + 4.81)) - Int(floor(y / 4))
        return day(year, 4, d)
    }

    /// 주말에 걸린 공휴일을 다음 평일로 미룬다 (영국·호주·캐나다식).
    /// `substitutable` 에 든 날만 옮기고, 이미 쉬는 날은 피해 간다 — 날짜 순서대로 처리한다.
    fileprivate func rollForward(_ holidays: [Holiday], substitutable: Set<String>, saturdayToo: Bool = true) -> [Holiday] {
        var taken = Set(holidays.map { dateKey($0.date) })
        var result: [Holiday] = []
        for h in holidays.sorted(by: { $0.date < $1.date }) where substitutable.contains(dateKey(h.date)) {
            let w = weekday(h.date)
            guard w == 1 || (saturdayToo && w == 7) else { continue }
            var d = adding(1, to: h.date)
            while isWeekend(d) || taken.contains(dateKey(d)) { d = adding(1, to: d) }
            taken.insert(dateKey(d))
            result.append(Holiday(date: d, name: "\(h.name) (\(Common.substitute))", isSubstitute: true))
        }
        return result
    }

    // MARK: - 독일 주(Bundesland) 공휴일

    func germanStateHolidays(for year: Int, region: String?, easter: Date) -> [Holiday] {
        guard let region else { return [] }
        var list: [(Date?, N)] = []
        let womensDay = N(ko: "세계 여성의 날", en: "International Women's Day", ja: "国際女性デー", zh: "国际妇女节", de: "Internationaler Frauentag", fr: "Journée internationale des femmes",
                          es: "Día Internacional de la Mujer", it: "Giornata internazionale della donna", pt: "Dia Internacional da Mulher", zht: "國際婦女節")
        let childrensDay = N(ko: "세계 어린이날", en: "World Children's Day", ja: "世界子どもの日", zh: "世界儿童日", de: "Weltkindertag", fr: "Journée mondiale de l’enfance",
                             es: "Día Mundial del Niño", it: "Giornata mondiale dell’infanzia", pt: "Dia Mundial da Criança", zht: "世界兒童日")
        let reformation = N(ko: "종교개혁일", en: "Reformation Day", ja: "宗教改革記念日", zh: "宗教改革日", de: "Reformationstag", fr: "Jour de la Réformation",
                            es: "Día de la Reforma", it: "Festa della Riforma", pt: "Dia da Reforma", zht: "宗教改革紀念日")
        let repentance = N(ko: "참회와 기도의 날", en: "Day of Repentance and Prayer", ja: "贖罪と祈りの日", zh: "忏悔祈祷日", de: "Buß- und Bettag", fr: "Jour de pénitence et de prière",
                           es: "Día de Penitencia y Oración", it: "Giorno di penitenza e preghiera", pt: "Dia de Arrependimento e Oração", zht: "懺悔祈禱日")

        let epiphany: [String] = ["DE-BW", "DE-BY", "DE-ST"]
        let corpus: [String] = ["DE-BW", "DE-BY", "DE-HE", "DE-NW", "DE-RP", "DE-SL"]
        let assumption: [String] = ["DE-BY", "DE-SL"]   // 바이에른은 가톨릭 지역(대부분)만
        let reformationStates: [String] = ["DE-BB", "DE-HB", "DE-HH", "DE-MV", "DE-NI", "DE-SN", "DE-ST", "DE-SH", "DE-TH"]
        let allSaints: [String] = ["DE-BW", "DE-BY", "DE-NW", "DE-RP", "DE-SL"]

        if epiphany.contains(region) { list.append((day(year, 1, 6), Common.epiphany)) }
        if region == "DE-BE" || (region == "DE-MV" && year >= 2023) { list.append((day(year, 3, 8), womensDay)) }
        if corpus.contains(region) { list.append((adding(60, to: easter), Common.corpusChristi)) }
        if assumption.contains(region) { list.append((day(year, 8, 15), Common.assumption)) }
        if region == "DE-TH" { list.append((day(year, 9, 20), childrensDay)) }
        if reformationStates.contains(region) { list.append((day(year, 10, 31), reformation)) }
        if allSaints.contains(region) { list.append((day(year, 11, 1), Common.allSaints)) }
        // 참회와 기도의 날: 11월 23일 이전의 마지막 수요일 (작센)
        if region == "DE-SN", let nov22 = day(year, 11, 22) {
            list.append((weekday(4, onOrBefore: nov22), repentance))
        }
        return list.compactMap { d, n in d.map { Holiday(date: $0, name: n.text) } }
    }

    // MARK: - 미국 주 공휴일

    /// 연방 공휴일에 더할 주 공휴일. `fixedDays` 는 주말이면 대체일을 두는 고정 날짜.
    func usStateHolidays(for year: Int, region: String?) -> (holidays: [Holiday], fixedDays: [(Int, Int)], dropsColumbusDay: Bool) {
        guard let region else { return ([], [], false) }
        var list: [(Date?, N)] = []
        var fixed: [(Int, Int)] = []
        func fixedDay(_ m: Int, _ d: Int, _ n: N) { list.append((day(year, m, d), n)); fixed.append((m, d)) }
        let thanksgiving = nthWeekday(nth: 4, weekday: 5, month: 11, year: year)
        func dayAfterThanksgiving() {
            if let t = thanksgiving { list.append((adding(1, to: t), Common.dayAfterThanksgiving)) }
        }
        let lincoln = N(ko: "링컨 탄생일", en: "Lincoln's Birthday", ja: "リンカーン誕生日", zh: "林肯诞辰", de: "Lincolns Geburtstag", fr: "Anniversaire de Lincoln",
                        es: "Natalicio de Lincoln", it: "Compleanno di Lincoln", pt: "Aniversário de Lincoln", zht: "林肯誕辰")
        let patriots = N(ko: "애국자의 날", en: "Patriots' Day", ja: "愛国者の日", zh: "爱国者日", de: "Patriots’ Day", fr: "Jour des Patriotes",
                         es: "Día de los Patriotas", it: "Giorno dei Patrioti", pt: "Dia dos Patriotas", zht: "愛國者日")

        switch region {
        case "US-AK":
            if let d = lastWeekday(weekday: 2, month: 3, year: year) {
                list.append((d, N(ko: "수어드의 날", en: "Seward's Day", zh: "西华德日", zht: "西華德日")))
            }
            fixedDay(10, 18, N(ko: "알래스카의 날", en: "Alaska Day", ja: "アラスカ・デー", zh: "阿拉斯加日", zht: "阿拉斯加日"))
        case "US-CA":
            fixedDay(3, 31, N(ko: "세사르 차베스의 날", en: "César Chávez Day", zh: "塞萨尔·查韦斯日", es: "Día de César Chávez", zht: "凱薩·查維斯日"))
            dayAfterThanksgiving()
        case "US-DC":
            fixedDay(4, 16, N(ko: "해방 기념일", en: "DC Emancipation Day", zh: "解放日", es: "Día de la Emancipación", zht: "解放日"))
            // 대통령 취임일 (4년마다 1월 20일)
            if year % 4 == 1 { fixedDay(1, 20, N(ko: "대통령 취임일", en: "Inauguration Day", ja: "大統領就任式", zh: "总统就职日", zht: "總統就職日")) }
        case "US-FL", "US-WA":
            dayAfterThanksgiving()
        case "US-HI":
            fixedDay(3, 26, N(ko: "쿠히오 왕자의 날", en: "Prince Kūhiō Day", zh: "库希奥王子日", zht: "庫希奧王子日"))
            fixedDay(6, 11, N(ko: "카메하메하 대왕의 날", en: "King Kamehameha Day", ja: "カメハメハ大王の日", zh: "卡美哈梅哈国王日", zht: "卡美哈梅哈國王日"))
            if let d = nthWeekday(nth: 3, weekday: 6, month: 8, year: year) {
                list.append((d, N(ko: "하와이 주 승격 기념일", en: "Statehood Day", ja: "州昇格記念日", zh: "建州日", zht: "建州紀念日")))
            }
            if let e = easter(year) { list.append((adding(-2, to: e), Common.goodFriday)) }
        case "US-IL":
            fixedDay(2, 12, lincoln)
            dayAfterThanksgiving()
        case "US-LA":
            if let e = easter(year) {
                list.append((adding(-47, to: e), N(ko: "마르디 그라", en: "Mardi Gras", ja: "マルディグラ", zh: "狂欢节", fr: "Mardi gras",
                                                     es: "Martes de Carnaval", it: "Martedì grasso", pt: "Terça-feira de Carnaval", zht: "懺悔星期二")))
                list.append((adding(-2, to: e), Common.goodFriday))
            }
        case "US-ME", "US-MA":
            if let d = nthWeekday(nth: 3, weekday: 2, month: 4, year: year) { list.append((d, patriots)) }
            if region == "US-ME" { dayAfterThanksgiving() }
        case "US-NY":
            fixedDay(2, 12, lincoln)
            // 선거일: 11월 첫 월요일 다음 화요일
            if let firstMonday = nthWeekday(nth: 1, weekday: 2, month: 11, year: year) {
                list.append((adding(1, to: firstMonday), N(ko: "선거일", en: "Election Day", ja: "選挙日", zh: "选举日", zht: "選舉日")))
            }
        case "US-TX":
            dayAfterThanksgiving()
            fixedDay(12, 24, Common.christmasEve)
            fixedDay(12, 26, N(ko: "크리스마스 다음 날", en: "Day after Christmas", ja: "クリスマス翌日", zh: "圣诞节翌日", zht: "聖誕節翌日"))
        default:
            break
        }
        let holidays = list.compactMap { d, n in d.map { Holiday(date: $0, name: n.text) } }
        return (holidays, fixed, region == "US-HI")
    }

    // MARK: - 영국

    func getUKHolidays(for year: Int, region: String?) -> [Holiday] {
        let region = region ?? "GB-ENG"   // 기본은 잉글랜드·웨일스 (인구 대부분)
        var list: [(Date?, N)] = []
        let earlyMay = N(ko: "5월 초 공휴일", en: "Early May bank holiday", ja: "5月初めのバンクホリデー", zh: "五月初银行假日", de: "Bankfeiertag Anfang Mai", fr: "Jour férié de début mai",
                         es: "Festivo de principios de mayo", it: "Festività di inizio maggio", pt: "Feriado bancário do início de maio", zht: "五月初銀行假日")
        let spring = N(ko: "봄 공휴일", en: "Spring bank holiday", ja: "春のバンクホリデー", zh: "春季银行假日", de: "Bankfeiertag im Frühling", fr: "Jour férié de printemps",
                       es: "Festivo de primavera", it: "Festività di primavera", pt: "Feriado bancário da primavera", zht: "春季銀行假日")
        let summer = N(ko: "여름 공휴일", en: "Summer bank holiday", ja: "夏のバンクホリデー", zh: "夏季银行假日", de: "Bankfeiertag im Sommer", fr: "Jour férié d’été",
                       es: "Festivo de verano", it: "Festività estiva", pt: "Feriado bancário de verão", zht: "夏季銀行假日")

        list.append((day(year, 1, 1), Common.newYear))
        if region == "GB-SCT" {
            list.append((day(year, 1, 2), N(ko: "1월 2일 공휴일", en: "2nd January", ja: "1月2日", zh: "1月2日假期", de: "2. Januar", fr: "2 janvier",
                                            es: "2 de enero", it: "2 gennaio", pt: "2 de janeiro", zht: "1月2日假期")))
        }
        if region == "GB-NIR" {
            list.append((day(year, 3, 17), N(ko: "성 패트릭의 날", en: "St Patrick's Day", ja: "聖パトリックの祝日", zh: "圣帕特里克节", de: "St. Patrick’s Day", fr: "Saint-Patrick",
                                             es: "Día de San Patricio", it: "Festa di San Patrizio", pt: "Dia de São Patrício", zht: "聖派翠克節")))
        }
        if let e = easter(year) {
            list.append((adding(-2, to: e), Common.goodFriday))
            if region != "GB-SCT" { list.append((adding(1, to: e), Common.easterMonday)) }
        }
        // 일회성 변경: 2020 VE데이 이동, 2022 여왕 즉위 70주년·장례, 2023 대관식
        switch year {
        case 2020: list.append((day(2020, 5, 8), earlyMay))
        case 2022:
            list.append((nthWeekday(nth: 1, weekday: 2, month: 5, year: year), earlyMay))
            list.append((day(2022, 6, 2), spring))
            list.append((day(2022, 6, 3), N(ko: "여왕 즉위 70주년", en: "Platinum Jubilee bank holiday", zh: "白金禧假日", zht: "白金禧假日")))
            list.append((day(2022, 9, 19), N(ko: "엘리자베스 2세 국장", en: "State Funeral of Queen Elizabeth II", zh: "伊丽莎白二世国葬", zht: "伊莉莎白二世國葬")))
        default:
            list.append((nthWeekday(nth: 1, weekday: 2, month: 5, year: year), earlyMay))
        }
        if year == 2023 { list.append((day(2023, 5, 8), N(ko: "국왕 대관식", en: "Coronation of King Charles III", zh: "查尔斯三世加冕", zht: "查爾斯三世加冕")) ) }
        if year != 2022 { list.append((lastWeekday(weekday: 2, month: 5, year: year), spring)) }
        if region == "GB-NIR" {
            list.append((day(year, 7, 12), N(ko: "보인 전투 기념일", en: "Battle of the Boyne (Orangemen's Day)", zh: "博因河战役纪念日", zht: "博因河戰役紀念日")))
        }
        if region == "GB-SCT" {
            list.append((nthWeekday(nth: 1, weekday: 2, month: 8, year: year), summer))
        } else {
            list.append((lastWeekday(weekday: 2, month: 8, year: year), summer))
        }
        if region == "GB-SCT" {
            list.append((day(year, 11, 30), N(ko: "성 앤드루의 날", en: "St Andrew's Day", ja: "聖アンデレの日", zh: "圣安德鲁日", de: "Andreastag", fr: "Saint-André",
                                              es: "Día de San Andrés", it: "Festa di Sant’Andrea", pt: "Dia de Santo André", zht: "聖安德魯日")))
        }
        list.append((day(year, 12, 25), Common.christmas))
        list.append((day(year, 12, 26), Common.boxing))

        var holidays = list.compactMap { d, n in d.map { Holiday(date: $0, name: n.text) } }
        // 고정 날짜 공휴일이 주말이면 다음 평일에 쉰다
        let fixedKeys = Set(holidays.filter { h in
            let c = calendar.dateComponents([.month, .day], from: h.date)
            return [(1, 1), (1, 2), (3, 17), (7, 12), (11, 30), (12, 25), (12, 26)].contains { $0.0 == c.month && $0.1 == c.day }
        }.map { dateKey($0.date) })
        holidays += rollForward(holidays, substitutable: fixedKeys)
        return holidays.filter { calendar.component(.year, from: $0.date) == year }.sorted { $0.date < $1.date }
    }

    // MARK: - 캐나다

    func getCanadaHolidays(for year: Int, region: String?) -> [Holiday] {
        let e = easter(year)
        let victoriaDate = day(year, 5, 24).map { weekday(2, onOrBefore: $0) }
        let febMonday = nthWeekday(nth: 3, weekday: 2, month: 2, year: year)
        let augMonday = nthWeekday(nth: 1, weekday: 2, month: 8, year: year)

        let names: [String: N] = [
            "newYear": Common.newYear,
            "family": N(ko: "가족의 날", en: "Family Day", ja: "ファミリー・デー", zh: "家庭日", de: "Familientag", fr: "Jour de la famille",
                        es: "Día de la Familia", it: "Giornata della famiglia", pt: "Dia da Família", zht: "家庭日"),
            "louisRiel": N(ko: "루이 리엘의 날", en: "Louis Riel Day", zh: "路易·瑞尔日", fr: "Journée Louis Riel", zht: "路易·瑞爾日"),
            "heritage": N(ko: "헤리티지 데이", en: "Heritage Day", zh: "传统日", fr: "Jour du patrimoine", zht: "傳統日"),
            "islander": N(ko: "아일랜더 데이", en: "Islander Day", zh: "岛民日", fr: "Fête des Insulaires", zht: "島民日"),
            "goodFriday": Common.goodFriday,
            "easterMonday": Common.easterMonday,
            "victoria": N(ko: "빅토리아 데이", en: "Victoria Day", ja: "ビクトリア・デー", zh: "维多利亚日", de: "Victoria Day", fr: "Fête de la Reine",
                          es: "Día de Victoria", it: "Festa della Regina Vittoria", pt: "Dia da Rainha Vitória", zht: "維多利亞日"),
            "patriots": N(ko: "애국자의 날", en: "National Patriots' Day", zh: "国家爱国者日", fr: "Journée nationale des patriotes", zht: "國家愛國者日"),
            "stJean": N(ko: "퀘벡 국경일", en: "Fête nationale du Québec", zh: "魁北克国庆日", fr: "Fête nationale du Québec", zht: "魁北克國慶日"),
            "canada": N(ko: "캐나다 데이", en: "Canada Day", ja: "カナダ・デー", zh: "加拿大国庆日", de: "Canada Day", fr: "Fête du Canada",
                        es: "Día de Canadá", it: "Festa del Canada", pt: "Dia do Canadá", zht: "加拿大國慶日"),
            "bcDay": N(ko: "브리티시컬럼비아 데이", en: "British Columbia Day", zh: "卑诗省日", fr: "Jour de la Colombie-Britannique", zht: "卑詩省日"),
            "nbDay": N(ko: "뉴브런즈윅 데이", en: "New Brunswick Day", zh: "新不伦瑞克日", fr: "Fête du Nouveau-Brunswick", zht: "新伯倫瑞克日"),
            "skDay": N(ko: "서스캐처원 데이", en: "Saskatchewan Day", zh: "萨斯喀彻温日", fr: "Fête de la Saskatchewan", zht: "薩斯喀徹溫日"),
            "labour": N(ko: "노동절", en: "Labour Day", ja: "レイバー・デー", zh: "劳动节", de: "Tag der Arbeit", fr: "Fête du Travail",
                        es: "Día del Trabajo", it: "Festa del Lavoro", pt: "Dia do Trabalho", zht: "勞動節"),
            "truth": N(ko: "진실과 화해의 날", en: "National Day for Truth and Reconciliation", ja: "真実と和解の日", zh: "真相与和解日",
                       de: "Nationaler Tag der Wahrheit und Versöhnung", fr: "Journée nationale de la vérité et de la réconciliation",
                       es: "Día Nacional de la Verdad y la Reconciliación", it: "Giornata della verità e della riconciliazione",
                       pt: "Dia Nacional da Verdade e Reconciliação", zht: "真相與和解日"),
            "thanksgiving": Common.thanksgiving,
            "remembrance": Common.remembrance,
            "christmas": Common.christmas,
            "boxing": Common.boxing,
        ]
        let dates: [String: Date?] = [
            "newYear": day(year, 1, 1),
            "family": febMonday, "louisRiel": febMonday, "heritage": febMonday, "islander": febMonday,
            "goodFriday": e.map { adding(-2, to: $0) },
            "easterMonday": e.map { adding(1, to: $0) },
            "victoria": victoriaDate, "patriots": victoriaDate,
            "stJean": day(year, 6, 24),
            "canada": day(year, 7, 1),
            "bcDay": augMonday, "nbDay": augMonday, "skDay": augMonday,
            "labour": nthWeekday(nth: 1, weekday: 2, month: 9, year: year),
            "truth": year >= 2021 ? day(year, 9, 30) : nil,
            "thanksgiving": nthWeekday(nth: 2, weekday: 2, month: 10, year: year),
            "remembrance": day(year, 11, 11),
            "christmas": day(year, 12, 25),
            "boxing": day(year, 12, 26),
        ]
        // 주마다 법정 공휴일 (Employment Standards). 지역 미선택 = 연방 규정(Canada Labour Code).
        let keys: [String]
        switch region {
        case "CA-AB": keys = ["newYear", "family", "goodFriday", "victoria", "canada", "labour", "thanksgiving", "remembrance", "christmas"]
        case "CA-BC": keys = ["newYear", "family", "goodFriday", "victoria", "canada", "bcDay", "labour", "truth", "thanksgiving", "remembrance", "christmas"]
        case "CA-MB": keys = ["newYear", "louisRiel", "goodFriday", "victoria", "canada", "labour", "truth", "thanksgiving", "remembrance", "christmas"]
        case "CA-NB": keys = ["newYear", "family", "goodFriday", "canada", "nbDay", "labour", "remembrance", "christmas"]
        case "CA-NL": keys = ["newYear", "goodFriday", "canada", "labour", "remembrance", "christmas"]
        case "CA-NS": keys = ["newYear", "heritage", "goodFriday", "canada", "labour", "remembrance", "christmas"]
        case "CA-ON": keys = ["newYear", "family", "goodFriday", "victoria", "canada", "labour", "thanksgiving", "christmas", "boxing"]
        case "CA-PE": keys = ["newYear", "islander", "goodFriday", "canada", "labour", "truth", "remembrance", "christmas"]
        case "CA-QC": keys = ["newYear", "goodFriday", "easterMonday", "patriots", "stJean", "canada", "labour", "thanksgiving", "christmas"]
        case "CA-SK": keys = ["newYear", "family", "goodFriday", "victoria", "canada", "skDay", "labour", "thanksgiving", "remembrance", "christmas"]
        default: keys = ["newYear", "goodFriday", "victoria", "canada", "labour", "truth", "thanksgiving", "remembrance", "christmas", "boxing"]
        }
        var holidays: [Holiday] = keys.compactMap { k in
            guard let d = dates[k] ?? nil, let n = names[k] else { return nil }
            return Holiday(date: d, name: n.text)
        }
        let fixed: Set<String> = ["newYear", "stJean", "canada", "truth", "remembrance", "christmas", "boxing"]
        let fixedKeys = Set(keys.filter { fixed.contains($0) }.compactMap { (dates[$0] ?? nil).map(dateKey) })
        holidays += rollForward(holidays, substitutable: fixedKeys)
        return holidays.filter { calendar.component(.year, from: $0.date) == year }.sorted { $0.date < $1.date }
    }

    // MARK: - 호주

    func getAustraliaHolidays(for year: Int, region: String?) -> [Holiday] {
        var list: [(Date?, N, substitute: Bool)] = []
        func add(_ d: Date?, _ n: N, substitute: Bool = false) { list.append((d, n, substitute)) }
        let e = easter(year)
        let labour = N(ko: "노동절", en: "Labour Day", ja: "レイバー・デー", zh: "劳动节", de: "Tag der Arbeit", fr: "Fête du Travail",
                       es: "Día del Trabajo", it: "Festa del Lavoro", pt: "Dia do Trabalho", zht: "勞動節")

        add(day(year, 1, 1), Common.newYear, substitute: true)
        add(day(year, 1, 26), N(ko: "호주의 날", en: "Australia Day", ja: "オーストラリア・デー", zh: "澳大利亚国庆日", de: "Australia Day", fr: "Fête nationale australienne",
                                es: "Día de Australia", it: "Festa dell’Australia", pt: "Dia da Austrália", zht: "澳洲國慶日"), substitute: true)
        if let e {
            add(adding(-2, to: e), Common.goodFriday)
            // 부활절 토요일 — 태즈메이니아·서호주는 공휴일이 아니다
            if region != nil && region != "AU-TAS" && region != "AU-WA" { add(adding(-1, to: e), Common.holySaturday) }
            add(adding(1, to: e), Common.easterMonday)
        }
        add(day(year, 4, 25), N(ko: "안작 데이", en: "Anzac Day", ja: "アンザック・デー", zh: "澳新军团日", de: "Anzac Day", fr: "Anzac Day",
                                es: "Día de Anzac", it: "Anzac Day", pt: "Dia de Anzac", zht: "澳紐軍團日"), substitute: region == "AU-WA")

        // 국왕 탄신일: 대부분 6월 둘째 월요일, 퀸즐랜드 10월 첫 월요일, 서호주는 9월 마지막 월요일(주정부 공포)
        switch region {
        case "AU-QLD": add(nthWeekday(nth: 1, weekday: 2, month: 10, year: year), Common.kingsBirthday)
        case "AU-WA": add(lastWeekday(weekday: 2, month: 9, year: year), Common.kingsBirthday)
        default: add(nthWeekday(nth: 2, weekday: 2, month: 6, year: year), Common.kingsBirthday)
        }

        switch region {
        case "AU-NSW":
            add(nthWeekday(nth: 1, weekday: 2, month: 10, year: year), labour)
        case "AU-VIC":
            add(nthWeekday(nth: 2, weekday: 2, month: 3, year: year), labour)
            if let nov1 = day(year, 11, 1) {
                add(weekday(3, onOrAfter: nov1), N(ko: "멜버른 컵", en: "Melbourne Cup", ja: "メルボルンカップ", zh: "墨尔本杯赛马日", zht: "墨爾本盃賽馬日"))
            }
        case "AU-QLD":
            add(nthWeekday(nth: 1, weekday: 2, month: 5, year: year), labour)
        case "AU-SA":
            add(nthWeekday(nth: 2, weekday: 2, month: 3, year: year), N(ko: "애들레이드 컵", en: "Adelaide Cup", zh: "阿德莱德杯赛马日", zht: "阿德雷德盃賽馬日"))
            add(nthWeekday(nth: 1, weekday: 2, month: 10, year: year), labour)
        case "AU-WA":
            add(nthWeekday(nth: 1, weekday: 2, month: 3, year: year), labour)
            add(nthWeekday(nth: 1, weekday: 2, month: 6, year: year), N(ko: "서호주의 날", en: "Western Australia Day", zh: "西澳日", zht: "西澳日"))
        case "AU-TAS":
            add(nthWeekday(nth: 2, weekday: 2, month: 3, year: year), N(ko: "8시간 노동의 날", en: "Eight Hours Day", zh: "八小时工作日纪念日", zht: "八小時工作制紀念日"))
        case "AU-ACT":
            add(nthWeekday(nth: 2, weekday: 2, month: 3, year: year), N(ko: "캔버라 데이", en: "Canberra Day", zh: "堪培拉日", zht: "坎培拉日"))
            if let may27 = day(year, 5, 27), year >= 2018 {
                add(weekday(2, onOrAfter: may27), N(ko: "화해의 날", en: "Reconciliation Day", zh: "和解日", zht: "和解日"))
            }
            add(nthWeekday(nth: 1, weekday: 2, month: 10, year: year), labour)
        case "AU-NT":
            add(nthWeekday(nth: 1, weekday: 2, month: 5, year: year), N(ko: "메이 데이", en: "May Day", zh: "五一节", zht: "五一節"))
            add(nthWeekday(nth: 1, weekday: 2, month: 8, year: year), N(ko: "피크닉 데이", en: "Picnic Day", zh: "野餐日", zht: "野餐日"))
        default:
            break
        }

        add(day(year, 12, 25), Common.christmas, substitute: true)
        let boxing = region == "AU-SA"
            ? N(ko: "선포의 날", en: "Proclamation Day", zh: "宣言日", zht: "宣言日")
            : Common.boxing
        add(day(year, 12, 26), boxing, substitute: true)

        var holidays = list.compactMap { d, n, _ in d.map { Holiday(date: $0, name: n.text) } }
        let subKeys = Set(list.filter { $0.substitute }.compactMap { $0.0.map(dateKey) })
        holidays += rollForward(holidays, substitutable: subKeys)
        return holidays.filter { calendar.component(.year, from: $0.date) == year }.sorted { $0.date < $1.date }
    }

    // MARK: - 스페인

    func getSpainHolidays(for year: Int, region: String?) -> [Holiday] {
        var list: [(Date?, N)] = []
        let e = easter(year)
        // 전국 공휴일
        list.append((day(year, 1, 1), Common.newYear))
        list.append((day(year, 1, 6), Common.epiphany))
        if let e { list.append((adding(-2, to: e), Common.goodFriday)) }
        list.append((day(year, 5, 1), Common.labour))
        list.append((day(year, 8, 15), Common.assumption))
        list.append((day(year, 10, 12), N(ko: "스페인 국경일", en: "Hispanic Day", ja: "スペイン建国記念日", zh: "西班牙国庆日", de: "Spanischer Nationalfeiertag", fr: "Fête nationale espagnole",
                                          es: "Fiesta Nacional de España", it: "Festa nazionale spagnola", pt: "Dia Nacional da Espanha", zht: "西班牙國慶日")))
        list.append((day(year, 11, 1), Common.allSaints))
        list.append((day(year, 12, 6), N(ko: "제헌절", en: "Constitution Day", ja: "憲法記念日", zh: "宪法日", de: "Tag der Verfassung", fr: "Jour de la Constitution",
                                         es: "Día de la Constitución", it: "Giorno della Costituzione", pt: "Dia da Constituição", zht: "行憲紀念日")))
        list.append((day(year, 12, 8), Common.immaculate))
        list.append((day(year, 12, 25), Common.christmas))

        if let region, let official = Self.spainOfficialRegional[year]?[region] {
            // 관보(BOE)에 발표된 해는 그 표를 그대로 쓴다 — 자치주 공휴일은 해마다 바뀐다
            let names = spainRegionalNames()
            for (m, d, key) in official {
                list.append((day(year, m, d), names[key] ?? Common.nationalDay))
            }
        } else if let region {
            // 발표 전 연도: 해마다 반복되는 날로 추정
            // 성목요일: 카탈루냐·발렌시아 말고는 모두 쉰다
            if let e, region != "ES-CT", region != "ES-VC" { list.append((adding(-3, to: e), Common.maundyThursday)) }
            // 부활절 월요일
            if let e, ["ES-CT", "ES-VC", "ES-PV", "ES-NC", "ES-IB"].contains(region) { list.append((adding(1, to: e), Common.easterMonday)) }
            func fixed(_ m: Int, _ d: Int, _ n: N) { list.append((day(year, m, d), n)) }
            func regionalDay(_ local: String, ko: String, en: String) -> N { N(ko: ko, en: en, es: local) }
            switch region {
            case "ES-AN": fixed(2, 28, regionalDay("Día de Andalucía", ko: "안달루시아의 날", en: "Andalusia Day"))
            case "ES-AR": fixed(4, 23, regionalDay("Día de Aragón", ko: "아라곤의 날", en: "Aragon Day"))
            case "ES-AS": fixed(9, 8, regionalDay("Día de Asturias", ko: "아스투리아스의 날", en: "Asturias Day"))
            case "ES-IB":
                fixed(3, 1, regionalDay("Dia de les Illes Balears", ko: "발레아레스 제도의 날", en: "Balearic Islands Day"))
                fixed(12, 26, Common.stStephen)
            case "ES-CN": fixed(5, 30, regionalDay("Día de Canarias", ko: "카나리아 제도의 날", en: "Canary Islands Day"))
            case "ES-CB":
                fixed(7, 28, regionalDay("Día de las Instituciones de Cantabria", ko: "칸타브리아 제도의 날", en: "Cantabria Institutions Day"))
                fixed(9, 15, regionalDay("La Bien Aparecida", ko: "비엔 아파레시다 성모 축일", en: "Our Lady of Bien Aparecida"))
            case "ES-CL": fixed(4, 23, regionalDay("Día de Castilla y León", ko: "카스티야 이 레온의 날", en: "Castile and León Day"))
            case "ES-CM": fixed(5, 31, regionalDay("Día de Castilla-La Mancha", ko: "카스티야라만차의 날", en: "Castilla–La Mancha Day"))
            case "ES-CT":
                fixed(6, 24, Common.stJohn)
                fixed(9, 11, regionalDay("Diada Nacional de Catalunya", ko: "카탈루냐의 날", en: "National Day of Catalonia"))
                fixed(12, 26, Common.stStephen)
            case "ES-VC":
                fixed(3, 19, Common.stJoseph)
                fixed(6, 24, Common.stJohn)
                fixed(10, 9, regionalDay("Dia de la Comunitat Valenciana", ko: "발렌시아의 날", en: "Valencian Community Day"))
            case "ES-EX": fixed(9, 8, regionalDay("Día de Extremadura", ko: "에스트레마두라의 날", en: "Extremadura Day"))
            case "ES-GA":
                fixed(5, 17, regionalDay("Día das Letras Galegas", ko: "갈리시아 문학의 날", en: "Galician Literature Day"))
                fixed(7, 25, regionalDay("Día Nacional de Galicia", ko: "갈리시아의 날", en: "Galician National Day"))
            case "ES-MD": fixed(5, 2, regionalDay("Fiesta de la Comunidad de Madrid", ko: "마드리드 자치주의 날", en: "Community of Madrid Day"))
            case "ES-MC": fixed(6, 9, regionalDay("Día de la Región de Murcia", ko: "무르시아의 날", en: "Murcia Day"))
            case "ES-PV": fixed(7, 25, regionalDay("Santiago Apóstol", ko: "성 야고보 축일", en: "St. James' Day"))
            case "ES-RI": fixed(6, 9, regionalDay("Día de La Rioja", ko: "라리오하의 날", en: "La Rioja Day"))
            case "ES-CE": fixed(9, 2, regionalDay("Día de Ceuta", ko: "세우타의 날", en: "Ceuta Day"))
            default: break
            }
        }
        // 같은 날 겹치면 하나만 (예: 12/26)
        var seen = Set<String>()
        return list.compactMap { d, n -> Holiday? in
            guard let d, seen.insert(dateKey(d)).inserted else { return nil }
            return Holiday(date: d, name: n.text)
        }.sorted { $0.date < $1.date }
    }

    /// 스페인 자치주 공휴일 — 관보(BOE) 발표분. 전국 공휴일은 빼고 지역 몫만 적는다.
    /// 2026: BOE-A-2025-21667 (2025-10-17). 새 해 발표가 나오면 여기에 더한다.
    static let spainOfficialRegional: [Int: [String: [(Int, Int, String)]]] = [
        2026: [
            "ES-AN": [(2, 28, "andalucia"), (4, 2, "maundy"), (11, 2, "afterAllSaints")],
            "ES-AR": [(4, 2, "maundy"), (4, 23, "aragon"), (11, 2, "afterAllSaints"), (12, 7, "afterConstitution")],
            "ES-AS": [(4, 2, "maundy"), (9, 8, "asturias"), (11, 2, "afterAllSaints"), (12, 7, "afterConstitution")],
            "ES-IB": [(3, 2, "balears"), (4, 2, "maundy"), (4, 6, "easterMonday"), (12, 26, "stStephen")],
            "ES-CN": [(4, 2, "maundy"), (5, 30, "canarias"), (11, 2, "afterAllSaints")],
            "ES-CB": [(4, 2, "maundy"), (7, 28, "cantabria"), (9, 15, "bienAparecida"), (12, 7, "afterConstitution")],
            "ES-CM": [(4, 2, "maundy"), (4, 6, "easterMonday"), (6, 4, "corpus"), (11, 2, "afterAllSaints")],
            "ES-CL": [(4, 2, "maundy"), (4, 23, "castillaLeon"), (11, 2, "afterAllSaints"), (12, 7, "afterConstitution")],
            "ES-CT": [(4, 6, "easterMonday"), (6, 24, "stJohn"), (9, 11, "catalunya"), (12, 26, "stStephen")],
            "ES-VC": [(4, 2, "maundy"), (4, 6, "easterMonday"), (6, 24, "stJohn"), (10, 9, "valencia")],
            "ES-EX": [(4, 2, "maundy"), (9, 8, "extremadura"), (11, 2, "afterAllSaints")],
            "ES-GA": [(4, 2, "maundy"), (6, 24, "stJohn"), (7, 25, "galicia")],
            "ES-MD": [(4, 2, "maundy"), (5, 2, "madrid")],
            "ES-MC": [(4, 2, "maundy"), (6, 9, "murcia"), (11, 2, "afterAllSaints")],
            "ES-NC": [(4, 2, "maundy"), (4, 6, "easterMonday")],
            "ES-PV": [(4, 2, "maundy"), (4, 6, "easterMonday"), (7, 25, "santiago")],
            "ES-RI": [(4, 2, "maundy"), (6, 9, "rioja")],
            "ES-CE": [(4, 2, "maundy"), (5, 27, "eidAdha"), (9, 2, "ceuta")],
            "ES-ML": [(3, 20, "eidFitr"), (4, 2, "maundy"), (5, 27, "eidAdha")],
        ],
    ]

    private func spainRegionalNames() -> [String: N] {
        func r(_ local: String, ko: String, en: String) -> N { N(ko: ko, en: en, es: local) }
        return [
            "maundy": Common.maundyThursday,
            "easterMonday": Common.easterMonday,
            "stJohn": Common.stJohn,
            "stStephen": Common.stStephen,
            "corpus": Common.corpusChristi,
            "afterAllSaints": N(ko: "만성절 대체 휴일", en: "All Saints' Day (observed)", ja: "諸聖人の日（振替）", zh: "诸圣节（补休）", de: "Allerheiligen (Ersatztag)",
                                fr: "Toussaint (jour de remplacement)", es: "Lunes siguiente a Todos los Santos", it: "Ognissanti (sostitutiva)",
                                pt: "Todos os Santos (transferido)", zht: "諸聖節（補假）"),
            "afterConstitution": N(ko: "제헌절 대체 휴일", en: "Constitution Day (observed)", ja: "憲法記念日（振替）", zh: "宪法日（补休）", de: "Tag der Verfassung (Ersatztag)",
                                   fr: "Jour de la Constitution (jour de remplacement)", es: "Lunes siguiente al Día de la Constitución", it: "Giorno della Costituzione (sostitutiva)",
                                   pt: "Dia da Constituição (transferido)", zht: "行憲紀念日（補假）"),
            "andalucia": r("Día de Andalucía", ko: "안달루시아의 날", en: "Andalusia Day"),
            "aragon": r("Día de Aragón", ko: "아라곤의 날", en: "Aragon Day"),
            "asturias": r("Día de Asturias", ko: "아스투리아스의 날", en: "Asturias Day"),
            "balears": r("Día de las Illes Balears (trasladado)", ko: "발레아레스 제도의 날 (대체)", en: "Balearic Islands Day (observed)"),
            "canarias": r("Día de Canarias", ko: "카나리아 제도의 날", en: "Canary Islands Day"),
            "cantabria": r("Día de las Instituciones de Cantabria", ko: "칸타브리아 제도의 날", en: "Cantabria Institutions Day"),
            "bienAparecida": r("La Bien Aparecida", ko: "비엔 아파레시다 성모 축일", en: "Our Lady of Bien Aparecida"),
            "castillaLeon": r("Día de Castilla y León", ko: "카스티야 이 레온의 날", en: "Castile and León Day"),
            "catalunya": r("Diada Nacional de Catalunya", ko: "카탈루냐의 날", en: "National Day of Catalonia"),
            "valencia": r("Dia de la Comunitat Valenciana", ko: "발렌시아의 날", en: "Valencian Community Day"),
            "extremadura": r("Día de Extremadura", ko: "에스트레마두라의 날", en: "Extremadura Day"),
            "galicia": r("Día Nacional de Galicia", ko: "갈리시아의 날", en: "Galician National Day"),
            "madrid": r("Fiesta de la Comunidad de Madrid", ko: "마드리드 자치주의 날", en: "Community of Madrid Day"),
            "murcia": r("Día de la Región de Murcia", ko: "무르시아의 날", en: "Murcia Day"),
            "rioja": r("Día de La Rioja", ko: "라리오하의 날", en: "La Rioja Day"),
            "santiago": r("Santiago Apóstol", ko: "성 야고보 축일", en: "St. James' Day"),
            "ceuta": r("Día de Ceuta", ko: "세우타의 날", en: "Ceuta Day"),
            "eidAdha": r("Fiesta del Sacrificio (Eidul Adha)", ko: "이드 알아드하", en: "Eid al-Adha"),
            "eidFitr": r("Fiesta del Fin del Ramadán (Eid al-Fitr)", ko: "이드 알피트르", en: "Eid al-Fitr"),
        ]
    }

    // MARK: - 이탈리아

    func getItalyHolidays(for year: Int) -> [Holiday] {
        var list: [(Date?, N)] = []
        list.append((day(year, 1, 1), Common.newYear))
        list.append((day(year, 1, 6), Common.epiphany))
        if let e = easter(year) { list.append((adding(1, to: e), Common.easterMonday)) }
        list.append((day(year, 4, 25), N(ko: "해방 기념일", en: "Liberation Day", ja: "解放記念日", zh: "解放日", de: "Tag der Befreiung", fr: "Fête de la Libération",
                                         es: "Día de la Liberación", it: "Festa della Liberazione", pt: "Dia da Libertação", zht: "解放紀念日")))
        list.append((day(year, 5, 1), Common.labour))
        list.append((day(year, 6, 2), N(ko: "공화국의 날", en: "Republic Day", ja: "共和国記念日", zh: "共和国日", de: "Tag der Republik", fr: "Fête de la République",
                                        es: "Día de la República", it: "Festa della Repubblica", pt: "Dia da República", zht: "共和國日")))
        list.append((day(year, 8, 15), Common.assumption))
        // 성 프란치스코 축일 — 2026년부터 국가 공휴일로 복원 (법률 2025년 제정)
        if year >= 2026 {
            list.append((day(year, 10, 4), N(ko: "성 프란치스코 축일", en: "St. Francis of Assisi Day", ja: "アッシジの聖フランチェスコの日", zh: "圣方济各日",
                                             de: "Franz-von-Assisi-Tag", fr: "Saint-François d’Assise", es: "San Francisco de Asís",
                                             it: "San Francesco d’Assisi", pt: "Dia de São Francisco de Assis", zht: "聖方濟各日")))
        }
        list.append((day(year, 11, 1), Common.allSaints))
        list.append((day(year, 12, 8), Common.immaculate))
        list.append((day(year, 12, 25), Common.christmas))
        list.append((day(year, 12, 26), Common.stStephen))
        return list.compactMap { d, n in d.map { Holiday(date: $0, name: n.text) } }.sorted { $0.date < $1.date }
    }

    // MARK: - 브라질

    /// 연방 공휴일 + 전국적으로 쉬는 임의 휴일(ponto facultativo: 카니발, 성체 축일).
    func getBrazilHolidays(for year: Int) -> [Holiday] {
        var list: [(Date?, N)] = []
        list.append((day(year, 1, 1), Common.newYear))
        if let e = easter(year) {
            let carnival = N(ko: "카니발", en: "Carnival", ja: "カーニバル", zh: "狂欢节", de: "Karneval", fr: "Carnaval",
                             es: "Carnaval", it: "Carnevale", pt: "Carnaval", zht: "嘉年華")
            list.append((adding(-48, to: e), carnival))
            list.append((adding(-47, to: e), carnival))
            list.append((adding(-2, to: e), Common.goodFriday))
            list.append((adding(60, to: e), Common.corpusChristi))
        }
        list.append((day(year, 4, 21), N(ko: "치라덴치스의 날", en: "Tiradentes Day", ja: "チラデンテスの日", zh: "拔牙者日", de: "Tiradentes", fr: "Tiradentes",
                                         es: "Día de Tiradentes", it: "Tiradentes", pt: "Tiradentes", zht: "拔牙者日")))
        list.append((day(year, 5, 1), Common.labour))
        list.append((day(year, 9, 7), N(ko: "독립기념일", en: "Independence Day", ja: "独立記念日", zh: "独立日", de: "Unabhängigkeitstag", fr: "Fête de l’Indépendance",
                                        es: "Día de la Independencia", it: "Festa dell’Indipendenza", pt: "Independência do Brasil", zht: "獨立紀念日")))
        list.append((day(year, 10, 12), N(ko: "아파레시다 성모 축일", en: "Our Lady of Aparecida", ja: "アパレシーダの聖母の日", zh: "阿帕雷西达圣母日", de: "Unsere Liebe Frau von Aparecida",
                                          fr: "Notre-Dame d’Aparecida", es: "Nuestra Señora Aparecida", it: "Nostra Signora Aparecida", pt: "Nossa Senhora Aparecida", zht: "阿帕雷西達聖母日")))
        list.append((day(year, 11, 2), N(ko: "위령의 날", en: "All Souls' Day", ja: "死者の日", zh: "万灵节", de: "Allerseelen", fr: "Jour des morts",
                                         es: "Día de Difuntos", it: "Commemorazione dei defunti", pt: "Finados", zht: "萬靈節")))
        list.append((day(year, 11, 15), N(ko: "공화국 선포일", en: "Republic Proclamation Day", ja: "共和国宣言記念日", zh: "共和国宣言日", de: "Ausrufung der Republik",
                                          fr: "Proclamation de la République", es: "Proclamación de la República", it: "Proclamazione della Repubblica",
                                          pt: "Proclamação da República", zht: "共和國宣言日")))
        if year >= 2024 {
            list.append((day(year, 11, 20), N(ko: "흑인 의식의 날", en: "Black Consciousness Day", ja: "黒人意識の日", zh: "黑人觉醒日", de: "Tag des schwarzen Bewusstseins",
                                              fr: "Jour de la conscience noire", es: "Día de la Conciencia Negra", it: "Giornata della coscienza nera",
                                              pt: "Dia da Consciência Negra", zht: "黑人覺醒日")))
        }
        list.append((day(year, 12, 25), Common.christmas))
        return list.compactMap { d, n in d.map { Holiday(date: $0, name: n.text) } }.sorted { $0.date < $1.date }
    }

    // MARK: - 대만

    /// 「紀念日及節日實施條例」(2025) 기준. 2025년부터 보충 근무일(補班)이 없어져 규칙으로 계산된다.
    /// - 토요일이면 전날(금), 일요일이면 다음 날(월) 보충 휴무
    /// - 설 연휴(小年夜~初三) 중 주말에 걸린 날만큼 연휴 뒤로 이어 쉰다
    /// - 어린이날과 청명이 겹치면 전날(목요일이면 다음 날) 쉰다
    func getTaiwanHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        var taken = Set<String>()
        func add(_ d: Date?, _ n: N, substitute: Bool = false) {
            guard let d, taken.insert(dateKey(d)).inserted else { return }
            holidays.append(Holiday(date: d, name: substitute ? "\(n.text) (\(Common.substitute))" : n.text, isSubstitute: substitute))
        }
        let lunarNewYear = N(ko: "춘절", en: "Lunar New Year", ja: "春節", zh: "春节", de: "Chinesisches Neujahr", fr: "Nouvel An chinois",
                             es: "Año Nuevo Lunar", it: "Capodanno lunare", pt: "Ano Novo Lunar", zht: "春節")
        let eve = N(ko: "섣달그믐", en: "Lunar New Year's Eve", ja: "大晦日（旧暦）", zh: "除夕", de: "Vorabend des chinesischen Neujahrs", fr: "Réveillon du Nouvel An chinois",
                    es: "Víspera del Año Nuevo Lunar", it: "Vigilia del Capodanno lunare", pt: "Véspera do Ano Novo Lunar", zht: "除夕")
        let smallEve = N(ko: "섣달그믐 전날", en: "Day before Lunar New Year's Eve", ja: "小年夜", zh: "小年夜", de: "Tag vor dem Vorabend des Neujahrs", fr: "Veille du réveillon du Nouvel An chinois",
                         es: "Antevíspera del Año Nuevo Lunar", it: "Antivigilia del Capodanno lunare", pt: "Antevéspera do Ano Novo Lunar", zht: "小年夜")
        let peace = N(ko: "평화기념일", en: "Peace Memorial Day", ja: "和平記念日", zh: "和平纪念日", de: "Friedensgedenktag", fr: "Journée commémorative de la paix",
                      es: "Día Conmemorativo de la Paz", it: "Giornata commemorativa della pace", pt: "Dia Memorial da Paz", zht: "和平紀念日")
        let children = N(ko: "어린이날", en: "Children's Day", ja: "児童節", zh: "儿童节", de: "Kindertag", fr: "Journée des enfants",
                         es: "Día del Niño", it: "Festa dei bambini", pt: "Dia das Crianças", zht: "兒童節")
        let tomb = N(ko: "청명절", en: "Tomb Sweeping Day", ja: "清明節", zh: "清明节", de: "Qingming-Fest", fr: "Fête de Qingming",
                     es: "Día de Barrer las Tumbas", it: "Festa di Qingming", pt: "Festival Qingming", zht: "民族掃墓節")
        let dragon = N(ko: "단오절", en: "Dragon Boat Festival", ja: "端午節", zh: "端午节", de: "Drachenbootfest", fr: "Fête des bateaux-dragons",
                       es: "Festival del Bote del Dragón", it: "Festa delle barche drago", pt: "Festival do Barco-Dragão", zht: "端午節")
        let midAutumn = N(ko: "중추절", en: "Mid-Autumn Festival", ja: "中秋節", zh: "中秋节", de: "Mondfest", fr: "Fête de la mi-automne",
                          es: "Festival del Medio Otoño", it: "Festa di metà autunno", pt: "Festival do Meio do Outono", zht: "中秋節")
        let teachers = N(ko: "스승의 날", en: "Teachers' Day", ja: "教師節", zh: "教师节", de: "Lehrertag", fr: "Journée des enseignants",
                         es: "Día del Maestro", it: "Giornata degli insegnanti", pt: "Dia do Professor", zht: "教師節")
        let doubleTen = N(ko: "쌍십절", en: "National Day (Double Tenth)", ja: "双十節", zh: "国庆日（双十节）", de: "Nationalfeiertag (Doppelzehnter)", fr: "Fête nationale (Double Dix)",
                          es: "Día Nacional (Doble Diez)", it: "Festa nazionale (Doppio Dieci)", pt: "Dia Nacional (Duplo Dez)", zht: "國慶日")
        let retrocession = N(ko: "대만 광복절", en: "Taiwan Retrocession Day", ja: "台湾光復節", zh: "台湾光复节", de: "Tag der Rückgabe Taiwans", fr: "Jour de la rétrocession de Taïwan",
                             es: "Día de la Retrocesión de Taiwán", it: "Giorno della retrocessione di Taiwan", pt: "Dia da Retrocessão de Taiwan", zht: "臺灣光復節")
        let constitution = N(ko: "제헌기념일", en: "Constitution Day", ja: "憲法記念日", zh: "行宪纪念日", de: "Verfassungstag", fr: "Jour de la Constitution",
                             es: "Día de la Constitución", it: "Giorno della Costituzione", pt: "Dia da Constituição", zht: "行憲紀念日")

        /// 토 → 전날, 일 → 다음 날 (이미 쉬는 날이면 한 칸 더)
        func withSubstitute(_ d: Date?, _ n: N) {
            guard let d else { return }
            add(d, n)
            switch weekday(d) {
            case 7:
                var s = adding(-1, to: d)
                while taken.contains(dateKey(s)) || isWeekend(s) { s = adding(-1, to: s) }
                add(s, n, substitute: true)
            case 1:
                var s = adding(1, to: d)
                while taken.contains(dateKey(s)) || isWeekend(s) { s = adding(1, to: s) }
                add(s, n, substitute: true)
            default: break
            }
        }

        withSubstitute(day(year, 1, 1), Common.newYear)

        // 설 연휴
        if let cny = lunar(year, month: 1, day: 1) {
            var days: [(Date, N)] = []
            if year >= 2026 { days.append((adding(-2, to: cny), smallEve)) }
            days.append((adding(-1, to: cny), eve))
            for i in 0..<3 { days.append((adding(i, to: cny), lunarNewYear)) }
            // 2024·2025는 보충 근무일과 맞바꾼 탄력 휴무(彈性放假)가 하루 더 있었다
            if year == 2024 || year == 2025 { days.insert((adding(-2, to: cny), lunarNewYear), at: 0) }
            for (d, n) in days { add(d, n) }
            let weekendCount = days.filter { isWeekend($0.0) }.count
            var next = adding(3, to: cny)
            var added = 0
            while added < weekendCount {
                if !isWeekend(next) && !taken.contains(dateKey(next)) {
                    add(next, lunarNewYear, substitute: true)
                    added += 1
                }
                next = adding(1, to: next)
            }
        }

        withSubstitute(day(year, 2, 28), peace)

        // 어린이날·청명
        if let childrensDay = day(year, 4, 4), let qm = qingming(year) {
            if calendar.isDate(childrensDay, inSameDayAs: qm) {
                add(qm, tomb)
                add(weekday(qm) == 5 ? adding(1, to: qm) : adding(-1, to: qm), children)
            } else {
                withSubstitute(qm, tomb)
                withSubstitute(childrensDay, children)
            }
        }

        withSubstitute(day(year, 5, 1), Common.labour)
        withSubstitute(lunar(year, month: 5, day: 5), dragon)
        withSubstitute(lunar(year, month: 8, day: 15), midAutumn)
        if year >= 2025 { withSubstitute(day(year, 9, 28), teachers) }
        withSubstitute(day(year, 10, 10), doubleTen)
        if year >= 2025 {
            withSubstitute(day(year, 10, 25), retrocession)
            withSubstitute(day(year, 12, 25), constitution)
        }
        return holidays.filter { calendar.component(.year, from: $0.date) == year }.sorted { $0.date < $1.date }
    }

    // MARK: - 홍콩

    /// 일반 공휴일(General Holidays) 기준 — 사무직 대부분이 쉬는 날.
    /// 일요일이면 다음 날(이미 쉬는 날이면 그다음) 쉰다.
    func getHongKongHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        var taken = Set<String>()
        func add(_ d: Date?, _ n: N, substitute: Bool = false) {
            guard let d, taken.insert(dateKey(d)).inserted else { return }
            holidays.append(Holiday(date: d, name: substitute ? "\(n.text) (\(Common.substitute))" : n.text, isSubstitute: substitute))
        }
        var sundayHolidays: [(Date, N)] = []
        func general(_ d: Date?, _ n: N) {
            guard let d else { return }
            add(d, n)
            if weekday(d) == 1 { sundayHolidays.append((d, n)) }
        }

        let lunarNewYear = N(ko: "음력 설", en: "Lunar New Year", ja: "旧正月", zh: "农历新年", de: "Chinesisches Neujahr", fr: "Nouvel An lunaire",
                             es: "Año Nuevo Lunar", it: "Capodanno lunare", pt: "Ano Novo Lunar", zht: "農曆年初")
        let chingMing = N(ko: "청명절", en: "Ching Ming Festival", ja: "清明節", zh: "清明节", de: "Qingming-Fest", fr: "Fête de Qingming",
                          es: "Festival Qingming", it: "Festa di Qingming", pt: "Festival Qingming", zht: "清明節")
        let dayAfterGoodFriday = N(ko: "성금요일 다음 날", en: "The day following Good Friday", ja: "聖金曜日の翌日", zh: "耶稣受难节翌日", de: "Tag nach Karfreitag", fr: "Lendemain du Vendredi saint",
                                   es: "Día siguiente al Viernes Santo", it: "Giorno dopo il Venerdì Santo", pt: "Dia seguinte à Sexta-feira Santa", zht: "耶穌受難節翌日")
        let buddha = N(ko: "부처님 오신 날", en: "Birthday of the Buddha", ja: "仏誕節", zh: "佛诞", de: "Buddhas Geburtstag", fr: "Anniversaire de Bouddha",
                       es: "Cumpleaños de Buda", it: "Compleanno di Buddha", pt: "Aniversário de Buda", zht: "佛誕")
        let tuenNg = N(ko: "단오절", en: "Tuen Ng Festival", ja: "端午節", zh: "端午节", de: "Drachenbootfest", fr: "Fête des bateaux-dragons",
                       es: "Festival del Bote del Dragón", it: "Festa delle barche drago", pt: "Festival do Barco-Dragão", zht: "端午節")
        let sar = N(ko: "홍콩 특별행정구 수립 기념일", en: "HKSAR Establishment Day", ja: "香港特別行政区成立記念日", zh: "香港特别行政区成立纪念日", de: "Gründungstag der SVR Hongkong",
                    fr: "Fête de la création de la RAS de Hong Kong", es: "Día del Establecimiento de la RAE de Hong Kong", it: "Giorno della fondazione della RAS di Hong Kong",
                    pt: "Dia do Estabelecimento da RAE de Hong Kong", zht: "香港特別行政區成立紀念日")
        let afterMidAutumn = N(ko: "중추절 다음 날", en: "The day following Mid-Autumn Festival", ja: "中秋節の翌日", zh: "中秋节翌日", de: "Tag nach dem Mondfest", fr: "Lendemain de la fête de la mi-automne",
                               es: "Día siguiente al Festival del Medio Otoño", it: "Giorno dopo la Festa di metà autunno", pt: "Dia seguinte ao Festival do Meio do Outono", zht: "中秋節翌日")
        let chungYeung = N(ko: "중양절", en: "Chung Yeung Festival", ja: "重陽節", zh: "重阳节", de: "Doppelneunfest", fr: "Fête du Double Neuf",
                           es: "Festival del Doble Nueve", it: "Festa del Doppio Nove", pt: "Festival do Duplo Nove", zht: "重陽節")
        let afterChristmas = N(ko: "크리스마스 다음 첫 평일", en: "The first weekday after Christmas Day", ja: "クリスマス後の最初の平日", zh: "圣诞节后第一个工作日", de: "Erster Werktag nach Weihnachten",
                               fr: "Premier jour ouvrable après Noël", es: "Primer día laborable después de Navidad", it: "Primo giorno feriale dopo Natale",
                               pt: "Primeiro dia útil após o Natal", zht: "聖誕節後第一個工作日")

        general(day(year, 1, 1), Common.newYear)
        if let cny = lunar(year, month: 1, day: 1) {
            let three = (0..<3).map { adding($0, to: cny) }
            for d in three { add(d, lunarNewYear) }
            // 사흘 중 하루가 일요일이면 나흘째도 쉰다
            if three.contains(where: { weekday($0) == 1 }) { add(adding(3, to: cny), lunarNewYear) }
        }
        let e = easter(year)
        if let e {
            add(adding(-2, to: e), Common.goodFriday)
            add(adding(-1, to: e), dayAfterGoodFriday)
            add(adding(1, to: e), Common.easterMonday)
        }
        // 청명이 부활절 월요일과 겹치면 그다음 날
        if let qm = qingming(year) {
            if let e, calendar.isDate(qm, inSameDayAs: adding(1, to: e)) {
                add(adding(2, to: e), chingMing)
            } else {
                general(qm, chingMing)
            }
        }
        general(day(year, 5, 1), Common.labour)
        general(lunar(year, month: 4, day: 8), buddha)
        general(lunar(year, month: 5, day: 5), tuenNg)
        general(day(year, 7, 1), sar)
        general(lunar(year, month: 8, day: 16), afterMidAutumn)
        general(day(year, 10, 1), Common.nationalDay)
        general(lunar(year, month: 9, day: 9), chungYeung)
        general(day(year, 12, 25), Common.christmas)
        // 크리스마스 다음 첫 평일 (일요일·공휴일이 아닌 날 — 홍콩은 토요일도 평일)
        if let xmas = day(year, 12, 25) {
            var d = adding(1, to: xmas)
            while weekday(d) == 1 || taken.contains(dateKey(d)) { d = adding(1, to: d) }
            add(d, afterChristmas)
        }
        // 일요일에 걸린 공휴일은 다음 날(이미 쉬는 날이면 그다음 날)
        for (d, n) in sundayHolidays.sorted(by: { $0.0 < $1.0 }) {
            var s = adding(1, to: d)
            while weekday(s) == 1 || taken.contains(dateKey(s)) { s = adding(1, to: s) }
            add(s, n, substitute: true)
        }
        return holidays.filter { calendar.component(.year, from: $0.date) == year }.sorted { $0.date < $1.date }
    }

    // MARK: - 걸프 (UAE·사우디·카타르)

    /// 이슬람력(움 알쿠라) 날짜 → 그해 양력 날짜들. 이슬람력 1년은 약 354일이라
    /// 같은 명절이 한 양력 해에 두 번 올 수도 있다(예: 2030년 이드 알피트르).
    /// 실제 날짜는 달 관측 발표로 하루쯤 달라질 수 있다 — 공휴일 관리에서 고칠 수 있다.
    fileprivate func hijri(_ year: Int, month: Int, day: Int, length: Int = 1) -> [Date] {
        let islamic = Calendar(identifier: .islamicUmmAlQura)
        let approx = year - 579   // 양력 2026 ≈ 이슬람력 1447~1448
        var result: [Date] = []
        for hy in (approx - 1)...(approx + 1) {
            guard let d = islamic.date(from: DateComponents(year: hy, month: month, day: day)),
                  islamic.component(.day, from: d) == day else { continue }
            let start = calendar.startOfDay(for: d)
            for i in 0..<length {
                let x = adding(i, to: start)
                if calendar.component(.year, from: x) == year { result.append(x) }
            }
        }
        return result
    }

    /// 라마단 29일 다음 날 — 라마단이 29일로 끝나면 샤왈 1일, 30일까지면 라마단 30일
    fileprivate func dayAfterRamadan29(_ year: Int, length: Int) -> [Date] {
        let islamic = Calendar(identifier: .islamicUmmAlQura)
        let approx = year - 579
        var result: [Date] = []
        for hy in (approx - 1)...(approx + 1) {
            guard let d = islamic.date(from: DateComponents(year: hy, month: 9, day: 29)) else { continue }
            let start = adding(1, to: calendar.startOfDay(for: d))
            for i in 0..<length {
                let x = adding(i, to: start)
                if calendar.component(.year, from: x) == year { result.append(x) }
            }
        }
        return result
    }

    private enum Gulf {
        static let eidFitr = N(ko: "이드 알피트르", en: "Eid al-Fitr", ja: "イード・アル＝フィトル", zh: "开斋节", de: "Zuckerfest (Eid al-Fitr)", fr: "Aïd el-Fitr",
                               es: "Eid al-Fitr", it: "Eid al-Fitr", pt: "Eid al-Fitr", zht: "開齋節")
        static let eidAdha = N(ko: "이드 알아드하", en: "Eid al-Adha", ja: "イード・アル＝アドハー", zh: "宰牲节", de: "Opferfest (Eid al-Adha)", fr: "Aïd el-Kébir",
                               es: "Eid al-Adha", it: "Eid al-Adha", pt: "Eid al-Adha", zht: "宰牲節")
        static let arafat = N(ko: "아라파트의 날", en: "Arafat Day", ja: "アラファの日", zh: "阿拉法特日", de: "Arafat-Tag", fr: "Jour d’Arafat",
                              es: "Día de Arafat", it: "Giorno di Arafat", pt: "Dia de Arafat", zht: "阿拉法特日")
        static let hijriNewYear = N(ko: "이슬람 새해", en: "Islamic New Year", ja: "イスラム新年", zh: "伊斯兰新年", de: "Islamisches Neujahr", fr: "Nouvel An islamique",
                                    es: "Año Nuevo islámico", it: "Capodanno islamico", pt: "Ano Novo Islâmico", zht: "伊斯蘭新年")
        static let prophetBirthday = N(ko: "예언자 탄신일", en: "Prophet's Birthday", ja: "預言者生誕祭", zh: "圣纪节", de: "Geburtstag des Propheten", fr: "Mawlid (naissance du Prophète)",
                                       es: "Nacimiento del Profeta", it: "Nascita del Profeta", pt: "Nascimento do Profeta", zht: "聖紀節")
        static let commemoration = N(ko: "순국자 추모일", en: "Commemoration Day", ja: "殉教者追悼の日", zh: "烈士纪念日", de: "Gedenktag für die Gefallenen", fr: "Jour de commémoration",
                                     es: "Día de la Conmemoración", it: "Giorno della Commemorazione", pt: "Dia da Comemoração", zht: "烈士紀念日")
        static let nationalDay = N(ko: "국경일", en: "National Day", ja: "ナショナルデー", zh: "国庆日", de: "Nationalfeiertag", fr: "Fête nationale",
                                   es: "Día Nacional", it: "Festa nazionale", pt: "Dia Nacional", zht: "國慶日")
        static let foundingDay = N(ko: "건국 기념일", en: "Founding Day", ja: "建国記念日", zh: "建国日", de: "Gründungstag", fr: "Jour de la Fondation",
                                   es: "Día de la Fundación", it: "Giorno della Fondazione", pt: "Dia da Fundação", zht: "建國日")
        static let sportDay = N(ko: "국가 스포츠의 날", en: "National Sport Day", ja: "ナショナル・スポーツ・デー", zh: "全国体育日", de: "Nationaler Sporttag", fr: "Journée nationale du sport",
                                es: "Día Nacional del Deporte", it: "Giornata nazionale dello sport", pt: "Dia Nacional do Esporte", zht: "全國體育日")
    }

    private func gulfList(_ items: [([Date], N)]) -> [Holiday] {
        var taken = Set<String>()
        var holidays: [Holiday] = []
        for (dates, n) in items {
            for d in dates where taken.insert(dateKey(d)).inserted {
                holidays.append(Holiday(date: d, name: n.text))
            }
        }
        return holidays.sorted { $0.date < $1.date }
    }

    /// UAE 공·민간 공통 공휴일 (내각 결정). 주말 토·일.
    func getUAEHolidays(for year: Int) -> [Holiday] {
        gulfList([
            ([day(year, 1, 1)].compactMap { $0 }, Common.newYear),
            (hijri(year, month: 10, day: 1, length: 3), Gulf.eidFitr),
            (hijri(year, month: 12, day: 9), Gulf.arafat),
            (hijri(year, month: 12, day: 10, length: 3), Gulf.eidAdha),
            (hijri(year, month: 1, day: 1), Gulf.hijriNewYear),
            (hijri(year, month: 3, day: 12), Gulf.prophetBirthday),
            ([day(year, 12, 1)].compactMap { $0 }, Gulf.commemoration),
            ([day(year, 12, 2), day(year, 12, 3)].compactMap { $0 }, Gulf.nationalDay),
        ])
    }

    /// 사우디 민간 부문 (노동법 시행규칙): 이드 알피트르 라마단 29일 다음 날부터 4일,
    /// 이드 알아드하 아라파트의 날부터 4일, 건국 기념일, 국경일. 주말 금·토.
    func getSaudiArabiaHolidays(for year: Int) -> [Holiday] {
        gulfList([
            ([day(year, 2, 22)].compactMap { $0 }, Gulf.foundingDay),
            (dayAfterRamadan29(year, length: 4), Gulf.eidFitr),
            (hijri(year, month: 12, day: 9), Gulf.arafat),
            (hijri(year, month: 12, day: 10, length: 3), Gulf.eidAdha),
            ([day(year, 9, 23)].compactMap { $0 }, Gulf.nationalDay),
        ])
    }

    /// 카타르 노동법 최소 공휴일 + 국가 스포츠의 날(2월 둘째 화요일). 주말 금·토.
    func getQatarHolidays(for year: Int) -> [Holiday] {
        gulfList([
            ([nthWeekday(nth: 2, weekday: 3, month: 2, year: year)].compactMap { $0 }, Gulf.sportDay),
            (hijri(year, month: 10, day: 1, length: 3), Gulf.eidFitr),
            (hijri(year, month: 12, day: 10, length: 3), Gulf.eidAdha),
            ([day(year, 12, 18)].compactMap { $0 }, Gulf.nationalDay),
        ])
    }

    // MARK: - 페루

    /// 공·민간 공통 국가 공휴일 (Decreto Legislativo 713과 이후 개정). 주말과 겹쳐도 옮기지 않는다.
    /// 정부가 해마다 따로 정하는 공공부문 "días no laborables"는 넣지 않았다.
    func getPeruHolidays(for year: Int) -> [Holiday] {
        var list: [(Date?, N)] = []
        list.append((day(year, 1, 1), Common.newYear))
        if let e = easter(year) {
            list.append((adding(-3, to: e), Common.maundyThursday))
            list.append((adding(-2, to: e), Common.goodFriday))
        }
        list.append((day(year, 5, 1), Common.labour))
        if year >= 2023 {
            list.append((day(year, 6, 7), N(ko: "아리카 전투·국기의 날", en: "Battle of Arica and Flag Day", ja: "アリカの戦い・国旗の日", zh: "阿里卡战役暨国旗日",
                                            de: "Schlacht von Arica und Tag der Flagge", fr: "Bataille d’Arica et Jour du drapeau", es: "Batalla de Arica y Día de la Bandera",
                                            it: "Battaglia di Arica e Giorno della Bandiera", pt: "Batalha de Arica e Dia da Bandeira", zht: "阿里卡戰役暨國旗日")))
        }
        list.append((day(year, 6, 29), N(ko: "성 베드로와 성 바오로 축일", en: "Saints Peter and Paul", ja: "聖ペトロと聖パウロの日", zh: "圣伯多禄和圣保禄节",
                                         de: "Peter und Paul", fr: "Saints Pierre et Paul", es: "San Pedro y San Pablo",
                                         it: "Santi Pietro e Paolo", pt: "São Pedro e São Paulo", zht: "聖伯多祿聖保祿節")))
        if year >= 2024 {
            list.append((day(year, 7, 23), N(ko: "페루 공군의 날", en: "Peruvian Air Force Day", ja: "ペルー空軍の日", zh: "秘鲁空军日",
                                             de: "Tag der Peruanischen Luftwaffe", fr: "Jour de l’armée de l’air péruvienne", es: "Día de la Fuerza Aérea del Perú",
                                             it: "Giorno dell’Aeronautica peruviana", pt: "Dia da Força Aérea do Peru", zht: "秘魯空軍日")))
        }
        let patrias = N(ko: "독립기념일 (피에스타스 파트리아스)", en: "Independence Day (Fiestas Patrias)", ja: "独立記念日", zh: "独立日",
                        de: "Unabhängigkeitstag", fr: "Fête de l’indépendance", es: "Fiestas Patrias",
                        it: "Festa dell’indipendenza", pt: "Dia da Independência", zht: "獨立紀念日")
        list.append((day(year, 7, 28), patrias))
        list.append((day(year, 7, 29), patrias))
        if year >= 2022 {
            list.append((day(year, 8, 6), N(ko: "후닌 전투 기념일", en: "Battle of Junín", ja: "フニンの戦い記念日", zh: "胡宁战役纪念日",
                                            de: "Schlacht von Junín", fr: "Bataille de Junín", es: "Batalla de Junín",
                                            it: "Battaglia di Junín", pt: "Batalha de Junín", zht: "胡寧戰役紀念日")))
        }
        list.append((day(year, 8, 30), N(ko: "리마의 성녀 로사 축일", en: "Saint Rose of Lima", ja: "リマの聖ロサの日", zh: "利马的圣罗撒节",
                                         de: "Heilige Rosa von Lima", fr: "Sainte Rose de Lima", es: "Santa Rosa de Lima",
                                         it: "Santa Rosa da Lima", pt: "Santa Rosa de Lima", zht: "利馬聖羅撒節")))
        list.append((day(year, 10, 8), N(ko: "앙가모스 해전 기념일", en: "Battle of Angamos", ja: "アンガモスの海戦記念日", zh: "安加莫斯海战纪念日",
                                         de: "Seeschlacht von Angamos", fr: "Combat d’Angamos", es: "Combate de Angamos",
                                         it: "Battaglia di Angamos", pt: "Combate de Angamos", zht: "安加莫斯海戰紀念日")))
        list.append((day(year, 11, 1), Common.allSaints))
        list.append((day(year, 12, 8), Common.immaculate))
        if year >= 2022 {
            list.append((day(year, 12, 9), N(ko: "아야쿠초 전투 기념일", en: "Battle of Ayacucho", ja: "アヤクーチョの戦い記念日", zh: "阿亚库乔战役纪念日",
                                             de: "Schlacht von Ayacucho", fr: "Bataille d’Ayacucho", es: "Batalla de Ayacucho",
                                             it: "Battaglia di Ayacucho", pt: "Batalha de Ayacucho", zht: "阿亞庫喬戰役紀念日")))
        }
        list.append((day(year, 12, 25), Common.christmas))
        return list.compactMap { d, n in d.map { Holiday(date: $0, name: n.text) } }.sorted { $0.date < $1.date }
    }
}
