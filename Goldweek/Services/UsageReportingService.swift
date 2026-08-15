//
//  UsageReportingService.swift
//  Goldweek
//
//  익명 사용 통계 — 피드백과 같은 공용 허브(FeedbackHub, CloudKit public DB)로 보내고 읽는다.
//  전송 엔진은 LeeoKit(LeeoUsageReporter)이고, 여기서는 이 앱의 지표·이벤트 정책만 정한다.
//
//  보내는 것
//   ① UsageSnapshot — 설치당 1건(익명 UUID recordName, upsert). 사용자 수/활성 사용자 집계용.
//   ② UsageEvent   — 주요 행동 스트림(이름만). "앱을 어떻게 쓰는지" 집계용, 이름당 6시간 쓰로틀.
//
//  ⚠️ PII 없음: 이름·메모·휴가 사유·기기 식별자(IDFA/IDFV)·위치는 절대 보내지 않는다.
//     보내는 값은 개수·비율 같은 집계 수치와 이벤트 이름뿐이다.
//  ⚠️ 사용자 옵트아웃 토글은 없다. 대신 개발자가 원격으로 멈출 수 있다(GoldweekFlag.usageReportingEnabled).
//     그래서 보내는 항목을 늘릴 땐 "이게 익명 집계 수치인가"를 더 엄격히 따질 것.
//  ⚠️ CloudKit Dashboard에 UsageSnapshot/UsageEvent 스키마 배포가 선행되어야 한다.
//     자세한 절차: docs/USAGE_STATS_HUB.md
//

import Foundation
import CloudKit
import SwiftData
import LeeoKit

enum UsageReportingService {

    private static var reporter: LeeoUsageReporter {
        LeeoUsageReporter(spec: GoldweekSpec.self)
    }

    /// 같은 이벤트 이름을 다시 보내기까지의 최소 간격 — 공개 DB 쓰기 폭주 방지.
    private static let eventThrottle: TimeInterval = 6 * 3600

    /// "이 설치가 오늘 활동했다"를 남기는 이벤트 — 일간 활성 사용자(DAU) 차트의 근거.
    /// 스냅샷의 lastActiveAt은 덮어쓰기라 날짜별 이력이 남지 않아, 하루 1건 이벤트로 대신한다.
    static let appOpenEvent = "app_open"

    /// 유닛 테스트 중에는 허브에 실제로 쓰지 않는다 (쓰로틀 로직 자체는 그대로 검증된다).
    static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    /// 원격 킬스위치 — 사용자가 끄는 옵트아웃은 없지만, 개발자는 심사 없이 즉시 멈출 수 있어야 한다.
    /// 조회 실패 시엔 켬이라 네트워크 문제로 수집이 임의로 멈추지는 않는다.
    private static var isReportingAllowed: Bool {
        LeeoRemoteFlags.isEnabled(GoldweekFlag.usageReportingEnabled)
    }

    // MARK: - 전송

    /// 사람이 앱을 실제로 앞으로 가져온 순간. 콜드 런치와 백그라운드 복귀 양쪽에서 불린다.
    ///
    /// ⚠️ 여기에 프로세스 시작을 태우지 말 것. 이 앱은 공유 일정 silent push로도 깨어나는데,
    ///    그때까지 접속으로 세면 활성 사용자 수가 실제보다 부풀어 오른다.
    @MainActor
    static func reportForegroundOpen(context: ModelContext) {
        // 실행 횟수는 프로세스당 1회만 — 리뷰/만족도 프롬프트 타이밍이 복귀할 때마다 앞당겨지면 안 된다.
        if !didRegisterLaunch {
            didRegisterLaunch = true
            LeeoEngagement.shared.registerLaunch()
        }

        // 하루 1건 — 일/주/월/연 차트의 "활동한 사용자"가 실제 접속을 반영하게 한다.
        record(event: appOpenEvent, minInterval: 20 * 3600, countsAsEngagement: false)

        guard !isRunningTests, isReportingAllowed else { return }

        // 지표는 메인 액터(SwiftData)에서 뽑아 값으로 넘긴다 — ModelContext는 Sendable이 아니다.
        let metrics = currentMetrics(context: context)
        Task(priority: .utility) {
            await reporter.report(metrics: metrics)
        }
    }

