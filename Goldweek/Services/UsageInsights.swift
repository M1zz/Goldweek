//
//  UsageInsights.swift
//  Goldweek
//
//  허브에서 읽어 온 원본(스냅샷·이벤트)을 "판단에 쓸 수 있는 숫자"로 바꾸는 순수 함수 모음.
//  네트워크도 UI도 없다 — 그래서 유닛 테스트로 검증할 수 있고, 통계 화면은 계산을 하지 않는다.
//
//  이 앱에서 확인하려는 것은 하나다: **사람들이 이 앱으로 실제로 쉬었는가.**
//  설치 수나 실행 횟수는 그 답이 아니라 분모일 뿐이라, 아래 지표들은 전부
//  "휴가를 등록했는가 / 추천을 받아들였는가 / 며칠을 확보했는가"로 수렴한다.
//

import Foundation

enum UsageInsights {

    // MARK: - 이벤트 매칭

    /// 이벤트 이름이 그 단계에 해당하는지. `leave_added:annual` 처럼 슬라이스가 붙은 이름도 잡는다.
    static func matches(_ name: String, step: String) -> Bool {
        name == step || name.hasPrefix(step + ":")
    }

    /// 그 이벤트를 남긴 서로 다른 설치 수.
    static func installs(in samples: [UsageReportingService.EventSample], named step: String) -> Set<String> {
        var ids: Set<String> = []
        for sample in samples where matches(sample.name, step: step) {
            if let id = sample.installID { ids.insert(id) }
        }
        return ids
    }

    // MARK: - 퍼널

    struct FunnelStage: Identifiable {
        let name: String
        /// 이 단계에 도달한 설치 수.
        let installs: Int
        /// 첫 단계 대비 비율 (0.0 ~ 1.0).
        let rateFromTop: Double
        /// 직전 단계 대비 비율 (0.0 ~ 1.0). 첫 단계는 1.0.
        let rateFromPrevious: Double
        var id: String { name }
    }

    private static func funnel(_ steps: [(String, Int)]) -> [FunnelStage] {
        var stages: [FunnelStage] = []
        var topCount = 0
        var previousCount = 0

        for (index, step) in steps.enumerated() {
            if index == 0 { topCount = step.1 }
            stages.append(FunnelStage(
                name: step.0,
                installs: step.1,
                rateFromTop: topCount > 0 ? Double(step.1) / Double(topCount) : 0,
                rateFromPrevious: index == 0 ? 1.0 : (previousCount > 0 ? Double(step.1) / Double(previousCount) : 0)
            ))
            previousCount = step.1
        }
        return stages
    }

    /// 활성화 퍼널 — 설치하고 나서 **가치에 도달하기까지** 어디서 빠지는지.
    ///
    /// ⚠️ 첫 단계만 스냅샷(설치) 기준이고 나머지는 이벤트 기준이다. 이벤트는 6시간 쓰로틀이
    ///    걸려 있어 건수는 줄지만, "한 번이라도 했는가"를 보는 설치 수는 영향을 받지 않는다.
    ///    다만 이벤트 조회 범위(최근 3,000건)를 벗어난 오래된 설치는 아래 단계에서 빠진다.
    static func activationFunnel(snapshots: [UsageReportingService.Snapshot],
                                 events: [UsageReportingService.EventSample]) -> [FunnelStage] {
        funnel([
            ("설치", snapshots.count),
            ("온보딩 완료", installs(in: events, named: "onboarding_complete").count),
            ("휴가 등록", installs(in: events, named: "leave_added").count),
            ("추천 채택", installs(in: events, named: "recommendation_added").count),
        ])
    }

    /// 결제 전환 퍼널 — 노출 → 시도 → 완료.
    /// 마지막 칸만 슬라이스까지 정확히 맞춘다(`paywall_purchase:success`) — 실패까지 세면 전환율이 거짓말이 된다.
    static func paywallFunnel(events: [UsageReportingService.EventSample]) -> [FunnelStage] {
        var succeeded: Set<String> = []
        for sample in events where sample.name == "paywall_purchase:success" {
            if let id = sample.installID { succeeded.insert(id) }
        }
        return funnel([
            ("페이월 노출", installs(in: events, named: "paywall_view").count),
            ("구매 시도", installs(in: events, named: "paywall_purchase").count),
            ("구매 완료", succeeded.count),
        ])
    }

