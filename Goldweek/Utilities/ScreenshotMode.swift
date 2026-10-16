//
//  ScreenshotMode.swift
//  Goldweek
//
//  App Store 스크린샷 촬영용 데모 모드 (DEBUG 전용)
//
//  scripts/take_screenshots.sh 가 언어별로 아래 인자를 붙여 실행한다.
//    -screenshotMode YES      저장소를 비우고 언어에 맞는 데모 데이터로 채운다
//    -screenshotTab 1         시작 탭 (0 현황 · 1 캘린더 · 3 설정)
//    -screenshotScroll recommendations   캘린더를 추천 목록까지 내려 둔다
//    -screenshotScroll nextYear          캘린더를 내년 1월로 연다
//    -screenshotPaywall <상품 ID>        페이월을 열고 그 상품을 골라 둔다 (앱 내 구입 심사 스크린샷)
//    -appLanguage de          앱 언어 (UserDefaults 인자 도메인으로 그대로 읽힌다)
//

import Foundation
import SwiftData

enum ScreenshotMode {
    #if DEBUG
    static var isActive: Bool { UserDefaults.standard.bool(forKey: "screenshotMode") }
    #else
    static let isActive = false
    #endif

    static var initialTab: Int {
        isActive ? UserDefaults.standard.integer(forKey: "screenshotTab") : 0
    }

    /// 처음 화면에서 내려 둘 위치 (`-screenshotScroll recommendations`)
    static var scrollTarget: String? {
        isActive ? UserDefaults.standard.string(forKey: "screenshotScroll") : nil
    }

    /// 페이월을 열어 골라 둘 상품 (`-screenshotPaywall com.Ysoup.LeaveWise.pro.yearly`)
    static var paywallProductID: String? {
        isActive ? UserDefaults.standard.string(forKey: "screenshotPaywall") : nil
    }

    /// 캘린더가 처음 보여 주고 골라 둘 날 — 캘린더를 찍을 땐(`recommendations`·`nextYear`) 내년 1월 1일.
    /// 연말엔 올해 남은 추천이 나라마다 0~3개로 들쭉날쭉해서, 언어마다 같은 화면이 나오게 맞춘다.
    static var calendarStartMonth: Date {
        let now = Date()
        guard scrollTarget == "recommendations" || scrollTarget == "nextYear" else { return now }
        let cal = Calendar.app
        return cal.date(from: DateComponents(year: cal.component(.year, from: now) + 1, month: 1, day: 1)) ?? now
    }

    /// 저장소를 비우고 현재 앱 언어에 맞는 국가·연차·휴가 기록을 넣는다.
    static func seed(container: ModelContainer) {
        guard isActive else { return }
        let context = ModelContext(container)
        try? context.delete(model: LeaveRecord.self)
        try? context.delete(model: BonusLeave.self)
        try? context.delete(model: CustomHoliday.self)
        try? context.delete(model: SchoolBreak.self)
        try? context.delete(model: FamilyAnniversary.self)
        try? context.delete(model: UserProfile.self)

        let lang = AppLanguage.current
        let (country, name, total): (Country, String, Double) = {
            switch lang {
            case .korean: return (.korea, "민지", 20)
            case .english: return (.usa, "Emily", 20)
            case .swedish: return (.sweden, "Emma", 25)
            case .norwegian: return (.norway, "Ingrid", 25)
            case .danish: return (.denmark, "Freja", 25)
            case .finnish: return (.finland, "Aino", 25)
            case .polish: return (.poland, "Ola", 26)
            case .czech: return (.czechia, "Tereza", 20)
            case .greek: return (.greece, "Ελένη", 20)
            case .turkish: return (.turkey, "Elif", 14)
            case .russian: return (.russia, "Анна", 20)
            case .indonesian: return (.indonesia, "Putri", 12)
            // 태국·베트남은 내장 공휴일이 없다 — 사용자가 하듯 직접 입력 모드에 그 나라 공휴일을 넣는다
            case .thai: return (.custom, "ปลา", 15)
            case .vietnamese: return (.custom, "Linh", 12)
            case .dutch: return (.netherlands, "Sanne", 25)
            case .japanese: return (.japan, "ゆき", 20)
            case .chinese: return (.china, "小雨", 15)
            case .german: return (.germany, "Lena", 30)
            case .french: return (.france, "Camille", 25)
            case .spanish: return (.spain, "Lucía", 22)
            case .italian: return (.italy, "Giulia", 26)
            case .portuguese: return (.brazil, "Ana", 22)
            case .chineseTraditional: return (.taiwan, "怡君", 14)
            }
        }()

        let profile = UserProfile(name: name, totalAnnualLeave: total, country: country)
        context.insert(profile)

        let cal = Calendar.app
        let today = cal.startOfDay(for: Date())
        let year = cal.component(.year, from: today)

        let customHolidays = demoCustomHolidays(for: lang, year: year, calendar: cal)
        customHolidays.forEach { context.insert($0) }

        // 지난 휴가 — 올해 봄·여름에 몇 번 쉰 것처럼
        for (month, weekOfMonth, days) in [(3, 2, 1), (5, 3, 2), (8, 2, 5)] {
            var c = DateComponents(year: year, month: month, weekday: 2, weekOfMonth: weekOfMonth)
            c.calendar = cal
            guard let monday = cal.date(from: c), monday < today,
                  let end = cal.date(byAdding: .day, value: days - 1, to: monday) else { continue }
            context.insert(LeaveRecord(startDate: monday, endDate: end, status: .used))
        }

        // 다가오는 휴가 — 공휴일 옆 징검다리를 채워 연휴로 만든 모습
        let holidays = HolidayService().getHolidays(for: year, country: country, customHolidays: customHolidays)
            + HolidayService().getHolidays(for: year + 1, country: country, customHolidays: customHolidays)
        var added: [(start: Date, end: Date)] = []
        for holiday in holidays where holiday.date > cal.date(byAdding: .day, value: 3, to: today)! {
            guard added.count < 2, let bridge = bridgeRange(for: holiday.date, calendar: cal) else { continue }
            // 앞서 넣은 휴가와 겹치거나 붙으면 건너뛴다 (연휴가 이어지는 주에 두 번 잡히던 문제)
            let dayAfter = { (d: Date) in cal.date(byAdding: .day, value: 1, to: d)! }
            if added.contains(where: { bridge.start <= dayAfter($0.end) && dayAfter(bridge.end) >= $0.start }) { continue }
            // 연휴 사이 평일이 다른 공휴일이면 휴가로 잡지 않는다
            if holidays.contains(where: { cal.isDate($0.date, inSameDayAs: bridge.start) || cal.isDate($0.date, inSameDayAs: bridge.end) }) { continue }
            context.insert(LeaveRecord(startDate: bridge.start, endDate: bridge.end, status: .planned))
            added.append(bridge)
        }

        try? context.save()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
    }

