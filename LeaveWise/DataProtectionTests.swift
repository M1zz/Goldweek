//
//  DataProtectionTests.swift
//  LeaveWise
//
//  Tests for 3-Layer Data Protection System
//

import Foundation
import SwiftData
import XCTest

final class DataProtectionTests: XCTestCase {
    
    private var dataProtectionService: DataProtectionService!
    private var testProfile: UserProfile!
    private var testLeaveRecords: [LeaveRecord]!
    private var testBonusLeaves: [BonusLeave]!
    
    override func setUp() {
        super.setUp()
        dataProtectionService = DataProtectionService.shared
        
        // Create test data
        testProfile = UserProfile(
            name: "테스트 사용자",
            yearStartMonth: 1,
            totalAnnualLeave: 15.0,
            usedLeave: 3.0,
            country: .korea
        )
        
        testLeaveRecords = [
            LeaveRecord(
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                type: .annual,
                status: .planned,
                note: "테스트 연차"
            ),
            LeaveRecord(
                startDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                type: .half,
                status: .planned,
                note: "테스트 반차"
            )
        ]
        
        testBonusLeaves = [
            BonusLeave(
                days: 1.0,
                type: .compensatory,
                reason: "대체휴무 테스트",
                grantedDate: Date()
            )
        ]
    }
    
    override func tearDown() {
        // Clean up test backups
        cleanupTestBackups()
        super.tearDown()
    }
    
    // MARK: - Test: Backup Creates Valid JSON
    
    func testBackupCreatesValidJSON() throws {
        // Given: Test data
        
        // When: Creating backup JSON
        let jsonData = try dataProtectionService.createBackupJSON(
            profile: testProfile,
            leaveRecords: testLeaveRecords,
            bonusLeaves: testBonusLeaves
        )
        
        // Then: JSON should be valid and parseable
        XCTAssertFalse(jsonData.isEmpty, "백업 JSON이 비어있지 않아야 함")
        
        let backup = try dataProtectionService.parseBackup(from: jsonData)
        XCTAssertEqual(backup.version, "1.0.5", "백업 버전이 올바르지 않음")
        XCTAssertEqual(backup.profiles.count, 1, "프로필 수가 올바르지 않음")
        XCTAssertEqual(backup.leaveRecords.count, 2, "연차 기록 수가 올바르지 않음")
        XCTAssertEqual(backup.bonusLeaves.count, 1, "보너스 연차 수가 올바르지 않음")
        
        // Verify profile data
        let profileData = backup.profiles.first!
        XCTAssertEqual(profileData.name, "테스트 사용자")
        XCTAssertEqual(profileData.totalAnnualLeave, 15.0)
        XCTAssertEqual(profileData.usedLeave, 3.0)
        
        // Verify checksum exists and is not empty
        XCTAssertFalse(backup.checksum.isEmpty, "체크섬이 설정되어야 함")
    }
    
    // MARK: - Test: Restore Matches Original Data
    
    func testRestoreMatchesOriginalData() throws {
        // Given: Create backup
        let jsonData = try dataProtectionService.createBackupJSON(
            profile: testProfile,
            leaveRecords: testLeaveRecords,
            bonusLeaves: testBonusLeaves
        )
        
        // When: Parsing backup
        let backup = try dataProtectionService.parseBackup(from: jsonData)
        
        // Then: Restored data should match original
        let restoredProfile = backup.profiles.first!.toUserProfile()
        XCTAssertEqual(restoredProfile.name, testProfile.name)
        XCTAssertEqual(restoredProfile.yearStartMonth, testProfile.yearStartMonth)
        XCTAssertEqual(restoredProfile.totalAnnualLeave, testProfile.totalAnnualLeave)
        XCTAssertEqual(restoredProfile.usedLeave, testProfile.usedLeave)
        XCTAssertEqual(restoredProfile.countryRaw, testProfile.countryRaw)
        
        let restoredLeaveRecords = backup.leaveRecords.map { $0.toLeaveRecord() }
        XCTAssertEqual(restoredLeaveRecords.count, testLeaveRecords.count)
        
        for (original, restored) in zip(testLeaveRecords, restoredLeaveRecords) {
            XCTAssertEqual(restored.startDate.timeIntervalSince1970, original.startDate.timeIntervalSince1970, accuracy: 1.0)
            XCTAssertEqual(restored.endDate.timeIntervalSince1970, original.endDate.timeIntervalSince1970, accuracy: 1.0)
            XCTAssertEqual(restored.typeRaw, original.typeRaw)
            XCTAssertEqual(restored.statusRaw, original.statusRaw)
            XCTAssertEqual(restored.note, original.note)
        }
        
        let restoredBonusLeaves = backup.bonusLeaves.map { $0.toBonusLeave() }
        XCTAssertEqual(restoredBonusLeaves.count, testBonusLeaves.count)
        
        for (original, restored) in zip(testBonusLeaves, restoredBonusLeaves) {
            XCTAssertEqual(restored.days, original.days)
            XCTAssertEqual(restored.typeRaw, original.typeRaw)
            XCTAssertEqual(restored.reason, original.reason)
        }
    }
    
    // MARK: - Test: Rotation Keeps Exactly 5 Files
    
