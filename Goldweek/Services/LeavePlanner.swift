//
//  LeavePlanner.swift
//  Goldweek
//
//  최적 연간 휴가 플래너 — N개의 가용 연차로 1년 동안 만들 수 있는
//  최장 연휴들의 조합을 찾는다.
//
//  알고리즘:
//   1. 한 해를 [Workday, Weekend, Holiday] 트리플렛으로 인덱싱
//   2. 공휴일·주말 클러스터 사이의 "다리(bridge)" 후보를 추출
//      — 한 다리는 (cost: 필요한 연차 수, gain: 결과 연휴 길이)
//   3. 다리는 시간상 서로 겹치지 않으므로 0/1 knapsack DP로 최적해 계산
//      dp[j] = j개 연차를 사용했을 때 얻을 수 있는 최대 휴식일 합
//   4. 역추적으로 선택된 다리를 복원
//
//  메모리 효율:
//   - 1D 롤링 DP 배열 (O(N) 공간, N = 가용 연차)
//   - 다리 후보는 ~30-50개 수준이라 전체 O(B × N) ≈ 1000 연산. 부동소수점 없음.
//

import Foundation

// MARK: - 입출력 모델

/// 연차로 만들어진 1개 연휴 블록
struct LeaveBreak: Identifiable, Hashable {
    let id = UUID()
    let startDate: Date          // 연휴 시작 (첫 휴일)
    let endDate: Date            // 연휴 끝 (마지막 휴일)
    let leaveDates: [Date]       // 그 연휴를 만들기 위해 써야 할 연차 날짜
    let totalDays: Int           // 연휴 총 길이 (주말+공휴일+연차)
    let holidaysIncluded: [String] // 포함된 공휴일 이름들 (UI 라벨용)

    var leaveCount: Int { leaveDates.count }
    var efficiency: Double {
        guard leaveCount > 0 else { return 0 }
        return Double(totalDays) / Double(leaveCount)
    }
}

/// 1년치 최적 휴가 계획
struct OptimalLeavePlan {
    let breaks: [LeaveBreak]         // 시작일 오름차순
    let totalDaysOff: Int            // 모든 연휴 길이 합
    let leaveDaysUsed: Int           // 사용 연차 합 (≤ 가용)
    let leaveDaysAvailable: Int      // 입력값 그대로
    let year: Int

    var efficiency: Double {
        guard leaveDaysUsed > 0 else { return 0 }
        return Double(totalDaysOff) / Double(leaveDaysUsed)
    }

    /// 선택된 모든 연차 날짜 (캘린더 시각화/일괄 등록용)
    var allLeaveDates: [Date] {
        breaks.flatMap { $0.leaveDates }.sorted()
    }
}

// MARK: - 플래너

enum LeavePlanner {

