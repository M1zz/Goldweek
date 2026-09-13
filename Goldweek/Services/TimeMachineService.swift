//
//  TimeMachineService.swift
//  Goldweek
//
//  타임머신: 시점별 데이터 스냅샷 자동 저장 + 복원 (Layer 0: 데이터 보호 최전선)
//
//  2026-07 데이터 유실 사고 재발 방지를 위한 설계 원칙:
//  1. 모든 모델(UserProfile, LeaveRecord, BonusLeave, CustomHoliday)의 전체 필드를 ID까지 보존
//     — 복원 후에도 bonusLeaveId 연결이 깨지지 않는다
//  2. 사용자 행동 없이 자동으로 저장된다 (데이터 변경 감지 + 앱 백그라운드 진입)
//  3. 복원 직전 상태도 자동 스냅샷 — 복원 자체를 되돌릴 수 있다
//  4. 스냅샷 파일은 SwiftData 저장소와 독립적인 JSON — 스키마 마이그레이션 실패에도 살아남는다
//

import Foundation
import SwiftData
import CryptoKit

@MainActor
final class TimeMachineService {
    static let shared = TimeMachineService()

    static let formatVersion = 2

    private let fileManager = FileManager.default
    private let filePrefix = "Snapshot_"
    private let fileExtension = "json"
    private let maxSnapshots = 60
    /// 이 기간 안의 스냅샷은 전부 보존, 그보다 오래되면 하루 1개만 유지
    private let keepAllInterval: TimeInterval = 7 * 86400
    private let autoDebounceSeconds: TimeInterval = 10
    private let lastHashKey = "TimeMachine.lastContentHash"

    private var pendingAutoSnapshot: Task<Void, Never>?

    private init() {}

    // MARK: - 스냅샷 저장 위치

