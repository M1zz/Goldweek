//
//  BurnoutEngine.swift
//  Goldweek
//
//  "지금 쉬어야 한다"를 판단하는 번아웃 엔진.
//
//  방어 가능한 가치 = 캘린더로 손쉽게 푸는 징검다리 계산이 아니라,
//  "내 휴식 이력으로만 계산되는, 사람이 손으로 못 푸는" 회복 상태다.
//   - 회복 잔량(recovery reserve): 과거 휴식들이 준 회복을 fade-out 곡선으로 적분한 현재 잔량
//   - 개인 휴식 주기(personal cycle): 내 과거 휴식 간격의 중앙값
//   - 번아웃 예측일(predicted risk date): 현 속도면 위험 구간에 진입할 미래 시점 외삽
//
//  근거 (docs/rest-radar-research.md):
//   - 휴가 효과는 ~8일 정점 후 복귀 1주 내 사라지고 번아웃은 3~4주 내 원위치
//     → decay 곡선 ~30일 소멸 (de Bloom 메타분석, European Psychologist 2023)
//   - 짧고 잦은 휴식 > 긴 휴가, 권고 ≈ 60일마다 (Maximizing Recovery, 2025)
//     → 개인 주기 기본값 60일, 기존 applyBurnoutSpacing의 60/40/21 임계와 정합
//
//  결정성: 모든 계산은 주입된 `asOf` 기준. Date()를 내부에서 부르지 않음 → 테스트 가능.
//

import Foundation

// MARK: - 입력

/// 사무실/일상에서 벗어난 1개 휴식 블록 (연차·출장 등). LeaveRecord에서 변환해 주입.
struct RestBlock: Hashable {
    let start: Date
    let end: Date

    /// 휴식 길이(일). 당일치기도 최소 1.
    func length(_ cal: Calendar) -> Int {
        (cal.dateComponents([.day], from: cal.startOfDay(for: start),
                            to: cal.startOfDay(for: end)).day ?? 0) + 1
    }
}

// MARK: - 출력

enum BurnoutLevel: Int, Comparable {
    case ok = 0          // 회복 충분
    case mindful = 1     // 슬슬 챙길 때
    case overdue = 2     // 평소 주기 초과 — 쉴 때
    case critical = 3    // 오래 무방비 — 강하게 권고

    static func < (l: BurnoutLevel, r: BurnoutLevel) -> Bool { l.rawValue < r.rawValue }
}

struct BurnoutAssessment {
    /// 0.0(완전 회복) ~ 1.0(고갈). 종합 위험 점수.
    let riskScore: Double
    let level: BurnoutLevel

    /// 회복 잔량 비율 0.0~1.0 (1.0 = 최근 휴식으로 가득 찬 상태)
    let recoveryReserveRatio: Double
    /// 내 과거 휴식 간격의 중앙값(일). 이력 부족 시 기본 60.
    let personalCycleDays: Int
    /// 주기의 신뢰도 — 휴식 표본이 충분한가 (간격 2개 미만이면 false → 기본값 사용 중)
    let cycleIsPersonalized: Bool
    /// 마지막 휴식 종료 후 경과일 (없으면 nil)
    let daysSinceLastBreak: Int?
    /// 현 속도면 위험(critical 진입)이 예상되는 날. 이미 위험이면 nil(=지금).
    let predictedRiskDate: Date?
    /// 사용자에게 보여줄 1차 사유 키 (UI/알림 문구 선택용)
    let primaryReason: BurnoutReason
}

enum BurnoutReason {
    case wellRested              // 최근 잘 쉼
    case planAhead               // 곧 예정된 휴식이 있어 안심
    case cycleExceeded           // 평소 주기를 넘김
    case longGap                 // 오래 못 쉼 (이력은 적지만 공백이 큼)
    case neverRested             // 휴식 기록 자체가 없음
    case subjectiveHigh          // 사용자가 직접 높은 피로를 보고함
}

