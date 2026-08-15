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
import TipKit
import LeeoKit

@main
struct GoldweekApp: App {
    @UIApplicationDelegateAdaptor(GoldweekAppDelegate.self) private var appDelegate
    let sharedModelContainer: ModelContainer

    init() {
        AppLogger.shared.info("Goldweek 앱 초기화 시작", category: .app)

        // 휴식 레이더 알림 델리게이트 등록 (포그라운드 표시 + 탭/스누즈 추적)
        NotificationService.registerDelegate()

        // 앱 소유 사용 통계·피드백 허브 (CloudKit, 외부 SDK 없음).
        // Firebase를 걷어낸 뒤로 이 경로가 유일한 분석 수단이다 — 이벤트는 각 화면에서
        // `UsageReportingService.record(event:)`로 직접 남긴다(이벤트 사전: docs/analytics-impact.md).

        // LeeoKit 내부(페이월·피드백·리뷰) 이벤트도 같은 경로로 모은다.
        LeeoAnalyticsCenter.register(GoldweekSpec.self)

        // 원격 킬스위치 캐시 갱신 (6시간 쓰로틀, 실패해도 조용히 넘어간다 — 읽기는 항상 캐시).
        LeeoRemoteFlags(spec: GoldweekSpec.self).refreshInBackground(GoldweekFlag.self)

        // 크래시·멈춤 진단 (MetricKit) → 허브. 구독만 하고 즉시 반환한다(런치 비용 없음).
        LeeoDiagnostics.shared.start(spec: GoldweekSpec.self) {
            LeeoRemoteFlags.isEnabled(GoldweekFlag.usageReportingEnabled)
        }

        // ⚠️ `LeeoKit.bootstrap`을 쓰지 않는 이유
        //   · registerLaunch: 이 앱은 공유 일정 silent push·알림으로도 프로세스가 뜬다. 여기서 세면
        //     열지도 않은 실행이 실행 횟수로 잡혀 만족도 프롬프트가 앞당겨진다
        //     → 화면이 실제로 뜨는 ContentView에서 센다.
        //   · 사용 스냅샷: 지표(SwiftData)를 실어야 의미가 있어 ContentView에서 보낸다.
        #if DEBUG
        LeeoPreflight.report(GoldweekSpec.self)
        #endif

        let schema = Schema([
            UserProfile.self,
            LeaveRecord.self,
            BonusLeave.self,
            CustomHoliday.self,
        ])

        sharedModelContainer = Self.createModelContainer(schema: schema)

        // 기능 팁 (TipKit) — 하루 1개씩 노출, 기능 사용 시 각 팁이 invalidate 됨
        #if DEBUG
        if ProcessInfo.processInfo.environment["SHOW_ALL_TIPS"] == "1" {
            try? Tips.resetDatastore()
            Tips.showAllTipsForTesting()
        }
        #endif
        try? Tips.configure([.displayFrequency(.daily)])

        checkICloudStatus()

        AppLogger.shared.info("Goldweek 앱 초기화 완료", category: .app)
    }

