//
//  ReviewManager.swift
//  Goldweek
//
//  앱 리뷰 요청 관리
//

import SwiftUI
import StoreKit
import LeeoKit

/// 앱 리뷰 요청을 관리하는 싱글톤
/// 적절한 시점에 리뷰를 요청하고, 과도한 요청을 방지
final class ReviewManager: ObservableObject {
    static let shared = ReviewManager()
    
    // MARK: - Keys
    private enum Keys {
        static let launchCount = "ReviewManager.launchCount"
        static let lastReviewRequestDate = "ReviewManager.lastReviewRequestDate"
        static let leaveRegistrationCount = "ReviewManager.leaveRegistrationCount"
        static let hasReviewed = "ReviewManager.hasReviewed"
        static let lastVersionPrompted = "ReviewManager.lastVersionPrompted"
    }
    
    // MARK: - Thresholds
    private let launchCountThreshold = 5          // 5회 실행 후
    private let registrationCountThreshold = 3    // 3회 연차 등록 후
    private let minimumDaysBetweenRequests = 60   // 최소 60일 간격
    
    // MARK: - Properties
    @Published private(set) var canRequestReview: Bool = false
    
    private var launchCount: Int {
        get { UserDefaults.standard.integer(forKey: Keys.launchCount) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.launchCount) }
    }
    
    private var leaveRegistrationCount: Int {
        get { UserDefaults.standard.integer(forKey: Keys.leaveRegistrationCount) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.leaveRegistrationCount) }
    }
    
    private var lastReviewRequestDate: Date? {
        get { UserDefaults.standard.object(forKey: Keys.lastReviewRequestDate) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastReviewRequestDate) }
    }
    
    private var lastVersionPrompted: String? {
        get { UserDefaults.standard.string(forKey: Keys.lastVersionPrompted) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastVersionPrompted) }
    }
    
    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private init() {
        updateCanRequestReview()
    }
    
    // MARK: - Public Methods
    
    /// 앱 실행 시 호출
    func recordLaunch() {
        launchCount += 1
        AppLogger.shared.debug("앱 실행 횟수: \(launchCount)", category: .app)
        updateCanRequestReview()
    }
    
    /// 연차 등록 완료 시 호출
    func recordLeaveRegistration() {
        leaveRegistrationCount += 1
        AppLogger.shared.debug("연차 등록 횟수: \(leaveRegistrationCount)", category: .app)
        updateCanRequestReview()
    }
    
    /// 리뷰 요청이 적절한 시점인지 확인 후 요청
    /// - Parameter requestReview: Environment에서 가져온 requestReview
    @MainActor
    func requestReviewIfAppropriate(using requestReview: RequestReviewAction) {
        guard shouldRequestReview() else {
            AppLogger.shared.debug("리뷰 요청 조건 미충족", category: .app)
            return
        }
        
        AppLogger.shared.info("리뷰 요청 실행", category: .app)
        requestReview()
        
        lastReviewRequestDate = Date()
        lastVersionPrompted = currentAppVersion
        updateCanRequestReview()
    }
    
    /// 연차 등록 완료 후 리뷰 요청 (자연스러운 타이밍)
    @MainActor
    func requestReviewAfterPositiveAction(using requestReview: RequestReviewAction) {
        guard leaveRegistrationCount >= registrationCountThreshold else { return }
        requestReviewIfAppropriate(using: requestReview)
    }

    /// Pro 구매 완료 후 리뷰 요청 — 임계값 무시, 최고 전환 시점
    @MainActor
    func requestReviewAfterPurchase(using requestReview: RequestReviewAction) {
        guard lastVersionPrompted != currentAppVersion else { return }
        AppLogger.shared.info("구매 후 리뷰 요청 실행", category: .app)
        requestReview()
        lastReviewRequestDate = Date()
        lastVersionPrompted = currentAppVersion
        updateCanRequestReview()
    }
    
    /// App Store 리뷰 페이지 직접 열기 (설정에서 사용)
    func openAppStoreForReview() {
        guard let appStoreId = GoldweekSpec.appStoreID else { return }
        
        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review") {
            AppLogger.shared.info("App Store 리뷰 페이지 열기", category: .app)
            UIApplication.shared.open(url)
        }
    }
    
    /// App Store 앱 페이지 열기 (공유용)
    func openAppStorePage() {
        guard let appStoreId = GoldweekSpec.appStoreID else { return }

        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldRequestReview() -> Bool {
        // 이미 이 버전에서 요청했으면 스킵
        if lastVersionPrompted == currentAppVersion {
            return false
        }
        
        // 최소 기간 체크
        if let lastDate = lastReviewRequestDate {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if daysSinceLastRequest < minimumDaysBetweenRequests {
                return false
            }
        }
        
        // 실행 횟수 또는 등록 횟수 조건 충족
        let meetsLaunchCriteria = launchCount >= launchCountThreshold
        let meetsRegistrationCriteria = leaveRegistrationCount >= registrationCountThreshold
        
        return meetsLaunchCriteria || meetsRegistrationCriteria
    }
    
    private func updateCanRequestReview() {
        canRequestReview = shouldRequestReview()
    }
}