    /// 직접 입력 모드로 찍는 언어(태국어·베트남어)의 공휴일 — 날짜가 고정인 것은 매년 반복, 음력 명절은 내년 것만
    private static func demoCustomHolidays(for lang: AppLanguage, year: Int, calendar cal: Calendar) -> [CustomHoliday] {
        func make(_ y: Int, _ m: Int, _ d: Int, _ name: String, yearly: Bool = true) -> CustomHoliday? {
            guard let date = cal.date(from: DateComponents(year: y, month: m, day: d)) else { return nil }
            return CustomHoliday(date: date, name: name, repeatsYearly: yearly)
        }
        switch lang {
        case .thai:
            return [
                make(year, 1, 1, "วันขึ้นปีใหม่"), make(year, 4, 6, "วันจักรี"),
                make(year, 4, 13, "วันสงกรานต์"), make(year, 4, 14, "วันสงกรานต์"), make(year, 4, 15, "วันสงกรานต์"),
                make(year, 5, 1, "วันแรงงานแห่งชาติ"), make(year, 5, 4, "วันฉัตรมงคล"),
                make(year, 6, 3, "วันเฉลิมพระชนมพรรษาพระราชินี"), make(year, 7, 28, "วันเฉลิมพระชนมพรรษา ร.10"),
                make(year, 8, 12, "วันแม่แห่งชาติ"), make(year, 10, 13, "วันนวมินทรมหาราช"),
                make(year, 10, 23, "วันปิยมหาราช"), make(year, 12, 5, "วันพ่อแห่งชาติ"),
                make(year, 12, 10, "วันรัฐธรรมนูญ"), make(year, 12, 31, "วันสิ้นปี"),
            ].compactMap { $0 }
        case .vietnamese:
            // Tết Nguyên Đán 2027: mùng 1 = 6/2/2027
            let tet = (4...10).compactMap { make(2027, 2, $0, "Tết Nguyên Đán", yearly: false) }
            return [
                make(year, 1, 1, "Tết Dương lịch"), make(year, 4, 30, "Ngày Giải phóng miền Nam"),
                make(year, 5, 1, "Quốc tế Lao động"), make(year, 9, 2, "Quốc khánh"),
            ].compactMap { $0 } + (year + 1 == 2027 || year == 2027 ? tet : [])
        default:
            return []
        }
    }

    /// 공휴일과 주말 사이 평일 — 화요일이면 월요일, 목요일이면 금요일
    private static func bridgeRange(for date: Date, calendar cal: Calendar) -> (start: Date, end: Date)? {
        let offsets: [Int: (Int, Int)] = [
            2: (1, 2),    // 월 → 화·수
            3: (-1, -1),  // 화 → 월
            4: (1, 2),    // 수 → 목·금
            5: (1, 1),    // 목 → 금
            6: (-2, -1),  // 금 → 수·목
        ]
        guard let (a, b) = offsets[cal.component(.weekday, from: date)],
              let start = cal.date(byAdding: .day, value: a, to: date),
              let end = cal.date(byAdding: .day, value: b, to: date) else { return nil }
        return (start, end)
    }
}
