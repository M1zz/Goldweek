//
//  PaywallView.swift
//  Goldweek
//
//  요금제 페이월 (다국어 지원). 무료 · 플러스 · 프로 세 칸을 위에서 아래로 놓고,
//  유료 칸마다 연 구독과 평생을 고른다(LeeoKit `LeeoTermPicker`). 칸 아래에 언제나 평생 패스 한 줄.
//  무엇을 왜 어느 칸에 두는지는 docs/MONETIZATION.md.
//

import SwiftUI
import StoreKit
import LeeoKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @State private var proManager = ProManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    /// 칸마다 고른 길 (연 구독 / 평생)
    @State private var terms: [ProTier: LeeoPlanTerm]
    /// 지금 결제 중인 칸
    @State private var buyingTier: ProTier?
    /// App Store 오퍼 코드 입력 시트 (StoreKit 2). 받은 코드는 `Transaction.updates` 로 들어와 Pro 가 열린다.
    @State private var showingOfferCode = false
    /// 처음 보여 줄 칸. 다른 화면이 칸을 정해 열었을 때만 그 칸으로 내려 준다.
    private let focusTier: ProTier
    private let scrollsToFocus: Bool

    /// - Parameter initialProductID: 처음 보여 줄 칸과 길을 정하는 상품 (기본: 프로 연 구독). 스크린샷 모드에서도 쓴다.
    init(initialProductID: String? = nil) {
        let id = initialProductID ?? ScreenshotMode.paywallProductID ?? ProManager.yearlyProductID
        let tier = ProManager.tier(of: id)
        focusTier = tier == .free ? .pro : tier
        scrollsToFocus = initialProductID != nil || ScreenshotMode.paywallProductID != nil
        let lifetime = ProManager.isLifetime(id)
        _terms = State(initialValue: [
            .plus: tier == .plus && lifetime ? .lifetime : .yearly,
            .pro: tier == .pro && lifetime ? .lifetime : .yearly,
        ])
    }

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        ForEach(Self.ladder, id: \.self) { tier in
                            tierCard(tier).id(tier)
                        }
                        // 언제나 평생 패스: 이 개발자의 모든 앱을 평생으로. 패스 상품은 LeeoKit 이 판다.
                        LeeoForeverPassLine(pass: ProExtras.shared.pass, ownsLifetimePro: proManager.ownsProLifetime)
                            .padding(.horizontal, 4)
                        // 평생 가격이 오르기 전까지만 서는 한 줄 (이미 산 사람은 그대로)
                        LeeoLifetimePriceNotice()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        storeActions
                        footerSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .onAppear {
                    UsageReportingService.record(event: "paywall_view")
                    guard scrollsToFocus else { return }
                    DispatchQueue.main.async { proxy.scrollTo(focusTier, anchor: .top) }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .alert(isSuccess ? Strings.purchaseSuccess : Strings.purchaseError,
               isPresented: $showingAlert) {
            Button(Strings.confirm) {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    /// 화면에 놓는 칸, 위에서 아래로
    static let ladder: [ProTier] = [.free, .plus, .pro]

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.yellow.opacity(0.15))
                    .frame(width: 84, height: 84)
                Image(systemName: Self.icon(of: .pro))
                    .font(.system(.largeTitle))
                    .foregroundStyle(.yellow)
                    .voDecorative()
            }
            .padding(.top, 4)

            // 맨 위 칸을 쓰는 사람에게는 파는 말 대신 "모두 열려 있어요". '내 혜택'의 전체 보기도 이 화면이다.
            Text(proManager.tier >= .pro ? Strings.benefitsAllUnlocked(.pro) : Strings.paywallLadderTitle)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if proManager.tier < .pro {
                Text(Strings.paywallLadderSubtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    static func icon(of tier: ProTier) -> String {
        switch tier {
        case .free: return "leaf.fill"
        case .plus: return "sparkles"
        case .pro: return "crown.fill"
        }
    }

    /// 칸을 처음 보여 줄 때 고를 상품 (연 구독)
    static func defaultProductID(for tier: ProTier) -> String {
        ProManager.yearlyID(for: tier == .free ? .pro : tier)
    }

    // MARK: - 칸 카드

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

    private func tierCard(_ tier: ProTier) -> some View {
        VStack(spacing: 0) {
            cardHeader(tier)
            Divider()
            ForEach(Array(Self.features(of: tier).enumerated()), id: \.element) { index, feature in
                if index > 0 { Divider().padding(.leading, 54) }
                featureRow(feature)
            }
            // 무료 칸은 버튼이 없다. 지금 무료로 되는 것을 적는 카드다.
            if tier != .free {
                Divider()
                buySection(tier)
                    .padding(14)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(tier == .pro ? Color.accentColor : Color(.systemGray5), lineWidth: tier == .pro ? 2 : 1)
        )
    }

    private func cardHeader(_ tier: ProTier) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: Self.icon(of: tier))
                .font(.title3)
                .foregroundStyle(tier == .free ? Color.green : Color.yellow)
                .frame(width: 30)
                .voDecorative()
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.trimName(tier))
                    .font(.title3.weight(.bold))
                Text(Strings.trimTagline(tier))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if proManager.tier == tier {
                badge(Strings.planActive, color: .green)
            } else if tier == .pro {
                badge(Strings.trimPopular, color: .accentColor)
            }
        }
        .padding(14)
        .accessibilityElement(children: .combine)
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
            .lineLimit(1)
    }

    private func featureRow(_ feature: TrimFeature) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: feature.icon)
                    .font(.system(.body))
                    .foregroundColor(feature.color)
                    .voDecorative()
            }
            Text(feature.title)
                .font(.body)
                .fontWeight(feature.isSummary ? .semibold : .regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            Image(systemName: "checkmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(.green)
                .voDecorative()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .accessibilityElement(children: .combine)
    }

    // MARK: - 사기

    /// 칸의 연 구독 상품 (불러온 것만)
    private func yearlyProduct(_ tier: ProTier) -> Product? {
        proManager.product(ProManager.yearlyID(for: tier))
    }

    /// 칸의 평생 상품. 플러스 평생을 산 사람에게 프로 평생은 올리기 상품이다.
    private func lifetimeProduct(_ tier: ProTier) -> Product? {
        proManager.product(ProManager.lifetimeID(for: tier, ownsPlusLifetime: proManager.ownsPlusLifetime))
    }

    /// 고른 길. 고른 쪽 상품이 없으면(App Store Connect 에 아직 없음) 있는 쪽으로 옮긴다.
    private func term(_ tier: ProTier) -> LeeoPlanTerm {
        let chosen = terms[tier] ?? .yearly
        switch chosen {
        case .yearly: return yearlyProduct(tier) == nil && lifetimeProduct(tier) != nil ? .lifetime : .yearly
        case .lifetime: return lifetimeProduct(tier) == nil && yearlyProduct(tier) != nil ? .yearly : .lifetime
        }
    }

    private func termBinding(_ tier: ProTier) -> Binding<LeeoPlanTerm> {
        Binding(get: { term(tier) }, set: { terms[tier] = $0; HapticFeedback.selection() })
    }

    private func selectedProduct(_ tier: ProTier) -> Product? {
        term(tier) == .yearly ? yearlyProduct(tier) : lifetimeProduct(tier)
    }

    @ViewBuilder
    private func buySection(_ tier: ProTier) -> some View {
        if proManager.tier >= tier {
            // 이미 이 칸 이상. 구매 버튼 대신 상태를 분명히 보여 준다
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .voDecorative()
                Text(Strings.trimIncluded)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.green.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if yearlyProduct(tier) == nil && lifetimeProduct(tier) == nil {
            priceStatus
        } else {
            VStack(spacing: 12) {
                LeeoTermPicker(term: termBinding(tier), yearly: yearlyProduct(tier), lifetime: lifetimeProduct(tier))
                purchaseButton(tier)
            }
        }
    }

    /// 가격 로드 실패/로딩 중. 빈칸 대신 상태를 보여준다
    private var priceStatus: some View {
        VStack(spacing: 10) {
            if proManager.productLoadFailed || proManager.hasAnyPrice {
                HStack(spacing: 6) {
                    Image(systemName: "wifi.exclamationmark")
                        .foregroundColor(.orange)
                        .voDecorative()
                    Text(Strings.priceLoadFailed)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button {
                    Task { await proManager.loadProducts() }
                } label: {
                    Text(Strings.retry)
                        .font(.body.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor)
                        .clipShape(Capsule())
                }
            } else {
                ProgressView()
                    .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private func purchaseTitle(_ tier: ProTier) -> String {
        if term(tier) == .yearly, let days = proManager.trialDays(for: ProManager.yearlyID(for: tier)) {
            return Strings.startTrial(days)
        }
        return Strings.startTrim(Strings.trimName(tier))
    }

    private func purchaseButton(_ tier: ProTier) -> some View {
        let buying = buyingTier == tier
        return Button { purchase(tier) } label: {
            HStack(spacing: 8) {
                if buying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: Self.icon(of: tier))
                }
                Text(buying ? Strings.purchasing : purchaseTitle(tier))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .background(proManager.isLoading || selectedProduct(tier) == nil ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        // 가격을 확인할 수 없는 상태에서는 구매를 막는다
        .disabled(proManager.isLoading || selectedProduct(tier) == nil)
    }

    /// 복원 · 오퍼 코드. 칸마다가 아니라 한 번만 둔다.
    private var storeActions: some View {
        VStack(spacing: 4) {
            Button(action: restorePurchases) {
                Text(Strings.restorePurchase)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .frame(minHeight: 44)
            }
            .disabled(proManager.isLoading)

            // 받은 오퍼 코드(할인·무료 기간)를 앱 안에서 바로 쓴다. App Store 앱을 따로 열지 않아도 된다.
            Button {
                UsageReportingService.record(event: "offer_code_open:paywall")
                showingOfferCode = true
            } label: {
                Text(Strings.redeemOfferCode)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(minHeight: 44)
            }
            .disabled(proManager.isLoading)
            .offerCodeRedemption(isPresented: $showingOfferCode) { result in
                if case .success = result {
                    Task { await proManager.checkEntitlement() }
                }
            }
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 10) {
            Text(Strings.subscriptionDisclosure)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                Link(Strings.termsOfService,
                     destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Link(Strings.privacyPolicy,
                     destination: GoldweekSpec.legal.privacyURL)
            }
            .font(.body)
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Actions

    private func purchase(_ tier: ProTier) {
        guard let product = selectedProduct(tier) else { return }
        buyingTier = tier
        Task {
            defer { buyingTier = nil }
            do {
                try await proManager.purchase(product.id)
                // 사용자가 취소한 경우 purchase()는 에러 없이 리턴되므로
                // 실제로 그 칸이 열렸을 때만 성공 알림을 띄운다
                guard proManager.tier >= tier else { return }
                UsageReportingService.record(event: "paywall_purchase:success")
                await MainActor.run {
                    isSuccess = true
                    alertMessage = Strings.youArePro
                    showingAlert = true
                }
                // 구매 완료 직후 리뷰 요청. 가장 만족도 높은 시점
                try? await Task.sleep(for: .seconds(1.5))
                ReviewManager.shared.requestReviewAfterPurchase(using: requestReview)
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
                if proManager.isPro {
                    isSuccess = true
                    alertMessage = Strings.restoreSuccess
                    showingAlert = true
                } else {
                    isSuccess = false
                    alertMessage = Strings.paywallNoPurchaseFound
                    showingAlert = true
                }
            }
        }
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

// MARK: - Feature Row Component

enum FeatureCellValue {
    case supported(Bool)
    case text(String)
}

struct FeatureRowView: View {
    let icon: String
    let iconColor: Color
    let feature: String
    var freeLabel: String? = nil
    var proLabel: String? = nil
    var freeValue: FeatureCellValue? = nil
    var proValue: FeatureCellValue? = nil
    var isHeader: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if isHeader {
                // Header row
                Text(Strings.paywallFeaturesHeader)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)

                if let free = freeLabel, let pro = proLabel {
                    Text(free)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 64, alignment: .center)

                    Text(pro)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(width: 64, alignment: .center)
                }
            } else {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: icon)
                        .font(.system(.body))
                        .foregroundColor(iconColor)
                        .voDecorative()
                }

                // Feature name
                Text(feature)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Free cell
                featureCell(value: freeValue, isPro: false)
                    .frame(width: 64)

                // Pro cell
                featureCell(value: proValue, isPro: true)
                    .frame(width: 64)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, isHeader ? 8 : 12)
        .background(isHeader ? Color(.systemGray6) : Color.clear)
    }

    @ViewBuilder
    private func featureCell(value: FeatureCellValue?, isPro: Bool) -> some View {
        if let value {
            switch value {
            case .supported(let yes):
                Image(systemName: yes ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(yes ? .green : Color(.systemGray4))
                    .font(.system(.body))
                    .accessibilityLabel(Text(yes ? "Yes" : "No"))
            case .text(let str):
                Text(str)
                    .font(.body)
                    .fontWeight(isPro ? .semibold : .regular)
                    .foregroundColor(isPro ? .primary : .secondary)
                    .multilineTextAlignment(.center)
            }
        }
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
