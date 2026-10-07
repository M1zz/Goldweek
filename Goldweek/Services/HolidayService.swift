//
//  HolidayService.swift
//  Goldweek
//
//  공휴일 서비스 (다국가 지원)
//

import Foundation

class HolidayService {

    let calendar = Calendar.current

    /// 음력 공휴일 테이블(한국 설날/추석, 중국 춘절 등)이 정확하게 수록된 마지막 연도.
    /// 이후 연도는 근사치 폴백이라 실제 날짜와 다를 수 있다 — 테이블 확장 시 함께 갱신할 것.
    static let reliableDataLastYear = 2030

    /// 해당 연도의 공휴일 데이터가 정확한 테이블 범위 안에 있는지
    func isHolidayDataReliable(for year: Int, country: Country = .korea) -> Bool {
        // 중국은 调休(주말 대체 근무) 때문에 정부 발표 전에는 실제 휴무일을 알 수 없다
        if country == .china { return year <= Self.chinaOfficialLastYear }
        // 러시아는 휴일 이동, 인도네시아는 공휴일 날짜 자체를 정부가 해마다 정한다
        if country == .russia { return year <= Self.russiaOfficialLastYear }
        if country == .indonesia { return Self.hasIndonesiaOfficialSchedule(year) }
        if country == .custom { return true }   // 기본 공휴일이 없으니 틀릴 것도 없다
        return year <= Self.reliableDataLastYear
    }

    // MARK: - 공휴일 데이터 (국가별)

    private let holidayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// (year, country) → 공휴일 기본 세트 캐시.
    /// 추천 탭에서 카드마다 같은 연도·국가로 6+회 호출되어 스크롤 버벅임의 주요 원인이었음.
    private var baseHolidaysCache: [String: [Holiday]] = [:]

    func dateKey(_ date: Date) -> String {
        holidayDateFormatter.string(from: date)
    }

