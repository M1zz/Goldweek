//
//  GoldweekApp.swift
//  Goldweek - 연차 관리 & 추천 앱
//
//  Created by Claude
//

import SwiftUI
import SwiftData
import CloudKit
import UIKit

@main
struct GoldweekApp: App {
    @UIApplicationDelegateAdaptor(GoldweekAppDelegate.self) private var appDelegate
    let sharedModelContainer: ModelContainer

    init() {
        AppLogger.shared.info("Goldweek 앱 초기화 시작", category: .app)

        // Firebase Analytics + Crashlytics 초기화 (SDK 미설치 시 no-op)
        AnalyticsService.configure()

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

// MARK: - 앱 델리게이트 (CloudKit 공유 수락 + silent push)
final class GoldweekAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // CloudKit 구독 silent push 수신용 (사용자 알림 권한 불필요)
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = GoldweekSceneDelegate.self
        return config
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        logWarning("원격 알림 등록 실패: \(error.localizedDescription)", category: .share)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let handled = ShareSyncService.shared.handleRemoteNotification(userInfo)
        completionHandler(handled ? .newData : .noData)
    }
}

// MARK: - 씬 델리게이트 (공유 초대 링크 수락)
final class GoldweekSceneDelegate: NSObject, UIWindowSceneDelegate {
    // 앱이 초대 링크로 콜드 런칭된 경우
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let metadata = connectionOptions.cloudKitShareMetadata {
            ShareSyncService.shared.acceptShare(metadata: metadata)
        }
    }

    // 앱 실행 중 초대 링크를 연 경우
    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        ShareSyncService.shared.acceptShare(metadata: cloudKitShareMetadata)
    }
}
