//
//  ScreenshotMode.swift
//  Goldweek
//
//  App Store 스크린샷 촬영용 데모 모드 (DEBUG 전용)
//
//  scripts/take_screenshots.sh 가 언어별로 아래 인자를 붙여 실행한다.
//    -screenshotMode YES      저장소를 비우고 언어에 맞는 데모 데이터로 채운다
//    -screenshotTab 1         시작 탭 (0 현황 · 1 캘린더 · 3 설정)
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

    /// 저장소를 비우고 현재 앱 언어에 맞는 국가·연차·휴가 기록을 넣는다.
    static func seed(container: ModelContainer) {
        guard isActive else { return }
        let context = ModelContext(container)
        try? context.delete(model: LeaveRecord.self)
        try? context.delete(model: BonusLeave.self)
        try? context.delete(model: CustomHoliday.self)
        try? context.delete(model: SchoolBreak.self)
        try? context.delete(model: UserProfile.self)

        let lang = AppLanguage.current
        let (country, name, total): (Country, String, Double) = {
            switch lang {
            case .korean: return (.korea, "민지", 20)
            case .english: return (.usa, "Emily", 20)
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

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let year = cal.component(.year, from: today)

        // 지난 휴가 — 올해 봄·여름에 몇 번 쉰 것처럼
        for (month, weekOfMonth, days) in [(3, 2, 1), (5, 3, 2), (8, 2, 5)] {
            var c = DateComponents(year: year, month: month, weekday: 2, weekOfMonth: weekOfMonth)
            c.calendar = cal
            guard let monday = cal.date(from: c), monday < today,
                  let end = cal.date(byAdding: .day, value: days - 1, to: monday) else { continue }
            context.insert(LeaveRecord(startDate: monday, endDate: end, status: .used))
        }

        // 다가오는 휴가 — 공휴일 옆 징검다리를 채워 연휴로 만든 모습
        let holidays = HolidayService().getHolidays(for: year, country: country)
            + HolidayService().getHolidays(for: year + 1, country: country)
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