    /// 사용자가 고른 공휴일 지역 (ISO 3166-2, 예: "DE-BY"). 원본은 `UserProfile.holidayRegionRaw` 이고,
    /// 프로필을 모르는 곳(여기저기서 `HolidayService()`를 새로 만든다)에서도 같은 값을 쓰도록 거울처럼 둔다.
    static var selectedRegionCode: String {
        get { UserDefaults.standard.string(forKey: "holidayRegion") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "holidayRegion") }
    }

    /// 사는 곳 지역 (원본은 `UserProfile.homeRegionRaw`) — 일하는 곳과 다르면 그 지역에만 있는 공휴일을 따로 보여 준다
    static var homeRegionCode: String {
        get { UserDefaults.standard.string(forKey: "homeHolidayRegion") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "homeHolidayRegion") }
    }

    /// 함께 볼 공휴일의 나라 (원본은 `UserProfile.homeCountryRaw`) — 비면 일하는 나라 안의 다른 지역(`homeRegionCode`)
    static var homeCountryCode: String {
        get { UserDefaults.standard.string(forKey: "homeHolidayCountry") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "homeHolidayCountry") }
    }

    /// 사는 곳 공휴일에도 쉬는지 — 기본은 아니다(연차는 일하는 곳 기준)
    static var homeHolidaysAreDaysOff: Bool {
        get { UserDefaults.standard.bool(forKey: "homeHolidaysDaysOff") }
        set { UserDefaults.standard.set(newValue, forKey: "homeHolidaysDaysOff") }
    }

    /// 공휴일 앞뒤로 휴가를 낼 수 없는 근무일 수 (0 = 제한 없음) — 공무원 등 직장 규정
    static var leaveBlackoutDays: Int {
        get { UserDefaults.standard.integer(forKey: "holidayBlackoutDays") }
        set { UserDefaults.standard.set(newValue, forKey: "holidayBlackoutDays") }
    }

    /// 함께 볼 공휴일의 나라·지역 — 사는 곳(같은 나라 다른 지역) 또는 회사 본사가 있는 다른 나라.
    /// 일하는 곳과 같거나 고른 게 없으면 nil.
    static func homePlace(for country: Country) -> (country: Country, region: HolidayRegion?)? {
        if let other = Country(rawValue: homeCountryCode), other != country, other != .custom {
            let region = HolidayRegion.find(homeRegionCode).flatMap { $0.country == other ? $0 : nil }
            return (other, region)
        }
        guard let home = HolidayRegion.find(homeRegionCode), home.country == country,
              home.code != activeRegion(for: country)?.code else { return nil }
        return (country, home)
    }

    /// 달력 범례·날짜 상세에 쓸 함께 보는 곳 이름 (예: "카탈루냐", "🇩🇪 독일")
    static func homePlaceName(for country: Country) -> String? {
        guard let place = homePlace(for: country) else { return nil }
        if place.country == country { return place.region?.displayName }
        let name = place.region.map { "\(place.country.displayName) \($0.displayName)" } ?? place.country.displayName
        return "\(place.country.flag) \(name)"
    }

    /// 함께 보는 곳에만 있는 공휴일 — 일하는 곳 공휴일과 날짜가 겹치지 않는 것
    func homeOnlyHolidays(for year: Int, country: Country) -> [Holiday] {
        guard let place = Self.homePlace(for: country) else { return [] }
        let work = Set(getHolidays(for: year, country: country).map { dateKey($0.date) })
        // 다른 나라에 지역을 안 골랐으면 전국 공휴일 — 일하는 곳 지역은 그 나라 것이 아니라 끼어들지 않는다
        return getHolidays(for: year, country: place.country, region: place.region)
            .filter { !work.contains(dateKey($0.date)) }
    }

    /// 그 나라에 적용할 지역 — 고른 지역이 다른 나라 것이면 없다
    static func activeRegion(for country: Country) -> HolidayRegion? {
        guard let region = HolidayRegion.find(selectedRegionCode), region.country == country else { return nil }
        return region
    }

    /// 해당 연도의 공휴일 목록 반환 (국가별, 커스텀 포함)
    /// `region` 을 주면 고른 지역 대신 그 지역으로 계산한다 (사는 곳 공휴일용)
    func getHolidays(for year: Int, country: Country = .korea,
                     customHolidays: [CustomHoliday] = [],
                     hiddenDates: Set<String> = [],
                     region regionOverride: HolidayRegion? = nil) -> [Holiday] {
        let region = regionOverride?.code ?? Self.activeRegion(for: country)?.code
        // 이름이 앱 언어를 따르므로 언어도 키에 넣는다 — 실행 중 언어를 바꿔도 예전 이름이 남지 않게
        let baseKey = "\(year)-\(country.rawValue)-\(region ?? "")-\(AppLanguage.current.rawValue)"
        var result: [Holiday]
        if let cached = baseHolidaysCache[baseKey] {
            result = cached
        } else {
            switch country {
            case .korea:
                result = getKoreanHolidays(for: year)
            case .japan:
                result = getJapaneseHolidays(for: year)
            case .china:
                result = getChineseHolidays(for: year)
            case .usa:
                result = getUSAHolidays(for: year, region: region)
            case .germany:
                result = getGermanyHolidays(for: year, region: region)
            case .france:
                result = getFranceHolidays(for: year)
            case .uk:
                result = getUKHolidays(for: year, region: region)
            case .canada:
                result = getCanadaHolidays(for: year, region: region)
            case .australia:
                result = getAustraliaHolidays(for: year, region: region)
            case .spain:
                result = getSpainHolidays(for: year, region: region)
            case .italy:
                result = getItalyHolidays(for: year)
            case .brazil:
                result = getBrazilHolidays(for: year)
            case .taiwan:
                result = getTaiwanHolidays(for: year)
            case .hongKong:
                result = getHongKongHolidays(for: year)
            case .uae:
                result = getUAEHolidays(for: year)
            case .saudiArabia:
                result = getSaudiArabiaHolidays(for: year)
            case .qatar:
                result = getQatarHolidays(for: year)
            case .peru:
                result = getPeruHolidays(for: year)
            case .netherlands:
                result = getNetherlandsHolidays(for: year)
            case .belgium:
                result = getBelgiumHolidays(for: year)
            case .austria:
                result = getAustriaHolidays(for: year)
            case .switzerland:
                result = getSwitzerlandHolidays(for: year)
            case .ireland:
                result = getIrelandHolidays(for: year)
            case .portugal:
                result = getPortugalHolidays(for: year)
            case .sweden:
                result = getSwedenHolidays(for: year)
            case .norway:
                result = getNorwayHolidays(for: year)
            case .denmark:
                result = getDenmarkHolidays(for: year)
            case .finland:
                result = getFinlandHolidays(for: year)
            case .poland:
                result = getPolandHolidays(for: year)
            case .czechia:
                result = getCzechiaHolidays(for: year)
            case .greece:
                result = getGreeceHolidays(for: year)
            case .turkey:
                result = getTurkeyHolidays(for: year)
            case .egypt:
                result = getEgyptHolidays(for: year)
            case .southAfrica:
                result = getSouthAfricaHolidays(for: year)
            case .mexico:
                result = getMexicoHolidays(for: year)
            case .argentina:
                result = getArgentinaHolidays(for: year)
            case .chile:
                result = getChileHolidays(for: year)
            case .colombia:
                result = getColombiaHolidays(for: year)
            case .newZealand:
                result = getNewZealandHolidays(for: year)
            case .russia:
                result = getRussiaHolidays(for: year)
            case .indonesia:
                result = getIndonesiaHolidays(for: year)
            case .custom:
                result = []   // 전부 사용자가 직접 넣는다
            }
            baseHolidaysCache[baseKey] = result
        }

        // hiddenDates·customHolidays는 매번 동적이므로 캐시 후 적용
        if !hiddenDates.isEmpty {
            result = result.filter { !hiddenDates.contains(dateKey($0.date)) }
        }
        if !customHolidays.isEmpty {
            result.append(contentsOf: customHolidays.compactMap { custom in
                custom.occurrence(in: year, calendar: calendar).map {
                    Holiday(date: $0, name: custom.name, isCustom: true)
                }
            })
            result.sort { $0.date < $1.date }
        }
        return result
    }

    // MARK: - 한국 공휴일

    private func getKoreanHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []

        // 고정 공휴일
        holidays.append(contentsOf: getKoreanFixedHolidays(for: year))

        // 음력 공휴일 (설날, 추석, 부처님오신날)
        holidays.append(contentsOf: getKoreanLunarHolidays(for: year))

        // 특별 공휴일 (선거일 등 임시 지정)
        holidays.append(contentsOf: getKoreanSpecialHolidays(for: year))

        // 대체공휴일 계산
        holidays.append(contentsOf: getKoreanSubstituteHolidays(holidays: holidays, year: year))

        return holidays.sorted { $0.date < $1.date }
    }

    private func getKoreanSpecialHolidays(for year: Int) -> [Holiday] {
        let lang = AppLanguage.current

        // 선거일 등 연도별 임시 공휴일
        // (month, day, names)
        let specialData: [Int: [(month: Int, day: Int, names: [AppLanguage: String])]] = [
            2025: [
                (6, 3, [.korean: "대통령선거일", .english: "Presidential Election Day", .japanese: "大統領選挙日", .chinese: "总统选举日"])
            ],
            2026: [
                // 9회 전국동시지방선거 — 2026-06-03 (수요일) 임시공휴일
                (6, 3, [.korean: "지방선거일", .english: "Local Election Day", .japanese: "地方選挙日", .chinese: "地方选举日"])
            ],
            2028: [
                // 23대 국회의원선거 — 임기만료(5/29) 전 50일 이후 첫 수요일
                (4, 12, [.korean: "국회의원선거일", .english: "National Assembly Election Day", .japanese: "国会議員選挙日", .chinese: "国会议员选举日"])
            ],
            2030: [
                // 10회 전국동시지방선거 — 임기만료(6/30) 전 30일 이후 첫 수요일
                (6, 5, [.korean: "지방선거일", .english: "Local Election Day", .japanese: "地方選挙日", .chinese: "地方选举日"])
            ]
        ]

        guard let yearData = specialData[year] else { return [] }

        return yearData.compactMap { special in
            var components = DateComponents()
            components.year = year
            components.month = special.month
            components.day = special.day
            guard let date = calendar.date(from: components) else { return nil }
            return Holiday(date: date, name: special.names[lang] ?? special.names[.english]!)
        }
    }

    private func getKoreanFixedHolidays(for year: Int) -> [Holiday] {
        let lang = AppLanguage.current
        var fixedDates: [(month: Int, day: Int, names: [AppLanguage: String])] = [
            (1, 1, [.korean: "신정", .english: "New Year's Day", .japanese: "元日", .chinese: "元旦"]),
            (3, 1, [.korean: "삼일절", .english: "Independence Movement Day", .japanese: "三一節", .chinese: "三一节"]),
            (5, 1, [.korean: "근로자의 날", .english: "Workers' Day", .japanese: "労働者の日", .chinese: "劳动节"]),
            (5, 5, [.korean: "어린이날", .english: "Children's Day", .japanese: "こどもの日", .chinese: "儿童节"]),
            (6, 6, [.korean: "현충일", .english: "Memorial Day", .japanese: "顕忠日", .chinese: "显忠日"]),
            (8, 15, [.korean: "광복절", .english: "Liberation Day", .japanese: "光復節", .chinese: "光复节"]),
            (10, 3, [.korean: "개천절", .english: "National Foundation Day", .japanese: "開天節", .chinese: "开天节"]),
            (10, 9, [.korean: "한글날", .english: "Hangul Day", .japanese: "ハングルの日", .chinese: "韩文日"]),
            (12, 25, [.korean: "크리스마스", .english: "Christmas", .japanese: "クリスマス", .chinese: "圣诞节"])
        ]

        // 제헌절(7/17): 2008년 주5일제 도입으로 공휴일에서 제외됐다가
        // 2025-01-29 공휴일법 개정안 통과로 2026년부터 18년 만에 공휴일 재지정.
        if year >= 2026 {
            fixedDates.append((7, 17, [.korean: "제헌절", .english: "Constitution Day", .japanese: "制憲節", .chinese: "制宪节"]))
        }

        return fixedDates.compactMap { fixed in
            var components = DateComponents()
            components.year = year
            components.month = fixed.month
            components.day = fixed.day
            guard let date = calendar.date(from: components) else { return nil }
            return Holiday(date: date, name: fixed.names[lang] ?? fixed.names[.english]!)
        }
    }

    private func getKoreanLunarHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        let lang = AppLanguage.current

        let lunarHolidayData: [Int: [(month: Int, day: Int, key: String, duration: Int)]] = [
            2024: [(2, 9, "seollal", 3), (5, 15, "buddha", 1), (9, 16, "chuseok", 3)],
            2025: [(1, 28, "seollal", 3), (5, 5, "buddha", 1), (10, 5, "chuseok", 3)],
            2026: [(2, 16, "seollal", 3), (5, 24, "buddha", 1), (9, 24, "chuseok", 3)],
            2027: [(2, 6, "seollal", 3), (5, 13, "buddha", 1), (9, 14, "chuseok", 3)],
            2028: [(1, 26, "seollal", 3), (5, 2, "buddha", 1), (10, 2, "chuseok", 3)],
            2029: [(2, 12, "seollal", 3), (5, 20, "buddha", 1), (9, 21, "chuseok", 3)],
            2030: [(2, 2, "seollal", 3), (5, 9, "buddha", 1), (9, 11, "chuseok", 3)]
        ]

        let nameMap: [String: [AppLanguage: (main: String, holiday: String)]] = [
            "seollal": [
                .korean: ("설날", "설날 연휴"),
                .english: ("Seollal", "Seollal Holiday"),
                .japanese: ("ソルラル", "ソルラル連休"),
                .chinese: ("春节", "春节假期")
            ],
            "chuseok": [
                .korean: ("추석", "추석 연휴"),
                .english: ("Chuseok", "Chuseok Holiday"),
                .japanese: ("秋夕", "秋夕連休"),
                .chinese: ("中秋节", "中秋节假期")
            ],
            "buddha": [
                .korean: ("부처님오신날", "부처님오신날"),
                .english: ("Buddha's Birthday", "Buddha's Birthday"),
                .japanese: ("釈迦誕生日", "釈迦誕生日"),
                .chinese: ("佛诞日", "佛诞日")
            ]
        ]

        guard let yearData = lunarHolidayData[year] else {
            return getDefaultKoreanLunarHolidays(for: year)
        }

        for holiday in yearData {
            var components = DateComponents()
            components.year = year
            components.month = holiday.month
            components.day = holiday.day

            guard let startDate = calendar.date(from: components) else { continue }
            let names = nameMap[holiday.key]?[lang] ?? nameMap[holiday.key]?[.english] ?? ("Holiday", "Holiday")

            if holiday.duration > 1 {
                for i in 0..<holiday.duration {
                    if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                        let dayName = i == 1 ? names.main : names.holiday
                        holidays.append(Holiday(date: date, name: dayName))
                    }
                }
            } else {
                holidays.append(Holiday(date: startDate, name: names.main))
            }
        }

        return holidays
    }

    private func getDefaultKoreanLunarHolidays(for year: Int) -> [Holiday] {
        let lang = AppLanguage.current
        var holidays: [Holiday] = []
        var components = DateComponents()
        components.year = year

        let seollalMain = lang == .korean ? "설날" : (lang == .japanese ? "ソルラル" : (lang == .chinese ? "春节" : "Seollal"))
        let seollalHoliday = lang == .korean ? "설날 연휴" : (lang == .japanese ? "ソルラル連休" : (lang == .chinese ? "春节假期" : "Seollal Holiday"))
        let chuseokMain = lang == .korean ? "추석" : (lang == .japanese ? "秋夕" : (lang == .chinese ? "中秋节" : "Chuseok"))
        let chuseokHoliday = lang == .korean ? "추석 연휴" : (lang == .japanese ? "秋夕連休" : (lang == .chinese ? "中秋节假期" : "Chuseok Holiday"))
        let buddhaName = lang == .korean ? "부처님오신날" : (lang == .japanese ? "釈迦誕生日" : (lang == .chinese ? "佛诞日" : "Buddha's Birthday"))

        components.month = 2; components.day = 1
        if let date = calendar.date(from: components) {
            for i in -1...1 {
                if let d = calendar.date(byAdding: .day, value: i, to: date) {
                    holidays.append(Holiday(date: d, name: i == 0 ? seollalMain : seollalHoliday))
                }
            }
        }

        components.month = 5; components.day = 15
        if let date = calendar.date(from: components) {
            holidays.append(Holiday(date: date, name: buddhaName))
        }

        components.month = 9; components.day = 15
        if let date = calendar.date(from: components) {
            for i in -1...1 {
                if let d = calendar.date(byAdding: .day, value: i, to: date) {
                    holidays.append(Holiday(date: d, name: i == 0 ? chuseokMain : chuseokHoliday))
                }
            }
        }

        return holidays
    }

    private func getKoreanSubstituteHolidays(holidays: [Holiday], year: Int) -> [Holiday] {
        var substituteHolidays: [Holiday] = []
        let lang = AppLanguage.current

        // 「관공서의 공휴일에 관한 규정」 제3조 대체공휴일 기준
        // - 토·일 또는 다른 공휴일과 겹치면: 삼일절·광복절·개천절·한글날·어린이날·부처님오신날·크리스마스·제헌절
        //   (부처님오신날·크리스마스는 2023년 개정으로 토요일까지 확대)
        // - 일요일 또는 다른 공휴일과 겹치면: 설날 연휴·추석 연휴
        // - 적용 제외: 신정·현충일·근로자의 날(관공서 공휴일 아님)
        let weekendEligible: [AppLanguage: [String]] = [
            .korean:   ["삼일절", "광복절", "개천절", "한글날", "어린이날", "부처님오신날", "제헌절", "크리스마스"],
            .english:  ["Independence Movement Day", "Liberation Day", "National Foundation Day", "Hangul Day", "Children's Day", "Buddha's Birthday", "Constitution Day", "Christmas"],
            .japanese: ["三一節", "光復節", "開天節", "ハングルの日", "こどもの日", "釈迦誕生日", "制憲節", "クリスマス"],
            .chinese:  ["三一节", "光复节", "开天节", "韩文日", "儿童节", "佛诞日", "制宪节", "圣诞节"]
        ]
        let sundayOnlyEligible: [AppLanguage: [String]] = [
            .korean:   ["설날", "설날 연휴", "추석", "추석 연휴"],
            .english:  ["Seollal", "Seollal Holiday", "Chuseok", "Chuseok Holiday"],
            .japanese: ["ソルラル", "ソルラル連休", "秋夕", "秋夕連休"],
            .chinese:  ["春节", "春节假期", "中秋节", "中秋节假期"]
        ]

        let weekendNames = weekendEligible[lang] ?? weekendEligible[.english]!
        let sundayNames = sundayOnlyEligible[lang] ?? sundayOnlyEligible[.english]!

        let subLabel: String
        switch lang {
        case .korean: subLabel = "대체공휴일"
        case .english: subLabel = "Substitute Holiday"
        case .swedish: subLabel = "Ersättningshelgdag"
        case .norwegian: subLabel = "Erstatningsfridag"
        case .danish: subLabel = "Erstatningshelligdag"
        case .finnish: subLabel = "Korvaava vapaapäivä"
        case .polish: subLabel = "Święto zastępcze"
        case .czech: subLabel = "Náhradní volno"
        case .greek: subLabel = "Αναπληρωματική αργία"
        case .turkish: subLabel = "İkame Tatil"
        case .russian: subLabel = "Перенесённый выходной"
        case .indonesian: subLabel = "Libur Pengganti"
        case .dutch: subLabel = "Vervangende feestdag"
        case .japanese: subLabel = "振替休日"
        case .chinese: subLabel = "补休日"
        case .german: subLabel = "Ersatzfeiertag"
        case .french: subLabel = "Jour férié de remplacement"
        case .spanish: subLabel = "Festivo trasladado"
        case .italian: subLabel = "Festività sostitutiva"
        case .portuguese: subLabel = "Feriado transferido"
        case .chineseTraditional: subLabel = "補假"
        }

        // 대체공휴일이 필요한 (공휴일, 개수) — 날짜 순서대로 처리해야 앞선 대체일을 피해 간다
        var triggers: [Holiday] = []
        let byDay = Dictionary(grouping: holidays) { dateKey($0.date) }
        for key in byDay.keys.sorted() {
            let sameDay = byDay[key]!
            let weekday = calendar.component(.weekday, from: sameDay[0].date)
            let isSunday = weekday == 1
            let isSaturday = weekday == 7
            let isWeekendEligible = { (h: Holiday) in weekendNames.contains { h.name.contains($0) } }
            let isSundayEligible = { (h: Holiday) in sundayNames.contains { h.name.contains($0) } }
            let eligible = sameDay.filter { isWeekendEligible($0) || isSundayEligible($0) }
            guard !eligible.isEmpty else { continue }

            if isSunday || isSaturday {
                // 토·일 적용 대상은 주말 전체, 설·추석은 일요일에만
                triggers += eligible.filter { isWeekendEligible($0) || isSunday }
                // 주말에 공휴일끼리 또 겹쳐도 대상 수만큼만 — 위에서 이미 하나씩 세었다
            } else if sameDay.count > 1 {
                // 평일에 공휴일이 겹치면(예: 2025 어린이날=부처님오신날, 2028 추석=개천절) 하나가 밀린다
                triggers += Array(eligible.prefix(sameDay.count - 1))
            }
        }

        for holiday in triggers {

            // 겹치지 않는 첫 평일을 대체공휴일로 지정
            var nextDay = calendar.date(byAdding: .day, value: 1, to: holiday.date)!
            while true {
                let nextWeekday = calendar.component(.weekday, from: nextDay)
                let isAlreadyHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: nextDay) }
                let isAlreadySubstitute = substituteHolidays.contains { calendar.isDate($0.date, inSameDayAs: nextDay) }

                if nextWeekday != 1 && nextWeekday != 7 && !isAlreadyHoliday && !isAlreadySubstitute {
                    substituteHolidays.append(Holiday(
                        date: nextDay,
                        name: "\(holiday.name) \(subLabel)",
                        isSubstitute: true
                    ))
                    break
                }

                nextDay = calendar.date(byAdding: .day, value: 1, to: nextDay)!
            }
        }

        return substituteHolidays
    }

    // MARK: - 일본 공휴일

    private func getJapaneseHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        let lang = AppLanguage.current

        // Fixed holidays
        let fixed: [(month: Int, day: Int, names: [AppLanguage: String])] = [
            (1, 1, [.korean: "설날", .english: "New Year's Day", .japanese: "元日", .chinese: "元旦"]),
            (2, 11, [.korean: "건국기념일", .english: "National Foundation Day", .japanese: "建国記念の日", .chinese: "建国纪念日"]),
            (2, 23, [.korean: "천황탄생일", .english: "Emperor's Birthday", .japanese: "天皇誕生日", .chinese: "天皇诞辰"]),
            (4, 29, [.korean: "쇼와의 날", .english: "Showa Day", .japanese: "昭和の日", .chinese: "昭和日"]),
            (5, 3, [.korean: "헌법기념일", .english: "Constitution Memorial Day", .japanese: "憲法記念日", .chinese: "宪法纪念日"]),
            (5, 4, [.korean: "녹색의 날", .english: "Greenery Day", .japanese: "みどりの日", .chinese: "绿之日"]),
            (5, 5, [.korean: "어린이날", .english: "Children's Day", .japanese: "こどもの日", .chinese: "儿童节"]),
            (8, 11, [.korean: "산의 날", .english: "Mountain Day", .japanese: "山の日", .chinese: "山之日"]),
            (11, 3, [.korean: "문화의 날", .english: "Culture Day", .japanese: "文化の日", .chinese: "文化日"]),
            (11, 23, [.korean: "근로감사의 날", .english: "Labor Thanksgiving Day", .japanese: "勤労感謝の日", .chinese: "勤劳感谢日"])
        ]

        for f in fixed {
            var comp = DateComponents()
            comp.year = year; comp.month = f.month; comp.day = f.day
            if let date = calendar.date(from: comp) {
                holidays.append(Holiday(date: date, name: f.names[lang] ?? f.names[.english]!))
            }
        }

        // Happy Monday holidays
        // Coming of Age Day: 2nd Monday of January
        let comingOfAgeName: [AppLanguage: String] = [.korean: "성인의 날", .english: "Coming of Age Day", .japanese: "成人の日", .chinese: "成人日"]
        if let d = nthWeekday(nth: 2, weekday: 2, month: 1, year: year) {
            holidays.append(Holiday(date: d, name: comingOfAgeName[lang] ?? comingOfAgeName[.english]!))
        }

        // Marine Day: 3rd Monday of July
        let marineName: [AppLanguage: String] = [.korean: "바다의 날", .english: "Marine Day", .japanese: "海の日", .chinese: "海之日"]
        if let d = nthWeekday(nth: 3, weekday: 2, month: 7, year: year) {
            holidays.append(Holiday(date: d, name: marineName[lang] ?? marineName[.english]!))
        }

        // Respect for the Aged Day: 3rd Monday of September
        let agedName: [AppLanguage: String] = [.korean: "경로의 날", .english: "Respect for the Aged Day", .japanese: "敬老の日", .chinese: "敬老日"]
        if let d = nthWeekday(nth: 3, weekday: 2, month: 9, year: year) {
            holidays.append(Holiday(date: d, name: agedName[lang] ?? agedName[.english]!))
        }

        // Sports Day: 2nd Monday of October
        let sportsName: [AppLanguage: String] = [.korean: "스포츠의 날", .english: "Sports Day", .japanese: "スポーツの日", .chinese: "体育日"]
        if let d = nthWeekday(nth: 2, weekday: 2, month: 10, year: year) {
            holidays.append(Holiday(date: d, name: sportsName[lang] ?? sportsName[.english]!))
        }

        // Vernal Equinox (~March 20-21)
        let vernalName: [AppLanguage: String] = [.korean: "춘분", .english: "Vernal Equinox", .japanese: "春分の日", .chinese: "春分"]
        let vernalDay = vernalEquinoxDay(year: year)
        var comp = DateComponents(); comp.year = year; comp.month = 3; comp.day = vernalDay
        if let date = calendar.date(from: comp) {
            holidays.append(Holiday(date: date, name: vernalName[lang] ?? vernalName[.english]!))
        }

        // Autumnal Equinox (~September 22-23)
        let autumnalName: [AppLanguage: String] = [.korean: "추분", .english: "Autumnal Equinox", .japanese: "秋分の日", .chinese: "秋分"]
        let autumnalDay = autumnalEquinoxDay(year: year)
        comp = DateComponents(); comp.year = year; comp.month = 9; comp.day = autumnalDay
        if let date = calendar.date(from: comp) {
            holidays.append(Holiday(date: date, name: autumnalName[lang] ?? autumnalName[.english]!))
        }

        // Japanese substitute holiday rule: if holiday falls on Sunday, next Monday is off
        holidays.append(contentsOf: getJapaneseSubstituteHolidays(holidays: holidays))

        return holidays.sorted { $0.date < $1.date }
    }

    private func getJapaneseSubstituteHolidays(holidays: [Holiday]) -> [Holiday] {
        var substitutes: [Holiday] = []
        let lang = AppLanguage.current
        let subLabel: String = {
            switch lang {
            case .korean: return "대체휴일"
            case .english: return "Substitute Holiday"
            case .swedish: return "Ersättningshelgdag"
            case .norwegian: return "Erstatningsfridag"
            case .danish: return "Erstatningshelligdag"
            case .finnish: return "Korvaava vapaapäivä"
            case .polish: return "Święto zastępcze"
            case .czech: return "Náhradní volno"
            case .greek: return "Αναπληρωματική αργία"
            case .turkish: return "Telafi Tatili"
            case .russian: return "Перенесённый выходной"
            case .indonesian: return "Libur Pengganti"
            case .dutch: return "Vervangende feestdag"
            case .japanese: return "振替休日"
            case .chinese: return "补休日"
            case .german: return "Ersatzfeiertag"
            case .french: return "Jour férié de remplacement"
            case .spanish: return "Festivo trasladado"
            case .italian: return "Festività sostitutiva"
            case .portuguese: return "Feriado transferido"
            case .chineseTraditional: return "補假"
            }
        }()

        let isTaken = { (d: Date) in
            holidays.contains { self.calendar.isDate($0.date, inSameDayAs: d) }
                || substitutes.contains { self.calendar.isDate($0.date, inSameDayAs: d) }
        }

        // 振替休日: 일요일 공휴일 → 그 뒤 첫 번째 "공휴일이 아닌 날" (예: 2026-05-03(일) → 5/6(수))
        for holiday in holidays.sorted(by: { $0.date < $1.date }) where calendar.component(.weekday, from: holiday.date) == 1 {
            var next = calendar.date(byAdding: .day, value: 1, to: holiday.date)!
            while isTaken(next) { next = calendar.date(byAdding: .day, value: 1, to: next)! }
            substitutes.append(Holiday(date: next, name: subLabel, isSubstitute: true))
        }

        // 国民の休日: 앞뒤가 모두 공휴일인 평일 (예: 2026-09-22 — 敬老の日과 秋分の日 사이)
        let citizensLabel: String = {
            switch lang {
            case .korean: return "국민의 휴일"
            case .english: return "Citizens' Holiday"
            case .swedish: return "Medborgarnas helgdag"
            case .norwegian: return "Borgernes fridag"
            case .danish: return "Folkets fridag"
            case .finnish: return "Kansalaisten vapaapäivä"
            case .polish: return "Święto obywatelskie"
            case .czech: return "Občanský svátek"
            case .greek: return "Αργία των πολιτών"
            case .turkish: return "Vatandaş Tatili"
            case .russian: return "Народный выходной"
            case .indonesian: return "Hari Libur Warga"
            case .dutch: return "Burgerfeestdag"
            case .japanese: return "国民の休日"
            case .chinese: return "国民休息日"
            case .german: return "Brückenfeiertag"
            case .french: return "Jour férié intercalaire"
            case .spanish: return "Festivo intermedio"
            case .italian: return "Festività intermedia"
            case .portuguese: return "Feriado intercalado"
            case .chineseTraditional: return "國民休假日"
            }
        }()
        for holiday in holidays {
            guard let mid = calendar.date(byAdding: .day, value: 1, to: holiday.date),
                  let after = calendar.date(byAdding: .day, value: 2, to: holiday.date),
                  calendar.component(.weekday, from: mid) != 1,
                  !isTaken(mid),
                  holidays.contains(where: { calendar.isDate($0.date, inSameDayAs: after) }) else { continue }
            substitutes.append(Holiday(date: mid, name: citizensLabel, isSubstitute: true))
        }
        return substitutes
    }

    // MARK: - 중국 공휴일

    /// 국무원이 매년 11월께 발표하는 **실제 휴무 기간**(调休 반영). 발표된 연도만 수록한다.
    /// (key, 시작 월, 시작 일, 일수) — key는 아래 이름표와 같다.
    private static let chinaOfficialSchedule: [Int: [(key: String, month: Int, day: Int, days: Int)]] = [
        2024: [("newYear", 1, 1, 1), ("spring", 2, 10, 8), ("qingming", 4, 4, 3), ("labor", 5, 1, 5),
               ("dragon", 6, 8, 3), ("midAutumn", 9, 15, 3), ("national", 10, 1, 7)],
        2025: [("newYear", 1, 1, 1), ("spring", 1, 28, 8), ("qingming", 4, 4, 3), ("labor", 5, 1, 5),
               ("dragon", 5, 31, 3), ("national", 10, 1, 8)],
        2026: [("newYear", 1, 1, 3), ("spring", 2, 15, 9), ("qingming", 4, 4, 3), ("labor", 5, 1, 5),
               ("dragon", 6, 19, 3), ("midAutumn", 9, 25, 3), ("national", 10, 1, 7)],
    ]

    /// 발표된 휴무표가 있는 마지막 연도 — 이후 연도는 음력 기준 추정치다.
    static let chinaOfficialLastYear = 2026

    /// 调休로 주말인데 출근하는 날(补班) (월, 일) — 같은 국무원 발표 원문. 발표된 연도만 수록한다.
    private static let chinaMakeupWorkdays: [Int: [(month: Int, day: Int)]] = [
        2024: [(2, 4), (2, 18), (4, 7), (4, 28), (5, 11), (9, 14), (9, 29), (10, 12)],
        2025: [(1, 26), (2, 8), (4, 27), (9, 28), (10, 11)],
        2026: [(1, 4), (2, 14), (2, 28), (5, 9), (9, 20), (10, 10)],
    ]

    /// 러시아 휴일 이동으로 출근하는 토요일 (рабочая суббота) — 같은 정부 결정 원문
    private static let russiaMakeupWorkdays: [Int: [(month: Int, day: Int)]] = [
        2025: [(11, 1)],
        2027: [(2, 20)],
    ]

    private static func makeupTable(_ country: Country) -> [Int: [(month: Int, day: Int)]] {
        switch country {
        case .china: return chinaMakeupWorkdays
        case .russia: return russiaMakeupWorkdays
        default: return [:]
        }
    }

    /// 주말이지만 출근하는 날인지 (중국 调休 补班 · 러시아 рабочая суббота)
    static func isMakeupWorkday(_ date: Date, country: Country, calendar: Calendar = .current) -> Bool {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = c.year, let days = makeupTable(country)[year] else { return false }
        return days.contains { $0.month == c.month && $0.day == c.day }
    }

    /// 내가 고른 주말 — "" 이면 나라 기본, "none" 이면 주말 없이 매일 근무, 아니면 "7,1" 같은 요일 목록.
    /// 원본은 UserDefaults — 프로필을 모르는 곳에서도 같은 값을 쓴다. (키 이름은 직접 입력 국가 전용이던 때 그대로)
    static var weekendOverrideRaw: String {
        get { UserDefaults.standard.string(forKey: "customWeekendDays") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "customWeekendDays") }
    }

    /// 내가 고른 주 시작 요일 — 0 이면 나라 기본, 아니면 Calendar weekday(1=일, 2=월, 7=토)
    static var firstWeekdayOverride: Int {
        UserDefaults.standard.integer(forKey: "firstWeekday")
    }

    /// 달력 첫 칸의 요일. 내가 고른 값이 있으면 그것, 없으면 나라 기본.
    static func firstWeekday(for country: Country, override: Int = firstWeekdayOverride) -> Int {
        (1...7).contains(override) ? override : country.standardFirstWeekday
    }

    /// 저장값 → 주말 요일. 나라 기본을 따르면 nil.
    static func parseWeekend(_ raw: String) -> Set<Int>? {
        if raw == "none" { return [] }
        let days = Set(raw.split(separator: ",").compactMap { Int($0) }.filter { (1...7).contains($0) })
        return days.isEmpty ? nil : days
    }

    /// 그 나라에서 쉬는 주말 요일 (Calendar weekday: 1=일 … 7=토). 내가 고른 값이 있으면 그것.
    static func weekendDays(for country: Country) -> Set<Int> {
        parseWeekend(weekendOverrideRaw) ?? country.standardWeekendDays
    }

    /// 요일만 보고 주말인지 — 보충 근무일은 따지지 않는다 (달력 색칠용)
    static func isWeekendDay(_ date: Date, country: Country, calendar: Calendar = .current) -> Bool {
        weekendDays(for: country).contains(calendar.component(.weekday, from: date))
    }

    /// 쉬는 주말인지 — 그 나라 주말 중 보충 근무일이 아닌 날
    static func isRestWeekend(_ date: Date, country: Country, calendar: Calendar = .current) -> Bool {
        isWeekendDay(date, country: country, calendar: calendar) && !isMakeupWorkday(date, country: country, calendar: calendar)
    }

    /// 한 해의 보충 근무일 (startOfDay) — 연휴 플래너용
    static func makeupWorkdays(for year: Int, country: Country, calendar: Calendar = .current) -> Set<Date> {
        guard let days = makeupTable(country)[year] else { return [] }
        return Set(days.compactMap { calendar.date(from: DateComponents(year: year, month: $0.month, day: $0.day)) })
    }

    private func getChineseHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        let lang = AppLanguage.current

        let names: [String: [AppLanguage: String]] = [
            "newYear": [.korean: "신정", .english: "New Year's Day", .japanese: "元日", .chinese: "元旦"],
            "spring": [.korean: "춘절", .english: "Spring Festival", .japanese: "春節", .chinese: "春节"],
            "qingming": [.korean: "청명절", .english: "Qingming Festival", .japanese: "清明節", .chinese: "清明节"],
            "labor": [.korean: "노동절", .english: "Labor Day", .japanese: "メーデー", .chinese: "劳动节"],
            "dragon": [.korean: "단오절", .english: "Dragon Boat Festival", .japanese: "端午節", .chinese: "端午节"],
            "midAutumn": [.korean: "중추절", .english: "Mid-Autumn Festival", .japanese: "中秋節", .chinese: "中秋节"],
            "national": [.korean: "국경절", .english: "National Day", .japanese: "国慶節", .chinese: "国庆节"],
        ]

        if let schedule = Self.chinaOfficialSchedule[year] {
            for item in schedule {
                var comp = DateComponents(); comp.year = year; comp.month = item.month; comp.day = item.day
                guard let start = calendar.date(from: comp) else { continue }
                let name = names[item.key]?[lang] ?? names[item.key]?[.english] ?? ""
                for i in 0..<item.days {
                    if let d = calendar.date(byAdding: .day, value: i, to: start) {
                        holidays.append(Holiday(date: d, name: name))
                    }
                }
            }
            return holidays.sorted { $0.date < $1.date }
        }

        // ── 발표 전 연도: 법정 휴일 + 관행으로 추정 (调休로 실제와 다를 수 있다 → 달력에 안내 배너)
        var taken = Set<String>()
        func add(_ key: String, _ date: Date, days: Int) {
            let name = names[key]?[lang] ?? names[key]?[.english] ?? ""
            for i in 0..<days {
                guard let d = calendar.date(byAdding: .day, value: i, to: date), taken.insert(dateKey(d)).inserted else { continue }
                holidays.append(Holiday(date: d, name: name))
            }
        }
        func date(_ month: Int, _ day: Int) -> Date? {
            var c = DateComponents(); c.year = year; c.month = month; c.day = day
            return calendar.date(from: c)
        }
        /// 하루짜리 명절은 주말과 붙여 3일로 쉬는 게 관행 — 월(토~월)·금(금~일)·토(토~월)·일(토~월)
        func addOneDay(_ key: String, _ d: Date) {
            switch calendar.component(.weekday, from: d) {
            case 2: add(key, calendar.date(byAdding: .day, value: -2, to: d)!, days: 3)
            case 6, 7: add(key, d, days: 3)
            case 1: add(key, calendar.date(byAdding: .day, value: -1, to: d)!, days: 3)
            default: add(key, d, days: 1)
            }
        }

        // 음력 명절 날짜 (춘절=정월 초하루, 청명, 단오, 중추)
        let lunar: [Int: (spring: (Int, Int), qingming: (Int, Int), dragon: (Int, Int), midAutumn: (Int, Int))] = [
            2027: ((2, 6), (4, 5), (6, 9), (9, 15)),
            2028: ((1, 26), (4, 4), (5, 28), (10, 3)),
            2029: ((2, 13), (4, 4), (6, 16), (9, 22)),
            2030: ((2, 3), (4, 5), (6, 5), (9, 12)),
        ]

        if let d = date(1, 1) { addOneDay("newYear", d) }
        if let l = lunar[year] {
            // 2025년 개정 후 관행: 섣달그믐(除夕)부터 초이레까지 8일
            if let cny = date(l.spring.0, l.spring.1), let eve = calendar.date(byAdding: .day, value: -1, to: cny) {
                add("spring", eve, days: 8)
            }
            if let d = date(l.qingming.0, l.qingming.1) { addOneDay("qingming", d) }
            if let d = date(l.dragon.0, l.dragon.1) { addOneDay("dragon", d) }
        }
        if let d = date(5, 1) { add("labor", d, days: 5) }
        // 중추절이 국경절 연휴에 걸리면 연휴가 8일로 늘어난다 (2025년 사례)
        if let l = lunar[year], let mid = date(l.midAutumn.0, l.midAutumn.1) {
            if l.midAutumn.0 == 10 || (l.midAutumn.0 == 9 && l.midAutumn.1 >= 29) {
                if let d = date(10, 1) { add("national", d, days: 8) }
                add("midAutumn", mid, days: 1)
            } else {
                addOneDay("midAutumn", mid)
                if let d = date(10, 1) { add("national", d, days: 7) }
            }
        } else if let d = date(10, 1) {
            add("national", d, days: 7)
        }

        // 주말과 붙인 신정이 전년도로 넘어간 날은 뺀다 (어차피 주말)
        holidays.removeAll { calendar.component(.year, from: $0.date) != year }
        return holidays.sorted { $0.date < $1.date }
    }

    // MARK: - 미국 공휴일

    private func getUSAHolidays(for year: Int, region: String? = nil) -> [Holiday] {
        var holidays: [Holiday] = []
        let lang = AppLanguage.current

        // Fixed-date holidays
        let fixed: [(month: Int, day: Int, names: [AppLanguage: String])] = [
            (1, 1, [.korean: "새해", .english: "New Year's Day", .japanese: "元日", .chinese: "元旦"]),
            (6, 19, [.korean: "준틴스", .english: "Juneteenth", .japanese: "ジューンティーンス", .chinese: "六月节"]),
            (7, 4, [.korean: "독립기념일", .english: "Independence Day", .japanese: "独立記念日", .chinese: "独立日"]),
            (11, 11, [.korean: "재향군인의 날", .english: "Veterans Day", .japanese: "退役軍人の日", .chinese: "退伍军人日"]),
            (12, 25, [.korean: "크리스마스", .english: "Christmas", .japanese: "クリスマス", .chinese: "圣诞节"])
        ]

        for f in fixed {
            var comp = DateComponents()
            comp.year = year; comp.month = f.month; comp.day = f.day
            if let date = calendar.date(from: comp) {
                holidays.append(Holiday(date: date, name: f.names[lang] ?? f.names[.english]!))
            }
        }

        // MLK Day: 3rd Monday of January
        let mlkName: [AppLanguage: String] = [.korean: "마틴 루터 킹의 날", .english: "Martin Luther King Jr. Day", .japanese: "キング牧師記念日", .chinese: "马丁·路德·金日"]
        if let d = nthWeekday(nth: 3, weekday: 2, month: 1, year: year) {
            holidays.append(Holiday(date: d, name: mlkName[lang] ?? mlkName[.english]!))
        }

        // Presidents' Day: 3rd Monday of February
        let presidentsName: [AppLanguage: String] = [.korean: "대통령의 날", .english: "Presidents' Day", .japanese: "大統領の日", .chinese: "总统日"]
        if let d = nthWeekday(nth: 3, weekday: 2, month: 2, year: year) {
            holidays.append(Holiday(date: d, name: presidentsName[lang] ?? presidentsName[.english]!))
        }

        // Memorial Day: Last Monday of May
        let memorialName: [AppLanguage: String] = [.korean: "현충일", .english: "Memorial Day", .japanese: "メモリアルデー", .chinese: "阵亡将士纪念日"]
        if let d = lastWeekday(weekday: 2, month: 5, year: year) {
            holidays.append(Holiday(date: d, name: memorialName[lang] ?? memorialName[.english]!))
        }

        // Labor Day: 1st Monday of September
        let laborName: [AppLanguage: String] = [.korean: "노동절", .english: "Labor Day", .japanese: "レイバーデー", .chinese: "劳动节"]
        if let d = nthWeekday(nth: 1, weekday: 2, month: 9, year: year) {
            holidays.append(Holiday(date: d, name: laborName[lang] ?? laborName[.english]!))
        }

        // Columbus Day: 2nd Monday of October
        let columbusName: [AppLanguage: String] = [.korean: "콜럼버스의 날", .english: "Columbus Day", .japanese: "コロンブスデー", .chinese: "哥伦布日"]
        if let d = nthWeekday(nth: 2, weekday: 2, month: 10, year: year) {
            holidays.append(Holiday(date: d, name: columbusName[lang] ?? columbusName[.english]!))
        }

        // Thanksgiving: 4th Thursday of November
        let thanksgivingName: [AppLanguage: String] = [.korean: "추수감사절", .english: "Thanksgiving", .japanese: "感謝祭", .chinese: "感恩节"]
        if let d = nthWeekday(nth: 4, weekday: 5, month: 11, year: year) {
            holidays.append(Holiday(date: d, name: thanksgivingName[lang] ?? thanksgivingName[.english]!))
        }

        // 주 공휴일 — 하와이는 콜럼버스의 날을 쉬지 않는다
        let state = usStateHolidays(for: year, region: region)
        if state.dropsColumbusDay {
            if let d = nthWeekday(nth: 2, weekday: 2, month: 10, year: year) {
                holidays.removeAll { calendar.isDate($0.date, inSameDayAs: d) }
            }
        }
        holidays.append(contentsOf: state.holidays)

        // USA observed holiday: Sat->Fri, Sun->Mon
        holidays.append(contentsOf: getUSAObservedHolidays(holidays: holidays, extraFixedDays: state.fixedDays))
        // 1/1(토)의 대체일 12/31은 전년도 날짜 — 전년도 목록으로 옮긴다
        holidays.removeAll { calendar.component(.year, from: $0.date) != year }
        var nextNewYear = DateComponents(); nextNewYear.year = year + 1; nextNewYear.month = 1; nextNewYear.day = 1
        if let d = calendar.date(from: nextNewYear), calendar.component(.weekday, from: d) == 7,
           let dec31 = calendar.date(byAdding: .day, value: -1, to: d) {
            let name = fixed[0].names[lang] ?? fixed[0].names[.english]!
            holidays.append(Holiday(date: dec31, name: "\(name) (\(usObservedLabel))", isSubstitute: true))
        }

        return holidays.sorted { $0.date < $1.date }
    }

    /// 미국 대체 휴일 표기 ("Observed")
    private var usObservedLabel: String {
        switch AppLanguage.current {
        case .korean: return "대체휴일"
        case .english: return "Observed"
        case .swedish: return "Observerad"
        case .norwegian: return "Avspasert fridag"
        case .danish: return "Afholdt"
        case .finnish: return "Vietetään"
        case .polish: return "Obchodzone"
        case .czech: return "Přeloženo"
        case .greek: return "Τηρείται"
        case .turkish: return "Uygulanan Gün"
        case .russian: return "Перенесённый"
        case .indonesian: return "Pengganti"
        case .dutch: return "Vrije dag"
        case .japanese: return "振替"
        case .chinese: return "补休"
        case .german: return "Ersatztag"
        case .french: return "Jour observé"
        case .spanish: return "Trasladado"
        case .italian: return "Sostitutivo"
        case .portuguese: return "Transferido"
        case .chineseTraditional: return "補假"
        }
    }

    private func getUSAObservedHolidays(holidays: [Holiday], extraFixedDays: [(Int, Int)] = []) -> [Holiday] {
        var observed: [Holiday] = []
        let obsLabel = usObservedLabel

        // Only fixed-date holidays get observed adjustments
        let fixedDays: [(Int, Int)] = [(1,1), (6,19), (7,4), (11,11), (12,25)] + extraFixedDays
        let fixedDateHolidays = holidays.filter { h in
            let comp = calendar.dateComponents([.month, .day], from: h.date)
            return fixedDays.contains { $0.0 == comp.month && $0.1 == comp.day }
        }

        for holiday in fixedDateHolidays {
            let weekday = calendar.component(.weekday, from: holiday.date)
            if weekday == 7 { // Saturday -> Friday
                if let friday = calendar.date(byAdding: .day, value: -1, to: holiday.date) {
                    let alreadyExists = holidays.contains { calendar.isDate($0.date, inSameDayAs: friday) }
                        || observed.contains { calendar.isDate($0.date, inSameDayAs: friday) }
                    if !alreadyExists {
                        observed.append(Holiday(date: friday, name: "\(holiday.name) (\(obsLabel))", isSubstitute: true))
                    }
                }
            } else if weekday == 1 { // Sunday -> Monday
                if let monday = calendar.date(byAdding: .day, value: 1, to: holiday.date) {
                    let alreadyExists = holidays.contains { calendar.isDate($0.date, inSameDayAs: monday) }
                        || observed.contains { calendar.isDate($0.date, inSameDayAs: monday) }
                    if !alreadyExists {
                        observed.append(Holiday(date: monday, name: "\(holiday.name) (\(obsLabel))", isSubstitute: true))
                    }
                }
            }
        }

        return observed
    }

    // MARK: - 독일 공휴일 (Brückentag 최적화 타깃)
    // 전국 공통(연방) 공휴일 + 고른 주(Bundesland)의 공휴일 (`germanStateHolidays`).

    private func getGermanyHolidays(for year: Int, region: String? = nil) -> [Holiday] {
        let lang = AppLanguage.current
        var holidays: [Holiday] = []

        // 고정 공휴일 (연방 단위)
        let fixed: [(month: Int, day: Int, names: [AppLanguage: String])] = [
            (1, 1, [.korean: "신정", .english: "New Year's Day",
                    .japanese: "元日", .chinese: "元旦", .german: "Neujahr", .french: "Jour de l’an", .spanish: "Año Nuevo", .italian: "Capodanno", .portuguese: "Confraternização Universal", .chineseTraditional: "元旦"]),
            (5, 1, [.korean: "노동절", .english: "Labour Day",
                    .japanese: "メーデー", .chinese: "劳动节", .german: "Tag der Arbeit", .french: "Fête du Travail", .spanish: "Día del Trabajador", .italian: "Festa dei Lavoratori", .portuguese: "Dia do Trabalhador", .chineseTraditional: "勞動節"]),
            (10, 3, [.korean: "독일 통일의 날", .english: "German Unity Day",
                     .japanese: "ドイツ統一の日", .chinese: "德国统一日", .german: "Tag der Deutschen Einheit", .french: "Jour de l’Unité allemande", .spanish: "Día de la Unidad Alemana", .italian: "Giorno dell’unità tedesca", .portuguese: "Dia da Unidade Alemã", .chineseTraditional: "德國統一日"]),
            (12, 25, [.korean: "크리스마스", .english: "Christmas Day",
                      .japanese: "クリスマス", .chinese: "圣诞节", .german: "1. Weihnachtstag", .french: "Noël", .spanish: "Navidad", .italian: "Natale", .portuguese: "Natal", .chineseTraditional: "聖誕節"]),
            (12, 26, [.korean: "성 슈테판의 날", .english: "St. Stephen's Day",
                      .japanese: "聖シュテファンの日", .chinese: "圣斯德望日", .german: "2. Weihnachtstag", .french: "Saint-Étienne", .spanish: "San Esteban", .italian: "Santo Stefano", .portuguese: "Dia de Santo Estêvão", .chineseTraditional: "聖斯德望日"])
        ]
        for fx in fixed {
            var c = DateComponents()
            c.year = year; c.month = fx.month; c.day = fx.day
            if let d = calendar.date(from: c) {
                let name = fx.names[lang] ?? fx.names[.english]!
                holidays.append(Holiday(date: d, name: name))
            }
        }

        // 부활절 기반 가변 공휴일
        guard let easter = Self.easterSunday(year: year, calendar: calendar) else { return holidays.sorted { $0.date < $1.date } }
        let movableNames: [(offsetDays: Int, names: [AppLanguage: String])] = [
            (-2, [.korean: "성금요일", .english: "Good Friday",
                  .japanese: "聖金曜日", .chinese: "耶稣受难日", .german: "Karfreitag", .french: "Vendredi saint", .spanish: "Viernes Santo", .italian: "Venerdì Santo", .portuguese: "Sexta-feira Santa", .chineseTraditional: "耶穌受難節"]),                     // 부활절 -2일 (금)
            (1,  [.korean: "부활절 월요일", .english: "Easter Monday",
                  .japanese: "イースターマンデー", .chinese: "复活节星期一", .german: "Ostermontag", .french: "Lundi de Pâques", .spanish: "Lunes de Pascua", .italian: "Lunedì dell’Angelo", .portuguese: "Segunda-feira de Páscoa", .chineseTraditional: "復活節星期一"]),         // 부활절 +1일 (월)
            (39, [.korean: "예수 승천일", .english: "Ascension Day",
                  .japanese: "キリスト昇天祭", .chinese: "耶稣升天节", .german: "Christi Himmelfahrt", .french: "Ascension", .spanish: "Ascensión", .italian: "Ascensione", .portuguese: "Ascensão", .chineseTraditional: "耶穌升天節"]),               // 부활절 +39일 (목)
            (50, [.korean: "성령강림절 월요일", .english: "Whit Monday",
                  .japanese: "聖霊降臨祭月曜日", .chinese: "圣灵降临节星期一", .german: "Pfingstmontag", .french: "Lundi de Pentecôte", .spanish: "Lunes de Pentecostés", .italian: "Lunedì di Pentecoste", .portuguese: "Segunda-feira de Pentecostes", .chineseTraditional: "聖靈降臨節星期一"])         // 부활절 +50일 (월)
        ]
        for mv in movableNames {
            if let d = calendar.date(byAdding: .day, value: mv.offsetDays, to: easter) {
                let name = mv.names[lang] ?? mv.names[.english]!
                holidays.append(Holiday(date: d, name: name))
            }
        }

        holidays.append(contentsOf: germanStateHolidays(for: year, region: region, easter: easter))
        return holidays.sorted { $0.date < $1.date }
    }

    // MARK: - 프랑스 공휴일 (Faire le pont 최적화 타깃)
    private func getFranceHolidays(for year: Int) -> [Holiday] {
        let lang = AppLanguage.current
        var holidays: [Holiday] = []

        let fixed: [(month: Int, day: Int, names: [AppLanguage: String])] = [
            (1, 1, [.korean: "신정", .english: "New Year's Day",
                    .japanese: "元日", .chinese: "元旦", .german: "Neujahr", .french: "Jour de l’an", .spanish: "Año Nuevo", .italian: "Capodanno", .portuguese: "Confraternização Universal", .chineseTraditional: "元旦"]),
            (5, 1, [.korean: "노동절", .english: "Labour Day",
                    .japanese: "メーデー", .chinese: "劳动节", .german: "Tag der Arbeit", .french: "Fête du Travail", .spanish: "Día del Trabajador", .italian: "Festa dei Lavoratori", .portuguese: "Dia do Trabalhador", .chineseTraditional: "勞動節"]),
            (5, 8, [.korean: "전승기념일", .english: "Victory in Europe Day",
                    .japanese: "戦勝記念日", .chinese: "胜利日", .german: "Tag des Sieges", .french: "Victoire 1945", .spanish: "Día de la Victoria", .italian: "Giorno della Vittoria", .portuguese: "Dia da Vitória", .chineseTraditional: "歐戰勝利紀念日"]),
            (7, 14, [.korean: "혁명기념일", .english: "Bastille Day",
                     .japanese: "革命記念日", .chinese: "国庆日", .german: "Französischer Nationalfeiertag", .french: "Fête nationale", .spanish: "Fiesta Nacional de Francia", .italian: "Festa nazionale francese", .portuguese: "Festa Nacional da França", .chineseTraditional: "法國國慶日"]),
            (8, 15, [.korean: "성모승천일", .english: "Assumption of Mary",
                     .japanese: "聖母被昇天祭", .chinese: "圣母升天节", .german: "Mariä Himmelfahrt", .french: "Assomption", .spanish: "Asunción de la Virgen", .italian: "Ferragosto", .portuguese: "Assunção de Nossa Senhora", .chineseTraditional: "聖母升天節"]),
            (11, 1, [.korean: "만성절", .english: "All Saints' Day",
                     .japanese: "諸聖人の日", .chinese: "诸圣节", .german: "Allerheiligen", .french: "Toussaint", .spanish: "Todos los Santos", .italian: "Ognissanti", .portuguese: "Dia de Todos os Santos", .chineseTraditional: "諸聖節"]),
            (11, 11, [.korean: "휴전기념일", .english: "Armistice Day",
                      .japanese: "休戦記念日", .chinese: "停战日", .german: "Waffenstillstandstag", .french: "Armistice 1918", .spanish: "Día del Armisticio", .italian: "Anniversario dell’armistizio", .portuguese: "Dia do Armistício", .chineseTraditional: "停戰紀念日"]),
            (12, 25, [.korean: "크리스마스", .english: "Christmas Day",
                      .japanese: "クリスマス", .chinese: "圣诞节", .german: "Weihnachten", .french: "Noël", .spanish: "Navidad", .italian: "Natale", .portuguese: "Natal", .chineseTraditional: "聖誕節"])
        ]
        for fx in fixed {
            var c = DateComponents()
            c.year = year; c.month = fx.month; c.day = fx.day
            if let d = calendar.date(from: c) {
                let name = fx.names[lang] ?? fx.names[.english]!
                holidays.append(Holiday(date: d, name: name))
            }
        }

        // 부활절 기반 — 프랑스는 부활절 월요일·승천일·성령강림절 월요일이 공휴일
        guard let easter = Self.easterSunday(year: year, calendar: calendar) else { return holidays.sorted { $0.date < $1.date } }
        let movableNames: [(offsetDays: Int, names: [AppLanguage: String])] = [
            (1,  [.korean: "부활절 월요일", .english: "Easter Monday",
                  .japanese: "イースターマンデー", .chinese: "复活节星期一", .german: "Ostermontag", .french: "Lundi de Pâques", .spanish: "Lunes de Pascua", .italian: "Lunedì dell’Angelo", .portuguese: "Segunda-feira de Páscoa", .chineseTraditional: "復活節星期一"]),
            (39, [.korean: "예수 승천일", .english: "Ascension Day",
                  .japanese: "キリスト昇天祭", .chinese: "耶稣升天节", .german: "Christi Himmelfahrt", .french: "Ascension", .spanish: "Ascensión", .italian: "Ascensione", .portuguese: "Ascensão", .chineseTraditional: "耶穌升天節"]),
            (50, [.korean: "성령강림절 월요일", .english: "Whit Monday",
                  .japanese: "聖霊降臨祭月曜日", .chinese: "圣灵降临节星期一", .german: "Pfingstmontag", .french: "Lundi de Pentecôte", .spanish: "Lunes de Pentecostés", .italian: "Lunedì di Pentecoste", .portuguese: "Segunda-feira de Pentecostes", .chineseTraditional: "聖靈降臨節星期一"])
        ]
        for mv in movableNames {
            if let d = calendar.date(byAdding: .day, value: mv.offsetDays, to: easter) {
                let name = mv.names[lang] ?? mv.names[.english]!
                holidays.append(Holiday(date: d, name: name))
            }
        }

        return holidays.sorted { $0.date < $1.date }
    }

    // MARK: - 부활절 계산 (Meeus/Jones/Butcher 알고리즘)
    // 그레고리안 부활절 (서방 교회) — 독일/프랑스 모두 이 날짜 사용

    static func easterSunday(year: Int, calendar: Calendar) -> Date? {
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
        let day = ((h + l - 7 * m + 114) % 31) + 1

        var comp = DateComponents()
        comp.year = year
        comp.month = month
        comp.day = day
        return calendar.date(from: comp)
    }

    // MARK: - 유틸리티

    /// 특정 날짜가 공휴일인지 확인
    func isHoliday(_ date: Date, in year: Int, country: Country = .korea) -> Bool {
        let holidays = getHolidays(for: year, country: country)
        return holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// 특정 날짜의 공휴일 정보 반환
    func getHoliday(for date: Date, in year: Int, country: Country = .korea) -> Holiday? {
        let holidays = getHolidays(for: year, country: country)
        return holidays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// 특정 월의 공휴일 목록
    func getHolidays(for month: Int, year: Int, country: Country = .korea) -> [Holiday] {
        let allHolidays = getHolidays(for: year, country: country)
        return allHolidays.filter {
            calendar.component(.month, from: $0.date) == month
        }
    }

    // MARK: - 날짜 계산 헬퍼

    /// n번째 특정 요일 찾기 (weekday: 1=Sun, 2=Mon, ...)
    func nthWeekday(nth: Int, weekday: Int, month: Int, year: Int) -> Date? {
        var comp = DateComponents()
        comp.year = year; comp.month = month; comp.day = 1
        guard let firstDay = calendar.date(from: comp) else { return nil }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var offset = weekday - firstWeekday
        if offset < 0 { offset += 7 }
        offset += (nth - 1) * 7

        return calendar.date(byAdding: .day, value: offset, to: firstDay)
    }

    /// 마지막 특정 요일 찾기
    func lastWeekday(weekday: Int, month: Int, year: Int) -> Date? {
        var comp = DateComponents()
        comp.year = year; comp.month = month + 1; comp.day = 0 // last day of month
        // Use a different approach: get last day of month
        comp = DateComponents()
        comp.year = year; comp.month = month
        guard let firstDay = calendar.date(from: comp),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return nil }

        comp.day = range.count
        guard let lastDay = calendar.date(from: comp) else { return nil }

        let lastWeekdayNum = calendar.component(.weekday, from: lastDay)
        var offset = weekday - lastWeekdayNum
        if offset > 0 { offset -= 7 }

        return calendar.date(byAdding: .day, value: offset, to: lastDay)
    }

    /// 춘분 계산 (근사값)
    private func vernalEquinoxDay(year: Int) -> Int {
        // Approximate formula for Japan
        let y = Double(year)
        let day = 20.8431 + 0.242194 * (y - 1980) - floor((y - 1980) / 4)
        return Int(floor(day))
    }

    /// 추분 계산 (근사값)
    private func autumnalEquinoxDay(year: Int) -> Int {
        let y = Double(year)
        let day = 23.2488 + 0.242194 * (y - 1980) - floor((y - 1980) / 4)
        return Int(floor(day))
    }
}
