//
//  ReviewManager.swift
//  LeaveWise
//
//  앱 리뷰 요청 관리
//

import SwiftUI
import StoreKit

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
        // LeaveWise App Store ID (출시 후 실제 ID로 교체 필요)
        let appStoreId = "6739899592" // TODO: 실제 App Store ID로 교체
        
        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review") {
            AppLogger.shared.info("App Store 리뷰 페이지 열기", category: .app)
            UIApplication.shared.open(url)
        }
    }
    
    /// App Store 앱 페이지 열기 (공유용)
    func openAppStorePage() {
        let appStoreId = "6739899592" // TODO: 실제 App Store ID로 교체
        
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