    /// 입력값을 받아 1년 최적 휴가 계획을 반환한다.
    /// - excludedDates: 이미 다른 일정이 있어 연차로 쓸 수 없는 날 (등록된 휴가 등)
    /// - minBreakLength: 이 길이 미만의 연휴 후보는 제외 (기본 3일 = 주말+α 정도)
    /// - earliestDate: 이 날짜 이전은 후보에서 제외 (오늘 이후만 고려할 때 사용)
    static func optimalPlan(
        year: Int,
        availableLeaveDays: Int,
        holidays: [Date],
        excludedDates: Set<Date> = [],
        minBreakLength: Int = 3,
        earliestDate: Date? = nil,
        calendar: Calendar = .current
    ) -> OptimalLeavePlan {
        guard availableLeaveDays > 0 else {
            return OptimalLeavePlan(breaks: [], totalDaysOff: 0,
                                     leaveDaysUsed: 0,
                                     leaveDaysAvailable: 0,
                                     year: year)
        }

        // 1. 1년치 날짜 인덱싱
        let dayInfo = buildDayIndex(year: year, holidays: holidays,
                                     excludedDates: excludedDates,
                                     calendar: calendar)

        // 2. 다리 후보 추출
        var candidates = enumerateBridges(dayInfo: dayInfo,
                                           maxCost: availableLeaveDays,
                                           calendar: calendar)

        // 3. earliestDate 필터링 (다리가 통째로 그 이전이면 제외)
        if let earliest = earliestDate {
            let cutoff = calendar.startOfDay(for: earliest)
            candidates = candidates.filter { $0.breakStart >= cutoff || $0.breakEnd >= cutoff }
        }

        // 4. minBreakLength 필터링
        candidates = candidates.filter { $0.gain >= minBreakLength }

        // 4-1. 사소한 연휴 제외 — 연차 1일로 단순히 3일(금 또는 월 + 주말)만 만드는 후보 제거.
        //      너무 뻔해서 추천 가치가 낮다는 사용자 피드백 반영.
        candidates = candidates.filter { !($0.cost == 1 && $0.gain == 3) }

        // 5. 0/1 knapsack DP — 다리들끼리는 시간상 겹치지 않는다
        //    (한 다리 = 1개 연속 휴식 블록, 다음 다리는 그 뒤 워크데이부터 시작)
        //    → 부분집합 선택 자유. 단 같은 워크데이가 두 다리에 중복 안 되게 보장 필요.
        let nonOverlapping = removeOverlaps(candidates)

        let dp = knapsack(items: nonOverlapping, capacity: availableLeaveDays)

        // 6. 역추적으로 선택된 다리 복원
        let selected = traceback(items: nonOverlapping, dp: dp,
                                  capacity: availableLeaveDays)

        // 7. LeaveBreak 객체로 변환
        let breaks = selected
            .sorted { $0.breakStart < $1.breakStart }
            .map { bridge in
                LeaveBreak(
                    startDate: bridge.breakStart,
                    endDate: bridge.breakEnd,
                    leaveDates: bridge.leaveDates,
                    totalDays: bridge.gain,
                    holidaysIncluded: bridge.holidayNames
                )
            }

        let usedDays = breaks.reduce(0) { $0 + $1.leaveCount }
        let totalOff = breaks.reduce(0) { $0 + $1.totalDays }

        return OptimalLeavePlan(
            breaks: breaks,
            totalDaysOff: totalOff,
            leaveDaysUsed: usedDays,
            leaveDaysAvailable: availableLeaveDays,
            year: year
        )
    }
}

// MARK: - 내부 자료구조

private extension LeavePlanner {

    enum DayType { case workday, weekend, holiday, excluded }

    struct DayInfo {
        let date: Date
        let dayIndex: Int   // 1월 1일 = 0
        let type: DayType
        let holidayName: String?
    }

    /// 한 다리 후보 — workday 구간 [startIdx, endIdx]를 PTO로 채우면
    /// 좌·우 휴일·주말과 합쳐 길이 `gain`의 연휴가 만들어진다.
    struct Bridge {
        let leaveDates: [Date]   // PTO로 써야 할 워크데이들
        let breakStart: Date     // 결과 연휴 시작
        let breakEnd: Date       // 결과 연휴 끝
        let startIdx: Int        // breakStart의 dayIndex
        let endIdx: Int          // breakEnd의 dayIndex
        let cost: Int            // leaveDates.count
        let gain: Int            // breakEnd - breakStart + 1
        let holidayNames: [String]
    }

    static func buildDayIndex(year: Int, holidays: [Date],
                              excludedDates: Set<Date>,
                              calendar: Calendar) -> [DayInfo] {
        let holidaySet: Set<Date> = Set(holidays.map { calendar.startOfDay(for: $0) })
        let excludedSet: Set<Date> = Set(excludedDates.map { calendar.startOfDay(for: $0) })

        let nameByDate: [Date: String] = [:]  // (이름 매핑은 호출부에서 hint를 못 받으므로 비워둠 — 미래 확장 여지)
        _ = nameByDate

        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1
        guard let yearStart = calendar.date(from: components) else { return [] }

        let daysInYear = calendar.range(of: .day, in: .year, for: yearStart)?.count ?? 365
        var result: [DayInfo] = []
        result.reserveCapacity(daysInYear)

        for i in 0..<daysInYear {
            guard let date = calendar.date(byAdding: .day, value: i, to: yearStart) else { break }
            let day = calendar.startOfDay(for: date)
            let weekday = calendar.component(.weekday, from: day)
            let isWeekend = (weekday == 1 || weekday == 7)
            let isHoliday = holidaySet.contains(day)
            let isExcluded = excludedSet.contains(day)

            let type: DayType = {
                if isHoliday { return .holiday }
                if isWeekend { return .weekend }
                if isExcluded { return .excluded }
                return .workday
            }()
            result.append(DayInfo(date: day, dayIndex: i, type: type, holidayName: nil))
        }
        return result
    }

