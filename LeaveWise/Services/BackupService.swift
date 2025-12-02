//
//  BackupService.swift
//  LeaveWise
//
//  iCloud 백업/복원 서비스
//

import Foundation
import SwiftData
import CryptoKit

// MARK: - 백업 데이터 구조
struct BackupData: Codable {
    let version: Int
    let createdAt: Date
    let profile: ProfileBackup
    let leaveRecords: [LeaveRecordBackup]
    let bonusLeaves: [BonusLeaveBackup]

    static let currentVersion = 1
}

struct ProfileBackup: Codable {
    let name: String
    let yearStartMonth: Int
    let totalAnnualLeave: Double
    let usedLeave: Double
    let preferredDurationRaw: String
    let preferredSeasonsRaw: String
    let preferLongWeekend: Bool
    let preferConsecutive: Bool
    let avoidPeakSeason: Bool
    let priorityActivitiesRaw: String
}

struct LeaveRecordBackup: Codable {
    let startDate: Date
    let endDate: Date
    let typeRaw: String
    let statusRaw: String
    let note: String
    let isRecommended: Bool
}

struct BonusLeaveBackup: Codable {
    let days: Double
    let typeRaw: String
    let reason: String
    let grantedDate: Date
    let expirationDate: Date?
    let isUsed: Bool
}

// MARK: - 백업 서비스
class BackupService {
    static let shared = BackupService()

    private let fileManager = FileManager.default
    private let backupFileName = "LeaveWiseBackup.enc"  // 암호화된 파일
    private let legacyBackupFileName = "LeaveWiseBackup.json"  // 기존 파일 호환

    // 암호화 키 (앱 고유 식별자 기반)
    private var encryptionKey: SymmetricKey {
        // 번들 ID + 기기 고유 정보를 조합한 키 생성
        let keyMaterial = "com.Ysoup.LeaveWise.backup.key.v1"
        let keyData = SHA256.hash(data: Data(keyMaterial.utf8))
        return SymmetricKey(data: keyData)
    }

    private init() {}

    // MARK: - iCloud 경로
    private var iCloudContainerURL: URL? {
        fileManager.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
    }