    private var snapshotDirectory: URL? {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = appSupport.appendingPathComponent("TimeMachine", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - 스냅샷 생성

    enum SnapshotReason: String, Codable {
        case auto           // 데이터 변경 감지 (디바운스)
        case background     // 앱이 백그라운드로 전환될 때
        case manual         // 사용자가 직접 생성
        case preRestore     // 복원 직전 자동 저장
        case unknown

        var displayName: String {
            switch self {
            case .auto: return Strings.snapshotReasonAuto
            case .background: return Strings.snapshotReasonBackground
            case .manual: return Strings.snapshotReasonManual
            case .preRestore: return Strings.snapshotReasonPreRestore
            case .unknown: return Strings.snapshotReasonAuto
            }
        }
    }

    /// 데이터 변경 시 호출 — 디바운스 후 스냅샷 저장 (연속 편집 중 과도한 저장 방지)
    func scheduleAutoSnapshot(context: ModelContext) {
        pendingAutoSnapshot?.cancel()
        pendingAutoSnapshot = Task { [autoDebounceSeconds] in
            try? await Task.sleep(nanoseconds: UInt64(autoDebounceSeconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self.captureNow(from: context, reason: .auto)
        }
    }

    /// 즉시 스냅샷 저장. 마지막 스냅샷과 내용이 같으면 저장하지 않고 false 반환.
    @discardableResult
    func captureNow(from context: ModelContext, reason: SnapshotReason) -> Bool {
        pendingAutoSnapshot?.cancel()

        guard let dir = snapshotDirectory else {
            logError("타임머신 디렉토리 접근 불가", category: .backup)
            return false
        }

        do {
            let profiles = try context.fetch(FetchDescriptor<UserProfile>())
            let leaves = try context.fetch(FetchDescriptor<LeaveRecord>())
            let bonuses = try context.fetch(FetchDescriptor<BonusLeave>())
            let holidays = try context.fetch(FetchDescriptor<CustomHoliday>())

            // 프로필조차 없는 완전히 빈 상태는 저장할 가치가 없다
            guard !profiles.isEmpty else { return false }

            var snapshot = TimeMachineSnapshot(
                formatVersion: Self.formatVersion,
                createdAt: Date(),
                reasonRaw: reason.rawValue,
                checksum: "",
                contentHash: "",
                profiles: profiles.map(TMProfileData.init),
                leaveRecords: leaves.map(TMLeaveData.init),
                bonusLeaves: bonuses.map(TMBonusData.init),
                customHolidays: holidays.map(TMHolidayData.init)
            )

            snapshot.contentHash = try Self.contentHash(of: snapshot)

            // 내용이 마지막 스냅샷과 동일하면 스킵
            if reason != .manual, snapshot.contentHash == UserDefaults.standard.string(forKey: lastHashKey) {
                return false
            }

            let data = try Self.encodeWithChecksum(snapshot)

            let stamp = ISO8601DateFormatter().string(from: snapshot.createdAt)
                .replacingOccurrences(of: ":", with: "-")
                .replacingOccurrences(of: ".", with: "-")
            let url = dir.appendingPathComponent("\(filePrefix)\(stamp).\(fileExtension)")
            try data.write(to: url, options: [.atomic, .completeFileProtection])

            UserDefaults.standard.set(snapshot.contentHash, forKey: lastHashKey)
            prune()
            logInfo("타임머신 스냅샷 저장 (\(reason.rawValue)) — 연차 \(leaves.count)건", category: .backup)
            return true
        } catch {
            logError("타임머신 스냅샷 저장 실패: \(error.localizedDescription)", category: .backup)
            return false
        }
    }

    // MARK: - 스냅샷 목록

    struct SnapshotInfo: Identifiable {
        let url: URL
        let createdAt: Date
        let reason: SnapshotReason
        let profileName: String
        let leaveCount: Int
        let bonusCount: Int
        let holidayCount: Int

        var id: URL { url }
    }

    func snapshotInfos() -> [SnapshotInfo] {
        guard let dir = snapshotDirectory else { return [] }

        let files = (try? fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        var infos: [SnapshotInfo] = []
        for url in files where url.lastPathComponent.hasPrefix(filePrefix) && url.pathExtension == fileExtension {
            guard let data = try? Data(contentsOf: url),
                  let snapshot = try? Self.decode(data) else { continue }
            infos.append(SnapshotInfo(
                url: url,
                createdAt: snapshot.createdAt,
                reason: SnapshotReason(rawValue: snapshot.reasonRaw) ?? .unknown,
                profileName: snapshot.profiles.first?.name ?? "",
                leaveCount: snapshot.leaveRecords.count,
                bonusCount: snapshot.bonusLeaves.count,
                holidayCount: snapshot.customHolidays.count
            ))
        }
        return infos.sorted { $0.createdAt > $1.createdAt }
    }

    func deleteSnapshot(_ info: SnapshotInfo) {
        try? fileManager.removeItem(at: info.url)
    }

    // MARK: - 복원

    /// 특정 스냅샷으로 복원. 복원 직전 현재 상태를 자동 저장하므로 복원 자체도 되돌릴 수 있다.
    func restore(from info: SnapshotInfo, to context: ModelContext) throws {
        let data = try Data(contentsOf: info.url)
        let snapshot = try Self.decode(data)

        guard Self.verifyChecksum(snapshot) else {
            throw TimeMachineError.checksumMismatch
        }

        captureNow(from: context, reason: .preRestore)
        try apply(snapshot, to: context)
        // 복원 결과가 새 "현재 상태"이므로 dedupe 기준을 갱신
        UserDefaults.standard.set(snapshot.contentHash, forKey: lastHashKey)
        logInfo("타임머신 복원 완료: \(info.createdAt)", category: .backup)
    }

    /// 가장 최근의 유효한 스냅샷으로 복원 (크래시 복구/빈 저장소 감지용).
    /// 체크섬이 깨진 스냅샷은 건너뛰고 다음으로 넘어간다.
    @discardableResult
    func restoreFromLatestSnapshot(to context: ModelContext) -> Bool {
        for info in snapshotInfos() {
            do {
                let data = try Data(contentsOf: info.url)
                let snapshot = try Self.decode(data)
                guard Self.verifyChecksum(snapshot) else {
                    logWarning("스냅샷 체크섬 불일치, 다음 스냅샷 시도: \(info.url.lastPathComponent)", category: .backup)
                    continue
                }
                try apply(snapshot, to: context)
                logInfo("타임머신 자동 복구 성공: \(info.createdAt)", category: .backup)
                return true
            } catch {
                logWarning("스냅샷 복원 실패, 다음 스냅샷 시도: \(error.localizedDescription)", category: .backup)
            }
        }
        return false
    }

    private func apply(_ snapshot: TimeMachineSnapshot, to context: ModelContext) throws {
        // 기존 레코드 전부 교체 (ID 보존 복원이므로 병합하지 않는다)
        try context.fetch(FetchDescriptor<LeaveRecord>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<BonusLeave>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<CustomHoliday>()).forEach { context.delete($0) }

        if let profileData = snapshot.profiles.first {
            let existing = try context.fetch(FetchDescriptor<UserProfile>())
            if let profile = existing.first {
                profileData.apply(to: profile)
            } else {
                context.insert(profileData.materialize())
            }
        }

        snapshot.leaveRecords.forEach { context.insert($0.materialize()) }
        snapshot.bonusLeaves.forEach { context.insert($0.materialize()) }
        snapshot.customHolidays.forEach { context.insert($0.materialize()) }

        try context.save()
    }

    // MARK: - 보존 정책

    /// 최근 7일은 전부 보존, 그 이전은 하루 1개, 전체 최대 60개
    private func prune() {
        let infos = snapshotInfos() // 최신순
        var keep: [URL] = []
        var seenDays = Set<String>()
        let cutoff = Date().addingTimeInterval(-keepAllInterval)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"

        for info in infos {
            if info.createdAt > cutoff {
                keep.append(info.url)
            } else {
                let day = dayFormatter.string(from: info.createdAt)
                if seenDays.insert(day).inserted {
                    keep.append(info.url)
                }
            }
        }
        let kept = Set(keep.prefix(maxSnapshots))

        for info in infos where !kept.contains(info.url) {
            try? fileManager.removeItem(at: info.url)
            logDebug("오래된 스냅샷 정리: \(info.url.lastPathComponent)", category: .backup)
        }
    }

    // MARK: - 인코딩/무결성

    private static func stableEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    static func decode(_ data: Data) throws -> TimeMachineSnapshot {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TimeMachineSnapshot.self, from: data)
    }

    /// 데이터 내용만의 해시 (생성 시각/사유와 무관) — 중복 스냅샷 스킵용
    static func contentHash(of snapshot: TimeMachineSnapshot) throws -> String {
        struct Payload: Codable {
            let profiles: [TMProfileData]
            let leaveRecords: [TMLeaveData]
            let bonusLeaves: [TMBonusData]
            let customHolidays: [TMHolidayData]
        }
        let payload = Payload(
            profiles: snapshot.profiles,
            leaveRecords: snapshot.leaveRecords,
            bonusLeaves: snapshot.bonusLeaves,
            customHolidays: snapshot.customHolidays
        )
        let data = try stableEncoder().encode(payload)
        return SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    static func encodeWithChecksum(_ snapshot: TimeMachineSnapshot) throws -> Data {
        var copy = snapshot
        copy.checksum = ""
        let base = try stableEncoder().encode(copy)
        copy.checksum = SHA256.hash(data: base).compactMap { String(format: "%02x", $0) }.joined()
        return try stableEncoder().encode(copy)
    }

    static func verifyChecksum(_ snapshot: TimeMachineSnapshot) -> Bool {
        guard !snapshot.checksum.isEmpty else { return false }
        var copy = snapshot
        copy.checksum = ""
        guard let base = try? stableEncoder().encode(copy) else { return false }
        let calculated = SHA256.hash(data: base).compactMap { String(format: "%02x", $0) }.joined()
        return calculated == snapshot.checksum
    }
}

// MARK: - 스냅샷 데이터 모델 (전체 필드 + ID 보존)

struct TimeMachineSnapshot: Codable {
    var formatVersion: Int
    var createdAt: Date
    var reasonRaw: String
    var checksum: String
    var contentHash: String
    var profiles: [TMProfileData]
    var leaveRecords: [TMLeaveData]
    var bonusLeaves: [TMBonusData]
    var customHolidays: [TMHolidayData]
}

struct TMProfileData: Codable {
    let id: UUID
    let name: String
    let yearStartMonth: Int
    let totalAnnualLeave: Double
    let usedLeave: Double
    let createdAt: Date
    let countryRaw: String
    let userTypeRaw: String
    let preferredDurationRaw: String
    let preferredSeasonsRaw: String
    let preferLongWeekend: Bool
    let preferConsecutive: Bool
    let avoidPeakSeason: Bool
    let priorityActivitiesRaw: String

    init(from profile: UserProfile) {
        self.id = profile.id
        self.name = profile.name
        self.yearStartMonth = profile.yearStartMonth
        self.totalAnnualLeave = profile.totalAnnualLeave
        self.usedLeave = profile.usedLeave
        self.createdAt = profile.createdAt
        self.countryRaw = profile.countryRaw
        self.userTypeRaw = profile.userTypeRaw
        self.preferredDurationRaw = profile.preferredDurationRaw
        self.preferredSeasonsRaw = profile.preferredSeasonsRaw
        self.preferLongWeekend = profile.preferLongWeekend
        self.preferConsecutive = profile.preferConsecutive
        self.avoidPeakSeason = profile.avoidPeakSeason
        self.priorityActivitiesRaw = profile.priorityActivitiesRaw
    }

    func apply(to profile: UserProfile) {
        profile.id = id
        profile.name = name
        profile.yearStartMonth = yearStartMonth
        profile.totalAnnualLeave = totalAnnualLeave
        profile.usedLeave = usedLeave
        profile.createdAt = createdAt
        profile.countryRaw = countryRaw
        profile.userTypeRaw = userTypeRaw
        profile.preferredDurationRaw = preferredDurationRaw
        profile.preferredSeasonsRaw = preferredSeasonsRaw
        profile.preferLongWeekend = preferLongWeekend
        profile.preferConsecutive = preferConsecutive
        profile.avoidPeakSeason = avoidPeakSeason
        profile.priorityActivitiesRaw = priorityActivitiesRaw
    }

    func materialize() -> UserProfile {
        let profile = UserProfile()
        apply(to: profile)
        return profile
    }
}

struct TMLeaveData: Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let typeRaw: String
    let statusRaw: String
    let note: String
    let isRecommended: Bool
    let bonusLeaveId: UUID?

    init(from record: LeaveRecord) {
        self.id = record.id
        self.startDate = record.startDate
        self.endDate = record.endDate
        self.typeRaw = record.typeRaw
        self.statusRaw = record.statusRaw
        self.note = record.note
        self.isRecommended = record.isRecommended
        self.bonusLeaveId = record.bonusLeaveId
    }

    func materialize() -> LeaveRecord {
        let record = LeaveRecord(
            startDate: startDate,
            endDate: endDate,
            type: LeaveType(rawValue: typeRaw) ?? .annual,
            status: LeaveStatus(rawValue: statusRaw) ?? .planned,
            note: note,
            isRecommended: isRecommended,
            bonusLeaveId: bonusLeaveId
        )
        record.id = id
        return record
    }
}

struct TMBonusData: Codable {
    let id: UUID
    let days: Double
    let usedDays: Double
    let typeRaw: String
    let reason: String
    let grantedDate: Date
    let expirationDate: Date?
    let isUsed: Bool

    init(from bonus: BonusLeave) {
        self.id = bonus.id
        self.days = bonus.days
        self.usedDays = bonus.usedDays
        self.typeRaw = bonus.typeRaw
        self.reason = bonus.reason
        self.grantedDate = bonus.grantedDate
        self.expirationDate = bonus.expirationDate
        self.isUsed = bonus.isUsed
    }

    func materialize() -> BonusLeave {
        let bonus = BonusLeave(
            days: days,
            type: BonusLeaveType(rawValue: typeRaw) ?? .other,
            reason: reason,
            grantedDate: grantedDate,
            expirationDate: expirationDate
        )
        bonus.id = id
        bonus.usedDays = usedDays
        bonus.isUsed = isUsed
        return bonus
    }
}

struct TMHolidayData: Codable {
    let id: UUID
    let date: Date
    let name: String
    let createdAt: Date

    init(from holiday: CustomHoliday) {
        self.id = holiday.id
        self.date = holiday.date
        self.name = holiday.name
        self.createdAt = holiday.createdAt
    }

    func materialize() -> CustomHoliday {
        let holiday = CustomHoliday(date: date, name: name)
        holiday.id = id
        holiday.createdAt = createdAt
        return holiday
    }
}

// MARK: - Errors

enum TimeMachineError: LocalizedError {
    case checksumMismatch

    var errorDescription: String? {
        switch self {
        case .checksumMismatch: return Strings.snapshotChecksumMismatch
        }
    }
}
