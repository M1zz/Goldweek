//
//  DataProtectionService.swift
//  Goldweek
//
//  자동 로컬 JSON 백업/복원 서비스 (Layer 2: 데이터 보호)
//

import Foundation
import SwiftData
import CryptoKit

class DataProtectionService {
    static let shared = DataProtectionService()

    private let fileManager = FileManager.default
    private let maxBackups = 5
    private let backupPrefix = "LeaveWiseAutoBackup_"
    private let backupExtension = "json"

    private init() {}

    // MARK: - Backup Directory (App Support)

    private var backupDirectory: URL? {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = appSupport.appendingPathComponent("LeaveWiseBackups", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - Auto Backup

    func performAutoBackup(
        profile: UserProfile,
        leaveRecords: [LeaveRecord],
        bonusLeaves: [BonusLeave]
    ) {
        do {
            let data = try createBackupJSON(
                profile: profile,
                leaveRecords: leaveRecords,
                bonusLeaves: bonusLeaves
            )

            try saveBackup(data: data)
            rotateBackups()
            logInfo("자동 백업 완료", category: .backup)
        } catch {
            logError("자동 백업 실패: \(error.localizedDescription)", category: .backup)
        }
    }

    // MARK: - Create Backup JSON

    func createBackupJSON(
        profile: UserProfile,
        leaveRecords: [LeaveRecord],
        bonusLeaves: [BonusLeave]
    ) throws -> Data {
        let backup = LocalBackupData(
            version: "1.0.5",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            checksum: "",
            profiles: [ProfileData(from: profile)],
            leaveRecords: leaveRecords.map { LeaveRecordData(from: $0) },
            bonusLeaves: bonusLeaves.map { BonusLeaveData(from: $0) }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        var data = try encoder.encode(backup)

        // Add checksum
        let hash = SHA256.hash(data: data)
        let checksumString = hash.compactMap { String(format: "%02x", $0) }.joined()
        var backupWithChecksum = try JSONDecoder().decode(LocalBackupData.self, from: data)
        backupWithChecksum.checksum = checksumString
        data = try encoder.encode(backupWithChecksum)

        return data
    }

    // MARK: - Save Backup

    private func saveBackup(data: Data) throws {
        guard let dir = backupDirectory else {
            throw DataProtectionError.directoryNotAvailable
        }

        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: ".", with: "-")
        let fileName = "\(backupPrefix)\(timestamp).\(backupExtension)"
        let fileURL = dir.appendingPathComponent(fileName)

        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    // MARK: - Rotate Backups (keep last 5)

    func rotateBackups() {
        guard let dir = backupDirectory else { return }

        do {
            let files = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.creationDateKey])
                .filter { $0.lastPathComponent.hasPrefix(backupPrefix) && $0.pathExtension == backupExtension }
                .sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    return date1 > date2 // newest first
                }

            if files.count > maxBackups {
                for file in files.dropFirst(maxBackups) {
                    try? fileManager.removeItem(at: file)
                    logDebug("오래된 백업 삭제: \(file.lastPathComponent)", category: .backup)
                }
            }
        } catch {
            logError("백업 로테이션 실패: \(error.localizedDescription)", category: .backup)
        }
    }

    // MARK: - Get Latest Backup

