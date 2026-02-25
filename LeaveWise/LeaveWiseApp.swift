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

        sharedModelContainer = Self.createModelContainer(schema: schema)

        checkICloudStatus()

        AppLogger.shared.info("LeaveWise 앱 초기화 완료", category: .app)
    }

    private static func createModelContainer(schema: Schema) -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            AppLogger.shared.info("ModelContainer 생성 성공 (영구 저장소)", category: .data)
            return container
        } catch {
            AppLogger.shared.error("ModelContainer 생성 실패: \(error)", category: .data)

            // Layer 2: 인메모리로 전환 + 로컬 백업에서 복구 시도
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
