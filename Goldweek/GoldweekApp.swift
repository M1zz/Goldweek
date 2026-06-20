//
//  GoldweekApp.swift
//  Goldweek - 연차 관리 & 추천 앱
//
//  Created by Claude
//

import SwiftUI
import SwiftData

@main
struct GoldweekApp: App {
    let sharedModelContainer: ModelContainer

    init() {
        AppLogger.shared.info("Goldweek 앱 초기화 시작", category: .app)

        // Firebase Analytics + Crashlytics 초기화 (SDK 미설치 시 no-op)
        AnalyticsService.configure()

        // 휴식 레이더 알림 델리게이트 등록 (포그라운드 표시 + 탭/스누즈 추적)
        NotificationService.registerDelegate()

        let schema = Schema([
            UserProfile.self,
            LeaveRecord.self,
            BonusLeave.self,
            CustomHoliday.self,
        ])

        sharedModelContainer = Self.createModelContainer(schema: schema)

        checkICloudStatus()

        AppLogger.shared.info("Goldweek 앱 초기화 완료", category: .app)
    }

    private static func createModelContainer(schema: Schema) -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            AppLogger.shared.info("ModelContainer 생성 성공 (영구 저장소)", category: .data)
            return container
        } catch {
            AppLogger.shared.error("ModelContainer 생성 실패: \(error)", category: .data)

            // Layer 1: 손상된 store 삭제 후 영구 저장소 재생성 (마이그레이션 불가 시)
            AppLogger.shared.warning("손상된 저장소 삭제 후 재생성 시도", category: .data)
            if deleteStoreFiles() {
                do {
                    let container = try ModelContainer(for: schema, configurations: [config])
                    AppLogger.shared.info("저장소 재생성 성공 — 데이터는 초기화됨", category: .data)

                    // 백업에서 복구 시도
                    Task {
                        let context = ModelContext(container)
                        if DataProtectionService.shared.restoreFromLatestBackup(to: context) {
                            AppLogger.shared.info("Layer 1 백업에서 데이터 복구 성공", category: .data)
                        }
                    }
                    return container
                } catch {
                    AppLogger.shared.error("저장소 재생성도 실패: \(error)", category: .data)
                }
            }

            // Layer 2: 인메모리로 전환 + 로컬 백업에서 복구 시도 (최후 수단)
            AppLogger.shared.warning("인메모리 전환 + Layer 2 백업 복구 시도", category: .data)
            let inMemConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                let container = try ModelContainer(for: schema, configurations: [inMemConfig])

                Task {
                    let context = ModelContext(container)
                    if DataProtectionService.shared.restoreFromLatestBackup(to: context) {
                        AppLogger.shared.info("Layer 2 백업에서 데이터 복구 성공!", category: .data)
                    } else {
                        AppLogger.shared.warning("Layer 2 백업 복구 실패", category: .data)
                    }
                }

                return container
            } catch {
                fatalError("인메모리 ModelContainer 생성 불가: \(error)")
            }
        }
    }

    /// 손상된 SwiftData store 파일 삭제 (App Group + 로컬 컨테이너 모두)
    /// - Returns: 1개라도 삭제되면 true
    private static func deleteStoreFiles() -> Bool {
        let fm = FileManager.default
        var candidateBaseURLs: [URL] = []

        // App Group 컨테이너 (위젯과 공유)
        if let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Ysoup.LeaveWise") {
            candidateBaseURLs.append(appGroup.appendingPathComponent("Library/Application Support"))
        }
        // 로컬 컨테이너
        if let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            candidateBaseURLs.append(appSupport)
        }

        var deletedAny = false
        for baseURL in candidateBaseURLs {
            // SwiftData/Core Data 기본 store + WAL/SHM 부속 파일
            let storeFiles = ["default.store", "default.store-wal", "default.store-shm"]
            for file in storeFiles {
                let url = baseURL.appendingPathComponent(file)
                if fm.fileExists(atPath: url.path) {
                    do {
                        try fm.removeItem(at: url)
                        AppLogger.shared.info("저장소 파일 삭제: \(file)", category: .data)
                        deletedAny = true
                    } catch {
                        AppLogger.shared.warning("저장소 파일 삭제 실패 (\(file)): \(error.localizedDescription)", category: .data)
                    }
                }
            }
        }
        return deletedAny
    }

    private func checkICloudStatus() {
        let isICloudAvailable = FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil
        if isICloudAvailable {
            AppLogger.shared.info("iCloud 사용 가능", category: .iCloud)
        } else {
            AppLogger.shared.warning("iCloud 사용 불가 - 백업 기능이 제한됩니다", category: .iCloud)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