    func getLatestBackup() -> URL? {
        guard let dir = backupDirectory else { return nil }

        do {
            let files = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.creationDateKey])
                .filter { $0.lastPathComponent.hasPrefix(backupPrefix) && $0.pathExtension == backupExtension }
                .sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    return date1 > date2
                }
            return files.first
        } catch {
            return nil
        }
    }

    // MARK: - Get All Backups

    func getBackupFiles() -> [URL] {
        guard let dir = backupDirectory else { return [] }

        do {
            return try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.creationDateKey])
                .filter { $0.lastPathComponent.hasPrefix(backupPrefix) && $0.pathExtension == backupExtension }
                .sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    return date1 > date2
                }
        } catch {
            return []
        }
    }

    // MARK: - Restore from Latest Backup

    func restoreFromLatestBackup(to modelContext: ModelContext) -> Bool {
        guard let latestURL = getLatestBackup() else {
            logWarning("복원할 백업 파일 없음", category: .backup)
            return false
        }

        do {
            let data = try Data(contentsOf: latestURL)
            let backup = try parseBackup(from: data)

            if !verifyChecksum(data: data, backup: backup) {
                logWarning("백업 체크섬 불일치, 다음 백업 시도", category: .backup)
                // Try next backup
                let files = getBackupFiles()
                for file in files.dropFirst() {
                    let nextData = try Data(contentsOf: file)
                    let nextBackup = try parseBackup(from: nextData)
                    if verifyChecksum(data: nextData, backup: nextBackup) {
                        try applyBackup(nextBackup, to: modelContext)
                        logInfo("이전 백업에서 복원 성공: \(file.lastPathComponent)", category: .backup)
                        return true
                    }
                }
                return false
            }

            try applyBackup(backup, to: modelContext)
            logInfo("최신 백업에서 복원 성공: \(latestURL.lastPathComponent)", category: .backup)
            return true
        } catch {
            logError("백업 복원 실패: \(error.localizedDescription)", category: .backup)
            return false
        }
    }

    // MARK: - Parse Backup

    func parseBackup(from data: Data) throws -> LocalBackupData {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(LocalBackupData.self, from: data)
    }

    // MARK: - Verify Checksum

    func verifyChecksum(data: Data, backup: LocalBackupData) -> Bool {
        guard !backup.checksum.isEmpty else { return true } // Skip if no checksum

        // Recalculate checksum by zeroing it out
        var copy = backup
        copy.checksum = ""

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let reencoded = try? encoder.encode(copy) else { return false }

        let hash = SHA256.hash(data: reencoded)
        let calculatedChecksum = hash.compactMap { String(format: "%02x", $0) }.joined()

        return calculatedChecksum == backup.checksum
    }

    // MARK: - Apply Backup to ModelContext

    func applyBackup(_ backup: LocalBackupData, to modelContext: ModelContext) throws {
        // Delete existing records
        let existingRecords = try? modelContext.fetch(FetchDescriptor<LeaveRecord>())
        existingRecords?.forEach { modelContext.delete($0) }

        let existingBonus = try? modelContext.fetch(FetchDescriptor<BonusLeave>())
        existingBonus?.forEach { modelContext.delete($0) }

        // Restore profile
        if let profileData = backup.profiles.first {
            let existingProfiles = try? modelContext.fetch(FetchDescriptor<UserProfile>())
            if let existingProfile = existingProfiles?.first {
                profileData.apply(to: existingProfile)
            } else {
                let newProfile = profileData.toUserProfile()
                modelContext.insert(newProfile)
            }
        }

        // Restore leave records
        for recordData in backup.leaveRecords {
            let record = recordData.toLeaveRecord()
            modelContext.insert(record)
        }

        // Restore bonus leaves
        for bonusData in backup.bonusLeaves {
            let bonus = bonusData.toBonusLeave()
            modelContext.insert(bonus)
        }

        try modelContext.save()
    }
}

// MARK: - Local Backup Data Models

struct LocalBackupData: Codable {
    let version: String
    let timestamp: String
    var checksum: String
    let profiles: [ProfileData]
    let leaveRecords: [LeaveRecordData]
    let bonusLeaves: [BonusLeaveData]
}

struct ProfileData: Codable {
    let name: String
    let yearStartMonth: Int
    let totalAnnualLeave: Double
    let usedLeave: Double
    let countryRaw: String
    let preferredDurationRaw: String
    let preferredSeasonsRaw: String
    let preferLongWeekend: Bool
    let preferConsecutive: Bool
    let avoidPeakSeason: Bool
    let priorityActivitiesRaw: String

