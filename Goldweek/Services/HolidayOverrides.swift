//
//  HolidayOverrides.swift
//  Goldweek
//
//  앱 업데이트 없이 공휴일을 고친다. CloudKit 공개 데이터베이스의 `HolidayOverride` 기록을 받아
//  앱 안 공휴일 표 위에 덮어쓴다 — 임시공휴일처럼 몇 주 전에야 정해지는 날 때문이다.
//  받은 것은 기기에 남겨 두므로 인터넷이 없어도 마지막으로 받은 대로 계산한다.
//  기록을 만드는 법 · 권한 설정은 docs/HOLIDAY_OVERRIDES.md.
//

import Foundation
import CloudKit
import GoldweekCore

/// 공휴일 한 건 고침. CloudKit 기록 하나가 하나다.
struct HolidayOverride: Codable, Equatable {
    enum Action: String, Codable {
        /// 공휴일을 더한다 (임시공휴일)
        case add
        /// 그날 공휴일을 뺀다 (취소되거나 잘못 들어간 날)
        case remove
        /// 그날 공휴일 이름만 바꾼다
        case rename
    }

    /// CloudKit recordName
    let id: String
    /// `Country.rawValue` (예: "korea")
    let country: String
    /// ISO 3166-2 (예: "DE-BY"). 없으면 나라 전체
    let region: String?
    /// yyyy-MM-dd
    let date: String
    let action: Action
    /// 언어별 이름 (`AppLanguage.rawValue` → 이름)
    let names: [String: String]
    let modifiedAt: Date

    /// 그 언어 이름 — 없으면 영어, 그것도 없으면 아무 이름
    func name(for language: AppLanguage) -> String? {
        names[language.rawValue] ?? names[AppLanguage.english.rawValue] ?? names.keys.sorted().first.flatMap { names[$0] }
    }

    /// (연, 월, 일) — 형식이 틀리면 nil
    var dayComponents: (year: Int, month: Int, day: Int)? {
        let parts = date.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3, (1...12).contains(parts[1]), (1...31).contains(parts[2]) else { return nil }
        return (parts[0], parts[1], parts[2])
    }
}

