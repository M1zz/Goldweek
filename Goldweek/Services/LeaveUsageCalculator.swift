//
//  LeaveUsageCalculator.swift
//  Goldweek
//
//  "며칠 썼나 / 며칠 남았나"를 계산하는 **유일한 자리**.
//
//  왜 필요했나: 같은 계산이 홈 카드·휴가 사용 내역·설정·휴가 등록 화면에 각각 복사돼 있었고,
//  필터가 조금씩 달라서 **같은 이름표를 단 숫자가 화면마다 달랐다**
//  (홈은 연차에서 차감되는 것만, 내역은 출장·병가까지 전부 더하고 있었다).
//  숫자가 어긋나면 사용자는 어느 쪽을 믿어야 할지 알 수 없다 → 정의를 여기 한 곳에 못박는다.
//
//  정의 (모든 화면 공통)
//   · 회계연도: 기준일(`YearStart` — 월 + 일, 예: 입사일 3월 21일)에 시작하는 1년. 기록은 **시작일** 기준으로 그 해에 속한다.
//   · 사용 완료: 상태가 `.used` 이거나, `.planned`인데 종료일이 이미 지난 것.
//     (지난 예정을 안 세면 연말에 "예정"만 잔뜩 남아 잔여가 실제와 어긋난다)
//   · 예정: `.planned`이고 종료일이 오늘 이후.
//   · 취소(`.cancelled`)는 어디에도 세지 않는다.
//   · 일수는 `effectiveLeaveDays` — 반차 0.5, 반반차 0.25, 기간 휴가는 주말·공휴일·내 방학을 뺀 평일 수.
//
//  ⚠️ 연차 차감(`deductsFromAnnualLeave`) 여부로 두 종류의 합계를 따로 낸다.
//     화면이 "총 연차" 옆에 놓는 숫자는 반드시 차감분(`annualUsed`)이어야 한다 —
//     출장·병가까지 더한 값을 총 연차 옆에 두면 잔여가 맞지 않는다.
//

import Foundation
import GoldweekCore

/// 연차가 새로 생기는 날 (회계연도 시작). 입사일 기준 회사는 3월 21일처럼 월 중간이다.
/// 정수 리터럴은 그 달 1일로 받는다 — `startMonth: 4` 는 4월 1일.
struct YearStart: Hashable, ExpressibleByIntegerLiteral {
    var month: Int
    var day: Int

    init(month: Int, day: Int = 1) {
        self.month = min(max(month, 1), 12)
        self.day = min(max(day, 1), 31)
    }

    init(integerLiteral value: Int) { self.init(month: value) }

    /// 기준일로 고를 수 있는 날 수 — 2월은 29일까지 (평년엔 28일로 맞춰 계산된다)
    static func selectableDays(inMonth month: Int) -> Int {
        switch month {
        case 2: return 29
        case 4, 6, 9, 11: return 30
        default: return 31
        }
    }

    /// 그 해의 기준일 0시. 그 달에 없는 날(2월 30일 등)은 그 달 마지막 날로.
    func date(in year: Int, calendar: Calendar = .app) -> Date {
        let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        let length = calendar.range(of: .day, in: .month, for: first)?.count ?? 28
        return calendar.date(byAdding: .day, value: min(day, length) - 1, to: first) ?? first
    }
}

enum LeaveUsageCalculator {

    // MARK: - 회계연도

    /// 기준일로 시작하는 회계연도의 시작일.
    static func fiscalYearStart(year: Int, startMonth start: YearStart, calendar: Calendar = .app) -> Date {
        start.date(in: year, calendar: calendar)
    }

    /// 회계연도의 마지막 순간 (다음 해 시작 1초 전).
    static func fiscalYearEnd(year: Int, startMonth start: YearStart, calendar: Calendar = .app) -> Date {
        let next = fiscalYearStart(year: year + 1, startMonth: start, calendar: calendar)
        return calendar.date(byAdding: .second, value: -1, to: next) ?? next
    }

    /// 이 날짜가 속한 회계연도 (예: 기준일 3월 21일이면 2026-03-20은 2025년도, 2026-03-21은 2026년도).
    static func fiscalYear(for date: Date, startMonth start: YearStart, calendar: Calendar = .app) -> Int {
        let year = calendar.component(.year, from: date)
        return date >= fiscalYearStart(year: year, startMonth: start, calendar: calendar) ? year : year - 1
    }

