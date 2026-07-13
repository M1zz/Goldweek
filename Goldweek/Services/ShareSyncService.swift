//
//  ShareSyncService.swift
//  Goldweek
//
//  CloudKit CKShare 기반 일정 공유 서비스
//  - 내 휴가 일정을 private DB 커스텀 존에 미러링하고 존 전체를 CKShare로 공유
//  - 공유받은 쪽은 shared DB에서 존을 읽어 실시간으로 표시
//  - 서버 운영 없이 Apple CloudKit 인프라만 사용
//

import Foundation
import CloudKit
import SwiftUI

// MARK: - 스냅샷 (SwiftData 모델을 async 경계 너머로 넘기지 않기 위한 값 타입)
struct ProfileSnapshot {
    let name: String
    let countryRaw: String

    init(profile: UserProfile) {
        self.name = profile.name
        self.countryRaw = profile.countryRaw
    }
}

struct LeaveSnapshot {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let typeRaw: String
    let statusRaw: String

    init(record: LeaveRecord) {
        self.id = record.id
        self.startDate = record.startDate
        self.endDate = record.endDate
        self.typeRaw = record.typeRaw
        self.statusRaw = record.statusRaw
    }
}

// MARK: - 공유받은 일정 (참여자 시점)
struct SharedLeaveItem: Identifiable {
    let id: String
    let startDate: Date
    let endDate: Date
    let typeRaw: String
    let statusRaw: String

    var type: LeaveType { LeaveType(rawValue: typeRaw) ?? .annual }
    var status: LeaveStatus { LeaveStatus(rawValue: statusRaw) ?? .planned }
}

struct SharedSchedule: Identifiable {
    let id: String
    let zoneID: CKRecordZone.ID
    let ownerName: String
    let leaves: [SharedLeaveItem]

    /// 오늘 이후 끝나는 휴가 (진행 중 포함)
    var upcomingLeaves: [SharedLeaveItem] {
        let today = Calendar.current.startOfDay(for: Date())
        return leaves.filter { $0.endDate >= today && $0.status != .cancelled }
    }
}

// MARK: - 공유 서비스
@Observable
@MainActor
final class ShareSyncService {
    static let shared = ShareSyncService()

    static let containerIdentifier = "iCloud.com.Ysoup.LeaveWise"
    private static let zoneName = "GoldweekSchedule"
    private static let profileRecordType = "SharedProfile"
    private static let leaveRecordType = "SharedLeave"
    private static let profileRecordName = "profile"
    private static let sharedDBSubscriptionID = "goldweek-shared-db-changes"
    private static let sharingEnabledKey = "goldweekScheduleSharingEnabled"

    // MARK: 상태 (뷰 바인딩용)
    private(set) var accountAvailable = false
    private(set) var isSharingActive: Bool
    private(set) var myShare: CKShare?
    private(set) var participantNames: [String] = []
    private(set) var sharedSchedules: [SharedSchedule] = []
    private(set) var lastSyncDate: Date?
    private(set) var isWorking = false