    // MARK: - 리텐션 (주간 코호트)

    struct RetentionRow: Identifiable {
        let cohortStart: Date
        /// 그 주에 설치한 수.
        let size: Int
        let day1: Int
        let day7: Int
        let day30: Int
        var id: Date { cohortStart }

        func rate(_ count: Int) -> Double {
            size > 0 ? Double(count) / Double(size) : 0
        }
    }

    /// 설치한 주별로 묶어 D1/D7/D30 잔존을 본다 (`app_open` 이벤트가 근거).
    /// ⚠️ 아직 그날이 오지 않은 설치는 잔존으로 세지 않는다 → 최근 코호트의 D30은 낮게 보인다.
    static func weeklyRetention(snapshots: [UsageReportingService.Snapshot],
                                events: [UsageReportingService.EventSample],
                                calendar: Calendar = .current,
                                now: Date = Date()) -> [RetentionRow] {

        // 설치별 활동일(자정 기준) 집합
        var activeDays: [String: Set<Date>] = [:]
        for event in events where matches(event.name, step: UsageReportingService.appOpenEvent) {
            guard let id = event.installID else { continue }
            activeDays[id, default: []].insert(calendar.startOfDay(for: event.date))
        }

        // 코호트(설치 주)별로 묶는다
        var cohorts: [Date: [(id: String, installedAt: Date)]] = [:]
        for snapshot in snapshots {
            guard let installDate = snapshot.installDate,
                  let week = calendar.dateInterval(of: .weekOfYear, for: installDate)?.start else { continue }
            cohorts[week, default: []].append((snapshot.id, installDate))
        }

        return cohorts.map { week, members in
            func retained(after offset: Int) -> Int {
                members.filter { member in
                    guard let target = calendar.date(byAdding: .day, value: offset,
                                                     to: calendar.startOfDay(for: member.installedAt)),
                          target <= now else { return false }   // 아직 안 온 날은 잔존으로 세지 않는다
                    return activeDays[member.id]?.contains(target) ?? false
                }.count
            }

            return RetentionRow(cohortStart: week,
                                size: members.count,
                                day1: retained(after: 1),
                                day7: retained(after: 7),
                                day30: retained(after: 30))
        }
        .sorted { $0.cohortStart > $1.cohortStart }
    }

    // MARK: - 효용 지표

    /// 한 줄로 읽는 판단 근거 — 값과, 그 값을 어떻게 읽어야 하는지.
    struct Signal: Identifiable {
        let name: String
        let value: String
        let hint: String
        var id: String { name }
    }

    /// 설치들 중 `key` 지표가 threshold를 넘는 비율.
    private static func share(_ snapshots: [UsageReportingService.Snapshot],
                              key: String,
                              over threshold: Double = 0) -> (count: Int, rate: Double) {
        guard !snapshots.isEmpty else { return (0, 0) }
        let count = snapshots.filter { ($0.metrics[key] ?? 0) > threshold }.count
        return (count, Double(count) / Double(snapshots.count))
    }

