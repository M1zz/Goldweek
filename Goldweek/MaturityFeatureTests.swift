//
//  MaturityFeatureTests.swift
//  Goldweek
//
//  2.4.1 에 더한 것 — 내 혜택 셈 · 새로운 기능을 누구에게 띄우나 · 새 문구 23개 언어.
//

import Foundation
import XCTest
@testable import Goldweek

final class MaturityFeatureTests: XCTestCase {

    private let cal = Calendar.app

    private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d))!
    }

    // MARK: - 내 혜택

    /// 한 추천은 쉬는 날을 사이에 두고 여러 기록으로 나뉘지만 제목이 같다 → 한 개로 센다.
    func testRecommendedPlansGroupBySplitSegments() {
        let entries = [
            ProBenefits.Entry(note: "Chuseok", startDate: day(2026, 9, 23), isRecommended: true, isCancelled: false),
            ProBenefits.Entry(note: "Chuseok", startDate: day(2026, 9, 28), isRecommended: true, isCancelled: false),
            ProBenefits.Entry(note: "Christmas", startDate: day(2026, 12, 24), isRecommended: true, isCancelled: false),
        ]
        XCTAssertEqual(ProBenefits.recommendedPlanCount(entries, year: 2026, calendar: cal), 2)
    }

    func testRecommendedPlansIgnoreOtherYearsManualAndCancelled() {
        let entries = [
            ProBenefits.Entry(note: "New Year", startDate: day(2025, 12, 30), isRecommended: true, isCancelled: false),
            ProBenefits.Entry(note: "Trip", startDate: day(2026, 5, 4), isRecommended: false, isCancelled: false),
            ProBenefits.Entry(note: "Spring", startDate: day(2026, 3, 2), isRecommended: true, isCancelled: true),
            ProBenefits.Entry(note: "Summer", startDate: day(2026, 8, 3), isRecommended: true, isCancelled: false),
        ]
        XCTAssertEqual(ProBenefits.recommendedPlanCount(entries, year: 2026, calendar: cal), 1)
    }

    /// 무료 한도는 게이트와 같은 값이다 — 추천 목록 앞 3개.
    func testFreeLimitMatchesGateAndExtraNeverNegative() {
        XCTAssertEqual(ProManager.freeRecommendationAddLimit, 3)
        XCTAssertEqual(ProBenefits.extra(used: 5, freeLimit: ProManager.freeRecommendationAddLimit), 2)
        XCTAssertEqual(ProBenefits.extra(used: 1, freeLimit: ProManager.freeRecommendationAddLimit), 0)
    }

    func testNextTierStopsAtFamily() {
        XCTAssertEqual(ProBenefits.nextTier(after: .plus), .pro)
        XCTAssertEqual(ProBenefits.nextTier(after: .pro), .family)
        XCTAssertNil(ProBenefits.nextTier(after: .family))
    }

    /// 위 등급에서 더 열리는 것은 페이월 비교표에서 가져온다 — 요약 줄을 빼도 비어 있으면 안 된다.
    func testUpgradeListComesFromPaywallTable() {
        for tier in [ProTier.plus, .pro, .family] {
            XCTAssertFalse(PaywallView.features(of: tier).filter { !$0.isSummary }.isEmpty, "\(tier)")
        }
    }

    // MARK: - 새로운 기능

    func testWhatsNewSkipsNewcomers() {
        XCTAssertEqual(WhatsNewGate.resolve(wasOnboardedAtLaunch: false, lastSeenVersion: nil), .newcomer)
    }

    func testWhatsNewShowsOnceToUpdaters() {
        XCTAssertEqual(WhatsNewGate.resolve(wasOnboardedAtLaunch: true, lastSeenVersion: nil), .show)
        XCTAssertEqual(WhatsNewGate.resolve(wasOnboardedAtLaunch: true, lastSeenVersion: "2.0.0"), .show)
        XCTAssertEqual(WhatsNewGate.resolve(wasOnboardedAtLaunch: true, lastSeenVersion: WhatsNewContent.version), .seen)
    }

    func testNewcomerIsMarkedSeenSoItNeverAppearsLater() {
        let defaults = UserDefaults(suiteName: "MaturityFeatureTests.\(UUID().uuidString)")!
        WhatsNewGate.wasOnboardedAtLaunch = false
        XCTAssertFalse(WhatsNewGate.shouldPresentNow(defaults: defaults))
        XCTAssertEqual(defaults.string(forKey: WhatsNewGate.lastSeenKey), WhatsNewContent.version)
        // 다음 실행 — 이제 온보딩을 마친 사람이지만 이미 본 것으로 적혀 있다
        WhatsNewGate.wasOnboardedAtLaunch = true
        XCTAssertFalse(WhatsNewGate.shouldPresentNow(defaults: defaults))
    }

    // MARK: - 새 문구

    /// 23개 언어 모두 빈칸 없이, 한국어가 아닌 언어에 한글이 섞이지 않게.
    /// (표에 언어가 빠지면 `pick` 의 assertionFailure 가 여기서 멈춘다.)
    func testNewStringsCoverEveryLanguage() {
        let saved = LanguageManager.shared.currentLanguage
        defer { LanguageManager.shared.currentLanguage = saved }
        for lang in AppLanguage.allCases {
            LanguageManager.shared.currentLanguage = lang
            let texts = [
                Strings.whatsNewTitle, Strings.whatsNewSubtitle, Strings.whatsNewBenefitsTitle,
                Strings.whatsNewBenefitsDetail, Strings.whatsNewCodeTitle, Strings.whatsNewCodeDetail,
                Strings.whatsNewRoadmapTitle, Strings.whatsNewRoadmapDetail, Strings.whatsNewA11yTitle,
                Strings.whatsNewA11yDetail, Strings.whatsNewContinue, Strings.whatsNewEntry,
                Strings.redeemOfferCode, Strings.stateOn, Strings.stateOff, Strings.stateAvailable,
                Strings.peopleCount(1), Strings.peopleCount(5), Strings.benefitsTitle,
                Strings.benefitsSummaryExtra(1), Strings.benefitsSummaryExtra(4),
                Strings.benefitsAllUnlocked(.pro), Strings.benefitsLimitsHeader,
                Strings.benefitsRecommendationsRow, Strings.benefitsFreeVsNow(free: 3, now: 5),
                Strings.benefitsBeyondFree(2), Strings.benefitsUnlockedHeader(.family),
                Strings.benefitsFamilyMembers, Strings.benefitsMoreHeader(.pro), Strings.benefitsExplore(.family),
                Strings.benefitsSeeAll, Strings.benefitsRowHint, Strings.a11yLeaveDeleted,
                Strings.a11yRecommendationAdded("X"),
            ]
            for text in texts {
                XCTAssertFalse(text.trimmingCharacters(in: .whitespaces).isEmpty, "\(lang.rawValue) 빈 문구")
                if lang != .korean {
                    XCTAssertNil(text.range(of: "[가-힣]", options: .regularExpression),
                                 "\(lang.rawValue) 에 한글이 섞임: \(text)")
                }
            }
        }
    }
}