    private nonisolated(unsafe) static var didRegisterLaunch = false

    /// 주요 행동 1건. 로컬 참여도 카운터를 올리고, 허브 쓰기는 이름당 쓰로틀 간격에 한 번만.
    /// - Parameters:
    ///   - name: 이벤트 이름(snake_case). 슬라이스가 있으면 `paywall_view:direct` 형태.
    ///   - minInterval: 같은 이름을 다시 보내기까지의 최소 간격 (기본 6시간).
    ///   - countsAsEngagement: 참여도 카운터(`eventCount` 지표)를 올릴지.
    ///     앱을 앞으로 가져온 것 자체는 "주요 행동"이 아니다 — 그건 실행 횟수가 이미 센다.
    static func record(event name: String,
                       minInterval: TimeInterval = eventThrottle,
                       countsAsEngagement: Bool = true) {
        if countsAsEngagement { LeeoEngagement.shared.registerSignificantEvent() }

        let key = "goldweek.usage.lastSent." + name
        if let last = UserDefaults.standard.object(forKey: key) as? Date,
           Date().timeIntervalSince(last) < minInterval { return }
        UserDefaults.standard.set(Date(), forKey: key)

        guard !isRunningTests, isReportingAllowed else { return }
        reporter.logEventInBackground(String(name.prefix(60)))
    }

    // MARK: - 지표

    /// 이 설치의 대략 지표 — 스냅샷 한 필드(metrics JSON)로 들어간다.
    /// 개수·비율 수치와 0/1 플래그만 담는다(이름·사유·날짜 같은 내용은 없다).
    ///
    /// 이 앱의 "효용"은 결국 **연차를 실제로 계획해서 쉬었는가**다. 그래서 등록 수보다
    /// `restDays`(확보한 쉬는 날)와 `adoptedRecommendations`(추천을 받아들인 수)를 중심에 둔다.
    @MainActor
    static func currentMetrics(context: ModelContext) -> [String: Double] {
        var metrics: [String: Double] = [:]

        let records = (try? context.fetch(FetchDescriptor<LeaveRecord>())) ?? []
        let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first
        let bonuses = (try? context.fetch(FetchDescriptor<BonusLeave>())) ?? []
        let holidays = (try? context.fetch(FetchDescriptor<CustomHoliday>())) ?? []

        let calendar = Calendar.current
        let thisYear = calendar.component(.year, from: Date())
        let active = records.filter { $0.status != .cancelled }
        let thisYearRecords = active.filter { calendar.component(.year, from: $0.startDate) == thisYear }

        metrics["leaves"] = Double(active.count)
        metrics["leavesThisYear"] = Double(thisYearRecords.count)
        // 이 앱이 만들어 낸 결과 — 등록된 휴가로 확보한 쉬는 날(주말·공휴일 포함 기간 길이).
        metrics["restDays"] = Double(active.reduce(0) { $0 + $1.daysCount })
        metrics["plannedLeaves"] = Double(active.filter { $0.status == .planned }.count)
        metrics["usedLeaves"] = Double(active.filter { $0.status == .used }.count)
        // 추천을 실제로 받아들인 수 — 추천 엔진이 값을 하는지의 유일한 증거.
        metrics["adoptedRecommendations"] = Double(active.filter(\.isRecommended).count)
        // 반차·반반차로 쪼개 쓴 기록 — 길이 축(LeaveLength)을 실제로 쓰는지.
        metrics["partialDayLeaves"] = Double(active.filter { $0.length != .full }.count)

        let annualUsed = thisYearRecords
            .filter(\.deductsFromAnnualLeave)
            .reduce(0.0) { $0 + $1.effectiveLeaveDays }
        metrics["annualUsed"] = (annualUsed * 100).rounded() / 100

        if let profile {
            metrics["annualTotal"] = profile.totalAnnualLeave
            if profile.totalAnnualLeave > 0 {
                metrics["usageRatePct"] = ((annualUsed / profile.totalAnnualLeave) * 100).rounded()
            }
            metrics["country.\(profile.countryRaw)"] = 1
            metrics["type.\(profile.userTypeRaw)"] = 1
            metrics["flag.leisure"] = profile.userType == .leisure ? 1 : 0
        }

        metrics["bonusLeaves"] = Double(bonuses.count)
        metrics["customHolidays"] = Double(holidays.count)

        metrics["flag.isPro"] = ProManager.shared.isPro ? 1 : 0
        metrics["flag.autoDetect"] = UserDefaults.standard.bool(forKey: "autoDetectLeavesEnabled") ? 1 : 0
        metrics["flag.sharing"] = ShareSyncService.shared.isSharingActive ? 1 : 0
        metrics["flag.familyShared"] = ShareSyncService.shared.sharedSchedules.isEmpty ? 0 : 1

        return metrics
    }