// MARK: - Review Prompt View Modifier
struct ReviewPromptModifier: ViewModifier {
    @Environment(\.requestReview) private var requestReview
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    ReviewManager.shared.requestReviewAfterPositiveAction(using: requestReview)
                }
            }
    }
}

extension View {
    /// 긍정적인 액션 후 리뷰 요청
    func reviewPrompt(trigger: Bool) -> some View {
        modifier(ReviewPromptModifier(trigger: trigger))
    }
}

// MARK: - 만족 순간에 묻기

/// "이 앱 덕분에 이득을 봤다"고 느낀 직후에 만족도 프롬프트(좋아요 → 별점, 아쉬움 → 피드백)를 띄운다.
/// 앱을 열자마자 묻는 것보다 리뷰로 이어지기 쉽다. 쿨다운·버전당 1회 규칙은 LeeoKit 정책을 그대로 쓴다.
/// 프롬프트 자체는 ContentView 의 `.leeoReviewGate` 가 그린다.
@Observable
final class ReviewMoments {
    static let shared = ReviewMoments()

    enum Moment: String {
        /// 추천 연휴를 일정에 넣었다
        case recommendationAdded
        /// 최적 연차 플랜을 한 번에 등록했다
        case optimalPlanAdded
        /// 휴가를 다녀왔다
        case returnedFromLeave
        /// 만족 순간이 없던 사람용 — 충분히 오래 쓴 뒤 앱을 열 때
        case longTimeUser
    }

    var isPresented = false

    /// 만족 순간 — 기본 정책(실행 3회·설치 2일·긍정 행동 1회)
    private let momentPolicy = LeeoReviewPolicy.default
    /// 앱 열 때 대비용 — 만족 순간에 먼저 묻도록 더 늦게
    private let fallbackPolicy = LeeoReviewPolicy(minLaunches: 10, minDaysSinceInstall: 14, minSignificantEvents: 3)

    private init() {}

    /// 만족 순간에 부른다. 조건이 안 맞으면 아무 일도 하지 않는다.
    @MainActor
    func trigger(_ moment: Moment, delay: Double = 1.0) {
        let policy = moment == .longTimeUser ? fallbackPolicy : momentPolicy
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

    /// 앱을 열 때 — 최근 끝난 휴가가 있으면 "다녀온 순간", 없으면 오래 쓴 사람 대비용
    @MainActor
    func checkOnOpen(leaveRecords: [LeaveRecord]) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let justBack = leaveRecords.contains { r in
            guard r.status != .cancelled else { return false }
            let end = cal.startOfDay(for: r.endDate)
            let days = cal.dateComponents([.day], from: end, to: today).day ?? 99
            // 휴가 마지막 날 다음 1~3일 안에 앱을 연 경우
            return (1...3).contains(days)
        }
        trigger(justBack ? .returnedFromLeave : .longTimeUser, delay: 1.2)
    }
}
