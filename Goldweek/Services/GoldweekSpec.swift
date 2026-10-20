//
//  GoldweekSpec.swift
//  Goldweek
//
//  LeeoKit 계약(LeeoAppSpec) 준수 — 이 앱의 공통 인프라 설정값 단일 소스.
//  피드백·사용통계·킬스위치 구현은 전부 LeeoKit에 있고, 앱은 이 설정만 제공한다.
//
//  ⚠️ recordType/구독 ID는 CloudKit Dashboard·기존 사용자 기기와의 계약이다 — 변경 금지.
//  ⚠️ 컨테이너는 여러 앱이 함께 쓰는 공용 허브(FeedbackHub)다. appIdentifier(번들 ID)로 앱을 구분한다.
//     Goldweek 자체 데이터(일정 공유·백업)는 계속 iCloud.com.Ysoup.LeaveWise가 담당한다.
//

import Foundation
import LeeoKit

enum GoldweekSpec: LeeoAppSpec {
    static let appName = "Goldweek"
    static let developerEmail = "leeo@kakao.com"

    /// Goldweek.entitlements에 iCloud.com.Ysoup.FeedbackHub 컨테이너가 있어야 한다.
    static let feedback = LeeoFeedbackConfig(
        containerIdentifier: "iCloud.com.Ysoup.FeedbackHub",
        appIdentifier: "com.Ysoup.LeaveWise"
    )

    /// 법적·지원 링크.
    /// ⚠️ 개인정보 처리방침 주소는 App Store Connect에 등록한 것과 같아야 한다.
    static let legal = LeeoLegalConfig(
        privacyURL: URL(string: "https://m1zz.github.io/Goldweek/support.html#privacy")!,
        supportURL: URL(string: "https://m1zz.github.io/Goldweek/support.html")!,
        termsURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
        // 계정을 만들지 않는다 — 데이터는 사용자의 기기/iCloud에만 있다.
        createsAccounts: false,
        marketingURL: URL(string: "https://m1zz.github.io/Goldweek/")!
    )

    /// 수익모델 — 무료로 쓰다가 연간 구독 또는 평생 구매로 Pro를 연다 (2.4.0부터. 그 전엔 평생 구매만).
    /// ⚠️ productID는 App Store Connect·기존 사용자 영수증과의 계약이다 — 변경 금지.
    static let monetization = LeeoMonetization.freemiumSubscription(
        LeeoSubscriptionConfig(
            productIDs: ProManager.allProductIDs,
            termsURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
            // 무료로 넣을 수 있는 추천 수. 마지막 칸에 닿기 전에 미리 알린다(`RecommendationGate`).
            gate: LeeoGatePolicy(
                freeLimits: [RecommendationGate.key: ProManager.freeRecommendationAddLimit],
                warnWhenRemaining: RecommendationGate.warnWhenRemaining
            ),
            // Pro 선물하기. 보내는 사람은 소모성 선물 상품을 사고, 받는 사람은 평생 Pro 를 산 것과 같아진다.
            // 선물 기록은 피드백과 같은 허브 컨테이너의 공개 DB 에 둔다. entitlements 에 이미 있다.
            // ⚠️ 선물 상품은 productIDs · entitlementIDs 에 넣지 않는다. 넣으면 선물을 산 사람이 Pro 가 된다.
            gift: LeeoGiftConfig(
                productID: ProManager.giftProductID,
                grantsProductID: ProManager.proProductID,
                containerIdentifier: "iCloud.com.Ysoup.FeedbackHub"
            ),
            // 팁(응원). 이미 다 가진 사람이 더 내고 싶을 때. 아무것도 열지 않는 소모성 상품이다.
            // ⚠️ 이것도 productIDs · entitlementIDs 에 넣지 않는다(사전 점검 `tip.sellsPro`).
            tipJar: LeeoTipJarConfig(productIDs: ProManager.tipProductIDs)
        )
    )

    /// "리뷰 남기기"가 App Store 작성 페이지로 바로 가게 한다.
    static let appStoreID: String? = "6755983135"

    /// 분석 싱크 — LeeoKit 내부 이벤트(페이월 노출·구매·피드백 제출·리뷰)를
    /// 앱 정책(쓰로틀·킬스위치)을 거쳐 허브로 흘려보낸다.
    static let analytics: any LeeoAnalytics = GoldweekAnalyticsSink()
}

/// LeeoKit → 앱 사용통계 정책으로 잇는 어댑터.
/// 직접 `LeeoUsageAnalytics`를 쓰지 않는 이유: 쓰로틀·킬스위치를 UsageReportingService가 쥐고 있어서,
/// 그걸 우회하면 같은 이벤트가 무제한으로 공개 DB에 쌓인다.
struct GoldweekAnalyticsSink: LeeoAnalytics {
    func track(_ event: LeeoEvent) {
        UsageReportingService.record(event: event.name)
    }
}

/// 원격 킬스위치 — 심사 없이 문제 기능을 끌 수 있는 최소 장치.
///
/// 운영 (CloudKit Dashboard, iCloud.com.Ysoup.FeedbackHub):
///   레코드 타입 `RemoteFlags` / recordName `flags_com.Ysoup.LeaveWise`
///   필드: 각 rawValue를 Int64(1=켬, 0=끔)로 두고 값을 바꾸면 다음 실행부터 반영된다.
///
/// ⚠️ 새 플래그의 기본값은 항상 "켬"이다. 조회 실패·필드 미생성 상태에서 기능이 꺼지면
///    킬스위치가 오히려 장애 원인이 된다(가용성 우선).
enum GoldweekFlag: String, LeeoRemoteFlag, CaseIterable {
    /// 익명 사용 통계 전송. 옵트아웃이 없는 설계라, 문제가 되면 이걸로 즉시 멈춘다.
    case usageReportingEnabled
    /// 일정 공유(CloudKit CKShare). 공유 사고 시 1순위 차단 대상.
    case shareEnabled
    /// 페이월 노출. 결제 흐름이 깨졌을 때 임시로 감춘다.
    case paywallEnabled
}