    /// 값을 가진 설치들의 평균.
    private static func average(_ snapshots: [UsageReportingService.Snapshot], key: String) -> Double {
        let values = snapshots.compactMap { $0.metrics[key] }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func percent(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

    private static func number(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }

    /// 이 앱이 값을 하고 있는지 판단하는 지표 묶음. 스냅샷이 없으면 빈 배열.
    static func valueSignals(snapshots: [UsageReportingService.Snapshot]) -> [Signal] {
        guard !snapshots.isEmpty else { return [] }

        let registered = share(snapshots, key: "leaves")
        let adopted = share(snapshots, key: "adoptedRecommendations")
        let shared = share(snapshots, key: "flag.sharing")
        let pro = share(snapshots, key: "flag.isPro")
        let empty = snapshots.filter { ($0.metrics["leaves"] ?? 0) == 0 }.count

        return [
            Signal(name: "휴가를 등록한 설치",
                   value: "\(registered.count)곳 (\(percent(registered.rate)))",
                   hint: "이 앱의 최소 가치 전달선. 여기서 막히면 온보딩이나 첫 등록 흐름 문제다."),
            Signal(name: "추천을 받아들인 설치",
                   value: "\(adopted.count)곳 (\(percent(adopted.rate)))",
                   hint: "추천 엔진이 값을 하는지의 유일한 증거. 낮으면 추천 품질이나 노출 위치를 의심한다."),
            Signal(name: "설치당 확보한 쉬는 날",
                   value: "\(number(average(snapshots, key: "restDays")))일",
                   hint: "등록된 휴가 기간의 합계 평균. 이 앱이 만들어 낸 결과에 가장 가까운 숫자다."),
            Signal(name: "설치당 등록 휴가",
                   value: "\(number(average(snapshots, key: "leaves")))건",
                   hint: "쓰는 사람은 계속 쌓는다. 1건 근처에 머물면 한 번 써보고 마는 것이다."),
            Signal(name: "연차 사용률 평균",
                   value: "\(number(average(snapshots, key: "usageRatePct")))%",
                   hint: "총 연차 대비 올해 쓴 비율. 연말로 갈수록 올라가는 게 정상이다."),
            Signal(name: "일정을 공유한 설치",
                   value: "\(shared.count)곳 (\(percent(shared.rate)))",
                   hint: "가족 공유가 실제로 쓰이는지. 낮으면 기능 발견 자체가 안 되는 것일 수 있다."),
            Signal(name: "Pro 사용자",
                   value: "\(pro.count)곳 (\(percent(pro.rate)))",
                   hint: "무료 사용자 대비 결제 비율."),
            Signal(name: "한 건도 등록 안 한 설치",
                   value: "\(empty)곳 (\(percent(Double(empty) / Double(snapshots.count))))",
                   hint: "깔고 아무것도 안 한 사람들. 이 수가 크면 설치를 늘려도 소용이 없다."),
        ]
    }

    // MARK: - 지표 라벨

    /// 0/1 플래그·분포 키인지 (평균이 아니라 비율로 읽어야 하는 것들).
    static func isFlag(_ key: String) -> Bool {
        key.hasPrefix("flag.") || key.hasPrefix("country.") || key.hasPrefix("type.")
    }

    /// 전송 키(고정) → 화면 라벨. 모르는 키는 원본 그대로 보여준다.
    static func metricLabel(_ key: String) -> String {
        switch key {
        case "leaves":                 return "등록 휴가 수"
        case "leavesThisYear":         return "올해 등록 휴가 수"
        case "restDays":               return "확보한 쉬는 날"
        case "plannedLeaves":          return "예정 휴가 수"
        case "usedLeaves":             return "사용 완료 휴가 수"
        case "adoptedRecommendations": return "채택한 추천 수"
        case "partialDayLeaves":       return "반차·반반차 기록 수"
        case "annualUsed":             return "올해 사용 연차"
        case "annualTotal":            return "총 연차"
        case "usageRatePct":           return "연차 사용률 (%)"
        case "bonusLeaves":            return "보너스 연차 수"
        case "customHolidays":         return "직접 추가한 공휴일 수"
        case "flag.isPro":             return "Pro 사용자"
        case "flag.autoDetect":        return "캘린더 자동 감지 켠 사용자"
        case "flag.sharing":           return "일정을 공유 중인 사용자"
        case "flag.familyShared":      return "공유받은 일정이 있는 사용자"
        case "flag.leisure":           return "자유 계획 유형 사용자"
        default:
            if key.hasPrefix("country.") { return "국가 " + String(key.dropFirst("country.".count)) }
            if key.hasPrefix("type.") { return "유형 " + String(key.dropFirst("type.".count)) }
            return key
        }
    }
}
