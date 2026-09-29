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
    /// 내 방학 날짜 (dateKey → 방학 이름)
    private(set) var breakDays: [String: String] = [:]
    private(set) var hiddenDays: Set<String> = []
    /// 자녀 방학 — 추천을 앞세우고 달력에 표시하는 참고 기간
    private(set) var childBreaks: [(name: String, start: Date, end: Date)] = []
    /// 내 방학 기간 — 번아웃 계산에서 휴식으로 본다
    private(set) var myBreaks: [(name: String, start: Date, end: Date)] = []

    @ObservationIgnored private var yearCache: [Int: Set<String>] = [:]
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
        for h in customHolidays { custom[key(h.date)] = h.name }
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

        let newFingerprint = "\(country.rawValue)|\(HolidayService.selectedRegionCode)|\(custom.keys.sorted().joined(separator: ","))|\(mine.keys.sorted().joined(separator: ","))|\(hiddenDates.sorted().joined(separator: ","))|"
            + children.map { "\(key($0.start))~\(key($0.end))" }.joined(separator: ",")
        guard newFingerprint != fingerprint else { return }

        lock.lock(); yearCache = [:]; lock.unlock()
        self.country = country
        self.customDays = custom
        self.breakDays = mine
        self.hiddenDays = hiddenDates
        self.childBreaks = children
        self.myBreaks = myRanges.sorted { $0.start < $1.start }
        self.fingerprint = newFingerprint
    }

    // MARK: - 조회

    func isDayOff(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 || weekday == 7 { return true }
        let k = key(date)
        if customDays[k] != nil || breakDays[k] != nil { return true }
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
        let taken = Set(result.map { key($0.date) })
        for (k, name) in customDays where k.hasPrefix("\(year)-") && !taken.contains(k) {
            guard let d = keyFormatter.date(from: k) else { continue }
            result.append(Holiday(date: d, name: name, isCustom: true))
        }
        for (k, name) in breakDays where k.hasPrefix("\(year)-") && !taken.contains(k) && customDays[k] == nil {
            guard let d = keyFormatter.date(from: k) else { continue }
            result.append(Holiday(date: d, name: name, isCustom: true, isBreak: true))
        }
        return result.sorted { $0.date < $1.date }
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
        let keys = Set(service.getHolidays(for: year, country: country, hiddenDates: hiddenDays).map { key($0.date) })
        lock.lock(); yearCache[year] = keys; lock.unlock()
        return keys
    }

    private func key(_ date: Date) -> String {
        keyFormatter.string(from: date)
    }
}
