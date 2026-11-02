//
//  MaturityFeatureTests.swift
//  Goldweek
//
//  2.4.1 에 더한 것 — 내 혜택 셈 · 새로운 기능을 누구에게 띄우나 · 새 문구 23개 언어.
//  수익화 — 무료 한도 미리 알림 · 응원(팁) 부탁 순간 · 선물 · 팁 상품이 Pro 를 열지 않는가.
//

import Foundation
import XCTest
import LeeoKit
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

    /// 패밀리를 프로에 합쳐 맨 위는 프로다.
    func testNextTierStopsAtPro() {
        XCTAssertEqual(ProBenefits.nextTier(after: .free), .plus)
        XCTAssertEqual(ProBenefits.nextTier(after: .plus), .pro)
        XCTAssertNil(ProBenefits.nextTier(after: .pro))
    }

    /// 위 등급에서 더 열리는 것은 페이월 비교표에서 가져온다 — 요약 줄을 빼도 비어 있으면 안 된다.
    /// 무료 칸도 지금 무료로 되는 것을 적는다.
    func testUpgradeListComesFromPaywallTable() {
        for tier in PaywallView.ladder {
            XCTAssertFalse(PaywallView.features(of: tier).filter { !$0.isSummary }.isEmpty, "\(tier)")
        }
    }

    // MARK: - 첫 화면 추천

    /// 첫 화면 추천은 앞으로의 날짜이고, 연차가 들고, 넣으면 쉬는 날이 아니라 일하는 날만 기록된다.
    func testFirstPlanIsUpcomingAndAddable() throws {
        let profile = UserProfile(name: "", yearStartMonth: 1, totalAnnualLeave: 15)
        profile.country = .korea
        let today = Calendar.app.startOfDay(for: Date())
        let plan = try XCTUnwrap(RecommendationEngine().nextHolidayPlan(for: profile, remainingLeave: 15, from: today))
        XCTAssertGreaterThanOrEqual(plan.startDate, today)
        XCTAssertGreaterThan(plan.requiredLeaveDays, 0)
        let records = plan.plannedRecords(country: .korea)
        XCTAssertFalse(records.isEmpty)
        XCTAssertTrue(records.allSatisfy { $0.status == .planned && $0.isRecommended })
    }

    /// 쓸 연차가 없으면 추천하지 않는다 — 첫 화면은 기존 빈 상태로 돌아간다.
    func testNoFirstPlanWithoutLeave() {
        let profile = UserProfile(name: "", yearStartMonth: 1, totalAnnualLeave: 0)
        profile.country = .korea
        XCTAssertNil(RecommendationEngine().nextHolidayPlan(for: profile, remainingLeave: 0))
    }

    // MARK: - 세 칸 권한 (무료 · 플러스 · 프로, 2.4.2)

    private func resolve(_ ids: [String], gifted: Bool = false, pass: Bool = false) -> ProManager.Entitlement {
        ProManager.resolve(owned: ids.map { (productID: $0, expires: nil) }, gifted: gifted, passActive: pass)
    }

    /// 새 상품: 플러스 평생 · 올리기 · 졸업. 연 구독은 같은 칸의 평생과 같은 권한이다.
    func testNewProductsOpenTheirTier() {
        XCTAssertEqual(resolve([ProManager.plusLifetimeProductID]).tier, .plus)
        XCTAssertEqual(resolve([ProManager.plusLifetimeProductID]).plan, .lifetime)
        XCTAssertEqual(resolve([ProManager.plusProductID]).tier, .plus)
        XCTAssertEqual(resolve([ProManager.plusProductID]).plan, .yearly(expires: nil))
        XCTAssertEqual(resolve([ProManager.yearlyProductID]).tier, .pro)
        XCTAssertEqual(resolve([ProManager.yearlyProductID]).plan, .yearly(expires: nil))
        XCTAssertEqual(resolve([ProManager.proProductID]).plan, .lifetime)
    }

    /// 졸업 상품 = 프로 평생. 구독이 아직 살아 있어도 평생이 앞선다.
    func testGraduateIsProLifetime() {
        let r = resolve([ProManager.yearlyProductID, ProManager.proGraduateProductID])
        XCTAssertEqual(r.tier, .pro)
        XCTAssertEqual(r.plan, .lifetime)
        XCTAssertTrue(r.ownsProLifetime)
        XCTAssertTrue(r.purchasedProTier)
    }

    /// 올리기 = 플러스 평생에서 프로 평생. 플러스 평생을 산 사람에게 프로 평생 버튼은 올리기 상품을 판다.
    func testUpgradeFromPlusLifetime() {
        let plusOnly = resolve([ProManager.plusLifetimeProductID])
        XCTAssertTrue(plusOnly.ownsPlusLifetime)
        XCTAssertFalse(plusOnly.ownsProLifetime)
        XCTAssertEqual(ProManager.lifetimeID(for: .pro, ownsPlusLifetime: true), ProManager.proUpgradeProductID)
        XCTAssertEqual(ProManager.lifetimeID(for: .pro, ownsPlusLifetime: false), ProManager.proProductID)
        XCTAssertEqual(ProManager.lifetimeID(for: .plus, ownsPlusLifetime: true), ProManager.plusLifetimeProductID)
        XCTAssertEqual(ProManager.yearlyID(for: .plus), ProManager.plusProductID)
        XCTAssertEqual(ProManager.yearlyID(for: .pro), ProManager.yearlyProductID)

        let upgraded = resolve([ProManager.plusLifetimeProductID, ProManager.proUpgradeProductID])
        XCTAssertEqual(upgraded.tier, .pro)
        XCTAssertEqual(upgraded.plan, .lifetime)
        XCTAssertTrue(upgraded.ownsProLifetime)
    }

    /// 예전 상품은 판매를 멈춰도 권한이 그대로다. 패밀리 구독자는 끝날 때까지 프로와 같다.
    func testLegacyProductsKeepAccess() {
        let expires = day(2027, 3, 1)
        let family = ProManager.resolve(owned: [(productID: ProManager.familyProductID, expires: expires)],
                                        gifted: false, passActive: false)
        XCTAssertEqual(family.tier, .pro)
        XCTAssertEqual(family.plan, .yearly(expires: expires))
        XCTAssertFalse(ProManager.saleProductIDs.contains(ProManager.familyProductID))
        XCTAssertTrue(ProManager.allProductIDs.contains(ProManager.familyProductID))
        // 2.4.0 전 평생 구매자
        XCTAssertEqual(resolve([ProManager.proProductID]).tier, .pro)
        // 2.4.0 전 설치자(빌드 11 이하)는 새로 유료가 된 기능을 계속 무료로 쓴다
        XCTAssertTrue(ProManager.isLegacyBuild("11"))
    }

    /// 선물은 프로 평생과 같고, 언제나 평생 패스는 이 앱의 가장 높은 칸(프로)을 연다. 둘 다 산 것은 아니다.
    func testGiftAndForeverPassOpenPro() {
        for r in [resolve([], gifted: true), resolve([], pass: true), resolve([ProManager.plusProductID], pass: true)] {
            XCTAssertEqual(r.tier, .pro)
            XCTAssertEqual(r.plan, .lifetime)
            XCTAssertFalse(r.purchasedProTier)
        }
        // 이미 산 프로 구독은 그대로 둔다(구독 관리 줄이 사라지지 않게)
        XCTAssertEqual(resolve([ProManager.yearlyProductID], pass: true).plan, .yearly(expires: nil))
        XCTAssertEqual(resolve([]).tier, .free)
        XCTAssertNil(resolve([]).plan)
    }

    /// 패스 상품은 앱의 권한 목록에 넣지 않는다. 패스가 따로 판정한다.
    func testForeverPassProductsAreNotEntitlements() {
        for id in LeeoForeverPassRule.productIDs(bundleID: "com.Ysoup.LeaveWise") {
            XCTAssertEqual(ProManager.tier(of: id), .free, id)
            XCTAssertFalse(ProManager.allProductIDs.contains(id), id)
        }
        XCTAssertTrue(LeeoForeverPassRule.family.contains("com.Ysoup.LeaveWise"))
    }

    /// 졸업은 자동 갱신 구독에게만 제안한다. 평생 상품은 대상이 아니다.
    func testGraduationTargetsSubscriptionsOnly() {
        XCTAssertEqual(ProManager.subscriptionProductIDs,
                       [ProManager.plusProductID, ProManager.yearlyProductID, ProManager.familyProductID])
        for id in [ProManager.proProductID, ProManager.plusLifetimeProductID, ProManager.proUpgradeProductID,
                   ProManager.proGraduateProductID] {
            XCTAssertTrue(ProManager.isLifetime(id), id)
        }
        for id in ProManager.subscriptionProductIDs {
            XCTAssertFalse(ProManager.isLifetime(id), id)
        }
        XCTAssertFalse(ProManager.isLifetime(ProManager.giftProductID))
    }

    /// 주 · 월 구독은 칸을 열지만 평생이 아니고, 졸업가 대상도 아니다.
    func testShortTermPlans() {
        for id in ProManager.shortTermProductIDs {
            XCTAssertFalse(ProManager.isLifetime(id), id)
            XCTAssertFalse(ProManager.subscriptionProductIDs.contains(id), id)
        }
        XCTAssertEqual(ProManager.tier(of: ProManager.plusWeeklyProductID), .plus)
        XCTAssertEqual(ProManager.tier(of: ProManager.proMonthlyProductID), .pro)
        XCTAssertEqual(resolve([ProManager.proWeeklyProductID]).plan, .shortTerm(expires: nil))
        XCTAssertEqual(resolve([ProManager.proWeeklyProductID, ProManager.proProductID]).plan, .lifetime)
    }

    // MARK: - 무료 한도 (freeGate)

    /// 추천 목록 앞 3칸이 무료 — 마지막 칸에 닿기 전에 미리 알리고, 넷째 칸에서 페이월.
    func testRecommendationGateWarnsBeforeTheWall() {
        XCTAssertEqual(RecommendationGate.decision(used: 0, hasPro: false), .allowed)
        XCTAssertEqual(RecommendationGate.decision(used: 1, hasPro: false), .allowedNearLimit(remaining: 1))
        XCTAssertEqual(RecommendationGate.decision(used: 2, hasPro: false), .allowedNearLimit(remaining: 0))
        XCTAssertTrue(RecommendationGate.decision(used: 3, hasPro: false).needsPaywall)
        XCTAssertTrue(RecommendationGate.decision(used: 9, hasPro: false).needsPaywall)
        XCTAssertEqual(RecommendationGate.decision(used: 9, hasPro: true), .allowed)
    }

    /// 게이트 정책의 한도는 '내 혜택' 이 비교하는 무료 한도와 같은 값이다.
    func testGatePolicyUsesTheSameFreeLimit() {
        XCTAssertEqual(RecommendationGate.policy.freeLimits[RecommendationGate.key], ProManager.freeRecommendationAddLimit)
        XCTAssertTrue(RecommendationGate.policy.hasAnyGate)
    }

    // MARK: - 선물 · 팁

    /// 선물 · 팁 상품이 Pro 를 열면 작은 결제가 평생 Pro 가 된다(되돌릴 수 없다).
    func testGiftAndTipsNeverUnlockPro() throws {
        let paywall = try XCTUnwrap(GoldweekSpec.paywall)
        let gift = try XCTUnwrap(paywall.gift)
        let tips = try XCTUnwrap(paywall.tipJar)
        XCTAssertEqual(gift.productID, ProManager.giftProductID)
        XCTAssertEqual(tips.productIDs, ProManager.tipProductIDs)
        for id in [gift.productID] + tips.productIDs {
            XCTAssertFalse(paywall.productIDs.contains(id), id)
            XCTAssertFalse(paywall.entitlementIDs.contains(id), id)
            XCTAssertEqual(ProManager.tier(of: id), .free, id)
        }
        // 받은 선물은 평생 Pro 를 산 것과 같다
        XCTAssertEqual(gift.grantsProductID, ProManager.proProductID)
        XCTAssertTrue(paywall.entitlementIDs.contains(gift.grantsProductID))
        XCTAssertEqual(gift.containerIdentifier, "iCloud.com.Ysoup.FeedbackHub")
        // 기존 상품 ID 는 그대로다. 패밀리는 팔지 않지만 권한 목록에는 남는다.
        XCTAssertEqual(paywall.productIDs, ["com.Ysoup.LeaveWise.plus.annual", "com.Ysoup.LeaveWise.plus",
                                            "com.Ysoup.LeaveWise.pro.yearly", "com.Ysoup.LeaveWise.pro",
                                            "com.Ysoup.LeaveWise.pro.upgrade", "com.Ysoup.LeaveWise.pro.graduate",
                                            "com.Ysoup.LeaveWise.plus.monthly", "com.Ysoup.LeaveWise.plus.weekly",
                                            "com.Ysoup.LeaveWise.pro.monthly", "com.Ysoup.LeaveWise.pro.weekly"])
        XCTAssertEqual(paywall.entitlementIDs, Set(paywall.productIDs + ["com.Ysoup.LeaveWise.family.yearly"]))
    }

    /// LeeoKit 사전 점검이 수익화 구성에서 잡는 것이 없다(선물이 아무것도 안 엶 · 팁이 Pro 를 엶 · 길 없는 페이월).
    func testPreflightFindsNoMonetizationError() {
        let codes = LeeoPreflight.audit(GoldweekSpec.self).filter { $0.severity == .error }.map(\.code)
        XCTAssertTrue(codes.filter { $0.hasPrefix("gift.") || $0.hasPrefix("tip.") || $0.hasPrefix("gate.") }.isEmpty, "\(codes)")
    }

    /// 부탁할 순간 — 넘어선 것만, 인상적인 것부터(추천으로 세운 계획이 앞).
    func testTipAskMomentsComeBiggestFirst() {
        XCTAssertTrue(TipAskMoments.reached(planCount: 2, leaveCount: 29, year: 2026).isEmpty)
        let ids = TipAskMoments.reached(planCount: 6, leaveCount: 40, year: 2026).map(\.id)
        XCTAssertEqual(ids, ["plans.2026.5", "plans.2026.3", "leaves.30"])
    }

    /// 순간 이름은 기기에 "이미 물었다" 로 남는다 — 해가 바뀌면 계획 수는 새로 센다.
    func testTipAskPlanMomentsAreScopedToYear() {
        let a = Set(TipAskMoments.reached(planCount: 3, leaveCount: 0, year: 2026).map(\.id))
        let b = Set(TipAskMoments.reached(planCount: 3, leaveCount: 0, year: 2027).map(\.id))
        XCTAssertTrue(a.isDisjoint(with: b))
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

    // MARK: - 처음 쓰는 사람의 화면

    private func nextFeature(_ unlocked: Set<SurfaceFeature> = [], records: Int = 0, upcoming: Int = 0,
                             otherKind: Bool = false, lastUnlock: Date? = nil) -> SurfaceFeature? {
        SurfaceFeature.next(unlocked: unlocked,
                            facts: SurfaceFacts(recordCount: records, upcomingCount: upcoming, usesOtherKind: otherKind),
                            lastUnlock: lastUnlock, now: day(2026, 11, 2), calendar: cal)
    }

    /// 필요해진 순간에만, 차례대로 하나씩 연다
    func testSurfaceOpensOneFeatureWhenItsMomentComes() {
        XCTAssertNil(nextFeature(records: 1))
        XCTAssertEqual(nextFeature(records: 2), .photoImport)
        XCTAssertEqual(nextFeature(records: 1, upcoming: 1), .sharePlan)
        XCTAssertEqual(nextFeature([.photoImport], records: 3), .restPace)
        XCTAssertEqual(nextFeature(records: 1, otherKind: true), .leaveKinds)
        XCTAssertEqual(nextFeature([.sharePlan], records: 1, upcoming: 2), .longView)
        let allButLast = Set(SurfaceFeature.allCases).subtracting([.everything])
        XCTAssertNil(nextFeature(allButLast, records: 7))
        XCTAssertEqual(nextFeature(allButLast, records: 8), .everything)
        XCTAssertNil(nextFeature(Set(SurfaceFeature.allCases), records: 99, upcoming: 9, otherKind: true))
    }

    /// 조건이 한꺼번에 맞아도 하루에 하나만
    func testSurfaceOpensAtMostOneFeatureADay() {
        XCTAssertNil(nextFeature(records: 9, upcoming: 3, otherKind: true, lastUnlock: day(2026, 11, 2)))
        XCTAssertEqual(nextFeature(records: 9, upcoming: 3, otherKind: true, lastUnlock: day(2026, 11, 1)), .photoImport)
    }

    func testSimpleSurfaceStringsCoverEveryLanguage() {
        let saved = LanguageManager.shared.currentLanguage
        defer { LanguageManager.shared.currentLanguage = saved }
        for lang in AppLanguage.allCases {
            LanguageManager.shared.currentLanguage = lang
            let texts = [Strings.showAllFeatures, Strings.showAllFeaturesFooter, Strings.surfaceUnlockHeader]
                + SurfaceFeature.allCases.flatMap { [Strings.surfaceFeatureTitle($0), Strings.surfaceFeatureDetail($0)] }
            for text in texts {
                XCTAssertFalse(text.isEmpty, lang.rawValue)
                if lang != .korean {
                    XCTAssertNil(text.range(of: "[가-힣]", options: .regularExpression), "\(lang.rawValue): \(text)")
                }
            }
        }
    }

    // MARK: - 보조 달력

    /// 각 달력의 새해·첫날로 알려진 양력 날짜 — 칸에는 1일이 나와야 한다
    func testSecondaryCalendarDays() {
        XCTAssertEqual(SecondaryCalendar.chinese.dayText(for: day(2026, 2, 17)), "1")   // 설날
        XCTAssertEqual(SecondaryCalendar.islamic.dayText(for: day(2026, 2, 18)), "1")   // 라마단 1일 (움알쿠라)
        XCTAssertEqual(SecondaryCalendar.hebrew.dayText(for: day(2026, 9, 12)), "1")    // 로시 하샤나
        XCTAssertEqual(SecondaryCalendar.persian.dayText(for: day(2026, 3, 21)), "1")   // 노루즈
        XCTAssertEqual(SecondaryCalendar.indian.dayText(for: day(2026, 3, 22)), "1")    // 차이트라 1일
        // 불기는 양력과 숫자가 같아 칸에 쓰지 않고, 카드에서 연도로 보여 준다
        XCTAssertNil(SecondaryCalendar.buddhist.dayText(for: day(2026, 2, 17)))

        let saved = LanguageManager.shared.currentLanguage
        defer { LanguageManager.shared.currentLanguage = saved }
        LanguageManager.shared.currentLanguage = .english
        XCTAssertTrue(SecondaryCalendar.buddhist.cardText(for: day(2026, 2, 17)).contains("2569"))
        XCTAssertTrue(SecondaryCalendar.hebrew.cardText(for: day(2026, 9, 12)).contains("5787"))
        XCTAssertEqual(SecondaryCalendar.chinese.cardText(for: day(2026, 2, 17)), "Lunar 1/1")
    }

    /// 고르지 않은 값(빈 문자열)은 보조 달력이 아니고, 모든 달력이 모든 언어에서 글로 나온다
    func testSecondaryCalendarCoversEveryLanguage() {
        XCTAssertNil(SecondaryCalendar(rawValue: ""))
        let saved = LanguageManager.shared.currentLanguage
        defer { LanguageManager.shared.currentLanguage = saved }
        for lang in AppLanguage.allCases {
            LanguageManager.shared.currentLanguage = lang
            let names = SecondaryCalendar.allCases.map(Strings.secondaryCalendarName)
            XCTAssertEqual(Set(names).count, SecondaryCalendar.allCases.count, lang.rawValue)
            for text in names + [Strings.secondaryCalendarTitle, Strings.secondaryCalendarNone, Strings.secondaryCalendarFooter] {
                XCTAssertFalse(text.isEmpty, lang.rawValue)
                if lang != .korean {
                    XCTAssertNil(text.range(of: "[가-힣]", options: .regularExpression), "\(lang.rawValue): \(text)")
                }
            }
            for calendar in SecondaryCalendar.allCases {
                XCTAssertFalse(calendar.cardText(for: day(2026, 11, 1)).isEmpty, lang.rawValue)
            }
        }
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
                Strings.benefitsBeyondFree(2), Strings.benefitsUnlockedHeader(.pro),
                Strings.benefitsFamilyMembers, Strings.benefitsMoreHeader(.pro), Strings.benefitsExplore(.plus),
                Strings.benefitsSeeAll, Strings.benefitsRowHint, Strings.a11yLeaveDeleted,
                Strings.a11yRecommendationAdded("X"),
                Strings.freeRecommendationNotice(remaining: 1), Strings.freeRecommendationNotice(remaining: 2),
                Strings.lifetimeDealNotice("X"), Strings.proLifetimeFamilySharing,
                Strings.homeOfferUpcoming, Strings.homeOfferHolidays, Strings.homeOfferYes, Strings.homeOfferNo,
                Strings.homeGotIt, Strings.homePaceAlways, Strings.homePaceAlwaysDescription, Strings.homeMoreActions,
                Strings.paceWarnSlow(year: 80, used: 30), Strings.paceWarnFast(year: 20, used: 60),
                Strings.compareTitle, Strings.compareRecommendations, Strings.compareUnlimited,
                Strings.shortPlansTitle, Strings.shortPlanWeekly("X"), Strings.shortPlanMonthly("X"),
                Strings.shortPlansDisclosure,
                Strings.tipAskPlans(5), Strings.tipAskLeaves(30), Strings.giftAndTipSection,
                Strings.tipEntry, Strings.tipEntrySubtitle, Strings.giftSendEntry, Strings.giftRedeemEntry,
                // 세 칸 페이월 (2.4.2)
                Strings.trimName(.free), Strings.trimName(.plus), Strings.trimName(.pro),
                Strings.trimTagline(.free), Strings.trimTagline(.plus), Strings.trimTagline(.pro),
                Strings.paywallLadderTitle, Strings.paywallLadderSubtitle, Strings.freeFeatTracking,
                Strings.freeFeatHolidays, Strings.freeFeatRecommendations(3), Strings.freeFeatRest,
                Strings.freeFeatBackupShare, Strings.switchToLifetimeEntry, Strings.togetherLocked, Strings.trimIncluded,
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