    /// 그 회계연도에 속한 기록만 (시작일 기준).
    static func records(_ records: [LeaveRecord],
                        inFiscalYear year: Int,
                        startMonth: YearStart,
                        calendar: Calendar = .app) -> [LeaveRecord] {
        let start = fiscalYearStart(year: year, startMonth: startMonth, calendar: calendar)
        let end = fiscalYearEnd(year: year, startMonth: startMonth, calendar: calendar)
        return records.filter { $0.startDate >= start && $0.startDate <= end }
    }

    // MARK: - 상태 판정

    /// 이미 지나간 휴가인가 — 상태가 `.used`이거나 종료일이 지난 `.planned`.
    static func isCompleted(_ record: LeaveRecord, asOf now: Date = Date(), calendar: Calendar = .app) -> Bool {
        let today = calendar.startOfDay(for: now)
        switch record.status {
        case .used: return true
        case .planned: return calendar.startOfDay(for: record.endDate) < today
        case .cancelled: return false
        }
    }

    /// 아직 오지 않은 예정 휴가인가.
    static func isUpcoming(_ record: LeaveRecord, asOf now: Date = Date(), calendar: Calendar = .app) -> Bool {
        let today = calendar.startOfDay(for: now)
        return record.status == .planned && calendar.startOfDay(for: record.endDate) >= today
    }

    // MARK: - 요약

    /// 한 회계연도의 사용 현황. 화면은 이 값만 읽어 그린다(자체 계산 금지).
    struct Summary: Equatable {
        /// 연차에서 차감된 사용 완료 일수 (보너스 연결분 제외).
        let annualUsed: Double
        /// 연차에서 차감될 예정 일수.
        let annualPlanned: Double
        /// 모든 유형을 합친 사용 완료 일수 (출장·병가·특별휴가 포함) — "며칠 쉬었나".
        let allTypesUsed: Double
        /// 모든 유형을 합친 예정 일수.
        let allTypesPlanned: Double
        /// 사용 완료 건수 (모든 유형).
        let usedCount: Int
        /// 예정 건수 (모든 유형).
        let plannedCount: Int
        /// 연차에서 차감되는 기록만 센 건수 — 일수와 건수가 서로 다른 모집단이면 안 된다.
        let annualUsedCount: Int
        let annualPlannedCount: Int
        /// 취소 건수.
        let cancelledCount: Int
        /// 부여받은 보너스 총합 / 사용된 보너스.
        let grantedBonus: Double
        let usedBonus: Double
        /// **아직 쓸 수 있는** 보너스 — 만료된 건 빠진다.
        /// ⚠️ `grantedBonus - usedBonus`로 계산하면 만료돼 사라진 날을 남은 것처럼 보여 준다.
        let remainingBonus: Double
        /// 지난해에서 넘어와 **지금 쓸 수 있는** 연차 (이월 설정이 꺼져 있거나 grant 를 안 주면 0).
        /// 사용 기한이 지났으면 그 전에 쓴 만큼만 남는다 — `carryOverUsable` 참고.
        var carryOver: Double = 0

        /// 연차에서 이미 나갔거나 나갈 예정인 총량 — 잔여 계산의 분자.
        var annualCommitted: Double { annualUsed + annualPlanned }
        /// 못 쓰고 만료된 보너스 — "총 = 사용 + 남음"이 안 맞을 때 그 차이가 이것이다.
        var expiredBonus: Double { max(0, grantedBonus - usedBonus - remainingBonus) }

        /// 화면에 "사용 완료"로 띄우는 값.
        /// 보너스 포함 설정이 켜져 있으면 쓴 보너스도 더한다 — 그래야 "총 = 사용 + 남음"이 맞는다.
        /// ⚠️ 홈·내역·설정이 **모두 이 함수를 통해** 값을 얻는다. 화면에서 직접 더하지 말 것.
        func used(includingBonus: Bool) -> Double {
            includingBonus ? annualUsed + usedBonus : annualUsed
        }

        /// 화면에 "총 연차"로 띄우는 값.
        func total(annualGrant: Double, includingBonus: Bool) -> Double {
            let grant = annualGrant + carryOver
            return includingBonus ? grant + grantedBonus : grant
        }

        /// 화면에 "남음"으로 띄우는 값 (예정분까지 뺀 실제 쓸 수 있는 양).
        func remaining(annualGrant: Double, includingBonus: Bool) -> Double {
            let annualRemaining = max(0, annualGrant + carryOver - annualCommitted)
            return includingBonus ? annualRemaining + remainingBonus : annualRemaining
        }
    }