    /// 워크데이 구간을 PTO로 채우는 모든 다리 후보 생성 (cost ≤ maxCost).
    /// 양 끝이 weekend/holiday로 둘러싸여야 의미 있다 (그래야 길게 늘어난다).
    static func enumerateBridges(dayInfo: [DayInfo], maxCost: Int,
                                  calendar: Calendar) -> [Bridge] {
        guard !dayInfo.isEmpty else { return [] }
        var bridges: [Bridge] = []

        // 워크데이 인덱스만 모음
        let n = dayInfo.count
        var i = 0
        while i < n {
            guard dayInfo[i].type == .workday else { i += 1; continue }
            // 워크데이 런: [i, j]
            var j = i
            while j + 1 < n && dayInfo[j + 1].type == .workday {
                j += 1
            }
            // 이 런 안에서 cost ≤ maxCost인 모든 부분 구간 시도 — 양 끝에 붙어야 효과적
            // 효과적인 후보는:
            //  (a) 런의 좌측 끝부터 k개 — 왼쪽 휴일 연장
            //  (b) 런의 우측 끝까지 k개 — 오른쪽 휴일 연장
            //  (c) 런 전체 — 양쪽 휴일 사이를 통째로 메움
            // 한 런 안에서 가운데만 떼는 건 무의미 (양 끝이 워크데이라 효과 없음)
            let runLen = j - i + 1
            let maxK = min(runLen, maxCost)
            for k in 1...maxK {
                // (a) 좌측 k개
                if i > 0 {  // 왼쪽에 휴일/주말이 있어야
                    if let bridge = makeBridge(leaveStart: i, leaveEnd: i + k - 1,
                                                dayInfo: dayInfo, calendar: calendar) {
                        bridges.append(bridge)
                    }
                }
                // (b) 우측 k개 (좌측 k개와 다를 때만)
                if k < runLen && j + 1 < n {
                    let s = j - k + 1
                    if let bridge = makeBridge(leaveStart: s, leaveEnd: j,
                                                dayInfo: dayInfo, calendar: calendar) {
                        bridges.append(bridge)
                    }
                }
                // (c) 양쪽 채우기 — runLen ≤ maxCost일 때만 의미
                if k == runLen && runLen <= maxCost && i > 0 && j + 1 < n {
                    if let bridge = makeBridge(leaveStart: i, leaveEnd: j,
                                                dayInfo: dayInfo, calendar: calendar) {
                        bridges.append(bridge)
                    }
                }
            }
            i = j + 1
        }
        // 중복 제거 (같은 leaveDates 셋)
        var seen = Set<[Date]>()
        var deduped: [Bridge] = []
        for b in bridges {
            if seen.insert(b.leaveDates).inserted { deduped.append(b) }
        }
        return deduped
    }

    /// 주어진 워크데이 구간 [leaveStart, leaveEnd]를 PTO로 채울 때 양 끝으로 확장된
    /// 연휴 블록을 만든다. 양 끝이 weekend/holiday로 막혀 있어야 한다.
    static func makeBridge(leaveStart: Int, leaveEnd: Int,
                           dayInfo: [DayInfo],
                           calendar: Calendar) -> Bridge? {
        // 좌측으로 weekend/holiday 만큼 확장
        var left = leaveStart
        while left > 0 {
            let prev = dayInfo[left - 1].type
            if prev == .weekend || prev == .holiday {
                left -= 1
            } else { break }
        }
        // 우측으로 확장
        var right = leaveEnd
        while right + 1 < dayInfo.count {
            let next = dayInfo[right + 1].type
            if next == .weekend || next == .holiday {
                right += 1
            } else { break }
        }
        // 확장이 전혀 없으면 의미 없음 (그냥 평일 1~N개 빠지는 거)
        guard left < leaveStart || right > leaveEnd else { return nil }

        let leaveDates = (leaveStart...leaveEnd).map { dayInfo[$0].date }
        let holidayNames: [String] = []  // 향후 holiday name 매핑 가능
        return Bridge(
            leaveDates: leaveDates,
            breakStart: dayInfo[left].date,
            breakEnd: dayInfo[right].date,
            startIdx: left,
            endIdx: right,
            cost: leaveDates.count,
            gain: right - left + 1,
            holidayNames: holidayNames
        )
    }