extension HolidayOverride {
    /// CloudKit 기록 → 고침. 꺼져 있거나(`active` = 0) 값이 틀리면 nil.
    /// 한 번의 실수가 모든 사용자에게 가므로, 모르는 나라 · 지난해보다 앞 · 3년보다 먼 날은 받지 않는다.
    init?(record: CKRecord, now: Date = Date()) {
        if let active = record["active"] as? Int, active == 0 { return nil }
        guard let country = record["country"] as? String,
              let parsed = Country(rawValue: country), parsed != .custom,
              let date = record["date"] as? String else { return nil }
        let action = Action(rawValue: (record["action"] as? String) ?? Action.add.rawValue)
        guard let action else { return nil }

        var names: [String: String] = [:]
        if let json = record["names"] as? String, let data = json.data(using: .utf8) {
            names = (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
        }
        names = names.filter { !$0.value.trimmingCharacters(in: .whitespaces).isEmpty }

        let region = (record["region"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        self.init(id: record.recordID.recordName, country: country, region: region, date: date,
                  action: action, names: names, modifiedAt: record.modificationDate ?? now)

        guard let day = dayComponents else { return nil }
        let thisYear = Calendar.app.component(.year, from: now)
        guard (thisYear - 1)...(thisYear + 3) ~= day.year else { return nil }
        if action != .remove, names.isEmpty { return nil }
    }
}

/// 받아 온 공휴일 고침을 들고 있는 곳. 앱 어디서든 `HolidayService` 가 이 값을 덮어쓴다.
enum HolidayOverrideStore {
    static let recordType = "HolidayOverride"
    /// 골드위크 컨테이너의 공개 데이터베이스 — 가족 공유(`ShareSyncService`)와 같은 컨테이너.
    /// 여러 앱이 쓰는 허브(FeedbackHub)에 두지 않는다: 그곳은 사용자가 기록을 만들 수 있어야 해서 권한이 다르다.
    static var containerIdentifier: String { ShareSyncService.containerIdentifier }

    private static let cacheKey = "holidayOverrides.v1"
    private static let fetchedAtKey = "holidayOverrides.fetchedAt"
    /// 이만큼 지나야 다시 받는다
    private static let refreshInterval: TimeInterval = 12 * 3600

    private static let lock = NSLock()
    nonisolated(unsafe) private static var memory: [HolidayOverride]?

    /// 지금 덮어쓸 고침 (기기에 남겨 둔 것)
    static var overrides: [HolidayOverride] {
        lock.withLock {
            if let memory { return memory }
            let loaded = UserDefaults.standard.data(forKey: cacheKey)
                .flatMap { try? JSONDecoder().decode([HolidayOverride].self, from: $0) } ?? []
            memory = loaded
            return loaded
        }
    }

    /// 공휴일 데이터 버전 — 앱 버전(앱 안 공휴일 표) + 받은 고침 중 가장 늦게 고친 시각.
    /// 계획을 만들 때 함께 남겨 두면, 나중에 공휴일이 바뀌었을 때 영향받는 계획을 가려낼 수 있다.
    static var dataVersion: String {
        let app = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        guard let latest = overrides.map(\.modifiedAt).max() else { return app }
        return "\(app)+\(Int(latest.timeIntervalSince1970))"
    }

    /// 하루 두 번까지만 받아 온다. 고침이 바뀌었으면 true.
    /// 받기에 실패하면(오프라인, 기록 종류가 아직 없음 등) 가진 것을 그대로 쓴다.
    @discardableResult
    static func refreshIfNeeded(now: Date = Date()) async -> Bool {
        let last = UserDefaults.standard.double(forKey: fetchedAtKey)
        guard now.timeIntervalSince1970 - last >= refreshInterval else { return false }
        do {
            let fetched = try await fetchAll(now: now)
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: fetchedAtKey)
            guard fetched != overrides else { return false }
            replace(with: fetched)
            logDebug("공휴일 고침 \(fetched.count)건으로 바뀜 (버전 \(dataVersion))", category: .app)
            return true
        } catch {
            logDebug("공휴일 고침 받기 실패: \(error.localizedDescription)", category: .app)
            return false
        }
    }

    /// 받은 고침을 기기에 남기고 바로 쓴다
    static func replace(with overrides: [HolidayOverride]) {
        let sorted = overrides.sorted { ($0.modifiedAt, $0.id) < ($1.modifiedAt, $1.id) }
        lock.withLock {
            memory = sorted
            UserDefaults.standard.set(try? JSONEncoder().encode(sorted), forKey: cacheKey)
        }
    }

    /// 공개 데이터베이스의 고침을 모두 읽는다. 읽기에는 iCloud 로그인이 필요 없다.
    /// ⚠️ `NSPredicate(value: true)` 조회라 대시보드에서 recordName 을 Queryable 로 두어야 한다.
    private static func fetchAll(now: Date) async throws -> [HolidayOverride] {
        let database = CKContainer(identifier: containerIdentifier).publicCloudDatabase
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        var result: [HolidayOverride] = []
        var cursor: CKQueryOperation.Cursor?
        repeat {
            let page: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
            if let cursor {
                page = try await database.records(continuingMatchFrom: cursor, resultsLimit: 200)
            } else {
                page = try await database.records(matching: query, resultsLimit: 200)
            }
            result += page.matchResults.compactMap { try? $0.1.get() }.compactMap { HolidayOverride(record: $0, now: now) }
            cursor = page.queryCursor
        } while cursor != nil && result.count < 2000
        return result
    }
}

// MARK: - 공휴일 표에 덮어쓰기

extension HolidayService {
    /// 앱 안 공휴일 표 위에 받은 고침을 덮어쓴다. 오래된 고침부터 차례로 — 같은 날을 두 번 고치면 나중 것이 남는다.
    static func applying(_ overrides: [HolidayOverride], to holidays: [Holiday], year: Int,
                         country: Country, region: String?, language: AppLanguage,
                         calendar: Calendar = .app) -> [Holiday] {
        let relevant = overrides.filter {
            $0.country == country.rawValue && ($0.region == nil || $0.region == region) && $0.dayComponents?.year == year
        }
        guard !relevant.isEmpty else { return holidays }

        func sameDay(_ holiday: Holiday, _ day: Date) -> Bool { calendar.isDate(holiday.date, inSameDayAs: day) }

        var result = holidays
        for change in relevant.sorted(by: { $0.modifiedAt < $1.modifiedAt }) {
            guard let parts = change.dayComponents,
                  let day = calendar.date(from: DateComponents(year: parts.year, month: parts.month, day: parts.day)) else { continue }
            switch change.action {
            case .remove:
                result.removeAll { sameDay($0, day) }
            case .rename:
                guard let name = change.name(for: language) else { continue }
                result = result.map { holiday in
                    guard sameDay(holiday, day) else { return holiday }
                    var renamed = Holiday(date: holiday.date, name: name, isSubstitute: holiday.isSubstitute,
                                          isCustom: holiday.isCustom, isBreak: holiday.isBreak)
                    renamed.isCollective = holiday.isCollective
                    return renamed
                }
            case .add:
                guard let name = change.name(for: language),
                      !result.contains(where: { sameDay($0, day) && $0.name == name }) else { continue }
                result.append(Holiday(date: day, name: name))
            }
        }
        return result.sorted { $0.date < $1.date }
    }
}
