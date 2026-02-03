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
        AppLogger.shared.debug("SwiftData 스키마 설정 완료", category: .data)

        sharedModelContainer = Self.createModelContainer(schema: schema)

        // iCloud 상태 확인
        checkICloudStatus()

        AppLogger.shared.info("LeaveWise 앱 초기화 완료", category: .app)
    }

    private static func createModelContainer(schema: Schema) -> ModelContainer {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLogger.shared.info("ModelContainer 생성 성공 (영구 저장소)", category: .data)
            return container
        } catch {
            // 상세 에러 로깅 (디버깅용)
            AppLogger.shared.error("ModelContainer 생성 실패: \(error)", category: .data)
            AppLogger.shared.error("에러 상세: \(String(describing: error))", category: .data)

            // 크래시 방지: 인메모리로 전환 (기존 저장소 파일은 유지)
            AppLogger.shared.warning("인메모리 저장소로 임시 전환 - 앱 재시작 시 데이터 복구 시도됨", category: .data)
            let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                fatalError("인메모리 ModelContainer 생성 불가: \(error)")
            }
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
