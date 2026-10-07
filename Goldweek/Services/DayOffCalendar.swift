//
//  DayOffCalendar.swift
//  Goldweek
//
//  "원래 쉬는 날" 판정 — 연차 차감·추천이 같은 기준을 쓰도록 한 곳에 모은다.
//
//  쉬는 날 = 주말 + 국가 공휴일(숨긴 날 제외) + 내가 추가한 공휴일 + 내 방학.
//  자녀 방학은 쉬는 날이 아니다(참고용) — `childBreaks`로 따로 들고 있다.
//
//  LeaveRecord.effectiveLeaveDays 같은 모델 계산은 다른 데이터를 조회할 수 없어서,
//  ContentView 가 사용자 설정이 바뀔 때마다 `update`로 밀어 넣는다.
//  @Observable 이라 이 값을 읽은 화면은 설정이 바뀌면 다시 그려진다.
//

import Foundation
import Observation

@Observable
final class DayOffCalendar {
    static let shared = DayOffCalendar()

    private(set) var country: Country = .korea
    /// 내가 추가한 공휴일 (dateKey → 이름)
    private(set) var customDays: [String: String] = [:]
    /// 매년 반복하는 내 공휴일 ("MM-dd" → 이름)
    private(set) var yearlyCustomDays: [String: String] = [:]
    /// 내 방학 날짜 (dateKey → 방학 이름)
    private(set) var breakDays: [String: String] = [:]
    private(set) var hiddenDays: Set<String> = []
    /// 자녀 방학 — 추천을 앞세우고 달력에 표시하는 참고 기간
    private(set) var childBreaks: [(name: String, start: Date, end: Date)] = []
    /// 내 방학 기간 — 번아웃 계산에서 휴식으로 본다
    private(set) var myBreaks: [(name: String, start: Date, end: Date)] = []

    @ObservationIgnored private var yearCache: [Int: Set<String>] = [:]
    /// 사는 곳에만 있는 공휴일 (연도 → dateKey → 이름)
    @ObservationIgnored private var homeCache: [Int: [String: String]] = [:]
    /// 사는 곳 공휴일에도 쉬는지
    private(set) var homeHolidaysAreDaysOff = false
    /// 공휴일 앞뒤로 휴가를 낼 수 없는 근무일 수 (0 = 제한 없음)
    private(set) var leaveBlackoutDays = 0
    /// 휴가 제한일 (연도 → dateKey)
    @ObservationIgnored private var blackoutCache: [Int: Set<String>] = [:]
    @ObservationIgnored private let lock = NSLock()
    @ObservationIgnored private let service = HolidayService()
    @ObservationIgnored private let calendar = Calendar.current
    @ObservationIgnored private let keyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// 추천 캐시 키 등에 쓰는 요약값 — 설정이 바뀌면 달라진다
    private(set) var fingerprint = ""

