//
//  BackupService.swift
//  Goldweek
//
//  iCloud 백업/복원 서비스
//

import Foundation
import SwiftData
import CryptoKit
import Security

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
    private let backupPrefix = "LeaveWiseICloud_"
    private let maxICloudBackups = 3
    private let autoBackupIntervalKey = "lastAutoICloudBackupDate"
    private let dailyBackupHour = 2  // 새벽 2시에 자동 백업
    private let backupChecksumKey = "icloudBackupChecksum"

    // 레거시 암호화 키 (v1 — 앱 전체 고정 키, 기존 백업 복호화 폴백 전용)
    private var legacyEncryptionKey: SymmetricKey {
        let keyMaterial = "com.Ysoup.LeaveWise.backup.key.v1"
        let keyData = SHA256.hash(data: Data(keyMaterial.utf8))
        return SymmetricKey(data: keyData)
    }

    // 개인 백업 키 (v2 — Keychain에 저장된 사용자별 랜덤 키)
    // iCloud Keychain으로 동기화되어 기기를 바꿔도 본인 백업을 복원할 수 있고,
    // 다른 사용자는 복호화할 수 없다. 일정 공유(CKShare)와는 완전히 분리된 용도.
    private var personalEncryptionKey: SymmetricKey? {
        BackupKeychain.loadOrCreateKey()
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
        // Keychain 접근이 불가한 예외 상황에서만 레거시 키로 저장 (백업 실패 방지)
        let key = personalEncryptionKey ?? legacyEncryptionKey
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw BackupError.encryptionFailed
        }
        return combined
    }

    private func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        // 개인 키 우선, 실패하면 레거시 키로 폴백 (v1 시절 백업 호환)
        if let personalKey = personalEncryptionKey,
           let plaintext = try? AES.GCM.open(sealedBox, using: personalKey) {
            return plaintext
        }
        return try AES.GCM.open(sealedBox, using: legacyEncryptionKey)
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

        try encryptedData.write(to: url, options: .atomic)
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
        try data.write(to: url, options: .atomic)
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

        // 1) 타임스탬프(로테이션) 백업 중 무결성 검증된 최신본 우선
        //    자동 백업이 단일 파일을 정리하므로 이 경로가 없으면 복원 자체가 불가능하다
        if let verifiedURL = await getVerifiedLatestICloudBackup() {
            logInfo("검증된 로테이션 백업 사용: \(verifiedURL.lastPathComponent)", category: .backup)
            let encryptedData = try Data(contentsOf: verifiedURL)
            let decryptedData = try decrypt(encryptedData)
            let backup = try parseBackup(from: decryptedData)
            logInfo("iCloud 복원 완료 - 연차기록: \(backup.leaveRecords.count)건, 보너스: \(backup.bonusLeaves.count)건", category: .backup)
            return backup
        }

        // 1-1) 체크섬 기록이 없어 검증 불가한 로테이션 백업(기기 교체 등)은 최신본을 복호화 시도
        //      복호화/파싱 실패는 그대로 throw되어 사용자에게 전달된다
        if let latestBackup = getTimestampedICloudBackups().max(by: {
            extractTimestamp(from: $0) < extractTimestamp(from: $1)
        }) {
            logWarning("무결성 미검증 로테이션 백업으로 복원 시도: \(latestBackup.lastPathComponent)", category: .backup)
            let encryptedData = try Data(contentsOf: latestBackup)
            let decryptedData = try decrypt(encryptedData)
            let backup = try parseBackup(from: decryptedData)
            logInfo("iCloud 복원 완료 - 연차기록: \(backup.leaveRecords.count)건, 보너스: \(backup.bonusLeaves.count)건", category: .backup)
            return backup
        }

        // 2) 기존 단일 암호화 백업 확인
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

        // 기존 연차 기록 삭제 — fetch 실패 시 중복 삽입을 막기 위해 복원을 중단한다
        let existingRecords = try modelContext.fetch(FetchDescriptor<LeaveRecord>())
        existingRecords.forEach { modelContext.delete($0) }

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

        // 기존 보너스 연차 삭제 — fetch 실패 시 중복 삽입을 막기 위해 복원을 중단한다
        let existingBonus = try modelContext.fetch(FetchDescriptor<BonusLeave>())
        existingBonus.forEach { modelContext.delete($0) }

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

    // MARK: - Layer 3: Enhanced iCloud Backup
    
    /// 자동 일일 백업 (조용히 백그라운드에서 실행)
    func performAutoICloudBackup(
        profile: UserProfile,
        leaveRecords: [LeaveRecord],
        bonusLeaves: [BonusLeave]
    ) async {
        guard shouldPerformAutoBackup() else {
            logDebug("자동 백업 조건 불충족, 스킵", category: .backup)
            return
        }
        
        do {
            try await backupToICloudWithRotation(
                profile: profile,
                leaveRecords: leaveRecords,
                bonusLeaves: bonusLeaves
            )
            
            // 백업 성공시 타임스탬프 업데이트
            UserDefaults.standard.set(Date(), forKey: autoBackupIntervalKey)
            logInfo("자동 iCloud 백업 완료", category: .backup)
        } catch {
            logError("자동 iCloud 백업 실패: \(error.localizedDescription)", category: .backup)
        }
    }
    
    /// 백업과 함께 로테이션 수행 (최대 3개 유지)
    func backupToICloudWithRotation(
        profile: UserProfile,
        leaveRecords: [LeaveRecord],
        bonusLeaves: [BonusLeave]
    ) async throws {
        // 기존 백업 파일들 가져오기
        let existingBackups = getTimestampedICloudBackups()
        
        // 새 백업 생성
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: ".", with: "-")
        let newBackupFileName = "\(backupPrefix)\(timestamp).enc"
        
        guard let containerURL = iCloudContainerURL else {
            throw BackupError.iCloudNotAvailable
        }
        
        let newBackupURL = containerURL.appendingPathComponent(newBackupFileName)
        
        // 백업 데이터 생성 및 무결성 체크섬 계산
        let jsonData = try createBackup(profile: profile, leaveRecords: leaveRecords, bonusLeaves: bonusLeaves)
        let checksum = calculateChecksum(for: jsonData)
        let encryptedData = try encrypt(jsonData)
        
        // iCloud Documents 디렉토리 생성
        try? fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true)
        
        // 새 백업 저장
        try encryptedData.write(to: newBackupURL, options: .atomic)
        
        // 체크섬 저장
        UserDefaults.standard.set(checksum, forKey: "\(backupChecksumKey)_\(timestamp)")
        
        logInfo("새 iCloud 백업 생성: \(newBackupFileName)", category: .backup)
        
        // 오래된 백업 삭제 (최대 3개 유지)
        await rotateICloudBackups(existingBackups: existingBackups)
        
        // 기존 단일 백업 파일 정리
        if let legacyURL = iCloudBackupURL, fileManager.fileExists(atPath: legacyURL.path) {
            try? fileManager.removeItem(at: legacyURL)
            logDebug("기존 단일 백업 파일 정리 완료", category: .backup)
        }
    }
    
    /// iCloud 백업 로테이션 (최대 3개 유지)
    private func rotateICloudBackups(existingBackups: [URL]) async {
        guard existingBackups.count >= maxICloudBackups else { return }
        
        // 최신순으로 정렬 (타임스탬프 기반)
        let sortedBackups = existingBackups.sorted { url1, url2 in
            let timestamp1 = extractTimestamp(from: url1)
            let timestamp2 = extractTimestamp(from: url2)
            return timestamp1 > timestamp2
        }
        
        // 최대 개수 초과시 오래된 것부터 삭제
        for oldBackup in sortedBackups.dropFirst(maxICloudBackups - 1) {
            do {
                try fileManager.removeItem(at: oldBackup)
                let timestamp = extractTimestamp(from: oldBackup)
                UserDefaults.standard.removeObject(forKey: "\(backupChecksumKey)_\(timestamp)")
                logDebug("오래된 iCloud 백업 삭제: \(oldBackup.lastPathComponent)", category: .backup)
            } catch {
                logWarning("백업 파일 삭제 실패: \(error.localizedDescription)", category: .backup)
            }
        }
    }
    
    /// 타임스탬프가 포함된 iCloud 백업 파일들 가져오기
    private func getTimestampedICloudBackups() -> [URL] {
        guard let containerURL = iCloudContainerURL else { return [] }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
            return contents.filter { url in
                url.lastPathComponent.hasPrefix(backupPrefix) &&
                url.pathExtension == "enc"
            }
        } catch {
            logWarning("iCloud 백업 디렉토리 읽기 실패: \(error.localizedDescription)", category: .backup)
            return []
        }
    }
    
    /// 백업 무결성 검증 (체크섬 기반)
    func verifyICloudBackupIntegrity(_ backupURL: URL) async -> Bool {
        guard fileManager.fileExists(atPath: backupURL.path) else {
            return false
        }
        
        do {
            let encryptedData = try Data(contentsOf: backupURL)
            let decryptedData = try decrypt(encryptedData)
            let calculatedChecksum = calculateChecksum(for: decryptedData)
            
            let timestamp = extractTimestamp(from: backupURL)
            let storedChecksum = UserDefaults.standard.string(forKey: "\(backupChecksumKey)_\(timestamp)")
            
            let isValid = calculatedChecksum == storedChecksum
            if !isValid {
                logWarning("백업 무결성 검증 실패: \(backupURL.lastPathComponent)", category: .backup)
            }
            return isValid
        } catch {
            logError("백업 무결성 검증 중 오류: \(error.localizedDescription)", category: .backup)
            return false
        }
    }
    
    /// 가장 최신이고 무결성이 검증된 iCloud 백업 찾기
    func getVerifiedLatestICloudBackup() async -> URL? {
        let backups = getTimestampedICloudBackups().sorted { url1, url2 in
            extractTimestamp(from: url1) > extractTimestamp(from: url2)
        }
        
        for backup in backups {
            if await verifyICloudBackupIntegrity(backup) {
                return backup
            }
        }
        
        // 검증된 백업이 없으면 nil 반환
        logWarning("검증된 iCloud 백업을 찾을 수 없음", category: .backup)
        return nil
    }
    
    /// 자동 백업 수행 조건 확인
    private func shouldPerformAutoBackup() -> Bool {
        guard isICloudAvailable else { return false }
        
        let lastBackupDate = UserDefaults.standard.object(forKey: autoBackupIntervalKey) as? Date
        
        // 마지막 백업이 24시간 이전이거나 없으면 백업 수행
        if let lastDate = lastBackupDate {
            let interval = Date().timeIntervalSince(lastDate)
            return interval >= 24 * 60 * 60  // 24시간 = 86400초
        }
        
        return true  // 처음 백업
    }
    
    /// 파일명에서 타임스탬프 추출
    private func extractTimestamp(from url: URL) -> String {
        let filename = url.lastPathComponent
        if filename.hasPrefix(backupPrefix) {
            let startIndex = filename.index(filename.startIndex, offsetBy: backupPrefix.count)
            let endIndex = filename.lastIndex(of: ".") ?? filename.endIndex
            return String(filename[startIndex..<endIndex])
        }
        return ""
    }
    
    /// 데이터 체크섬 계산
    private func calculateChecksum(for data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - 백업 정보
    func getICloudBackupInfo() async -> (exists: Bool, date: Date?) {
        // 새로운 타임스탬프 백업들 확인
        let timestampedBackups = getTimestampedICloudBackups()
        if let latestBackup = timestampedBackups.max(by: { url1, url2 in
            extractTimestamp(from: url1) < extractTimestamp(from: url2)
        }) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: latestBackup.path)
                let modificationDate = attributes[.modificationDate] as? Date
                return (true, modificationDate)
            } catch {
                return (true, nil)
            }
        }
        
        // 기존 단일 백업 파일 확인 (레거시 호환)
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
    
    /// 모든 iCloud 백업 정보 가져오기 (관리용)
    func getAllICloudBackups() async -> [(url: URL, date: Date?, verified: Bool)] {
        let backups = getTimestampedICloudBackups()
        var result: [(url: URL, date: Date?, verified: Bool)] = []
        
        for backup in backups {
            let attributes = try? fileManager.attributesOfItem(atPath: backup.path)
            let date = attributes?[.modificationDate] as? Date
            let verified = await verifyICloudBackupIntegrity(backup)
            result.append((backup, date, verified))
        }
        
        return result.sorted { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }
    }
}

