//
//  ReviewManager.swift
//  Goldweek
//
//  앱 리뷰 요청 — 이 앱 덕분에 이득을 봤다고 느낀 순간에만 묻는다
//

import SwiftUI
import LeeoKit
import GoldweekCore

// MARK: - 만족 순간에 묻기

/// "이 앱 덕분에 이득을 봤다"고 느낀 직후에 만족도 프롬프트(좋아요 → 별점, 아쉬움 → 피드백)를 띄운다.
/// ⚠️ 효능감이 없는 시점(앱 실행 횟수, 결제 직후, 오래 썼다는 것만으로)에는 묻지 않는다 — 그때 묻는 별점은
///    앱이 해 준 일이 아니라 기분을 매긴다. 쿨다운·버전당 1회 규칙은 LeeoKit 정책을 그대로 쓴다.
/// 프롬프트 자체는 ContentView 의 `.leeoReviewGate` 가 그린다.
@Observable
final class ReviewMoments {
    static let shared = ReviewMoments()

    enum Moment: String {
        /// 추천 연휴를 일정에 넣었다
        case recommendationAdded
        /// 최적 연차 플랜을 한 번에 등록했다
        case optimalPlanAdded
        /// 빠른 넣기에서 쓴 연차보다 이틀 이상 더 쉬게 된 걸 확인했다 ("연차 1일 → 3일 쉼")
        case longerRestSaved
        /// 휴가를 다녀왔다
        case returnedFromLeave
    }

    var isPresented = false

    /// 기본 정책(실행 3회·설치 2일·긍정 행동 1회)
    private let policy = LeeoReviewPolicy.default

    private init() {}

    /// 만족 순간에 부른다. 조건이 안 맞으면 아무 일도 하지 않는다.
    @MainActor
    func trigger(_ moment: Moment, delay: Double = 1.0) {
        guard !ScreenshotMode.isActive, !isPresented,
              LeeoReviewRequest.shouldRequest(policy: policy) else { return }
        Task { @MainActor in
            // 저장 햅틱·시트 닫힘이 끝난 뒤에 — 겹치면 프롬프트가 묻힌다
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !self.isPresented, LeeoReviewRequest.shouldRequest(policy: policy) else { return }
            // 노출하는 순간 쿨다운을 기록해 다음에 곧바로 다시 뜨지 않게 한다
            LeeoReviewRequest.markRequested()
            UsageReportingService.record(event: "review_moment:\(moment.rawValue)", countsAsEngagement: false)
            self.isPresented = true
        }
    }

    /// 앱을 열 때 — 휴가가 막 끝났으면 "다녀온 순간". 그 밖엔 묻지 않는다
    @MainActor
    func checkOnOpen(leaveRecords: [LeaveRecord]) {
        let cal = Calendar.app
        let today = cal.startOfDay(for: Date())
        let justBack = leaveRecords.contains { r in
            guard r.status != .cancelled else { return false }
            let end = cal.startOfDay(for: r.endDate)
            let days = cal.dateComponents([.day], from: end, to: today).day ?? 99
            // 휴가 마지막 날 다음 1~3일 안에 앱을 연 경우
            return (1...3).contains(days)
        }
        if justBack { trigger(.returnedFromLeave, delay: 1.2) }
    }
}