    /// 같은 연휴 블록을 만드는 다리들 중 효율(gain/cost) 가장 좋은 것 1개만 남긴다.
    /// (서로 다른 PTO 조합이라도 결과 break가 같으면 중복)
    static func removeOverlaps(_ bridges: [Bridge]) -> [Bridge] {
        // 동일한 breakStart+breakEnd는 cost 가장 작은 것만 남긴다
        var bestByBreak: [String: Bridge] = [:]
        for b in bridges {
            let key = "\(b.startIdx)-\(b.endIdx)"
            if let existing = bestByBreak[key] {
                if b.cost < existing.cost { bestByBreak[key] = b }
            } else {
                bestByBreak[key] = b
            }
        }
        return Array(bestByBreak.values)
    }

    /// 0/1 knapsack DP (1D 롤링 배열, O(N) 공간)
    /// 동시에 선택된 다리들은 시간상 겹치지 않게 해야 하므로 선형 시간순 DP로 변환.
    /// breakStart 인덱스 오름차순으로 정렬한 뒤, 각 시점에서 "선택/스킵" 결정.
    static func knapsack(items: [Bridge], capacity: Int) -> [[Int]] {
        // dp[i][j] = items[0..<i] 중 cost 합 ≤ j 이면서 다리들이 시간상 겹치지 않을 때 최대 gain
        // 시간 정렬 후, 이전 선택된 다리와 겹치지 않는 다리만 이을 수 있게 마지막 endIdx 추적
        // → 2D DP가 필요해지므로, 다리가 작은 규모(~50개)면 그냥 비트마스크가 간단하지만,
        //   여기서는 "이전 끝나는 인덱스" + DP로 풀자.
        // 단순화: 다리들이 서로 시간상 겹치지 않게 사전 정렬했다면 그냥 knapsack과 같다.
        // 다리는 [startIdx, endIdx] 구간을 점유한다. 겹침 = startIdx ≤ other.endIdx && other.startIdx ≤ endIdx
        //
        // 정확한 풀이: "weighted interval scheduling + capacity" — 일종의 2D DP
        //   sorted by endIdx 오름차순
        //   p[i] = items[i]와 겹치지 않는 가장 마지막 인덱스 (없으면 -1)
        //   dp[i][j] = max(dp[i-1][j],                                          // 스킵
        //                  dp[p[i]][j - items[i].cost] + items[i].gain)         // 선택
        let sorted = items.sorted { $0.endIdx < $1.endIdx }
        let n = sorted.count
        var dp = Array(repeating: Array(repeating: 0, count: capacity + 1), count: n + 1)

        // p[i] = sorted[0..<i] 중 sorted[i-1]과 겹치지 않는 마지막 인덱스 + 1 (없으면 0)
        var p = [Int](repeating: 0, count: n + 1)
        for i in 1...n {
            let current = sorted[i - 1]
            var lo = 0, hi = i - 1, ans = 0
            while lo < hi {
                let mid = (lo + hi) / 2
                if sorted[mid].endIdx < current.startIdx {
                    ans = mid + 1
                    lo = mid + 1
                } else {
                    hi = mid
                }
            }
            p[i] = ans
        }

        for i in 1...n {
            let item = sorted[i - 1]
            for j in 0...capacity {
                // 스킵
                dp[i][j] = dp[i - 1][j]
                // 선택 가능 시
                if item.cost <= j {
                    let take = dp[p[i]][j - item.cost] + item.gain
                    if take > dp[i][j] { dp[i][j] = take }
                }
            }
        }
        // 역추적을 위해 정렬된 items도 함께 보관 — 따로 클로저로 노출
        TracebackContext.shared.set(sorted: sorted, p: p)
        return dp
    }

    /// dp 테이블에서 선택된 다리들을 복원
    static func traceback(items: [Bridge], dp: [[Int]], capacity: Int) -> [Bridge] {
        let ctx = TracebackContext.shared
        guard let sorted = ctx.sorted, let p = ctx.p else { return [] }
        var result: [Bridge] = []
        var i = sorted.count
        var j = capacity
        while i > 0 {
            let item = sorted[i - 1]
            let skipValue = dp[i - 1][j]
            let takeValue = (item.cost <= j) ? dp[p[i]][j - item.cost] + item.gain : -1
            if takeValue > skipValue {
                result.append(item)
                j -= item.cost
                i = p[i]
            } else {
                i -= 1
            }
        }
        return result
    }

    /// knapsack과 traceback 사이에 정렬·p 배열 공유용. 단일 호출 흐름이라 안전.
    final class TracebackContext {
        static let shared = TracebackContext()
        var sorted: [Bridge]?
        var p: [Int]?
        func set(sorted: [Bridge], p: [Int]) {
            self.sorted = sorted; self.p = p
        }
    }
}