    /// 회계연도 하나의 요약을 만든다.
    /// - Parameters:
    ///   - records: 전체 휴가 기록 (연도 필터는 여기서 한다).
    ///   - bonuses: 전체 보너스 연차.
    ///   - year: 볼 회계연도. 지난 해 내역도 같은 방식으로 계산된다.
    static func summary(records: [LeaveRecord],
                        bonuses: [BonusLeave] = [],
                        year: Int,
                        startMonth: YearStart,
                        annualGrant: Double? = nil,
                        asOf now: Date = Date(),
                        calendar: Calendar = .app) -> Summary {
        let scoped = self.records(records, inFiscalYear: year, startMonth: startMonth, calendar: calendar)

        // 보너스도 그 해에 부여된 것만 — 지난 해 내역을 볼 때 올해 받은 보너스가 끼어들면 안 된다.
        let start = fiscalYearStart(year: year, startMonth: startMonth, calendar: calendar)
        let end = fiscalYearEnd(year: year, startMonth: startMonth, calendar: calendar)
        let scopedBonuses = bonuses.filter { $0.grantedDate >= start && $0.grantedDate <= end }

        let completed = scoped.filter { isCompleted($0, asOf: now, calendar: calendar) }
        let upcoming = scoped.filter { isUpcoming($0, asOf: now, calendar: calendar) }

        func days(_ list: [LeaveRecord], annualOnly: Bool) -> Double {
            list.filter { annualOnly ? $0.deductsFromAnnualLeave : true }
                .reduce(0.0) { $0 + $1.effectiveLeaveDays }
        }

        var summary = Summary(
            annualUsed: days(completed, annualOnly: true),
            annualPlanned: days(upcoming, annualOnly: true),
            allTypesUsed: days(completed, annualOnly: false),
            allTypesPlanned: days(upcoming, annualOnly: false),
            usedCount: completed.count,
            plannedCount: upcoming.count,
            annualUsedCount: completed.filter(\.deductsFromAnnualLeave).count,
            annualPlannedCount: upcoming.filter(\.deductsFromAnnualLeave).count,
            cancelledCount: scoped.filter { $0.status == .cancelled }.count,
            grantedBonus: scopedBonuses.reduce(0) { $0 + $1.days },
            usedBonus: scopedBonuses.reduce(0) { $0 + $1.usedDays },
            // 만료일이 지난 보너스는 남은 것으로 세지 않는다 — 쓸 수 없는 날이다.
            remainingBonus: scopedBonuses
                .filter { $0.expirationDate == nil || $0.expirationDate! > now }
                .reduce(0) { $0 + $1.remainingDays }
        )
        if let annualGrant {
            summary.carryOver = carryOverUsable(year: year, on: now, records: records, annualGrant: annualGrant,
                                                startMonth: startMonth, calendar: calendar)
        }
        return summary
    }

    /// 오늘이 속한 회계연도의 요약 — 홈·설정처럼 "지금"만 보는 화면용.
    static func currentSummary(records: [LeaveRecord],
                               bonuses: [BonusLeave] = [],
                               startMonth: YearStart,
                               annualGrant: Double? = nil,
                               asOf now: Date = Date(),
                               calendar: Calendar = .app) -> Summary {
        summary(records: records,
                bonuses: bonuses,
                year: fiscalYear(for: now, startMonth: startMonth, calendar: calendar),
                startMonth: startMonth,
                annualGrant: annualGrant,
                asOf: now,
                calendar: calendar)
    }

    // MARK: - 미리 계획 · 이월 (네덜란드 사용자 피드백)
    //
    // · 휴가는 **그 휴가가 속한 해**의 연차에서 빠진다. 10월에 내년 1월 휴가를 잡으면 내년 연차로 센다
    //   (예전엔 등록 화면이 올해 잔여로 막아서, 해가 바뀌기 전엔 내년 계획을 못 세웠다).
    // · 이월: 지난해 남은 연차를 회사 규정만큼 넘긴다 — 상한(일)과 사용 기한(새 해 시작 후 N개월).
    //   기한이 있으면 그 전에 시작한 휴가가 넘어온 연차부터 쓰고, 기한 뒤에는 못 쓴 만큼 사라진다.