    init(from profile: UserProfile) {
        self.name = profile.name
        self.yearStartMonth = profile.yearStartMonth
        self.totalAnnualLeave = profile.totalAnnualLeave
        self.usedLeave = profile.usedLeave
        self.countryRaw = profile.countryRaw
        self.preferredDurationRaw = profile.preferredDurationRaw
        self.preferredSeasonsRaw = profile.preferredSeasonsRaw
        self.preferLongWeekend = profile.preferLongWeekend
        self.preferConsecutive = profile.preferConsecutive
        self.avoidPeakSeason = profile.avoidPeakSeason
        self.priorityActivitiesRaw = profile.priorityActivitiesRaw
    }

    func apply(to profile: UserProfile) {
        profile.name = name
        profile.yearStartMonth = yearStartMonth
        profile.totalAnnualLeave = totalAnnualLeave
        profile.usedLeave = usedLeave
        profile.countryRaw = countryRaw
        profile.preferredDurationRaw = preferredDurationRaw
        profile.preferredSeasonsRaw = preferredSeasonsRaw
        profile.preferLongWeekend = preferLongWeekend
        profile.preferConsecutive = preferConsecutive
        profile.avoidPeakSeason = avoidPeakSeason
        profile.priorityActivitiesRaw = priorityActivitiesRaw
    }

    func toUserProfile() -> UserProfile {
        let profile = UserProfile(
            name: name,
            yearStartMonth: yearStartMonth,
            totalAnnualLeave: totalAnnualLeave,
            usedLeave: usedLeave,
            country: Country(rawValue: countryRaw) ?? .korea
        )
        profile.preferredDurationRaw = preferredDurationRaw
        profile.preferredSeasonsRaw = preferredSeasonsRaw
        profile.preferLongWeekend = preferLongWeekend
        profile.preferConsecutive = preferConsecutive
        profile.avoidPeakSeason = avoidPeakSeason
        profile.priorityActivitiesRaw = priorityActivitiesRaw
        return profile
    }
}

struct LeaveRecordData: Codable {
    let startDate: Date
    let endDate: Date
    let typeRaw: String
    let statusRaw: String
    let note: String
    let isRecommended: Bool

    init(from record: LeaveRecord) {
        self.startDate = record.startDate
        self.endDate = record.endDate
        self.typeRaw = record.typeRaw
        self.statusRaw = record.statusRaw
        self.note = record.note
        self.isRecommended = record.isRecommended
    }

    func toLeaveRecord() -> LeaveRecord {
        LeaveRecord(
            startDate: startDate,
            endDate: endDate,
            type: LeaveType(rawValue: typeRaw) ?? .annual,
            status: LeaveStatus(rawValue: statusRaw) ?? .planned,
            note: note,
            isRecommended: isRecommended
        )
    }
}

struct BonusLeaveData: Codable {
    let days: Double
    let typeRaw: String
    let reason: String
    let grantedDate: Date
    let expirationDate: Date?
    let isUsed: Bool

    init(from bonus: BonusLeave) {
        self.days = bonus.days
        self.typeRaw = bonus.typeRaw
        self.reason = bonus.reason
        self.grantedDate = bonus.grantedDate
        self.expirationDate = bonus.expirationDate
        self.isUsed = bonus.isUsed
    }

    func toBonusLeave() -> BonusLeave {
        let bonus = BonusLeave(
            days: days,
            type: BonusLeaveType(rawValue: typeRaw) ?? .other,
            reason: reason,
            grantedDate: grantedDate,
            expirationDate: expirationDate
        )
        bonus.isUsed = isUsed
        return bonus
    }
}

// MARK: - Errors

enum DataProtectionError: LocalizedError {
    case directoryNotAvailable
    case backupNotFound
    case checksumMismatch
    case restoreFailed

    var errorDescription: String? {
        switch self {
        case .directoryNotAvailable: return "백업 디렉토리에 접근할 수 없습니다."
        case .backupNotFound: return "백업 파일을 찾을 수 없습니다."
        case .checksumMismatch: return "백업 데이터 무결성 검증 실패."
        case .restoreFailed: return "백업 복원에 실패했습니다."
        }
    }
}
