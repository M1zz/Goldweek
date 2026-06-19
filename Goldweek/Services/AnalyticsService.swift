//
//  AnalyticsService.swift
//  Goldweek
//
//  Firebase Analytics + Crashlytics 통합 헬퍼.
//  SDK 미설치 상태에서도 빌드되도록 #if canImport 가드 사용.
//

import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

enum AnalyticsService {

    // MARK: - 초기화 (앱 시작 시 1회 호출)

    static func configure() {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    // MARK: - 사용자 속성 (그룹 분석용)

    static func setUser(country: String, userType: String, language: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserProperty(country, forName: "country")
        Analytics.setUserProperty(userType, forName: "user_type")
        Analytics.setUserProperty(language, forName: "language")
        #endif
    }

    // MARK: - 핵심 이벤트

    /// 온보딩 완료
    static func logOnboardingComplete(country: String, totalLeave: Double) {
        log("onboarding_complete", [
            "country": country,
            "total_leave": totalLeave
        ])
    }

    /// 휴가 등록
    static func logLeaveAdded(type: String, days: Double, isRecommended: Bool) {
        log("leave_added", [
            "type": type,
            "days": days,
            "is_recommended": isRecommended ? 1 : 0
        ])
    }

    /// 휴가 삭제
    static func logLeaveDeleted(type: String) {
        log("leave_deleted", ["type": type])
    }

    /// 추천 노출 (사용자에게 추천 목록이 보여짐) — 채택률의 분모.
    /// - source: "list"(추천 화면) | "calendar"(캘린더 통합)
    /// - count: 이번에 노출된 추천 개수
    /// - avgEfficiency: 노출된 추천들의 평균 효율(연차당 휴식 배수)
    /// 한 번의 추천 생성당 1회 호출. 재렌더링으로 중복 발화할 수 있으므로
    /// 분석 시 (user_id, day) 단위로 dedupe하거나 session_id로 묶어 집계할 것.
    static func logRecommendationShown(count: Int, avgEfficiency: Double, source: String) {
        guard count > 0 else { return }
        log("recommendation_shown", [
            "count": count,
            "avg_efficiency": avgEfficiency,
            "source": source
        ])
    }

    /// 추천 일정 추가 (사용자가 추천을 받아들임)
    static func logRecommendationAdded(days: Int, efficiency: Double) {
        log("recommendation_added", [
            "days": days,
            "efficiency": efficiency
        ])
    }

    // MARK: - 마이리얼트립

    static func logMRTOptInShow() { log("mrt_optin_show", [:]) }
    static func logMRTOptInDismiss() { log("mrt_optin_dismiss", [:]) }

    /// 마이리얼트립 카드 탭
    /// - category: "flight" | "stay" | "tour"
    static func logMRTCardTap(category: String, city: String) {
        log("mrt_card_tap", [
            "category": category,
            "city": city
        ])
    }

    // MARK: - Paywall / Pro

    static func logPaywallView(source: String) {
        log("paywall_view", ["source": source])
    }

    static func logPaywallPurchase(success: Bool, productId: String) {
        log("paywall_purchase", [
            "success": success ? 1 : 0,
            "product_id": productId
        ])
    }

    static func logPaywallRestore(success: Bool) {
        log("paywall_restore", ["success": success ? 1 : 0])
    }

    // MARK: - 화면 진입

    static func logScreenView(_ screenName: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
        #endif
    }

    // MARK: - Crashlytics 헬퍼

    /// Non-fatal 에러 기록 (Crashlytics 대시보드에 표시)
    static func recordError(_ error: Error, context: [String: Any] = [:]) {
        #if canImport(FirebaseCrashlytics)
        if !context.isEmpty {
            Crashlytics.crashlytics().setCustomKeysAndValues(context)
        }
        Crashlytics.crashlytics().record(error: error)
        #endif
    }

    /// 사용자 식별자 설정 (개인정보 주의 — UUID 등 비식별 ID 권장)
    static func setUserId(_ id: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserID(id)
        #endif
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setUserID(id)
        #endif
    }

    /// 디버그용 로그 (Crashlytics 크래시 시점에 함께 캡처됨)
    static func logBreadcrumb(_ message: String) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(message)
        #endif
    }

    // MARK: - 내부 공용

    private static func log(_ name: String, _ params: [String: Any]) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(name, parameters: params.isEmpty ? nil : params)
        #endif
    }
}