    /// 이월 상한 (일). 0 = 이월 안 함, -1 = 남은 만큼 전부.
    static var carryOverMaxDays: Int {
        get { UserDefaults.standard.integer(forKey: "carryOverMaxDays") }
        set { UserDefaults.standard.set(newValue, forKey: "carryOverMaxDays") }
    }

    /// 넘어온 연차를 쓸 수 있는 기간 (새 해 시작 후 개월). 0 = 기한 없음.
    static var carryOverExpiryMonths: Int {
        get { UserDefaults.standard.integer(forKey: "carryOverExpiryMonths") }
        set { UserDefaults.standard.set(newValue, forKey: "carryOverExpiryMonths") }
    }

    /// 넘어온 연차의 사용 기한 (그 시각부터는 못 쓴다). 기한이 없으면 nil.
    static func carryOverExpiry(year: Int, startMonth: YearStart, calendar: Calendar = .app) -> Date? {
        guard carryOverExpiryMonths > 0 else { return nil }
        return calendar.date(byAdding: .month, value: carryOverExpiryMonths,
                             to: fiscalYearStart(year: year, startMonth: startMonth, calendar: calendar))
    }

    /// 그 해의 연차 차감 확정량 (사용 + 예정, 취소 제외) — 날짜 조건을 주면 그 전에 시작한 것만
    private static func committed(_ records: [LeaveRecord], year: Int, startMonth: YearStart,
                                  before limit: Date? = nil, calendar: Calendar) -> Double {
        self.records(records, inFiscalYear: year, startMonth: startMonth, calendar: calendar)
            .filter { $0.status != .cancelled && $0.deductsFromAnnualLeave && (limit == nil || $0.startDate < limit!) }
            .reduce(0) { $0 + $1.effectiveLeaveDays }
    }

    /// 사용자가 직접 적은 "그 해로 넘어온 연차" — 적었으면 계산 대신 이 값을 쓴다. 안 적었으면 nil.
    /// (앱을 올해 처음 써서 지난해 기록이 없는 사람은 계산으로는 넘어온 양을 알 수 없다)
    static func carryOverManual(year: Int) -> Double? {
        UserDefaults.standard.object(forKey: "carryOverManual.\(year)") as? Double
    }

    static func setCarryOverManual(_ days: Double?, year: Int) {
        let key = "carryOverManual.\(year)"
        if let days { UserDefaults.standard.set(max(0, days), forKey: key) } else { UserDefaults.standard.removeObject(forKey: key) }
    }

    /// 지난해에서 그 해로 넘어오는 연차 (기한과 상관없이 넘어온 양). 앞의 해를 몇 해까지 거슬러 계산한다.
    static func carryOverIn(year: Int, records: [LeaveRecord], annualGrant: Double, startMonth: YearStart,
                            depth: Int = 3, usesManual: Bool = true, calendar: Calendar = .app) -> Double {
        if usesManual, let manual = carryOverManual(year: year) { return manual }
        let cap = carryOverMaxDays
        let previousGrant = grant(year: year - 1, fallback: annualGrant, startMonth: startMonth, calendar: calendar)
        guard cap != 0, depth > 0, previousGrant > 0 else { return 0 }
        let previous = year - 1
        // 기록이 하나도 없는 해부터는 이 앱을 안 쓴 해라 넘길 게 없다고 본다
        guard !self.records(records, inFiscalYear: previous, startMonth: startMonth, calendar: calendar).isEmpty else { return 0 }
        let prevCarry = carryOverIn(year: previous, records: records, annualGrant: annualGrant,
                                    startMonth: startMonth, depth: depth - 1, calendar: calendar)
        // 지난해 안에서 기한이 지나 사라진 몫은 빼고 남은 양
        let prevUsable = carryOverUsableAtYearEnd(carryIn: prevCarry, year: previous, records: records,
                                                  startMonth: startMonth, calendar: calendar)
        let left = max(0, previousGrant + prevUsable - committed(records, year: previous, startMonth: startMonth, calendar: calendar))
        return cap < 0 ? left : min(Double(cap), left)
    }

    /// 넘어온 연차 중 해가 끝날 때 살아 있는 몫 — 기한이 있으면 기한 전에 쓴 만큼만
    private static func carryOverUsableAtYearEnd(carryIn: Double, year: Int, records: [LeaveRecord],
                                                 startMonth: YearStart, calendar: Calendar) -> Double {
        guard carryIn > 0, let expiry = carryOverExpiry(year: year, startMonth: startMonth, calendar: calendar) else { return carryIn }
        return min(carryIn, committed(records, year: year, startMonth: startMonth, before: expiry, calendar: calendar))
    }