    private var localBackupURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(backupFileName)
    }

    private var iCloudBackupURL: URL? {
        iCloudContainerURL?.appendingPathComponent(backupFileName)
    }

    private var legacyICloudBackupURL: URL? {
        iCloudContainerURL?.appendingPathComponent(legacyBackupFileName)
    }

    var isICloudAvailable: Bool {
        iCloudContainerURL != nil
    }

    // MARK: - 암호화/복호화
    private func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        guard let combined = sealedBox.combined else {
            throw BackupError.encryptionFailed
        }
        return combined
    }

    private func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: encryptionKey)
    }

    // MARK: - 백업
    func createBackup(
        profile: UserProfile,
        leaveRecords: [LeaveRecord],
        bonusLeaves: [BonusLeave]
    ) throws -> Data {
        let profileBackup = ProfileBackup(
            name: profile.name,
            yearStartMonth: profile.yearStartMonth,
            totalAnnualLeave: profile.totalAnnualLeave,
            usedLeave: profile.usedLeave,
            preferredDurationRaw: profile.preferredDurationRaw,
            preferredSeasonsRaw: profile.preferredSeasonsRaw,
            preferLongWeekend: profile.preferLongWeekend,
            preferConsecutive: profile.preferConsecutive,
            avoidPeakSeason: profile.avoidPeakSeason,
            priorityActivitiesRaw: profile.priorityActivitiesRaw
        )

        let leaveRecordBackups = leaveRecords.map { record in
            LeaveRecordBackup(
                startDate: record.startDate,
                endDate: record.endDate,
                typeRaw: record.typeRaw,
                statusRaw: record.statusRaw,
                note: record.note,
                isRecommended: record.isRecommended
            )
        }

        let bonusLeaveBackups = bonusLeaves.map { bonus in
            BonusLeaveBackup(
                days: bonus.days,
                typeRaw: bonus.typeRaw,
                reason: bonus.reason,
                grantedDate: bonus.grantedDate,
                expirationDate: bonus.expirationDate,
                isUsed: bonus.isUsed
            )
        }

        let backup = BackupData(
            version: BackupData.currentVersion,
            createdAt: Date(),
            profile: profileBackup,
            leaveRecords: leaveRecordBackups,
            bonusLeaves: bonusLeaveBackups
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(backup)
    }

    // MARK: - iCloud에 백업 (암호화)
    func backupToICloud(
        profile: UserProfile,
        leaveRecords: [LeaveRecord],
        bonusLeaves: [BonusLeave]
    ) async throws {
        logInfo("iCloud 백업 시작", category: .backup)
        logDebug("iCloud 사용 가능 여부: \(isICloudAvailable)", category: .iCloud)

        guard let url = iCloudBackupURL else {
            logError("iCloud 컨테이너 URL을 찾을 수 없음", category: .iCloud)
            throw BackupError.iCloudNotAvailable
        }

        logDebug("iCloud 백업 URL: \(url.path)", category: .iCloud)

        // iCloud Documents 디렉토리 생성
        if let containerURL = iCloudContainerURL {
            logDebug("iCloud Documents 디렉토리 생성 시도: \(containerURL.path)", category: .iCloud)
            try? fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true)
        }

        logDebug("백업 데이터 생성 중 - 프로필: \(profile.name), 연차기록: \(leaveRecords.count)건, 보너스: \(bonusLeaves.count)건", category: .backup)
        let jsonData = try createBackup(profile: profile, leaveRecords: leaveRecords, bonusLeaves: bonusLeaves)
        logDebug("JSON 데이터 크기: \(jsonData.count) bytes", category: .backup)

        // 암호화하여 저장
        logDebug("데이터 암호화 중...", category: .backup)
        let encryptedData = try encrypt(jsonData)
        logDebug("암호화된 데이터 크기: \(encryptedData.count) bytes", category: .backup)

        try encryptedData.write(to: url)
        logInfo("iCloud 백업 완료: \(url.lastPathComponent)", category: .backup)

        // 기존 평문 백업 파일 삭제 (보안)
        if let legacyURL = legacyICloudBackupURL, fileManager.fileExists(atPath: legacyURL.path) {
            logWarning("레거시 평문 백업 파일 발견, 삭제 중...", category: .backup)
            try? fileManager.removeItem(at: legacyURL)
            logInfo("레거시 백업 파일 삭제 완료", category: .backup)
        }
    }

    // MARK: - 로컬에 백업
    func backupToLocal(
        profile: UserProfile,
        leaveRecords: [LeaveRecord],
        bonusLeaves: [BonusLeave]
    ) throws -> URL {
        guard let url = localBackupURL else {
            throw BackupError.localPathNotAvailable
        }

        let data = try createBackup(profile: profile, leaveRecords: leaveRecords, bonusLeaves: bonusLeaves)
        try data.write(to: url)
        return url
    }

    // MARK: - 복원
    func parseBackup(from data: Data) throws -> BackupData {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupData.self, from: data)
    }

    func restoreFromICloud() async throws -> BackupData {
        logInfo("iCloud 복원 시작", category: .backup)
        logDebug("iCloud 사용 가능 여부: \(isICloudAvailable)", category: .iCloud)

        guard let url = iCloudBackupURL else {
            logError("iCloud 컨테이너 URL을 찾을 수 없음", category: .iCloud)
            throw BackupError.iCloudNotAvailable
        }

        logDebug("iCloud 백업 URL 확인: \(url.path)", category: .iCloud)

        // 새 암호화 백업 확인
        if fileManager.fileExists(atPath: url.path) {
            logInfo("암호화된 백업 파일 발견", category: .backup)
            let encryptedData = try Data(contentsOf: url)
            logDebug("암호화된 데이터 크기: \(encryptedData.count) bytes", category: .backup)

            logDebug("데이터 복호화 중...", category: .backup)
            let decryptedData = try decrypt(encryptedData)
            logDebug("복호화된 데이터 크기: \(decryptedData.count) bytes", category: .backup)

            let backup = try parseBackup(from: decryptedData)
            logInfo("iCloud 복원 완료 - 연차기록: \(backup.leaveRecords.count)건, 보너스: \(backup.bonusLeaves.count)건", category: .backup)
            return backup
        }

        // 기존 평문 백업 확인 (레거시 호환)
        if let legacyURL = legacyICloudBackupURL, fileManager.fileExists(atPath: legacyURL.path) {
            logWarning("레거시 평문 백업 파일 사용", category: .backup)
            let data = try Data(contentsOf: legacyURL)
            logDebug("레거시 데이터 크기: \(data.count) bytes", category: .backup)

            let backup = try parseBackup(from: data)
            logInfo("레거시 백업 복원 완료", category: .backup)
            return backup
        }

        logError("백업 파일을 찾을 수 없음", category: .backup)
        throw BackupError.backupNotFound
    }

    func restoreFromLocal() throws -> BackupData {
        guard let url = localBackupURL else {
            throw BackupError.localPathNotAvailable
        }

        guard fileManager.fileExists(atPath: url.path) else {
            throw BackupError.backupNotFound
        }

        let data = try Data(contentsOf: url)
        return try parseBackup(from: data)
    }

    func restoreFromURL(_ url: URL) throws -> BackupData {
        let data = try Data(contentsOf: url)
        return try parseBackup(from: data)
    }

    // MARK: - 데이터 적용
    func applyBackup(
        _ backup: BackupData,
        to modelContext: ModelContext,
        existingProfile: UserProfile?
    ) throws {
        // 프로필 업데이트 또는 생성
        if let profile = existingProfile {
            profile.name = backup.profile.name
            profile.yearStartMonth = backup.profile.yearStartMonth
            profile.totalAnnualLeave = backup.profile.totalAnnualLeave
            profile.usedLeave = backup.profile.usedLeave
            profile.preferredDurationRaw = backup.profile.preferredDurationRaw
            profile.preferredSeasonsRaw = backup.profile.preferredSeasonsRaw
            profile.preferLongWeekend = backup.profile.preferLongWeekend
            profile.preferConsecutive = backup.profile.preferConsecutive
            profile.avoidPeakSeason = backup.profile.avoidPeakSeason
            profile.priorityActivitiesRaw = backup.profile.priorityActivitiesRaw
        } else {
            let newProfile = UserProfile(
                name: backup.profile.name,
                yearStartMonth: backup.profile.yearStartMonth,
                totalAnnualLeave: backup.profile.totalAnnualLeave,
                usedLeave: backup.profile.usedLeave
            )
            newProfile.preferredDurationRaw = backup.profile.preferredDurationRaw
            newProfile.preferredSeasonsRaw = backup.profile.preferredSeasonsRaw
            newProfile.preferLongWeekend = backup.profile.preferLongWeekend
            newProfile.preferConsecutive = backup.profile.preferConsecutive
            newProfile.avoidPeakSeason = backup.profile.avoidPeakSeason
            newProfile.priorityActivitiesRaw = backup.profile.priorityActivitiesRaw
            modelContext.insert(newProfile)
        }

        // 기존 연차 기록 삭제
        let existingRecords = try? modelContext.fetch(FetchDescriptor<LeaveRecord>())
        existingRecords?.forEach { modelContext.delete($0) }

        // 연차 기록 복원
        for record in backup.leaveRecords {
            let newRecord = LeaveRecord(
                startDate: record.startDate,
                endDate: record.endDate,
                type: LeaveType(rawValue: record.typeRaw) ?? .annual,
                status: LeaveStatus(rawValue: record.statusRaw) ?? .planned,
                note: record.note,
                isRecommended: record.isRecommended
            )
            modelContext.insert(newRecord)
        }

        // 기존 보너스 연차 삭제
        let existingBonus = try? modelContext.fetch(FetchDescriptor<BonusLeave>())
        existingBonus?.forEach { modelContext.delete($0) }

        // 보너스 연차 복원
        for bonus in backup.bonusLeaves {
            let newBonus = BonusLeave(
                days: bonus.days,
                type: BonusLeaveType(rawValue: bonus.typeRaw) ?? .other,
                reason: bonus.reason,
                grantedDate: bonus.grantedDate,
                expirationDate: bonus.expirationDate
            )
            newBonus.isUsed = bonus.isUsed
            modelContext.insert(newBonus)
        }

        try modelContext.save()
    }

    // MARK: - 백업 정보
    func getICloudBackupInfo() async -> (exists: Bool, date: Date?) {
        guard let url = iCloudBackupURL else {
            return (false, nil)
        }

        guard fileManager.fileExists(atPath: url.path) else {
            return (false, nil)
        }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            let modificationDate = attributes[.modificationDate] as? Date
            return (true, modificationDate)
        } catch {
            return (true, nil)
        }
    }
}

// MARK: - 에러
enum BackupError: LocalizedError {
    case iCloudNotAvailable
    case localPathNotAvailable
    case backupNotFound
    case invalidBackupData
    case encryptionFailed
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .iCloudNotAvailable:
            return "iCloud를 사용할 수 없습니다. 설정에서 iCloud Drive를 활성화해주세요."
        case .localPathNotAvailable:
            return "로컬 저장 경로에 접근할 수 없습니다."
        case .backupNotFound:
            return "백업 파일을 찾을 수 없습니다."
        case .invalidBackupData:
            return "백업 데이터를 읽을 수 없습니다."
        case .encryptionFailed:
            return "백업 암호화에 실패했습니다."
        case .decryptionFailed:
            return "백업 복호화에 실패했습니다. 다른 기기의 백업일 수 있습니다."
        }
    }
}