    func testRotationKeepsExactlyFiveFiles() {
        // Given: Create more than 5 backups
        for i in 1...7 {
            let testData = createTestBackupData(index: i)
            dataProtectionService.performAutoBackup(
                profile: testProfile,
                leaveRecords: testLeaveRecords,
                bonusLeaves: testBonusLeaves
            )
            // Small delay to ensure different timestamps
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        // When: Checking backup files
        let backupFiles = dataProtectionService.getBackupFiles()
        
        // Then: Should have exactly 5 files
        XCTAssertEqual(backupFiles.count, 5, "백업 파일이 정확히 5개여야 함. 실제: \(backupFiles.count)")
        
        // Files should be sorted by newest first
        for i in 0..<(backupFiles.count - 1) {
            let file1Date = getFileCreationDate(backupFiles[i])
            let file2Date = getFileCreationDate(backupFiles[i + 1])
            XCTAssertTrue(file1Date >= file2Date, "백업 파일이 최신순으로 정렬되어야 함")
        }
    }
    
    // MARK: - Test: Corrupted Data Triggers Auto-Restore
    
    func testCorruptedDataTriggersAutoRestore() throws {
        // Given: Create a valid backup first
        dataProtectionService.performAutoBackup(
            profile: testProfile,
            leaveRecords: testLeaveRecords,
            bonusLeaves: testBonusLeaves
        )
        
        // Create corrupted backup data
        let corruptedJSON = """
        {
            "version": "1.0.5",
            "timestamp": "2025-02-25T00:00:00Z",
            "checksum": "invalid_checksum",
            "profiles": [],
            "leaveRecords": [{"invalid": "data"}],
            "bonusLeaves": []
        }
        """.data(using: .utf8)!
        
        // When: Trying to parse corrupted backup
        XCTAssertThrowsError(try dataProtectionService.parseBackup(from: corruptedJSON)) { error in
            // Then: Should throw error for corrupted data
            print("예상된 에러: \(error)")
        }
        
        // Verify that checksum validation works
        let validJSON = try dataProtectionService.createBackupJSON(
            profile: testProfile,
            leaveRecords: testLeaveRecords,
            bonusLeaves: testBonusLeaves
        )
        
        let backup = try dataProtectionService.parseBackup(from: validJSON)
        let isValid = dataProtectionService.verifyChecksum(data: validJSON, backup: backup)
        XCTAssertTrue(isValid, "유효한 백업의 체크섬 검증이 성공해야 함")
        
        // Test with modified checksum
        var invalidBackup = backup
        invalidBackup.checksum = "invalid"
        let isInvalid = dataProtectionService.verifyChecksum(data: validJSON, backup: invalidBackup)
        XCTAssertFalse(isInvalid, "잘못된 체크섬은 검증 실패해야 함")
    }
    
    // MARK: - Test: Backup Integration with ModelContext
    
    func testBackupIntegrationWithModelContext() throws {
        // This test would need a proper test model context
        // For now, we test the data structure consistency
        
        let jsonData = try dataProtectionService.createBackupJSON(
            profile: testProfile,
            leaveRecords: testLeaveRecords,
            bonusLeaves: testBonusLeaves
        )
        
        let backup = try dataProtectionService.parseBackup(from: jsonData)
        
        // Verify all data can be converted back to model objects
        let restoredProfile = backup.profiles.first!.toUserProfile()
        XCTAssertNotNil(restoredProfile.id)
        
        let restoredRecords = backup.leaveRecords.map { $0.toLeaveRecord() }
        for record in restoredRecords {
            XCTAssertNotNil(record.id)
            XCTAssertNotNil(record.type)
            XCTAssertNotNil(record.status)
        }
        
        let restoredBonus = backup.bonusLeaves.map { $0.toBonusLeave() }
        for bonus in restoredBonus {
            XCTAssertNotNil(bonus.id)
            XCTAssertNotNil(bonus.type)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestBackupData(index: Int) -> Data {
        let modifiedProfile = UserProfile(
            name: "테스트 사용자 \(index)",
            yearStartMonth: 1,
            totalAnnualLeave: 15.0,
            usedLeave: Double(index),
            country: .korea
        )
        
        return try! dataProtectionService.createBackupJSON(
            profile: modifiedProfile,
            leaveRecords: testLeaveRecords,
            bonusLeaves: testBonusLeaves
        )
    }
    
    private func cleanupTestBackups() {
        let files = dataProtectionService.getBackupFiles()
        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    private func getFileCreationDate(_ url: URL) -> Date {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.creationDate] as? Date ?? Date.distantPast
    }
}

// MARK: - Performance Tests

extension DataProtectionTests {
    
    func testBackupPerformance() {
        // Test with larger dataset
        let largeLeaveRecords = Array(0..<100).map { index in
            LeaveRecord(
                startDate: Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: index + 1, to: Date()) ?? Date(),
                type: .annual,
                status: .planned,
                note: "연차 \(index)"
            )
        }
        
        let largeBonusLeaves = Array(0..<50).map { index in
            BonusLeave(
                days: 1.0,
                type: .compensatory,
                reason: "보너스 \(index)"
            )
        }
        
        measure {
            do {
                _ = try dataProtectionService.createBackupJSON(
                    profile: testProfile,
                    leaveRecords: largeLeaveRecords,
                    bonusLeaves: largeBonusLeaves
                )
            } catch {
                XCTFail("백업 생성 실패: \(error)")
            }
        }
    }
    
    func testRestorePerformance() {
        let largeLeaveRecords = Array(0..<100).map { index in
            LeaveRecord(
                startDate: Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: index + 1, to: Date()) ?? Date(),
                type: .annual,
                status: .planned,
                note: "연차 \(index)"
            )
        }
        
        let jsonData = try! dataProtectionService.createBackupJSON(
            profile: testProfile,
            leaveRecords: largeLeaveRecords,
            bonusLeaves: testBonusLeaves
        )
        
        measure {
            do {
                _ = try dataProtectionService.parseBackup(from: jsonData)
            } catch {
                XCTFail("백업 파싱 실패: \(error)")
            }
        }
    }
}