// MARK: - 백업 키 Keychain 저장소
/// 개인 백업 암호화 키를 Keychain에 보관한다.
/// kSecAttrSynchronizable로 iCloud Keychain에 동기화되어 기기 교체 시에도 복원 가능.
enum BackupKeychain {
    private static let service = "com.Ysoup.LeaveWise.backup"
    private static let account = "personal-backup-key.v2"

    static func loadOrCreateKey() -> SymmetricKey? {
        if let existing = loadKey() {
            return existing
        }
        return createKey()
    }

    private static func loadKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, data.count == 32 else {
            return nil
        }
        return SymmetricKey(data: data)
    }

    private static func createKey() -> SymmetricKey? {
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }

        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanTrue!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: keyData
        ]

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecSuccess {
            logInfo("개인 백업 키 생성 완료 (Keychain)", category: .backup)
            return key
        }
        // 동시 생성 등으로 이미 존재하면 다시 읽는다
        if status == errSecDuplicateItem {
            return loadKey()
        }
        logWarning("개인 백업 키 저장 실패 (status: \(status)) — 레거시 키로 동작", category: .backup)
        return nil
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
    case integrityVerificationFailed
    case backupRotationFailed
    case checksumMismatch

    var errorDescription: String? {
        switch LanguageManager.shared.currentLanguage {
        case .korean:
            switch self {
            case .iCloudNotAvailable: return "iCloud를 사용할 수 없습니다. 설정에서 iCloud Drive를 활성화해주세요."
            case .localPathNotAvailable: return "로컬 저장 경로에 접근할 수 없습니다."
            case .backupNotFound: return "백업 파일을 찾을 수 없습니다."
            case .invalidBackupData: return "백업 데이터를 읽을 수 없습니다."
            case .encryptionFailed: return "백업 암호화에 실패했습니다."
            case .decryptionFailed: return "백업 복호화에 실패했습니다. 다른 기기의 백업일 수 있습니다."
            case .integrityVerificationFailed: return "백업 파일 무결성 검증에 실패했습니다."
            case .backupRotationFailed: return "백업 파일 로테이션에 실패했습니다."
            case .checksumMismatch: return "백업 파일이 손상되었습니다. (체크섬 불일치)"
            }
        case .english:
            switch self {
            case .iCloudNotAvailable: return "iCloud is unavailable. Please enable iCloud Drive in Settings."
            case .localPathNotAvailable: return "Cannot access local storage path."
            case .backupNotFound: return "Backup file not found."
            case .invalidBackupData: return "Cannot read backup data."
            case .encryptionFailed: return "Backup encryption failed."
            case .decryptionFailed: return "Backup decryption failed. It may be a backup from another device."
            case .integrityVerificationFailed: return "Backup integrity verification failed."
            case .backupRotationFailed: return "Backup file rotation failed."
            case .checksumMismatch: return "Backup file is corrupted. (Checksum mismatch)"
            }
        case .japanese:
            switch self {
            case .iCloudNotAvailable: return "iCloudを使用できません。設定でiCloud Driveを有効にしてください。"
            case .localPathNotAvailable: return "ローカル保存パスにアクセスできません。"
            case .backupNotFound: return "バックアップファイルが見つかりません。"
            case .invalidBackupData: return "バックアップデータを読み込めません。"
            case .encryptionFailed: return "バックアップの暗号化に失敗しました。"
            case .decryptionFailed: return "バックアップの復号に失敗しました。他のデバイスのバックアップの可能性があります。"
            case .integrityVerificationFailed: return "バックアップファイルの整合性検証に失敗しました。"
            case .backupRotationFailed: return "バックアップファイルのローテーションに失敗しました。"
            case .checksumMismatch: return "バックアップファイルが破損しています。(チェックサム不一致)"
            }
        case .chinese:
            switch self {
            case .iCloudNotAvailable: return "无法使用iCloud,请在设置中启用iCloud Drive。"
            case .localPathNotAvailable: return "无法访问本地存储路径。"
            case .backupNotFound: return "找不到备份文件。"
            case .invalidBackupData: return "无法读取备份数据。"
            case .encryptionFailed: return "备份加密失败。"
            case .decryptionFailed: return "备份解密失败,可能是其他设备的备份。"
            case .integrityVerificationFailed: return "备份文件完整性验证失败。"
            case .backupRotationFailed: return "备份文件轮换失败。"
            case .checksumMismatch: return "备份文件已损坏。(校验和不匹配)"
            }
        }
    }
}