// MARK: - 엔진

struct BurnoutEngine {

    // 튜닝 파라미터 (측정 후 analytics로 보정 — docs/analytics-impact.md)
    struct Config {
        /// 휴식 회복이 0으로 소멸하기까지의 일수 (근거: 효과 3~4주 내 소멸)
        var decayDays: Double = 30
        /// 이력 부족 시 사용할 기본 개인 주기 (근거: ~60일마다 휴식 권고)
        var defaultCycleDays: Double = 60
        /// "꽉 찬 회복 탱크" 1단위로 볼 휴식 길이(일). 잔량 비율 정규화 분모.
        var fullTankRestDays: Double = 3
        /// critical 판정 위험 임계값
        var criticalThreshold: Double = 0.66
        /// overdue 판정 임계값
        var overdueThreshold: Double = 0.45
        /// mindful 판정 임계값
        var mindfulThreshold: Double = 0.25
        /// 곧 예정된 휴식이 있으면 안심으로 처리할 창(일)
        var plannedSoonDays: Int = 30

        // 위험 점수 가중치 (존재하는 신호만 사용, 합산 후 정규화)
        var wDepletion: Double = 0.45   // 회복 잔량 고갈
        var wOverdue: Double = 0.30     // 개인 주기 초과 압력
        var wExpiry: Double = 0.10      // 연차 소멸 임박
        var wSubjective: Double = 0.15  // 사용자 주관 보고(SIB)

        init() {}
    }

    var config = Config()
    var calendar = Calendar.current