    /// 그 해의 넘어온 연차 중 `date` 에 쓸 수 있는 양 — 기한 전이면 전부, 기한 뒤면 그 전에 쓴 만큼만
    static func carryOverUsable(year: Int, on date: Date, records: [LeaveRecord], annualGrant: Double,
                                startMonth: YearStart, calendar: Calendar = .app) -> Double {
        let carryIn = carryOverIn(year: year, records: records, annualGrant: annualGrant, startMonth: startMonth, calendar: calendar)
        guard carryIn > 0, let expiry = carryOverExpiry(year: year, startMonth: startMonth, calendar: calendar),
              date >= expiry else { return carryIn }
        return min(carryIn, committed(records, year: year, startMonth: startMonth, before: expiry, calendar: calendar))
    }

    /// `date` 에 시작하는 휴가에 쓸 수 있는 연차 — **그 휴가가 속한 해** 기준 (내년 휴가는 내년 연차).
    /// - Parameter excluding: 고치는 중인 기록은 빼고 센다.
    static func availableAnnual(on date: Date, records: [LeaveRecord], annualGrant: Double, startMonth: YearStart,
                                excluding: UUID? = nil, calendar: Calendar = .app) -> Double {
        let others = excluding.map { id in records.filter { $0.id != id } } ?? records
        let year = fiscalYear(for: date, startMonth: startMonth, calendar: calendar)
        func balance(on day: Date) -> Double {
            let carry = carryOverUsable(year: year, on: day, records: others, annualGrant: annualGrant,
                                        startMonth: startMonth, calendar: calendar)
            guard let accrual else {
                return annualGrant + carry - committed(others, year: year, startMonth: startMonth, calendar: calendar)
            }
            // 쌓이는 연차: 그날까지 쌓인 만큼에서, 그날까지 시작한 휴가만 뺀다
            let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)) ?? day
            return accrual.earned(year: year, startMonth: startMonth, through: day, calendar: calendar) + carry
                - committed(others, year: year, startMonth: startMonth, before: nextDay, calendar: calendar)
        }
        guard accrual != nil else { return max(0, balance(on: date)) }
        // 이날 쓰면 뒤에 잡아 둔 휴가 때 모자라지 않아야 한다 → 이날과 뒤의 휴가 시작일마다 잔액을 보고 가장 적은 값
        let later = self.records(others, inFiscalYear: year, startMonth: startMonth, calendar: calendar)
            .filter { $0.status != .cancelled && $0.deductsFromAnnualLeave && $0.startDate > date }
            .map(\.startDate)
        return max(0, ([date] + later).map(balance(on:)).min() ?? 0)
    }

    // MARK: - 쌓이는 연차 (미국 사용자 피드백)
    //
    // 연차를 받는 방식은 둘이다.
    //  · 한 번에 받음 — 해가 시작될 때 1년치(`totalAnnualLeave`)를 받는다. 예전부터의 방식.
    //  · 조금씩 쌓임 — 급여일마다 정해진 양(예: 2.31시간)이 쌓인다. 미국 회사에 흔하다.
    // 쌓임이면 `totalAnnualLeave` 는 "그 해 끝까지 쌓일 양"으로 맞춰 두고(→ `syncAccrualTotal`),
    // 휴가를 넣을 수 있는지는 **그 휴가 날까지 쌓인 양**으로 따진다(→ `availableAnnual`).

    struct Accrual: Equatable {
        enum Period: String, CaseIterable, Identifiable {
            case weekly, biweekly, semimonthly, monthly
            var id: String { rawValue }
        }

        /// 급여일 한 번에 쌓이는 양 (`isHours` 면 시간, 아니면 일)
        var amount: Double
        var isHours: Bool
        var period: Period
        /// 급여일 하나 — 매주·2주마다·매달은 이 날을 기준으로 돈다 (한 달에 두 번은 15일·말일 고정)
        var payDay: Date

        /// 한 번에 쌓이는 양을 일로 — 시간이면 하루 근무 시간으로 나눈다
        var daysPerPeriod: Double {
            isHours ? amount * 60 / Double(max(1, LeaveLength.workdayMinutes)) : amount
        }

        /// `start`~`end` (둘 다 포함) 사이의 급여일
        func payDates(from start: Date, through end: Date, calendar: Calendar = .app) -> [Date] {
            let from = calendar.startOfDay(for: start), to = calendar.startOfDay(for: end)
            guard from <= to else { return [] }
            var dates: [Date] = []
            switch period {
            case .weekly, .biweekly:
                let step = period == .weekly ? 7 : 14
                let anchor = calendar.startOfDay(for: payDay)
                let offset = calendar.dateComponents([.day], from: anchor, to: from).day ?? 0
                var k = Int((Double(offset) / Double(step)).rounded(.up))
                while let d = calendar.date(byAdding: .day, value: k * step, to: anchor), d <= to {
                    dates.append(d); k += 1
                }
            case .semimonthly, .monthly:
                let wanted = calendar.component(.day, from: payDay)
                var month = calendar.date(from: calendar.dateComponents([.year, .month], from: from)) ?? from
                while month <= to {
                    let last = calendar.range(of: .day, in: .month, for: month)?.count ?? 28
                    let days = period == .monthly ? [min(wanted, last)] : [15, last]
                    for day in days {
                        if let d = calendar.date(byAdding: .day, value: day - 1, to: month), d >= from, d <= to {
                            dates.append(d)
                        }
                    }
                    month = calendar.date(byAdding: .month, value: 1, to: month) ?? to.addingTimeInterval(1)
                }
            }
            return dates
        }

        /// 그 회계연도 시작부터 `date` 까지 쌓인 연차 (일)
        func earned(year: Int, startMonth: YearStart, through date: Date, calendar: Calendar = .app) -> Double {
            let start = fiscalYearStart(year: year, startMonth: startMonth, calendar: calendar)
            let end = min(date, fiscalYearEnd(year: year, startMonth: startMonth, calendar: calendar))
            return Double(payDates(from: start, through: end, calendar: calendar).count) * daysPerPeriod
        }

        /// 그 해 끝까지 쌓일 연차 (일)
        func yearTotal(year: Int, startMonth: YearStart, calendar: Calendar = .app) -> Double {
            earned(year: year, startMonth: startMonth,
                   through: fiscalYearEnd(year: year, startMonth: startMonth, calendar: calendar), calendar: calendar)
        }
    }

    /// 지금 설정된 쌓이는 연차. 한 번에 받는 방식이면 nil. 설정 화면의 @AppStorage 와 같은 키를 쓴다.
    static var accrual: Accrual? {
        get {
            let d = UserDefaults.standard
            guard let period = Accrual.Period(rawValue: d.string(forKey: "accrualPeriod") ?? "") else { return nil }
            return Accrual(amount: d.double(forKey: "accrualAmount"),
                           isHours: d.bool(forKey: "accrualIsHours"),
                           period: period,
                           payDay: Date(timeIntervalSinceReferenceDate: d.double(forKey: "accrualPayDay")))
        }
        set {
            let d = UserDefaults.standard
            guard let newValue else { d.removeObject(forKey: "accrualPeriod"); return }
            d.set(newValue.period.rawValue, forKey: "accrualPeriod")
            d.set(newValue.amount, forKey: "accrualAmount")
            d.set(newValue.isHours, forKey: "accrualIsHours")
            d.set(newValue.payDay.timeIntervalSinceReferenceDate, forKey: "accrualPayDay")
        }
    }

    /// 그 해의 1년치 연차 — 쌓임이면 그 해 끝까지 쌓일 양, 아니면 `fallback`(총 연차)
    static func grant(year: Int, fallback: Double, startMonth: YearStart, calendar: Calendar = .app) -> Double {
        accrual?.yearTotal(year: year, startMonth: startMonth, calendar: calendar) ?? fallback
    }

    /// 쌓임이면 총 연차를 올해 끝까지 쌓일 양으로 맞춘다 — 총 연차를 읽는 화면·위젯이 따로 계산하지 않게.
    @discardableResult
    static func syncAccrualTotal(_ profile: UserProfile, now: Date = Date(), calendar: Calendar = .app) -> Bool {
        guard profile.userType == .employee, let accrual else { return false }
        let year = fiscalYear(for: now, startMonth: profile.yearStart, calendar: calendar)
        let total = (accrual.yearTotal(year: year, startMonth: profile.yearStart, calendar: calendar) * 100).rounded() / 100
        guard abs(profile.totalAnnualLeave - total) > 0.001 else { return false }
        profile.totalAnnualLeave = total
        return true
    }
}
