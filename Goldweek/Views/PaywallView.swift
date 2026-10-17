//
//  PaywallView.swift
//  Goldweek
//
//  Pro 기능 업그레이드 페이월 뷰 (다국어 지원)
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @State private var proManager = ProManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var selectedTier: ProTier
    @State private var selectedProductID: String
    /// App Store 오퍼 코드 입력 시트 (StoreKit 2). 받은 코드는 `Transaction.updates` 로 들어와 Pro 가 열린다.
    @State private var showingOfferCode = false

    /// - Parameter initialProductID: 처음 골라 둘 상품 (기본: 프로 연간). 스크린샷 모드에서도 쓴다.
    init(initialProductID: String? = nil) {
        let id = initialProductID ?? ScreenshotMode.paywallProductID ?? ProManager.yearlyProductID
        let tier = ProManager.tier(of: id)
        _selectedTier = State(initialValue: tier == .free ? .pro : tier)
        _selectedProductID = State(initialValue: tier == .free ? ProManager.yearlyProductID : id)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    trimPicker
                    featuresSection
                    pricingSection
                    purchaseButtons
                    footerSection
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { UsageReportingService.record(event: "paywall_view") }
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

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.yellow.opacity(0.15))
                    .frame(width: 84, height: 84)
                Image(systemName: Self.icon(of: selectedTier))
                    .font(.system(.largeTitle))
                    .foregroundStyle(.yellow)
                    .voDecorative()
            }
            .padding(.top, 4)

            // 이미 이 등급을 쓰는 사람에게는 파는 말 대신 "모두 열려 있어요" — '내 혜택'의 전체 보기도 이 화면이다.
            Text(proManager.tier >= selectedTier ? Strings.benefitsAllUnlocked(selectedTier) : Strings.trimTagline(selectedTier))
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    static func icon(of tier: ProTier) -> String {
        switch tier {
        case .free, .plus: return "sparkles"
        case .pro: return "crown.fill"
        case .family: return "person.3.fill"
        }
    }

    // MARK: - 트림 고르기

    private var trimPicker: some View {
        HStack(spacing: 8) {
            ForEach([ProTier.plus, .pro, .family], id: \.self) { tier in
                let isSelected = selectedTier == tier
                Button {
                    selectedTier = tier
                    selectedProductID = Self.defaultProductID(for: tier)
                    HapticFeedback.selection()
                } label: {
                    VStack(spacing: 4) {
                        Text(Strings.trimName(tier))
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(tier == .pro ? Strings.trimPopular : " ")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.white.opacity(0.9) : Color.accentColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    static func defaultProductID(for tier: ProTier) -> String {
        switch tier {
        case .free, .pro: return ProManager.yearlyProductID
        case .plus: return ProManager.plusProductID
        case .family: return ProManager.familyProductID
        }
    }

    // MARK: - Features Section

    /// 등급 비교표의 한 줄 — '내 혜택' 화면도 이 목록을 그대로 쓴다(목록은 여기 한 곳에만 적는다).
    struct TrimFeature: Hashable {
        let icon: String
        let color: Color
        let title: String
        var isSummary = false
    }

    private var features: [TrimFeature] { Self.features(of: selectedTier) }

    /// 등급이 더하는 기능. 위 등급은 맨 앞 요약 줄(`isSummary`)로 아래 등급을 모두 포함한다고 말한다.
    static func features(of tier: ProTier) -> [TrimFeature] {
        switch tier {
        case .free, .plus:
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
            ]
        case .family:
            return [
                TrimFeature(icon: "checkmark.seal.fill", color: .accentColor, title: Strings.trimEverythingIn(Strings.trimName(.pro)), isSummary: true),
                TrimFeature(icon: "person.2.fill", color: .pink, title: Strings.featFamilySharing),
            ]
        }
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                if index > 0 { Divider().padding(.leading, 54) }
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
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .animation(.default, value: selectedTier)
    }

    // MARK: - Pricing Section

    /// 고른 트림에서 살 수 있는 상품 (화면 순서)
    private var tierProductIDs: [String] {
        switch selectedTier {
        case .free, .pro: return [ProManager.yearlyProductID, ProManager.proProductID]
        case .plus: return [ProManager.plusProductID]
        case .family: return [ProManager.familyProductID]
        }
    }

    private var tierHasPrice: Bool {
        tierProductIDs.contains { PaywallPrice.price(of: $0) != nil }
    }

    private var pricingSection: some View {
        VStack(spacing: 10) {
            if !tierHasPrice {
                // 가격 로드 실패/로딩 중 — 빈칸 대신 상태를 보여준다
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
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                )
            } else if proManager.tier < selectedTier {
                ForEach(tierProductIDs, id: \.self) { id in
                    if let price = PaywallPrice.price(of: id) {
                        TrimPriceCard(isSelected: selectedProductID == id,
                                      title: id == ProManager.proProductID ? Strings.planLifetime : Strings.planYearly,
                                      price: id == ProManager.proProductID ? price.display : Strings.yearlyPriceLabel(price.display),
                                      caption: caption(for: id, price: price)) {
                            selectedProductID = id
                            HapticFeedback.selection()
                        }
                    }
                }
            }
        }
    }

    private func caption(for id: String, price: PaywallPrice) -> String {
        if id == ProManager.proProductID { return Strings.oneTimePurchase }
        if let days = PaywallPrice.trialDays(of: id) { return Strings.trialThenPrice(days, price.display) }
        if id == ProManager.familyProductID { return Strings.familyPerPersonHint(price.perMonth(dividedBy: 6)) }
        return Strings.perMonthHint(price.perMonth(dividedBy: 1))
    }

    // MARK: - Purchase Buttons

    @ViewBuilder
    private var purchaseButtons: some View {
        if proManager.tier >= selectedTier {
            // 이미 이 트림 이상 — 구매 버튼 대신 상태를 분명히 보여 준다
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .voDecorative()
                Text(Strings.trimIncluded)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        } else {
            purchaseActions
        }
    }

    private var purchaseTitle: String {
        if let days = PaywallPrice.trialDays(of: selectedProductID) { return Strings.startTrial(days) }
        return Strings.startTrim(Strings.trimName(selectedTier))
    }

    private var purchaseActions: some View {
        VStack(spacing: 12) {
            Button(action: purchase) {
                HStack(spacing: 8) {
                    if proManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.85)
                    } else {
                        Image(systemName: Self.icon(of: selectedTier))
                    }
                    Text(proManager.isLoading ? Strings.purchasing : purchaseTitle)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(proManager.isLoading || !tierHasPrice ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            // 가격을 확인할 수 없는 상태에서는 구매를 막는다
            .disabled(proManager.isLoading || !tierHasPrice)

            Button(action: restorePurchases) {
                Text(Strings.restorePurchase)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .frame(height: 44)
            }
            .disabled(proManager.isLoading)

            // 받은 오퍼 코드(할인·무료 기간)를 앱 안에서 바로 쓴다 — App Store 앱을 따로 열지 않아도 된다.
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

    private func purchase() {
        let tier = selectedTier
        Task {
            do {
                try await proManager.purchase(selectedProductID)
                // 사용자가 취소한 경우 purchase()는 에러 없이 리턴되므로
                // 실제로 그 트림이 열렸을 때만 성공 알림을 띄운다
                guard proManager.tier >= tier else { return }
                UsageReportingService.record(event: "paywall_purchase:success")
                await MainActor.run {
                    isSuccess = true
                    alertMessage = Strings.youArePro
                    showingAlert = true
                }
                // 구매 완료 직후 리뷰 요청 — 가장 만족도 높은 시점
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

// MARK: - 트림 요금 카드

private struct TrimPriceCard: View {
    let isSelected: Bool
    let title: String
    let price: String
    let caption: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
}

// MARK: - 가격

/// 페이월이 보여 줄 가격. App Store에서 불러온 상품이 기준이고,
/// 스크린샷 모드(DEBUG)에서만 상품을 못 불러오면 App Store Connect에 넣은 미국 가격을 쓴다 — 심사용 화면 촬영.
struct PaywallPrice {
    let display: String
    private let amount: Decimal
    private let format: Decimal.FormatStyle.Currency

    func perMonth(dividedBy people: Int) -> String {
        (amount / Decimal(12 * max(people, 1))).formatted(format)
    }

    static func price(of id: String) -> PaywallPrice? {
        if let product = ProManager.shared.product(id) {
            return PaywallPrice(display: product.displayPrice, amount: product.price, format: product.priceFormatStyle)
        }
        guard ScreenshotMode.isActive, let usd = screenshotUSD[id] else { return nil }
        let format = Decimal.FormatStyle.Currency(code: "USD", locale: Locale(identifier: "en_US"))
        return PaywallPrice(display: usd.formatted(format), amount: usd, format: format)
    }

    static func trialDays(of id: String) -> Int? {
        if ProManager.shared.product(id) != nil { return ProManager.shared.trialDays(for: id) }
        guard ScreenshotMode.isActive else { return nil }
        return [ProManager.yearlyProductID, ProManager.familyProductID].contains(id) ? 7 : nil
    }

    /// docs/MONETIZATION.md 의 미국 가격
    private static let screenshotUSD: [String: Decimal] = [
        ProManager.plusProductID: Decimal(string: "9.99")!,
        ProManager.yearlyProductID: Decimal(string: "19.99")!,
        ProManager.proProductID: Decimal(string: "49.99")!,
        ProManager.familyProductID: Decimal(string: "29.99")!,
    ]
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