    // MARK: - 조회 (개발자 통계 화면용)

    typealias Snapshot = LeeoUsageReporter.UsageSnapshot

    /// 설치 스냅샷 전체 (이 앱 것만, 최근 활동순).
    static func fetchSnapshots(limit: Int = 1000) async throws -> [Snapshot] {
        try await reporter.fetchSnapshots(limit: limit)
    }

    /// 이벤트 이름별 집계 결과.
    struct EventStat: Identifiable, Sendable {
        let name: String
        /// 기록된 이벤트 건수 (조회 범위 안에서).
        let count: Int
        /// 그 이벤트를 남긴 서로 다른 설치 수.
        let installs: Int
        /// 가장 최근 발생 시각.
        let lastAt: Date?
        var id: String { name }
    }

    /// 이벤트 1건 (차트용 원본 표본).
    struct EventSample: Sendable {
        let name: String
        let installID: String?
        let date: Date
    }

    /// 최근 이벤트를 원본 표본 그대로 읽는다 — 이름별 집계와 기간별 차트가 이 하나를 함께 쓴다.
    /// LeeoKit은 스냅샷 조회만 제공해서, 이벤트 스트림은 여기서 직접 읽는다.
    /// ⚠️ 남의 레코드를 읽으므로 컨테이너 read 권한이 필요하다(피드백 인박스와 동일).
    static func fetchEvents(limit: Int = 3000) async throws -> [EventSample] {
        let config = GoldweekSpec.feedback
        let database = CKContainer(identifier: config.containerIdentifier).publicCloudDatabase

        // 허브 전체를 읽고 appId는 클라이언트에서 거른다 — appId Queryable 인덱스 없이 동작하게.
        let query = CKQuery(recordType: LeeoUsageReporter.eventType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        var samples: [EventSample] = []
        var cursor: CKQueryOperation.Cursor?
        repeat {
            let page: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
            if let cursor {
                page = try await database.records(continuingMatchFrom: cursor,
                                                  resultsLimit: min(200, limit - samples.count))
            } else {
                page = try await database.records(matching: query, resultsLimit: min(200, limit))
            }

            for record in page.matchResults.compactMap({ try? $0.1.get() }) {
                guard config.appIdentifier == nil || (record["appId"] as? String) == config.appIdentifier else { continue }
                // ⚠️ creationDate는 서버가 "쓴 시각"으로 찍는다. 오프라인에서 밀렸다 나간 건
                //    보낸 날로 뭉치므로 실제 발생 시각(occurredAt)을 우선 본다.
                let occurredAt = (record["occurredAt"] as? Date) ?? record.creationDate ?? Date()
                samples.append(EventSample(name: (record["event"] as? String) ?? "-",
                                           installID: record["installID"] as? String,
                                           date: occurredAt))
            }
            cursor = page.queryCursor
        } while cursor != nil && samples.count < limit

        return samples
    }

    /// 표본 → 이름별 집계 (화면 계산용, 네트워크 없음).
    static func eventStats(from samples: [EventSample]) -> [EventStat] {
        var counts: [String: (count: Int, installs: Set<String>, lastAt: Date?)] = [:]
        for sample in samples {
            var entry = counts[sample.name] ?? (0, [], nil)
            entry.count += 1
            if let install = sample.installID { entry.installs.insert(install) }
            if (entry.lastAt ?? .distantPast) < sample.date { entry.lastAt = sample.date }
            counts[sample.name] = entry
        }
        return counts
            .map { EventStat(name: $0.key, count: $0.value.count, installs: $0.value.installs.count, lastAt: $0.value.lastAt) }
            .sorted { $0.count > $1.count }
    }

    // MARK: - 기간별 추이 (일·주·월·연)

    /// 차트 묶음 단위.
    enum BucketUnit: String, CaseIterable, Identifiable {
        case day, week, month, year
        var id: String { rawValue }

        var calendarComponent: Calendar.Component {
            switch self {
            case .day: return .day
            case .week: return .weekOfYear
            case .month: return .month
            case .year: return .year
            }
        }

        /// 한 화면에 보이는 묶음 개수 — 나머지는 좌우로 스크롤해서 본다.
        var visibleBuckets: Int {
            switch self {
            case .day: return 14
            case .week: return 12
            case .month: return 12
            case .year: return 5
            }
        }

        var localizedName: String {
            switch self {
            case .day: return "일간"
            case .week: return "주간"
            case .month: return "월간"
            case .year: return "연간"
            }
        }
    }

    /// 한 묶음(하루/한 주/한 달/한 해)의 집계값.
    struct TrendPoint: Identifiable, Sendable {
        /// 묶음의 시작 시각 (차트 X축 값).
        let date: Date
        /// 그 기간에 기록된 이벤트 건수.
        let events: Int
        /// 그 기간에 활동한 서로 다른 설치 수.
        let activeInstalls: Int
        /// 그 기간에 처음 설치된 수.
        let newInstalls: Int
        var id: Date { date }
    }

    /// 빈 구간까지 채운 연속 추이를 만든다 — 차트가 끊기지 않도록.
    /// 데이터가 없으면 빈 배열. 안전장치로 최대 400묶음까지만 만든다.
    static func trend(unit: BucketUnit,
                      events: [EventSample],
                      snapshots: [Snapshot],
                      calendar: Calendar = .current,
                      now: Date = Date()) -> [TrendPoint] {
        func bucketStart(_ date: Date) -> Date? {
            calendar.dateInterval(of: unit.calendarComponent, for: date)?.start
        }

        var eventCounts: [Date: Int] = [:]
        var installsByBucket: [Date: Set<String>] = [:]
        for sample in events {
            guard let start = bucketStart(sample.date) else { continue }
            eventCounts[start, default: 0] += 1
            if let install = sample.installID {
                installsByBucket[start, default: []].insert(install)
            }
        }

        var newInstalls: [Date: Int] = [:]
        for snapshot in snapshots {
            guard let installDate = snapshot.installDate, let start = bucketStart(installDate) else { continue }
            newInstalls[start, default: 0] += 1
        }

        let starts = Set(eventCounts.keys).union(installsByBucket.keys).union(newInstalls.keys)
        guard let first = starts.min(), let today = bucketStart(now) else { return [] }
        let last = max(starts.max() ?? today, today)

        var points: [TrendPoint] = []
        var cursor = first
        while cursor <= last && points.count < 400 {
            points.append(TrendPoint(date: cursor,
                                     events: eventCounts[cursor] ?? 0,
                                     activeInstalls: installsByBucket[cursor]?.count ?? 0,
                                     newInstalls: newInstalls[cursor] ?? 0))
            guard let next = calendar.date(byAdding: unit.calendarComponent, value: 1, to: cursor) else { break }
            cursor = next
        }
        return points
    }

    /// 허브에 접수된 이 앱의 피드백 (최신순). 통계 화면 요약용.
    static func fetchFeedback(limit: Int = 100) async throws -> [LeeoFeedbackService.FeedbackRecord] {
        try await LeeoFeedbackService(spec: GoldweekSpec.self).fetchAll(limit: limit)
    }
}
