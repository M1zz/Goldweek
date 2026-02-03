//
//  LeaveWiseApp.swift
//  LeaveWise - 연차 관리 & 추천 앱
//
//  Created by Claude
//

import SwiftUI
import SwiftData

@main
struct LeaveWiseApp: App {
    let sharedModelContainer: ModelContainer

    init() {
        AppLogger.shared.info("LeaveWise 앱 초기화 시작", category: .app)

        let schema = Schema([
            UserProfile.self,
            LeaveRecord.self,
            BonusLeave.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        AppLogger.shared.debug("SwiftData 스키마 설정 완료", category: .data)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLogger.shared.info("ModelContainer 생성 성공 (영구 저장소)", category: .data)
        } catch {
            AppLogger.shared.error("ModelContainer 생성 실패: \(error.localizedDescription)", category: .data)
            // 기본 컨테이너 사용 (영구 저장소 - 데이터 절대 삭제하지 않음)
            sharedModelContainer = try! ModelContainer(for: schema)
            AppLogger.shared.warning("기본 컨테이너로 폴백 (영구 저장소 유지)", category: .data)
        }

        // iCloud 상태 확인
        checkICloudStatus()

        AppLogger.shared.info("LeaveWise 앱 초기화 완료", category: .app)
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
