//
//  LaunchSafety.swift
//  Goldweek
//
//  연속 크래시 보호(세이프 모드) · 성능 측정 구간(OSSignposter)
//

import Foundation
import os
import LeeoKit

/// 켤 때마다 같은 자리에서 죽으면 다음 실행은 **세이프 모드**로 연다.
///
/// 세이프 모드에서 건너뛰는 것 — 앱을 쓰는 데 없어도 되는 시작 작업만:
///   · 기능 팁(TipKit) 저장소 열기 — 저장소가 깨지면 configure 에서 죽을 수 있다
///   · 휴가 종류 설정 iCloud 동기화 시작
///   · 공유 일정·휴식 레이더 갱신(네트워크·알림 예약)
/// 데이터(SwiftData)는 그대로 연다 — 기록을 못 보는 세이프 모드는 쓸모가 없다.
/// 세이프 모드로 무사히 뜨면 횟수가 0 으로 돌아가고, 그다음 실행은 평소대로 연다.
enum LaunchSafety {
    private static let crashGuard = LeeoCrashLoopGuard(name: "app", defaults: .standard)

    /// 이번 프로세스가 세이프 모드인가 (실행 도중에 바뀌지 않는다)
    private(set) static var isSafeMode = false

    /// `GoldweekApp.init` 맨 앞에서 한 번.
    static func beginLaunch() {
        // UI 시험·스크린샷은 강제 종료가 잦아 실패로 세면 안 된다
        guard !ScreenshotMode.isActive,
              !ProcessInfo.processInfo.arguments.contains("-uiTesting") else { return }
        isSafeMode = crashGuard.beginLaunch()
        if isSafeMode {
            AppLogger.shared.warning("연속으로 시작에 실패해 세이프 모드로 엽니다", category: .app)
        }
    }

    /// 첫 화면이 뜬 뒤. 몇 초 살아 있으면 이번 실행을 성공으로 적고, 지난 실패를 사용 통계로 한 번 보낸다.
    static func firstScreenAppeared() {
        crashGuard.markLaunchSucceededAfterSurvivalDelay()
        let missed = crashGuard.takeUnreportedIncompleteLaunches()
        for _ in 0..<min(missed, LeeoCrashLoopGuard.maxEventsPerReport) {
            UsageReportingService.record(event: "\(LeeoCrashLoopGuard.incompleteLaunchEvent):app")
        }
    }
}

/// Instruments(Points of Interest)에서 핵심 작업 시간을 본다. 출시 빌드에서도 비용이 거의 없다.
enum AppSignpost {
    static let signposter = OSSignposter(subsystem: Bundle.main.bundleIdentifier ?? "com.Ysoup.LeaveWise",
                                         category: .pointsOfInterest)

    /// 구간 하나를 재며 `body` 를 돈다.
    @discardableResult
    static func measure<T>(_ name: StaticString, _ body: () throws -> T) rethrows -> T {
        let state = signposter.beginInterval(name, id: signposter.makeSignpostID())
        defer { signposter.endInterval(name, state) }
        return try body()
    }

    static func measure<T>(_ name: StaticString, _ body: () async throws -> T) async rethrows -> T {
        let state = signposter.beginInterval(name, id: signposter.makeSignpostID())
        defer { signposter.endInterval(name, state) }
        return try await body()
    }
}
