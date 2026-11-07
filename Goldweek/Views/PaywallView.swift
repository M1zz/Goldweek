//
//  PaywallView.swift
//  Goldweek
//
//  **요금제 페이월.** 그림으로 판다(LeeoKit `LeeoShowcasePaywall`, 2026-11 개편). 클립키보드와 같은 틀:
//
//    플러스 | 프로      칸 고르기. 머리말(앱 이름 · 미사여구)은 두지 않는다
//    기능 그림          옆으로 넘긴다. 그 기능이 적용된 화면을 SwiftUI 로 줄여 그린다(PaywallShowcaseArt)
//    월간 · 연간 · 평생  첫 화면에 다 들어온다. 줄마다 실제로 내는 값과 기간, 연간에는 "N% 절약"
//    ─── 스크롤해야 보임 ───
//    갱신 조건 · 복원 · 코드 · 약관 · 비교표
//    ═══ 늘 떠 있음 ═══
//    구매 단추         고른 칸 · 고른 길 그대로
//
//  예전에는 무료 · 플러스 · 프로 카드 세 장에 카드마다 길 고르기와 구매 단추가 따로 있었다.
//  고를 것은 한 번에 하나, 가격은 숨기지 않고, 구매 단추는 하나.
//  주간 구독은 이 화면에서 팔지 않는다(구독 중인 사람의 권한은 그대로). 무엇을 왜 어느 칸에 두는지는 docs/MONETIZATION.md.
//
//  ⚠️ 무엇을 결제하는지는 `productID(_:)` 한 곳이 정한다. 화면에 적은 값과 결제하는 상품은 같다.
//