    /// 핵심 평가.
    /// - breaks: 과거~미래 휴식 블록 전체 (취소 제외해서 주입)
    /// - asOf: 기준 시각 (보통 오늘)
    /// - subjectiveFatigue: 단일문항 번아웃 0~10 (선택, docs 근거 E). nil이면 미사용.
    /// - expiryPressure: 연차 소멸 임박도 0~1 (선택). nil이면 미사용.
    func assess(
        breaks: [RestBlock],
        asOf: Date,
        subjectiveFatigue: Int? = nil,
        expiryPressure: Double? = nil
    ) -> BurnoutAssessment {
        let today = calendar.startOfDay(for: asOf)

        let past = breaks
            .filter { calendar.startOfDay(for: $0.end) <= today }
            .sorted { $0.end < $1.end }
        let future = breaks
            .filter { calendar.startOfDay(for: $0.start) > today }
            .sorted { $0.start < $1.start }

        // 1. 개인 휴식 주기 (간격 중앙값)
        let (cycle, personalized) = personalCycle(past: past)

        // 2. 마지막 휴식 후 경과일
        let lastEnd = past.last?.end
        let daysSince = lastEnd.map {
            calendar.dateComponents([.day], from: calendar.startOfDay(for: $0), to: today).day ?? 0
        }

        // 3. 회복 잔량
        let reserveRatio = recoveryReserveRatio(past: past, asOf: today)

        // 4. 곧 예정된 휴식 여부
        let nextStart = future.first?.start
        let daysUntilNext = nextStart.map {
            calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: $0)).day ?? 0
        }
        let plannedSoon = (daysUntilNext.map { $0 <= config.plannedSoonDays }) ?? false

        // 5. 종합 위험 점수
        let risk = riskScore(
            reserveRatio: reserveRatio,
            daysSince: daysSince,
            cycle: cycle,
            hasHistory: !past.isEmpty,
            subjectiveFatigue: subjectiveFatigue,
            expiryPressure: expiryPressure,
            plannedSoon: plannedSoon
        )

        // 6. 레벨 + 사유
        let level = levelFor(risk: risk, plannedSoon: plannedSoon)
        let reason = reasonFor(
            level: level, plannedSoon: plannedSoon, hasHistory: !past.isEmpty,
            personalized: personalized, daysSince: daysSince, cycle: cycle,
            subjectiveFatigue: subjectiveFatigue
        )

        // 7. 예측일 (현재 이미 critical이면 nil = 지금)
        let predicted = (level == .critical) ? nil :
            predictRiskDate(past: past, future: future, asOf: today,
                            subjectiveFatigue: subjectiveFatigue, expiryPressure: expiryPressure)

        return BurnoutAssessment(
            riskScore: risk,
            level: level,
            recoveryReserveRatio: reserveRatio,
            personalCycleDays: Int(cycle.rounded()),
            cycleIsPersonalized: personalized,
            daysSinceLastBreak: daysSince,
            predictedRiskDate: predicted,
            primaryReason: reason
        )
    }

    // MARK: - 회복 잔량

    /// 과거 휴식들의 회복을 fade-out 곡선으로 적분한 현재 잔량 비율(0~1).
    /// decay(d) = max(0, 1 − d/decayDays). 휴식 길이로 가중, fullTank로 정규화.
    func recoveryReserveRatio(past: [RestBlock], asOf today: Date) -> Double {
        var reserve = 0.0
        for b in past {
            let endDay = calendar.startOfDay(for: b.end)
            let d = Double(calendar.dateComponents([.day], from: endDay, to: today).day ?? 0)
            let decay = max(0, 1 - d / config.decayDays)
            guard decay > 0 else { continue }
            reserve += Double(b.length(calendar)) * decay
        }
        return min(1, reserve / config.fullTankRestDays)
    }

    // MARK: - 개인 주기

    /// 과거 휴식 시작일 간격의 중앙값. 간격 2개 미만이면 기본값.
    /// - Returns: (주기일, 개인화여부)
    func personalCycle(past: [RestBlock]) -> (Double, Bool) {
        let starts = past.map { calendar.startOfDay(for: $0.start) }.sorted()
        guard starts.count >= 3 else { return (config.defaultCycleDays, false) }
        var gaps: [Double] = []
        for i in 1..<starts.count {
            let g = calendar.dateComponents([.day], from: starts[i - 1], to: starts[i]).day ?? 0
            if g > 0 { gaps.append(Double(g)) }
        }
        guard gaps.count >= 2 else { return (config.defaultCycleDays, false) }
        let sorted = gaps.sorted()
        let mid = sorted.count / 2
        let median = sorted.count % 2 == 0 ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid]
        // 비현실적으로 짧거나 긴 주기는 합리 범위로 클램프 (14~120일)
        return (min(120, max(14, median)), true)
    }

    // MARK: - 위험 점수

    private func riskScore(
        reserveRatio: Double,
        daysSince: Int?,
        cycle: Double,
        hasHistory: Bool,
        subjectiveFatigue: Int?,
        expiryPressure: Double?,
        plannedSoon: Bool
    ) -> Double {
        let depletion = 1 - reserveRatio

        // 주기 초과 압력: 0.5*cycle부터 상승, 1.5*cycle에서 1.0
        let overdue: Double
        if let ds = daysSince {
            overdue = clamp(Double(ds) / cycle - 0.5, 0, 1)
        } else {
            // 휴식 기록 없음 — 중간 압력
            overdue = 0.6
        }

        // 존재하는 신호만 가중 합산 후, 사용한 가중치 합으로 정규화
        var num = config.wDepletion * depletion + config.wOverdue * overdue
        var den = config.wDepletion + config.wOverdue

        if let s = subjectiveFatigue {
            num += config.wSubjective * clamp(Double(s) / 10, 0, 1)
            den += config.wSubjective
        }
        if let e = expiryPressure {
            num += config.wExpiry * clamp(e, 0, 1)
            den += config.wExpiry
        }

        var score = den > 0 ? num / den : 0
        // 곧 예정된 휴식이 있으면 안심 — 점수 완화
        if plannedSoon { score *= 0.5 }
        return clamp(score, 0, 1)
    }

    private func levelFor(risk: Double, plannedSoon: Bool) -> BurnoutLevel {
        if risk >= config.criticalThreshold { return .critical }
        if risk >= config.overdueThreshold { return .overdue }
        if risk >= config.mindfulThreshold { return .mindful }
        return .ok
    }

    private func reasonFor(
        level: BurnoutLevel, plannedSoon: Bool, hasHistory: Bool,
        personalized: Bool, daysSince: Int?, cycle: Double,
        subjectiveFatigue: Int?
    ) -> BurnoutReason {
        if plannedSoon { return .planAhead }
        if level == .ok { return .wellRested }
        if !hasHistory { return .neverRested }
        if let s = subjectiveFatigue, s >= 7 { return .subjectiveHigh }
        if personalized, let ds = daysSince, Double(ds) > cycle { return .cycleExceeded }
        return .longGap
    }

    // MARK: - 예측

    /// 현 속도면 위험(critical)에 진입할 날을 미래로 외삽.
    /// 미래 예정 휴식은 그 시점에 잔량을 회복시키는 것으로 반영.
    /// 최대 180일 탐색, 못 찾으면 nil.
    func predictRiskDate(
        past: [RestBlock],
        future: [RestBlock],
        asOf today: Date,
        subjectiveFatigue: Int?,
        expiryPressure: Double?,
        horizonDays: Int = 180
    ) -> Date? {
        for offset in 1...horizonDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { break }
            let dayStart = calendar.startOfDay(for: day)

            // 그날 기준, 그날 이전의 모든 휴식(과거 + 그 사이 예정)을 과거로 간주
            let knownBreaks = (past + future).filter {
                calendar.startOfDay(for: $0.end) <= dayStart
            }
            let reserve = recoveryReserveRatio(past: knownBreaks, asOf: dayStart)
            let (cycle, _) = personalCycle(past: knownBreaks)
            let lastEnd = knownBreaks.map { $0.end }.max()
            let daysSince = lastEnd.map {
                calendar.dateComponents([.day], from: calendar.startOfDay(for: $0), to: dayStart).day ?? 0
            }
            // 그 사이/이후 예정 휴식이 곧 있으면 안심 반영
            let nextStart = (past + future)
                .map { calendar.startOfDay(for: $0.start) }
                .filter { $0 > dayStart }.min()
            let plannedSoon = nextStart.map {
                (calendar.dateComponents([.day], from: dayStart, to: $0).day ?? 999) <= config.plannedSoonDays
            } ?? false

            // 예측은 미래의 주관/소멸 신호를 모르므로 구조적 신호(잔량·주기)만 사용
            let risk = riskScore(
                reserveRatio: reserve, daysSince: daysSince, cycle: cycle,
                hasHistory: !knownBreaks.isEmpty, subjectiveFatigue: nil,
                expiryPressure: nil, plannedSoon: plannedSoon
            )
            if risk >= config.criticalThreshold {
                return dayStart
            }
        }
        return nil
    }

    private func clamp(_ x: Double, _ lo: Double, _ hi: Double) -> Double {
        min(hi, max(lo, x))
    }
}

// MARK: - LeaveRecord 변환 헬퍼

extension BurnoutEngine {
    /// LeaveRecord 배열을 RestBlock으로 변환.
    /// 휴식으로 칠 것: 연차 차감 휴가 + 출장(일상 루틴 이탈). 취소는 제외.
    /// (BurnoutPaceCard.countsAsBreak 와 동일 기준 — 단일 진실 소스화 목적)
    static func restBlocks(from records: [LeaveRecord]) -> [RestBlock] {
        records.compactMap { r in
            guard r.status != .cancelled else { return nil }
            let counts = r.deductsFromAnnualLeave || r.type == .businessTrip
            guard counts else { return nil }
            return RestBlock(start: r.startDate, end: r.endDate)
        }
    }
}