    func update(country: Country, customHolidays: [CustomHoliday], hiddenDates: Set<String>, breaks: [SchoolBreak]) {
        var custom: [String: String] = [:]
        var yearly: [String: String] = [:]
        for h in customHolidays {
            if h.repeatsYearly {
                yearly[String(key(h.date).dropFirst(5))] = h.name
            } else {
                custom[key(h.date)] = h.name
            }
        }
        var mine: [String: String] = [:]
        var children: [(name: String, start: Date, end: Date)] = []
        var myRanges: [(name: String, start: Date, end: Date)] = []
        for b in breaks {
            let start = calendar.startOfDay(for: b.startDate)
            let end = calendar.startOfDay(for: b.endDate)
            guard start <= end else { continue }
            switch b.kind {
            case .mine:
                myRanges.append((b.name, start, end))
                var d = start
                while d <= end {
                    mine[key(d)] = b.name
                    d = calendar.date(byAdding: .day, value: 1, to: d)!
                }
            case .child:
                children.append((b.name, start, end))
            }
        }
        children.sort { $0.start < $1.start }

        let weekend = HolidayService.weekendDays(for: country).sorted().map(String.init).joined()
        let homeDaysOff = HolidayService.homeHolidaysAreDaysOff
        let blackout = HolidayService.leaveBlackoutDays
        let newFingerprint = "\(country.rawValue)|\(weekend)|blackout\(blackout)|\(HolidayService.selectedRegionCode)|\(HolidayService.partTimeSwapsRaw)|\(HolidayService.homeCountryCode)|\(HolidayService.homeRegionCode)|\(homeDaysOff)|\(custom.keys.sorted().joined(separator: ","))|\(yearly.keys.sorted().joined(separator: ","))|\(mine.keys.sorted().joined(separator: ","))|\(hiddenDates.sorted().joined(separator: ","))|"
            + children.map { "\(key($0.start))~\(key($0.end))" }.joined(separator: ",")
        guard newFingerprint != fingerprint else { return }

        lock.lock(); yearCache = [:]; homeCache = [:]; blackoutCache = [:]; lock.unlock()
        self.country = country
        self.homeHolidaysAreDaysOff = homeDaysOff
        self.leaveBlackoutDays = blackout
        self.customDays = custom
        self.yearlyCustomDays = yearly
        self.breakDays = mine
        self.hiddenDays = hiddenDates
        self.childBreaks = children
        self.myBreaks = myRanges.sorted { $0.start < $1.start }
        self.fingerprint = newFingerprint
    }

    // MARK: - 조회

    func isDayOff(_ date: Date) -> Bool {
        if HolidayService.isRestWeekend(date, country: country, calendar: calendar) { return true }
        let k = key(date)
        if customDays[k] != nil || breakDays[k] != nil || yearlyCustomDays[String(k.dropFirst(5))] != nil { return true }
        return holidayKeys(for: calendar.component(.year, from: date)).contains(k)
    }

    /// 기간 안에서 연차를 내야 하는 날(쉬는 날이 아닌 날) 수
    func workdays(from start: Date, to end: Date) -> Int {
        var d = calendar.startOfDay(for: start)
        let last = calendar.startOfDay(for: end)
        var count = 0
        while d <= last {
            if !isDayOff(d) { count += 1 }
            guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
            d = next
        }
        return count
    }

    /// 한 해의 쉬는 날 목록 (국가 공휴일 − 숨김 + 내 공휴일 + 내 방학) — 추천 엔진·달력용
    func holidays(for year: Int, country: Country) -> [Holiday] {
        let hidden = country == self.country ? hiddenDays : []
        var result = service.getHolidays(for: year, country: country, hiddenDates: hidden)
        guard country == self.country else { return result }
        // 사는 곳 공휴일에도 쉬면 그날들도 쉬는 날 목록에 넣는다 (숨긴 날은 빼고)
        if homeHolidaysAreDaysOff {
            result += service.homeOnlyHolidays(for: year, country: country).filter { !hidden.contains(key($0.date)) }
        }
        let taken = Set(result.map { key($0.date) })
        for (k, name) in customDays where k.hasPrefix("\(year)-") && !taken.contains(k) {
            guard let d = keyFormatter.date(from: k) else { continue }
            result.append(Holiday(date: d, name: name, isCustom: true))
        }
        for (md, name) in yearlyCustomDays {
            // 2월 29일 반복은 평년엔 키가 만들어지지 않는다
            let k = "\(year)-\(md)"
            guard !taken.contains(k), customDays[k] == nil, let d = keyFormatter.date(from: k),
                  key(d) == k else { continue }
            result.append(Holiday(date: d, name: name, isCustom: true))
        }
        for (k, name) in breakDays where k.hasPrefix("\(year)-") && !taken.contains(k) && customDays[k] == nil
            && yearlyCustomDays[String(k.dropFirst(5))] == nil {
            guard let d = keyFormatter.date(from: k) else { continue }
            result.append(Holiday(date: d, name: name, isCustom: true, isBreak: true))
        }
        return result.sorted { $0.date < $1.date }
    }