import SwiftUI
import StoreKit
import LeeoKit
import GoldweekCore

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var proManager = ProManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    /// 고른 칸
    @State private var tier: ProTier
    /// 칸마다 고른 길. 없으면 `initialTerm`.
    @State private var terms: [ProTier: Term] = [:]
    @State private var buying = false
    @State private var showsComparison = false
    /// 연간 첫 구독 할인을 받을 수 있는가(고른 칸의 연간 상품 기준)
    @State private var introEligible = false
    /// App Store 오퍼 코드 입력 시트 (StoreKit 2). 받은 코드는 `Transaction.updates` 로 들어와 칸이 열린다.
    @State private var showingOfferCode = false
    private let initialTerm: Term
    /// 설정에서 화면으로 넘어와 열렸다 — 내비게이션 · 닫기 단추는 바깥 것을 쓴다(클립키보드와 같다)
    private let embedded: Bool

    /// 월 · 연 · 평생. 위에서 아래로 놓는 순서.
    enum Term: CaseIterable { case monthly, yearly, lifetime }

    /// - Parameter initialProductID: 처음 고를 칸과 길을 정하는 상품 (기본: 프로 연간). 스크린샷 모드에서도 쓴다.
    init(initialProductID: String? = nil, embedded: Bool = false) {
        self.embedded = embedded
        let id = initialProductID ?? ScreenshotMode.paywallProductID ?? ProManager.yearlyProductID
        let tier = ProManager.tier(of: id)
        _tier = State(initialValue: tier == .free ? .pro : tier)
        initialTerm = ProManager.isLifetime(id) ? .lifetime
            : ProManager.shortTermProductIDs.contains(id) ? .monthly : .yearly
    }

    var body: some View {
        Group {
            if embedded {
                // 아래 고정 구매 막대 · 약관 줄을 탭 막대가 가리지 않게
                page.toolbar(.hidden, for: .tabBar)
            } else {
                NavigationView {
                    page
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(Strings.cancel) { dismiss() }
                                    .foregroundColor(.secondary)
                            }
                        }
                }
            }
        }
        .onAppear {
            UsageReportingService.record(event: "paywall_view")
            // 이미 가진 칸을 열었으면 그 위 칸으로
            if !purchasableTiers.contains(tier), let first = purchasableTiers.last { tier = first }
        }
        .task(id: product(.yearly)?.id) {
            introEligible = await product(.yearly)?.subscription?.isEligibleForIntroOffer ?? false
        }
        .offerCodeRedemption(isPresented: $showingOfferCode) { result in
            if case .success = result { Task { await proManager.checkEntitlement() } }
        }
        .alert(isSuccess ? Strings.purchaseSuccess : Strings.purchaseError, isPresented: $showingAlert) {
            Button(Strings.confirm) { if isSuccess { dismiss() } }
        } message: {
            Text(alertMessage)
        }
    }

    /// 그림으로 파는 틀(LeeoKit `LeeoShowcasePaywall`): 칸 고르기 · 기능 그림 · 요금이 첫 화면에, 구매 단추는 늘 떠 있다.
    /// 갱신 조건 · 복원 · 코드 · 약관 · 비교표는 스크롤한 아래에.
    private var page: some View {
        LeeoShowcasePaywall(showcases: pageShowcases) {
            if purchasableTiers.count > 1 { tierSwitch }
        } plans: {
            if purchasableTiers.contains(tier) {
                options
            } else {
                // 맨 위 칸을 쓰는 사람('내 혜택'의 전체 보기) — 파는 말 대신 "모두 열려 있어요"
                Text(Strings.benefitsAllUnlocked(.pro))
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
        } button: {
            if purchasableTiers.contains(tier) { buyButton }
        } details: {
            VStack(spacing: 18) {
                if purchasableTiers.contains(tier) {
                    if let renewal = renewalTerms(product(term)) {
                        Text(renewal)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    footerLinks
                }
                comparison
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// 넘겨 볼 장 — 고른 칸의 것. 다 가진 사람은 플러스 · 프로 모두.
    private var pageShowcases: [LeeoShowcase] {
        purchasableTiers.contains(tier) ? Self.showcases(of: tier) : Self.showcases(of: .plus) + Self.showcases(of: .pro)
    }

    /// 화면에 놓는 칸, 낮은 것부터 (비교표 · '내 혜택' 이 쓴다)
    static let ladder: [ProTier] = [.free, .plus, .pro]

    static func icon(of tier: ProTier) -> String {
        switch tier {
        case .free: return "leaf.fill"
        case .plus: return "sparkles"
        case .pro: return "crown.fill"
        }
    }

    /// 칸을 처음 보여 줄 때 고를 상품 (연간)
    static func defaultProductID(for tier: ProTier) -> String {
        ProManager.yearlyID(for: tier == .free ? .pro : tier)
    }

    // MARK: - 칸

    /// 살 수 있는 칸. 이미 가진 칸은 빠진다. 주간 · 월간 구독 중이면 같은 칸의 연간 · 평생으로 옮길 수 있다.
    private var purchasableTiers: [ProTier] {
        [ProTier.plus, .pro].filter { proManager.tier < $0 || (proManager.tier == $0 && isOnShortTermPlan) }
    }

    private var isOnShortTermPlan: Bool {
        if case .shortTerm = proManager.activePlan { return true }
        return false
    }

    private var tierSwitch: some View {
        HStack(spacing: 4) {
            ForEach(purchasableTiers, id: \.self) { t in
                let selected = t == tier
                Button {
                    HapticFeedback.selection()
                    withAnimation(.snappy(duration: 0.25)) { tier = t }
                } label: {
                    HStack(spacing: 6) {
                        Text(Strings.trimName(t)).fontWeight(.bold)
                        if t == .pro {
                            Text(Strings.trimPopular)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.accentColor.opacity(selected ? 0.18 : 0.12), in: Capsule())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .font(.body)
                    .foregroundStyle(selected ? Color.primary : Color.secondary)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background {
                        if selected {
                            Capsule().fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Color(.secondarySystemBackground), in: Capsule())
    }

    // MARK: - 혜택

    /// 등급 비교표의 한 줄. '내 혜택' 화면도 이 목록을 그대로 쓴다(목록은 여기 한 곳에만 적는다).
    struct TrimFeature: Hashable {
        let icon: String
        let color: Color
        let title: String
        var isSummary = false
    }

    /// 칸이 여는 기능. 위 칸은 맨 앞 요약 줄(`isSummary`)로 아래 칸을 모두 포함한다고 말한다.
    /// 무료 칸은 지금 무료로 되는 것을 적는다.
    static func features(of tier: ProTier) -> [TrimFeature] {
        switch tier {
        case .free:
            return [
                TrimFeature(icon: "calendar.badge.checkmark", color: AppTheme.Colors.brand, title: Strings.freeFeatTracking),
                TrimFeature(icon: "flag.fill", color: .red, title: Strings.freeFeatHolidays),
                TrimFeature(icon: "lightbulb", color: .orange, title: Strings.freeFeatRecommendations(ProManager.freeRecommendationAddLimit)),
                TrimFeature(icon: "bell.badge", color: .purple, title: Strings.freeFeatRest),
                TrimFeature(icon: "icloud", color: .blue, title: Strings.freeFeatBackupShare),
            ]
        case .plus:
            return [
                TrimFeature(icon: "sparkles", color: AppTheme.Colors.bonus, title: Strings.proFeatureAIAnnualPlanner),
                TrimFeature(icon: "lightbulb.fill", color: .orange, title: Strings.featUnlimitedRecs),
                TrimFeature(icon: "calendar", color: .purple, title: Strings.featOtherYears),
                TrimFeature(icon: "calendar.badge.plus", color: .green, title: Strings.calendarExportToggle),
            ]
        case .pro:
            return [
                TrimFeature(icon: "checkmark.seal.fill", color: .accentColor, title: Strings.trimEverythingIn(Strings.trimName(.plus)), isSummary: true),
                TrimFeature(icon: "gift.fill", color: .pink, title: Strings.bonusLeaveManagement),
                TrimFeature(icon: "gauge.with.needle", color: .teal, title: Strings.paywallAllowanceFeature),
                TrimFeature(icon: "doc.viewfinder", color: .indigo, title: Strings.schoolImportTitle),
                TrimFeature(icon: "calendar.badge.clock", color: .blue, title: Strings.autoDetectSettingTitle),
                TrimFeature(icon: "person.2.fill", color: .pink, title: Strings.togetherTitle),
                TrimFeature(icon: "heart.fill", color: .red, title: Strings.familyAnniversariesTitle),
            ]
        }
    }

    // MARK: - 길

    /// 이 칸 · 이 길로 결제하는 상품. 플러스 평생을 가진 사람에게 프로 평생은 올리기 상품이다.
    private func productID(_ term: Term) -> String {
        switch term {
        case .monthly: return tier == .plus ? ProManager.plusMonthlyProductID : ProManager.proMonthlyProductID
        case .yearly: return ProManager.yearlyID(for: tier)
        case .lifetime: return ProManager.lifetimeID(for: tier, ownsPlusLifetime: proManager.ownsPlusLifetime)
        }
    }

    private func product(_ term: Term) -> Product? { proManager.product(productID(term)) }

    /// 줄로 세우는 길. 상품이 안 온 길은 빠진다(App Store Connect 에 아직 없음).
    /// 월간 구독 중이면 월간은 빼고 연간 · 평생만 — 같은 것을 다시 살 수는 없다.
    private var availableTerms: [Term] {
        Term.allCases.filter { t in
            product(t) != nil && !(t == .monthly && proManager.tier == tier && isOnShortTermPlan)
        }
    }

    /// 고른 길. 고른 길의 상품이 없으면 연간 → 평생 → 월간 순으로 있는 것.
    private var term: Term {
        let chosen = terms[tier] ?? initialTerm
        if availableTerms.contains(chosen) { return chosen }
        return [Term.yearly, .lifetime, .monthly].first(where: availableTerms.contains) ?? chosen
    }

    @ViewBuilder
    private var options: some View {
        if availableTerms.isEmpty {
            priceStatus
        } else {
            // 연간 줄의 할인 배지가 줄 위로 올라오므로 간격과 위 여백을 둔다
            VStack(spacing: 14) {
                ForEach(availableTerms, id: \.self) { optionRow($0) }
                // 평생 가격이 오르기 전까지만 서는 한 줄
                if term == .lifetime, LeeoLadderSchedule.showsLifetimeNotice() {
                    Label(Strings.lifetimeDealNotice(LeeoLadderSchedule.lifetimePriceChange.formatted(.dateTime.month(.wide).day())),
                          systemImage: "calendar.badge.clock")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 10)
        }
    }

    private func optionRow(_ t: Term) -> some View {
        let selected = t == term
        return Button {
            HapticFeedback.selection()
            terms[tier] = t
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? Color.accentColor : Color(.tertiaryLabel))
                    .voDecorative()
                VStack(alignment: .leading, spacing: 2) {
                    Text(title(t)).font(.body.weight(.semibold))
                    if let caption = caption(t) {
                        Text(caption)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price(t) ?? " ")
                        .font(.body.weight(.semibold))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                    // 할인이 붙은 연간이면 월간으로 열두 달 낼 값을 그어 보인다 — 얼마나 아끼는지 한눈에
                    if saving(t) != nil, let monthly = product(.monthly) {
                        Text((monthly.price * 12).formatted(monthly.priceFormatStyle))
                            .font(.footnote)
                            .strikethrough()
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .voDecorative()
                    }
                }
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(selected ? Color.accentColor : .clear, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if let percent = saving(t) { savingBadge(percent) }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func title(_ t: Term) -> String {
        switch t {
        case .monthly: return Strings.planMonthly
        case .yearly: return Strings.planYearly
        case .lifetime: return Strings.planLifetime
        }
    }

    /// 줄 오른쪽: 실제로 내는 값과 그 기간. 월 환산값을 크게 쓰지 않는다(청구 주기가 흐려진다).
    private func price(_ t: Term) -> String? {
        guard let item = product(t) else { return nil }
        switch t {
        case .monthly: return Strings.monthlyPriceLabel(item.displayPrice)
        case .yearly: return Strings.yearlyPriceLabel(item.displayPrice)
        case .lifetime: return item.displayPrice
        }
    }

    /// 줄 아래 작은 글. 연간은 첫 해 할인(받을 수 있는 사람만) 또는 한 달 값, 평생은 올리기 값이거나 연간 몇 해치.
    private func caption(_ t: Term) -> String? {
        switch t {
        case .monthly:
            return nil
        case .yearly:
            guard let yearly = product(.yearly) else { return nil }
            if introEligible, let offer = yearly.subscription?.introductoryOffer {
                if offer.paymentMode == .freeTrial, let days = proManager.trialDays(for: yearly.id) {
                    return Strings.startTrial(days)
                }
                if offer.paymentMode == .payUpFront || offer.paymentMode == .payAsYouGo {
                    return Strings.firstYearPrice(offer.displayPrice)
                }
            }
            return Strings.perMonthHint((yearly.price / 12).formatted(yearly.priceFormatStyle))
        case .lifetime:
            if productID(.lifetime) == ProManager.proUpgradeProductID {
                return Strings.upgradeLifetimeCaption(from: Strings.trimName(.plus), to: Strings.trimName(.pro))
            }
            guard let years = PaywallPricing.lifetimeYears(yearly: product(.yearly)?.price,
                                                           lifetime: product(.lifetime)?.price) else { return nil }
            return Strings.lifetimeWorth(years)
        }
    }

    /// 연간이 월간 열두 달보다 몇 % 싼가. 연간 줄에만, 5% 이상일 때만.
    private func saving(_ t: Term) -> Int? {
        guard t == .yearly else { return nil }
        return PaywallPricing.yearlySaving(monthly: product(.monthly)?.price, yearly: product(.yearly)?.price)
    }

    /// 연간 줄 모서리에 올라앉는 할인 배지 — 눈에 띄게(LeeoKit 3.37 페이월과 같은 모양)
    private func savingBadge(_ percent: Int) -> some View {
        Text(Strings.yearlySaving(percent))
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.accentColor, in: Capsule())
            .shadow(color: Color.accentColor.opacity(0.35), radius: 4, y: 2)
            .offset(x: -14, y: -14)
    }

    /// 가격 로드 실패/로딩 중. 빈칸 대신 상태를 보여준다
    private var priceStatus: some View {
        VStack(spacing: 10) {
            if proManager.productLoadFailed || proManager.hasAnyPrice {
                Label(Strings.priceLoadFailed, systemImage: "wifi.exclamationmark")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button(Strings.retry) { Task { await proManager.loadProducts() } }
                    .font(.body.weight(.semibold))
                    .buttonStyle(.bordered)
            } else {
                ProgressView().padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 비교표

    /// 비교표 한 칸: 있음 · 없음 · 글자
    private enum CompareCell { case yes, no, text(String) }

    private var compareRows: [(title: String, free: CompareCell, plus: CompareCell, pro: CompareCell)] {
        [
            (Strings.freeFeatTracking, .yes, .yes, .yes),
            (Strings.freeFeatHolidays, .yes, .yes, .yes),
            (Strings.compareRecommendations, .text("\(ProManager.freeRecommendationAddLimit)"),
             .text(Strings.compareUnlimited), .text(Strings.compareUnlimited)),
            (Strings.featOtherYears, .no, .yes, .yes),
            (Strings.proFeatureAIAnnualPlanner, .no, .yes, .yes),
            (Strings.calendarExportToggle, .no, .yes, .yes),
            ("\(Strings.bonusLeaveManagement) · \(Strings.paywallAllowanceFeature)", .no, .no, .yes),
            (Strings.schoolImportTitle, .no, .no, .yes),
            (Strings.autoDetectSettingTitle, .no, .no, .yes),
            ("\(Strings.togetherTitle) · \(Strings.familyAnniversariesTitle)", .no, .no, .yes),
            (Strings.freeFeatRest, .yes, .yes, .yes),
            (Strings.freeFeatBackupShare, .yes, .yes, .yes),
        ]
    }

    private var comparison: some View {
        DisclosureGroup(isExpanded: $showsComparison) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(compareRows.enumerated()), id: \.offset) { _, row in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(row.title)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 8) {
                            compareValue(.free, row.free)
                            compareValue(.plus, row.plus)
                            compareValue(.pro, row.pro)
                        }
                    }
                    .padding(.vertical, 10)
                    .accessibilityElement(children: .combine)
                    Divider()
                }
            }
            .padding(.top, 8)
        } label: {
            Text(Strings.compareTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .tint(.secondary)
    }

    /// 칸 이름과 값을 함께 적는다. 좁은 칸에 세 열로 맞추지 않아 큰 글자와 긴 번역에서도 잘리지 않는다.
    private func compareValue(_ tier: ProTier, _ cell: CompareCell) -> some View {
        VStack(spacing: 2) {
            Text(Strings.trimName(tier))
                .font(.body)
                .foregroundStyle(.secondary)
            switch cell {
            case .yes:
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.green)
                    .accessibilityLabel(Text(Strings.stateOn))
            case .no:
                Text(verbatim: "–")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(Text(Strings.stateOff))
            case .text(let value):
                Text(value)
                    .font(.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 아래 고정

    /// 늘 떠 있는 구매 단추 하나. 갱신 조건 · 약관은 스크롤한 아래에 있다.
    private var buyButton: some View {
        let item = product(term)
        return Button { purchase() } label: {
            Group {
                if buying {
                    ProgressView().tint(.white)
                } else {
                    Text(ctaTitle).fontWeight(.bold)
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(item == nil || proManager.isLoading ? Color.gray : Color.accentColor,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        // 상품을 못 읽었으면 누를 수 없다. 누른 뒤에 "상품 없음" 을 듣는 것보다 낫다.
        .disabled(buying || item == nil || proManager.isLoading)
        .accessibilityLabel(buying ? Strings.purchasing : ctaTitle)
    }

    private var ctaTitle: String {
        if term == .yearly, introEligible, let days = proManager.trialDays(for: productID(.yearly)) {
            return Strings.startTrial(days)
        }
        return Strings.startTrim(Strings.trimName(tier))
    }

    /// 고른 길의 갱신 조건(심사 기준 3.1.2). 평생은 갱신이 없다고 말한다.
    private func renewalTerms(_ item: Product?) -> String? {
        guard let item else { return nil }
        switch term {
        case .monthly: return Strings.renewalTerms(item.displayPrice, yearly: false)
        case .yearly: return Strings.renewalTerms(item.displayPrice, yearly: true)
        case .lifetime: return Strings.lifetimeOnceTerms
        }
    }

    /// 복원 · 오퍼 코드 · 약관 · 개인정보. 늘 같은 자리에 있다. 한 줄에 안 들어가면 두 줄로.
    private var footerLinks: some View {
        let store = HStack(spacing: 14) {
            Button(Strings.restorePurchase, action: restorePurchases)
                .disabled(proManager.isLoading)
            // 받은 오퍼 코드(할인 · 선물)를 앱 안에서 바로 쓴다
            Button(Strings.redeemOfferCode) {
                UsageReportingService.record(event: "offer_code_open:paywall")
                showingOfferCode = true
            }
        }
        let legal = HStack(spacing: 14) {
            Link(Strings.termsOfService, destination: Self.termsURL)
            Link(Strings.privacyPolicy, destination: GoldweekSpec.legal.privacyURL)
        }
        return ViewThatFits {
            HStack(spacing: 14) { store; legal }
            VStack(spacing: 6) { store; legal }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .buttonStyle(.plain)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    private static let termsURL = GoldweekSpec.legal.termsURL
        ?? URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    // MARK: - Actions

    private func purchase() {
        guard let product = product(term) else { return }
        let bought = tier
        buying = true
        Task {
            defer { buying = false }
            do {
                try await proManager.purchase(product.id)
                // 사용자가 취소한 경우 purchase()는 에러 없이 리턴되므로
                // 실제로 그 칸이 열렸을 때만 성공 알림을 띄운다
                guard proManager.tier >= bought else { return }
                UsageReportingService.record(event: "paywall_purchase:success")
                await MainActor.run {
                    isSuccess = true
                    alertMessage = Strings.youArePro
                    showingAlert = true
                }
            } catch {
                // 사용자 취소는 에러가 아니므로 알림을 띄우지 않는다
                if let skError = error as? StoreKitError, case .userCancelled = skError {
                    return
                }
                await MainActor.run {
                    isSuccess = false
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }

    private func restorePurchases() {
        Task {
            await proManager.restorePurchases()
            await MainActor.run {
                isSuccess = proManager.isPro
                alertMessage = proManager.isPro ? Strings.restoreSuccess : Strings.paywallNoPurchaseFound
                showingAlert = true
            }
        }
    }
}

// MARK: - 값 계산

enum PaywallPricing {
    /// 연간이 월간 열두 달보다 몇 % 싼가(내림). 5% 아래거나 모르면 nil — LeeoKit 페이월과 같은 기준. **순수 함수.**
    static func yearlySaving(monthly: Decimal?, yearly: Decimal?) -> Int? {
        guard let monthly, let yearly, monthly > 0 else { return nil }
        let ratio = NSDecimalNumber(decimal: yearly / (monthly * 12)).doubleValue
        let percent = Int(((1 - ratio) * 100).rounded(.down))
        return percent >= 5 ? percent : nil
    }

    /// 평생이 연간 몇 해치인가(내림). 두 해 아래면 nil. **순수 함수.**
    /// ⚠️ `NSDecimalNumber.intValue` 는 자릿수가 긴 몫에서 엉뚱한 값을 낸다. double 로 내린다.
    static func lifetimeYears(yearly: Decimal?, lifetime: Decimal?) -> Int? {
        guard let yearly, let lifetime, yearly > 0 else { return nil }
        let years = Int(NSDecimalNumber(decimal: lifetime / yearly).doubleValue.rounded(.down))
        return years >= 2 ? years : nil
    }
}

// MARK: - 구독 졸업

/// 구독 중인 사람에게 보이는 졸업가 화면(LeeoKit). 사면 칸을 다시 센다.
/// 졸업 상품은 앱이 뜬 뒤에 올 수 있어 이 화면이 직접 읽고, 없으면 불러온다.
struct GraduationSheet: View {
    private let proManager = ProManager.shared

    var body: some View {
        LeeoGraduationOfferView(graduate: proManager.graduateProduct) {
            UsageReportingService.record(event: "purchase_plan:graduate")
            await proManager.checkEntitlement()
        }
        .task {
            if proManager.graduateProduct == nil { await proManager.loadProducts() }
        }
    }
}

// MARK: - 요금제 고르기

/// 연간 구독 / 평생 구매 카드 두 장. 불러온 상품만 보인다
/// (App Store Connect에 연간 상품이 아직 없으면 평생 카드 하나만 남는다).
struct ProPlanPicker: View {
    @Binding var selectedID: String
    private let proManager = ProManager.shared

    var body: some View {
        VStack(spacing: 10) {
            if let yearly = proManager.yearlyProduct {
                card(id: yearly.id,
                     title: Strings.planYearly,
                     price: Strings.yearlyPriceLabel(yearly.displayPrice),
                     caption: Strings.perMonthHint(Self.monthlyPrice(of: yearly)))
            }
            if let lifetime = proManager.lifetimeProduct {
                card(id: lifetime.id,
                     title: Strings.planLifetime,
                     price: lifetime.displayPrice,
                     caption: Strings.oneTimePurchase)
            }
        }
        .onAppear(perform: fixSelection)
        .onChange(of: proManager.products.count) { _, _ in fixSelection() }
    }

    /// 고른 상품이 목록에 없으면(연간 상품 미등록 등) 있는 것으로 옮긴다
    private func fixSelection() {
        guard !proManager.products.contains(where: { $0.id == selectedID }),
              let first = proManager.products.first else { return }
        selectedID = first.id
    }

    private func card(id: String, title: String, price: String, caption: String) -> some View {
        let isSelected = selectedID == id
        return Button {
            selectedID = id
            HapticFeedback.selection()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.systemGray3))
                    .voDecorative()
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(caption)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Text(price)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? Color.accentColor : .primary)
                    .multilineTextAlignment(.trailing)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor.opacity(0.08) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// 연간 가격 ÷ 12 — 그 나라 통화 형식 그대로
    static func monthlyPrice(of product: Product) -> String {
        (product.price / 12).formatted(product.priceFormatStyle)
    }
}

// MARK: - Pro Banner Component

struct ProBannerView: View {
    /// 스마트 트리거 아이콘 (nil이면 crown 기본)
    var triggerIcon: String? = nil
    /// 스마트 트리거 메시지 (nil이면 기본 문구)
    var triggerMessage: String? = nil
    /// 배너가 화면에 표시될 때 호출 (쿨다운 타임스탬프 기록용)
    var onShow: (() -> Void)? = nil

    @State private var showingPaywall = false

    private var displayMessage: String {
        triggerMessage ?? Strings.proFeaturesBanner
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if let icon = triggerIcon {
                        Text(icon)
                            .font(.body)
                            .voDecorative()
                    } else {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.body)
                            .voDecorative()
                    }
                    Text(Strings.upgradeToPro)
                        .font(.body)
                        .fontWeight(.semibold)
                }

                Text(displayMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("\(Strings.upgradeToPro), \(displayMessage)"))

            Spacer()

            Button(action: {
                showingPaywall = true
            }) {
                Text(Strings.upgradeToPro)
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel(Text(Strings.upgradeToPro))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                )
        )
        .onAppear {
            onShow?()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}

#Preview("Pro Banner") {
    ProBannerView()
        .padding()
}
