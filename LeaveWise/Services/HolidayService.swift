//
//  HolidayService.swift
//  LeaveWise
//
//  공휴일 서비스 (다국가 지원)
//

import Foundation

class HolidayService {

    private let calendar = Calendar.current

    // MARK: - 공휴일 데이터 (국가별)

    /// 해당 연도의 공휴일 목록 반환 (국가별)
    func getHolidays(for year: Int, country: Country = .korea) -> [Holiday] {
        switch country {
        case .korea:
            return getKoreanHolidays(for: year)
        case .japan:
            return getJapaneseHolidays(for: year)
        case .china:
            return getChineseHolidays(for: year)
        case .usa:
            return getUSAHolidays(for: year)
        }
    }

    // MARK: - 한국 공휴일

    private func getKoreanHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []

        // 고정 공휴일
        holidays.append(contentsOf: getKoreanFixedHolidays(for: year))

        // 음력 공휴일 (설날, 추석, 부처님오신날)
        holidays.append(contentsOf: getKoreanLunarHolidays(for: year))

        // 대체공휴일 계산
        holidays.append(contentsOf: getKoreanSubstituteHolidays(holidays: holidays, year: year))

        return holidays.sorted { $0.date < $1.date }
    }

    private func getKoreanFixedHolidays(for year: Int) -> [Holiday] {
        let lang = AppLanguage.current
        let fixedDates: [(month: Int, day: Int, names: [AppLanguage: String])] = [
            (1, 1, [.korean: "신정", .english: "New Year's Day", .japanese: "元日", .chinese: "元旦"]),
            (3, 1, [.korean: "삼일절", .english: "Independence Movement Day", .japanese: "三一節", .chinese: "三一节"]),
            (5, 5, [.korean: "어린이날", .english: "Children's Day", .japanese: "こどもの日", .chinese: "儿童节"]),
            (6, 6, [.korean: "현충일", .english: "Memorial Day", .japanese: "顕忠日", .chinese: "显忠日"]),
            (8, 15, [.korean: "광복절", .english: "Liberation Day", .japanese: "光復節", .chinese: "光复节"]),
            (10, 3, [.korean: "개천절", .english: "National Foundation Day", .japanese: "開天節", .chinese: "开天节"]),
            (10, 9, [.korean: "한글날", .english: "Hangul Day", .japanese: "ハングルの日", .chinese: "韩文日"]),
            (12, 25, [.korean: "크리스마스", .english: "Christmas", .japanese: "クリスマス", .chinese: "圣诞节"])
        ]

        return fixedDates.compactMap { fixed in
            var components = DateComponents()
            components.year = year
            components.month = fixed.month
            components.day = fixed.day
            guard let date = calendar.date(from: components) else { return nil }
            return Holiday(date: date, name: fixed.names[lang] ?? fixed.names[.korean]!)
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
            let names = nameMap[holiday.key]?[lang] ?? nameMap[holiday.key]?[.korean] ?? ("Holiday", "Holiday")

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

        let seollalMain = lang == .korean ? "설날" : (lang == .english ? "Seollal" : (lang == .japanese ? "ソルラル" : "春节"))
        let seollalHoliday = lang == .korean ? "설날 연휴" : (lang == .english ? "Seollal Holiday" : (lang == .japanese ? "ソルラル連休" : "春节假期"))
        let chuseokMain = lang == .korean ? "추석" : (lang == .english ? "Chuseok" : (lang == .japanese ? "秋夕" : "中秋节"))
        let chuseokHoliday = lang == .korean ? "추석 연휴" : (lang == .english ? "Chuseok Holiday" : (lang == .japanese ? "秋夕連休" : "中秋节假期"))
        let buddhaName = lang == .korean ? "부처님오신날" : (lang == .english ? "Buddha's Birthday" : (lang == .japanese ? "釈迦誕生日" : "佛诞日"))

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

        let substituteEligibleKR = ["어린이날", "설날", "설날 연휴", "추석", "추석 연휴",
                                     "삼일절", "광복절", "개천절", "한글날", "크리스마스"]
        let substituteEligibleEN = ["Children's Day", "Seollal", "Seollal Holiday", "Chuseok", "Chuseok Holiday",
                                     "Independence Movement Day", "Liberation Day", "National Foundation Day", "Hangul Day", "Christmas"]
        let substituteEligibleJP = ["こどもの日", "ソルラル", "ソルラル連休", "秋夕", "秋夕連休",
                                     "三一節", "光復節", "開天節", "ハングルの日", "クリスマス"]
        let substituteEligibleZH = ["儿童节", "春节", "春节假期", "中秋节", "中秋节假期",
                                     "三一节", "光复节", "开天节", "韩文日", "圣诞节"]

        let substituteEligible: [String]
        switch lang {
        case .korean: substituteEligible = substituteEligibleKR
        case .english: substituteEligible = substituteEligibleEN
        case .japanese: substituteEligible = substituteEligibleJP
        case .chinese: substituteEligible = substituteEligibleZH
        }

        let subLabel: String
        switch lang {
        case .korean: subLabel = "대체공휴일"
        case .english: subLabel = "Substitute Holiday"
        case .japanese: subLabel = "振替休日"
        case .chinese: subLabel = "补休日"
        }

        for holiday in holidays {
            let weekday = calendar.component(.weekday, from: holiday.date)
            let isWeekend = weekday == 1 || weekday == 7

            if isWeekend && substituteEligible.contains(where: { holiday.name.contains($0) }) {
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
                holidays.append(Holiday(date: date, name: f.names[lang] ?? f.names[.japanese]!))
            }
        }

        // Happy Monday holidays
        // Coming of Age Day: 2nd Monday of January
        let comingOfAgeName: [AppLanguage: String] = [.korean: "성인의 날", .english: "Coming of Age Day", .japanese: "成人の日", .chinese: "成人日"]
        if let d = nthWeekday(nth: 2, weekday: 2, month: 1, year: year) {
            holidays.append(Holiday(date: d, name: comingOfAgeName[lang] ?? comingOfAgeName[.japanese]!))
        }

        // Marine Day: 3rd Monday of July
        let marineName: [AppLanguage: String] = [.korean: "바다의 날", .english: "Marine Day", .japanese: "海の日", .chinese: "海之日"]
        if let d = nthWeekday(nth: 3, weekday: 2, month: 7, year: year) {
            holidays.append(Holiday(date: d, name: marineName[lang] ?? marineName[.japanese]!))
        }

        // Respect for the Aged Day: 3rd Monday of September
        let agedName: [AppLanguage: String] = [.korean: "경로의 날", .english: "Respect for the Aged Day", .japanese: "敬老の日", .chinese: "敬老日"]
        if let d = nthWeekday(nth: 3, weekday: 2, month: 9, year: year) {
            holidays.append(Holiday(date: d, name: agedName[lang] ?? agedName[.japanese]!))
        }

        // Sports Day: 2nd Monday of October
        let sportsName: [AppLanguage: String] = [.korean: "스포츠의 날", .english: "Sports Day", .japanese: "スポーツの日", .chinese: "体育日"]
        if let d = nthWeekday(nth: 2, weekday: 2, month: 10, year: year) {
            holidays.append(Holiday(date: d, name: sportsName[lang] ?? sportsName[.japanese]!))
        }

        // Vernal Equinox (~March 20-21)
        let vernalName: [AppLanguage: String] = [.korean: "춘분", .english: "Vernal Equinox", .japanese: "春分の日", .chinese: "春分"]
        let vernalDay = vernalEquinoxDay(year: year)
        var comp = DateComponents(); comp.year = year; comp.month = 3; comp.day = vernalDay
        if let date = calendar.date(from: comp) {
            holidays.append(Holiday(date: date, name: vernalName[lang] ?? vernalName[.japanese]!))
        }

        // Autumnal Equinox (~September 22-23)
        let autumnalName: [AppLanguage: String] = [.korean: "추분", .english: "Autumnal Equinox", .japanese: "秋分の日", .chinese: "秋分"]
        let autumnalDay = autumnalEquinoxDay(year: year)
        comp = DateComponents(); comp.year = year; comp.month = 9; comp.day = autumnalDay
        if let date = calendar.date(from: comp) {
            holidays.append(Holiday(date: date, name: autumnalName[lang] ?? autumnalName[.japanese]!))
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
            case .japanese: return "振替休日"
            case .chinese: return "补休日"
            }
        }()

        for holiday in holidays {
            let weekday = calendar.component(.weekday, from: holiday.date)
            if weekday == 1 { // Sunday
                if let nextMonday = calendar.date(byAdding: .day, value: 1, to: holiday.date) {
                    let alreadyExists = holidays.contains { calendar.isDate($0.date, inSameDayAs: nextMonday) }
                        || substitutes.contains { calendar.isDate($0.date, inSameDayAs: nextMonday) }
                    if !alreadyExists {
                        substitutes.append(Holiday(date: nextMonday, name: subLabel, isSubstitute: true))
                    }
                }
            }
        }
        return substitutes
    }

    // MARK: - 중국 공휴일

    private func getChineseHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        let lang = AppLanguage.current

        // New Year
        let newYearName: [AppLanguage: String] = [.korean: "설날", .english: "New Year's Day", .japanese: "元日", .chinese: "元旦"]
        var comp = DateComponents(); comp.year = year; comp.month = 1; comp.day = 1
        if let date = calendar.date(from: comp) {
            holidays.append(Holiday(date: date, name: newYearName[lang] ?? newYearName[.chinese]!))
        }

        // Labor Day (May 1-5)
        let laborName: [AppLanguage: String] = [.korean: "노동절", .english: "Labor Day", .japanese: "メーデー", .chinese: "劳动节"]
        for day in 1...5 {
            comp = DateComponents(); comp.year = year; comp.month = 5; comp.day = day
            if let date = calendar.date(from: comp) {
                holidays.append(Holiday(date: date, name: laborName[lang] ?? laborName[.chinese]!))
            }
        }

        // National Day (Oct 1-7)
        let nationalName: [AppLanguage: String] = [.korean: "국경절", .english: "National Day", .japanese: "国慶節", .chinese: "国庆节"]
        for day in 1...7 {
            comp = DateComponents(); comp.year = year; comp.month = 10; comp.day = day
            if let date = calendar.date(from: comp) {
                holidays.append(Holiday(date: date, name: nationalName[lang] ?? nationalName[.chinese]!))
            }
        }

        // Lunar-based holidays (hardcoded per year)
        holidays.append(contentsOf: getChineseLunarHolidays(for: year))

        return holidays.sorted { $0.date < $1.date }
    }

    private func getChineseLunarHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        let lang = AppLanguage.current

        let springName: [AppLanguage: String] = [.korean: "춘절", .english: "Spring Festival", .japanese: "春節", .chinese: "春节"]
        let qingmingName: [AppLanguage: String] = [.korean: "청명절", .english: "Qingming Festival", .japanese: "清明節", .chinese: "清明节"]
        let dragonName: [AppLanguage: String] = [.korean: "단오절", .english: "Dragon Boat Festival", .japanese: "端午節", .chinese: "端午节"]
        let midAutumnName: [AppLanguage: String] = [.korean: "중추절", .english: "Mid-Autumn Festival", .japanese: "中秋節", .chinese: "中秋节"]

        // Spring Festival, Qingming, Dragon Boat, Mid-Autumn per year
        struct LunarData {
            let springStart: (Int, Int) // month, day - 7 days
            let qingming: (Int, Int)    // 3 days
            let dragon: (Int, Int)      // 3 days
            let midAutumn: (Int, Int)   // 3 days
        }

        let data: [Int: LunarData] = [
            2024: LunarData(springStart: (2, 10), qingming: (4, 4), dragon: (6, 10), midAutumn: (9, 15)),
            2025: LunarData(springStart: (1, 29), qingming: (4, 4), dragon: (5, 31), midAutumn: (10, 6)),
            2026: LunarData(springStart: (2, 17), qingming: (4, 5), dragon: (6, 19), midAutumn: (9, 25)),
            2027: LunarData(springStart: (2, 6), qingming: (4, 5), dragon: (6, 9), midAutumn: (9, 15)),
            2028: LunarData(springStart: (1, 26), qingming: (4, 4), dragon: (5, 28), midAutumn: (10, 3)),
            2029: LunarData(springStart: (2, 13), qingming: (4, 4), dragon: (6, 16), midAutumn: (9, 22)),
            2030: LunarData(springStart: (2, 3), qingming: (4, 5), dragon: (6, 5), midAutumn: (9, 12))
        ]

        guard let yearData = data[year] else { return holidays }

        // Spring Festival (7 days)
        for i in 0..<7 {
            var comp = DateComponents()
            comp.year = year; comp.month = yearData.springStart.0; comp.day = yearData.springStart.1
            if let start = calendar.date(from: comp),
               let date = calendar.date(byAdding: .day, value: i, to: start) {
                holidays.append(Holiday(date: date, name: springName[lang] ?? springName[.chinese]!))
            }
        }

        // Qingming (3 days)
        for i in 0..<3 {
            var comp = DateComponents()
            comp.year = year; comp.month = yearData.qingming.0; comp.day = yearData.qingming.1
            if let start = calendar.date(from: comp),
               let date = calendar.date(byAdding: .day, value: i, to: start) {
                holidays.append(Holiday(date: date, name: qingmingName[lang] ?? qingmingName[.chinese]!))
            }
        }

        // Dragon Boat (3 days)
        for i in 0..<3 {
            var comp = DateComponents()
            comp.year = year; comp.month = yearData.dragon.0; comp.day = yearData.dragon.1
            if let start = calendar.date(from: comp),
               let date = calendar.date(byAdding: .day, value: i, to: start) {
                holidays.append(Holiday(date: date, name: dragonName[lang] ?? dragonName[.chinese]!))
            }
        }

        // Mid-Autumn (3 days)
        for i in 0..<3 {
            var comp = DateComponents()
            comp.year = year; comp.month = yearData.midAutumn.0; comp.day = yearData.midAutumn.1
            if let start = calendar.date(from: comp),
               let date = calendar.date(byAdding: .day, value: i, to: start) {
                holidays.append(Holiday(date: date, name: midAutumnName[lang] ?? midAutumnName[.chinese]!))
            }
        }

        return holidays
    }

    // MARK: - 미국 공휴일

    private func getUSAHolidays(for year: Int) -> [Holiday] {
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

        // USA observed holiday: Sat->Fri, Sun->Mon
        holidays.append(contentsOf: getUSAObservedHolidays(holidays: holidays))

        return holidays.sorted { $0.date < $1.date }
    }

    private func getUSAObservedHolidays(holidays: [Holiday]) -> [Holiday] {
        var observed: [Holiday] = []
        let lang = AppLanguage.current
        let obsLabel: String = {
            switch lang {
            case .korean: return "관측일"
            case .english: return "Observed"
            case .japanese: return "振替"
            case .chinese: return "补休"
            }
        }()

        // Only fixed-date holidays get observed adjustments
        let fixedDateHolidays = holidays.filter { h in
            let comp = calendar.dateComponents([.month, .day], from: h.date)
            let fixedDays: [(Int, Int)] = [(1,1), (6,19), (7,4), (11,11), (12,25)]
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
    private func nthWeekday(nth: Int, weekday: Int, month: Int, year: Int) -> Date? {
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
    private func lastWeekday(weekday: Int, month: Int, year: Int) -> Date? {
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