    private static func createModelContainer(schema: Schema) -> ModelContainer {
        // CloudKit 동기화는 ShareSyncService가 CKRecord로 직접 처리 —
        // entitlement 감지로 .automatic이 CloudKit 미러링을 켜면 모델 검증 실패로 컨테이너 생성이 throw됨
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            AppLogger.shared.info("ModelContainer 생성 성공 (영구 저장소)", category: .data)
            return container
        } catch {
            AppLogger.shared.error("ModelContainer 생성 실패: \(error)", category: .data)

            // Layer 1: 손상된 store를 격리(이동)한 뒤 영구 저장소 재생성 (마이그레이션 불가 시)
            // 절대 삭제하지 않는다 — 격리된 파일은 나중에 수동 복구할 수 있다
            AppLogger.shared.warning("손상된 저장소 격리 후 재생성 시도", category: .data)
            if quarantineStoreFiles() {
                do {
                    let container = try ModelContainer(for: schema, configurations: [config])
                    AppLogger.shared.info("저장소 재생성 성공 — 기존 파일은 격리 보관됨", category: .data)
                    restoreFromSafetyNet(container: container, layer: "Layer 1")
                    return container
                } catch {
                    AppLogger.shared.error("저장소 재생성도 실패: \(error)", category: .data)
                }
            }

            // Layer 2: 인메모리로 전환 + 백업에서 복구 시도 (최후 수단)
            AppLogger.shared.warning("인메모리 전환 + Layer 2 백업 복구 시도", category: .data)
            let inMemConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            do {
                let container = try ModelContainer(for: schema, configurations: [inMemConfig])
                restoreFromSafetyNet(container: container, layer: "Layer 2")
                return container
            } catch {
                fatalError("인메모리 ModelContainer 생성 불가: \(error)")
            }
        }
    }

    /// 타임머신 스냅샷 → 레거시 자동 백업 순으로 데이터 복구를 시도한다
    private static func restoreFromSafetyNet(container: ModelContainer, layer: String) {
        Task { @MainActor in
            let context = ModelContext(container)
            if TimeMachineService.shared.restoreFromLatestSnapshot(to: context) {
                AppLogger.shared.info("\(layer) 타임머신 스냅샷에서 데이터 복구 성공", category: .data)
            } else if DataProtectionService.shared.restoreFromLatestBackup(to: context) {
                AppLogger.shared.info("\(layer) 백업에서 데이터 복구 성공", category: .data)
            } else {
                AppLogger.shared.warning("\(layer) 복구할 백업/스냅샷 없음", category: .data)
            }
        }
    }

    /// 손상된 SwiftData store 파일을 격리 폴더로 이동 (App Group + 로컬 컨테이너 모두)
    /// 사용자 데이터가 담긴 파일은 절대 삭제하지 않는다 — 이동만 한다
    /// - Returns: 1개라도 격리되면 true
    private static func quarantineStoreFiles() -> Bool {
        let fm = FileManager.default

        guard let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return false
        }
        let quarantineRoot = appSupport.appendingPathComponent("QuarantinedStores", isDirectory: true)
        let stamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let quarantineDir = quarantineRoot.appendingPathComponent(stamp, isDirectory: true)

        var candidateBaseURLs: [URL] = []
        // App Group 컨테이너 (위젯과 공유)
        if let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Ysoup.LeaveWise") {
            candidateBaseURLs.append(appGroup.appendingPathComponent("Library/Application Support"))
        }
        // 로컬 컨테이너
        candidateBaseURLs.append(appSupport)

        var movedAny = false
        for (index, baseURL) in candidateBaseURLs.enumerated() {
            // SwiftData/Core Data 기본 store + WAL/SHM 부속 파일
            let storeFiles = ["default.store", "default.store-wal", "default.store-shm"]
            for file in storeFiles {
                let url = baseURL.appendingPathComponent(file)
                guard fm.fileExists(atPath: url.path) else { continue }
                do {
                    try fm.createDirectory(at: quarantineDir, withIntermediateDirectories: true)
                    try fm.moveItem(at: url, to: quarantineDir.appendingPathComponent("\(index)_\(file)"))
                    AppLogger.shared.info("저장소 파일 격리: \(file)", category: .data)
                    movedAny = true
                } catch {
                    AppLogger.shared.warning("저장소 파일 격리 실패 (\(file)): \(error.localizedDescription)", category: .data)
                }
            }
        }

        pruneQuarantine(root: quarantineRoot, keep: 3)
        return movedAny
    }

    /// 격리 폴더가 무한히 쌓이지 않게 최신 keep개만 유지
    private static func pruneQuarantine(root: URL, keep: Int) {
        let fm = FileManager.default
        guard let dirs = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil) else { return }
        // 폴더명이 ISO8601 타임스탬프라 이름 내림차순 = 최신순
        let sorted = dirs.sorted { $0.lastPathComponent > $1.lastPathComponent }
        for dir in sorted.dropFirst(keep) {
            try? fm.removeItem(at: dir)
            AppLogger.shared.info("오래된 격리 저장소 정리: \(dir.lastPathComponent)", category: .data)
        }
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