    /// 공휴일 앞뒤 휴가 제한일인지 — 공휴일 바로 앞뒤의 근무일 N개 (주말·쉬는 날은 건너뛰고 센다)
    func isLeaveBlocked(_ date: Date) -> Bool {
        guard leaveBlackoutDays > 0 else { return false }
        return blackoutKeys(for: calendar.component(.year, from: date)).contains(key(date))
    }

    /// 한 해의 휴가 제한일 (startOfDay) — 최적 플랜에서 제외할 날
    func blockedDates(in year: Int) -> Set<Date> {
        guard leaveBlackoutDays > 0 else { return [] }
        return Set(blackoutKeys(for: year).compactMap { keyFormatter.date(from: $0) }.map { calendar.startOfDay(for: $0) })
    }

    private func blackoutKeys(for year: Int) -> Set<String> {
        lock.lock()
        if let cached = blackoutCache[year] { lock.unlock(); return cached }
        lock.unlock()
        var blocked = Set<String>()
        // 연말·연초 공휴일이 이웃 해의 날을 막을 수 있어 앞뒤 해도 본다
        for y in (year - 1)...(year + 1) {
            for k in holidayKeys(for: y) {
                guard let h = keyFormatter.date(from: k) else { continue }
                for step in [-1, 1] {
                    var d = h, count = 0, guardrail = 0
                    while count < leaveBlackoutDays && guardrail < 60 {
                        guard let next = calendar.date(byAdding: .day, value: step, to: d) else { break }
                        d = next; guardrail += 1
                        if isDayOff(d) { continue }
                        if calendar.component(.year, from: d) == year { blocked.insert(key(d)) }
                        count += 1
                    }
                }
            }
        }
        lock.lock(); blackoutCache[year] = blocked; lock.unlock()
        return blocked
    }

    /// 그 날이 함께 보는 곳(사는 곳·본사 나라)에만 있는 공휴일이면 이름 — 달력 표시·날짜 상세용
    func homeHolidayName(on date: Date) -> String? {
        let year = calendar.component(.year, from: date)
        lock.lock()
        let cached = homeCache[year]
        lock.unlock()
        let names = cached ?? {
            let map = Dictionary(service.homeOnlyHolidays(for: year, country: country).map { (key($0.date), $0.name) },
                                 uniquingKeysWith: { a, _ in a })
            lock.lock(); homeCache[year] = map; lock.unlock()
            return map
        }()
        return names[key(date)]
    }

    /// 그 날이 속한 자녀 방학 이름
    func childBreakName(on date: Date) -> String? {
        let d = calendar.startOfDay(for: date)
        return childBreaks.first { d >= $0.start && d <= $0.end }?.name
    }

    /// 기간이 자녀 방학과 겹치는지
    func overlapsChildBreak(start: Date, end: Date) -> Bool {
        let s = calendar.startOfDay(for: start), e = calendar.startOfDay(for: end)
        return childBreaks.contains { s <= $0.end && e >= $0.start }
    }

    // MARK: - 내부

    private func holidayKeys(for year: Int) -> Set<String> {
        lock.lock()
        if let cached = yearCache[year] { lock.unlock(); return cached }
        lock.unlock()
        var keys = Set(service.getHolidays(for: year, country: country, hiddenDates: hiddenDays).map { key($0.date) })
        if homeHolidaysAreDaysOff {
            keys.formUnion(service.homeOnlyHolidays(for: year, country: country).map { key($0.date) }.filter { !hiddenDays.contains($0) })
        }
        lock.lock(); yearCache[year] = keys; lock.unlock()
        return keys
    }

    private func key(_ date: Date) -> String {
        keyFormatter.string(from: date)
    }
}