    private let container: CKContainer
    private var privateDB: CKDatabase { container.privateCloudDatabase }
    private var sharedDB: CKDatabase { container.sharedCloudDatabase }
    private var zoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: Self.zoneName, ownerName: CKCurrentUserDefaultName)
    }
    private var shareRecordID: CKRecord.ID {
        CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: zoneID)
    }

    private var didRegisterSubscription = false
    private var mirrorTask: Task<Void, Never>?

    private init() {
        container = CKContainer(identifier: Self.containerIdentifier)
        isSharingActive = UserDefaults.standard.bool(forKey: Self.sharingEnabledKey)
    }

    // MARK: - 앱 활성화 시 진입점
    /// 계정 확인 → 구독 등록 → 내 공유 상태/공유받은 일정 새로고침 → 공유 중이면 미러링
    func onAppActive(profile: ProfileSnapshot, leaves: [LeaveSnapshot]) async {
        await updateAccountStatus()
        guard accountAvailable else { return }

        await registerSubscriptionIfNeeded()
        await refreshMyShareState()
        await refreshSharedSchedules()

        if isSharingActive {
            await mirrorMySchedule(profile: profile, leaves: leaves)
        }
    }

    /// 로컬 기록 변경 시 호출 — 2초 디바운스 후 미러링
    func scheduleMirror(profile: ProfileSnapshot, leaves: [LeaveSnapshot]) {
        guard isSharingActive, accountAvailable else { return }
        mirrorTask?.cancel()
        mirrorTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await self?.mirrorMySchedule(profile: profile, leaves: leaves)
        }
    }

    // MARK: - 계정
    func updateAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            accountAvailable = (status == .available)
            if !accountAvailable {
                logWarning("iCloud 계정 사용 불가: \(status)", category: .share)
            }
        } catch {
            accountAvailable = false
            logError("iCloud 계정 상태 확인 실패: \(error.localizedDescription)", category: .share)
        }
    }

    // MARK: - 공유 시작 (존 생성 → 미러링 → CKShare 생성)
    /// 이미 공유 중이면 기존 CKShare를 반환한다
    @discardableResult
    func startSharing(profile: ProfileSnapshot, leaves: [LeaveSnapshot]) async throws -> CKShare {
        isWorking = true
        defer { isWorking = false }

        try await ensureZone()
        try await performMirror(profile: profile, leaves: leaves)

        // 기존 공유가 있으면 재사용
        if let existing = try? await privateDB.record(for: shareRecordID) as? CKShare {
            setSharingActive(true)
            applyShare(existing)
            logInfo("기존 CKShare 재사용", category: .share)
            return existing
        }

        let share = CKShare(recordZoneID: zoneID)
        share[CKShare.SystemFieldKey.title] = Strings.shareCKTitle(profile.name) as CKRecordValue
        share.publicPermission = .none

        let (saveResults, _) = try await privateDB.modifyRecords(saving: [share], deleting: [])
        var savedShare = share
        for (_, result) in saveResults {
            if case .success(let record) = result, let ckShare = record as? CKShare {
                savedShare = ckShare
            }
        }

        setSharingActive(true)
        applyShare(savedShare)
        lastSyncDate = Date()
        logInfo("CKShare 생성 완료", category: .share)
        return savedShare
    }

    // MARK: - 공유 중지 (존 삭제 → 공유·데이터 모두 제거)
    func stopSharing() async throws {
        isWorking = true
        defer { isWorking = false }

        _ = try await privateDB.modifyRecordZones(saving: [], deleting: [zoneID])
        setSharingActive(false)
        myShare = nil
        participantNames = []
        logInfo("일정 공유 중지 완료", category: .share)
    }

    // MARK: - 미러링 (로컬 → CloudKit private 존)
    func mirrorMySchedule(profile: ProfileSnapshot, leaves: [LeaveSnapshot]) async {
        guard isSharingActive else { return }
        do {
            try await performMirror(profile: profile, leaves: leaves)
            lastSyncDate = Date()
            logInfo("일정 미러링 완료 (\(leaves.count)건 기준)", category: .share)
        } catch {
            logError("일정 미러링 실패: \(error.localizedDescription)", category: .share)
        }
    }

    private func performMirror(profile: ProfileSnapshot, leaves: [LeaveSnapshot]) async throws {
        try await ensureZone()

        // 취소된 휴가는 공유하지 않는다
        let activeLeaves = leaves.filter { LeaveStatus(rawValue: $0.statusRaw) != .cancelled }

        var recordsToSave: [CKRecord] = []

        let profileRecord = CKRecord(
            recordType: Self.profileRecordType,
            recordID: CKRecord.ID(recordName: Self.profileRecordName, zoneID: zoneID)
        )
        profileRecord["name"] = profile.name as CKRecordValue
        profileRecord["country"] = profile.countryRaw as CKRecordValue
        recordsToSave.append(profileRecord)

        for leave in activeLeaves {
            let record = CKRecord(
                recordType: Self.leaveRecordType,
                recordID: CKRecord.ID(recordName: leave.id.uuidString, zoneID: zoneID)
            )
            record["startDate"] = leave.startDate as CKRecordValue
            record["endDate"] = leave.endDate as CKRecordValue
            record["type"] = leave.typeRaw as CKRecordValue
            record["status"] = leave.statusRaw as CKRecordValue
            recordsToSave.append(record)
        }

        // 서버에는 있지만 로컬에서 사라진 휴가는 삭제 (미러 = 로컬이 진실)
        let existing = try await fetchAllRecords(database: privateDB, zoneID: zoneID)
        let currentNames = Set(activeLeaves.map { $0.id.uuidString })
        let idsToDelete = existing
            .filter { $0.recordType == Self.leaveRecordType && !currentNames.contains($0.recordID.recordName) }
            .map { $0.recordID }

        // CloudKit 배치 제한(400) 아래로 나눠 저장
        for chunk in recordsToSave.chunked(into: 300) {
            _ = try await privateDB.modifyRecords(
                saving: chunk,
                deleting: [],
                savePolicy: .allKeys,
                atomically: false
            )
        }
        if !idsToDelete.isEmpty {
            _ = try await privateDB.modifyRecords(saving: [], deleting: idsToDelete)
        }
    }

    private func ensureZone() async throws {
        let zone = CKRecordZone(zoneName: Self.zoneName)
        _ = try await privateDB.modifyRecordZones(saving: [zone], deleting: [])
    }

    // MARK: - 내 공유 상태 새로고침 (참여자 목록 포함)
    func refreshMyShareState() async {
        do {
            if let share = try await privateDB.record(for: shareRecordID) as? CKShare {
                setSharingActive(true)
                applyShare(share)
            } else {
                setSharingActive(false)
                myShare = nil
                participantNames = []
            }
        } catch let error as CKError where error.code == .unknownItem || error.code == .zoneNotFound {
            setSharingActive(false)
            myShare = nil
            participantNames = []
        } catch {
            logWarning("공유 상태 확인 실패: \(error.localizedDescription)", category: .share)
        }
    }

    private func applyShare(_ share: CKShare) {
        myShare = share
        let formatter = PersonNameComponentsFormatter()
        participantNames = share.participants
            .filter { $0.role != .owner }
            .compactMap { participant in
                if let components = participant.userIdentity.nameComponents {
                    let name = formatter.string(from: components)
                    if !name.isEmpty { return name }
                }
                return participant.userIdentity.lookupInfo?.emailAddress
                    ?? participant.userIdentity.lookupInfo?.phoneNumber
            }
    }

    // MARK: - 공유 수락 (초대 링크를 연 쪽)
    func acceptShare(metadata: CKShare.Metadata) {
        Task {
            do {
                _ = try await container.accept(metadata)
                logInfo("공유 수락 완료", category: .share)
                await updateAccountStatus()
                await registerSubscriptionIfNeeded()
                await refreshSharedSchedules()
            } catch {
                logError("공유 수락 실패: \(error.localizedDescription)", category: .share)
            }
        }
    }

    // MARK: - 공유받은 일정 새로고침 (shared DB 전체)
    func refreshSharedSchedules() async {
        do {
            let zones = try await sharedDB.allRecordZones()
            var schedules: [SharedSchedule] = []

            for zone in zones {
                let records = try await fetchAllRecords(database: sharedDB, zoneID: zone.zoneID)

                var ownerName = Strings.shareOwnerFallback
                if let profileRecord = records.first(where: { $0.recordType == Self.profileRecordType }),
                   let name = profileRecord["name"] as? String, !name.isEmpty {
                    ownerName = name
                } else if let shareRecord = records.compactMap({ $0 as? CKShare }).first,
                          let components = shareRecord.owner.userIdentity.nameComponents {
                    let name = PersonNameComponentsFormatter().string(from: components)
                    if !name.isEmpty { ownerName = name }
                }

                let leaves = records
                    .filter { $0.recordType == Self.leaveRecordType }
                    .compactMap { record -> SharedLeaveItem? in
                        guard let start = record["startDate"] as? Date,
                              let end = record["endDate"] as? Date else { return nil }
                        return SharedLeaveItem(
                            id: record.recordID.recordName,
                            startDate: start,
                            endDate: end,
                            typeRaw: record["type"] as? String ?? LeaveType.annual.rawValue,
                            statusRaw: record["status"] as? String ?? LeaveStatus.planned.rawValue
                        )
                    }
                    .sorted { $0.startDate < $1.startDate }

                schedules.append(SharedSchedule(
                    id: "\(zone.zoneID.ownerName)|\(zone.zoneID.zoneName)",
                    zoneID: zone.zoneID,
                    ownerName: ownerName,
                    leaves: leaves
                ))
            }

            sharedSchedules = schedules.sorted { $0.ownerName < $1.ownerName }
        } catch {
            logWarning("공유받은 일정 새로고침 실패: \(error.localizedDescription)", category: .share)
        }
    }

    // MARK: - 공유 나가기 (참여자가 스스로 참여 해제)
    func leaveSharedSchedule(_ schedule: SharedSchedule) async {
        do {
            _ = try await sharedDB.modifyRecordZones(saving: [], deleting: [schedule.zoneID])
            sharedSchedules.removeAll { $0.id == schedule.id }
            logInfo("공유 나가기 완료: \(schedule.ownerName)", category: .share)
        } catch {
            logError("공유 나가기 실패: \(error.localizedDescription)", category: .share)
        }
    }

    // MARK: - 실시간 갱신 (silent push 구독)
    func registerSubscriptionIfNeeded() async {
        guard !didRegisterSubscription else { return }

        let subscription = CKDatabaseSubscription(subscriptionID: Self.sharedDBSubscriptionID)
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info

        do {
            _ = try await sharedDB.modifySubscriptions(saving: [subscription], deleting: [])
            didRegisterSubscription = true
            logDebug("shared DB 구독 등록 완료", category: .share)
        } catch {
            // 푸시가 안 돼도 포그라운드 진입 시 새로고침으로 동작한다
            logWarning("shared DB 구독 등록 실패: \(error.localizedDescription)", category: .share)
        }
    }

    /// CloudKit silent push 처리. CloudKit 알림이면 true를 반환한다.
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let notification = CKNotification(
            fromRemoteNotificationDictionary: userInfo as? [String: NSObject] ?? [:]
        ) else { return false }

        logDebug("CloudKit 푸시 수신: \(notification.notificationType.rawValue)", category: .share)
        Task {
            await refreshSharedSchedules()
        }
        return true
    }

    // MARK: - 헬퍼
    private func setSharingActive(_ active: Bool) {
        isSharingActive = active
        UserDefaults.standard.set(active, forKey: Self.sharingEnabledKey)
    }

    /// 존의 모든 레코드를 change-token 페이지네이션으로 가져온다 (쿼리 인덱스 불필요)
    private func fetchAllRecords(database: CKDatabase, zoneID: CKRecordZone.ID) async throws -> [CKRecord] {
        var records: [CKRecord] = []
        var token: CKServerChangeToken? = nil

        while true {
            do {
                let changes = try await database.recordZoneChanges(inZoneWith: zoneID, since: token)
                for (_, result) in changes.modificationResultsByID {
                    if case .success(let modification) = result {
                        records.append(modification.record)
                    }
                }
                token = changes.changeToken
                if !changes.moreComing { break }
            } catch let error as CKError where error.code == .zoneNotFound {
                return []
            }
        }
        return records
    }
}

// MARK: - 배열 청크 분할
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
