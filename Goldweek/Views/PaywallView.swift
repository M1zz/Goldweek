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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    featuresSection
                    pricingSection
                    purchaseButtons
                    footerSection
                }
                .onAppear { AnalyticsService.logPaywallView(source: "direct") }
                .padding(.horizontal)
                .padding(.bottom, 32)
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

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.yellow.opacity(0.15))
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(.yellow.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "crown.fill")
                    .font(.system(.largeTitle))
                    .foregroundStyle(.yellow)
                    .voDecorative()
            }
            .padding(.top, 8)

            VStack(spacing: 6) {
                Text(Strings.goldweekPro)
                    .font(.title)
                    .fontWeight(.bold)

                Text(Strings.unlockAllFeatures)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Strings.featureComparison)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                FeatureRowView(
                    icon: "calendar.badge.checkmark",
                    iconColor: .blue,
                    feature: Strings.basicLeaveManagement,
                    freeLabel: Strings.freeVersion,
                    proLabel: Strings.proVersion,
                    isHeader: true
                )

                Divider().padding(.leading, 52)

                FeatureRowView(
                    icon: "calendar.badge.checkmark",
                    iconColor: .blue,
                    feature: Strings.basicLeaveManagement,
                    freeValue: .supported(true),
                    proValue: .supported(true)
                )

                Divider().padding(.leading, 52)

                FeatureRowView(
                    icon: "lightbulb.fill",
                    iconColor: .orange,
                    feature: Strings.leaveRecommendations,
                    freeValue: .text(Strings.limitedRecommendations),
                    proValue: .text(Strings.unlimitedRecommendations)
                )

                Divider().padding(.leading, 52)

                FeatureRowView(
                    icon: "calendar",
                    iconColor: .purple,
                    feature: Strings.yearSelector,
                    freeValue: .text(Strings.currentYearOnly),
                    proValue: .text(Strings.allYears)
                )

                Divider().padding(.leading, 52)

                FeatureRowView(
                    icon: "gift.fill",
                    iconColor: .pink,
                    feature: Strings.bonusLeaveManagement,
                    freeValue: .supported(false),
                    proValue: .supported(true)
                )

                Divider().padding(.leading, 52)

                FeatureRowView(
                    icon: "icloud.fill",
                    iconColor: .cyan,
                    feature: Strings.iCloudBackup,
                    freeValue: .supported(false),
                    proValue: .supported(true)
                )

                Divider().padding(.leading, 52)

                FeatureRowView(
                    icon: "calendar.badge.plus",
                    iconColor: .green,
                    feature: Strings.systemCalendarSync,
                    freeValue: .supported(false),
                    proValue: .supported(true)
                )

                Divider().padding(.leading, 52)

                FeatureRowView(
                    icon: "sparkles",
                    iconColor: AppTheme.Colors.bonus,
                    feature: Strings.proFeatureAIAnnualPlanner,
                    freeValue: .supported(false),
                    proValue: .supported(true)
                )
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 10) {
            if !proManager.proPrice.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Strings.goldweekPro)
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(Strings.oneTimePurchase)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(proManager.proPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentColor.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1.5)
                )
            }

            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.footnote)
                Text(Strings.noSubscription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Purchase Buttons

    private var purchaseButtons: some View {
        VStack(spacing: 12) {
            Button(action: purchasePro) {
                HStack(spacing: 8) {
                    if proManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.85)
                    } else {
                        Image(systemName: "crown.fill")
                    }
                    Text(proManager.isLoading ? Strings.purchasing : Strings.purchase)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(proManager.isLoading ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(proManager.isLoading)

            Button(action: restorePurchases) {
                Text(Strings.restorePurchase)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .frame(height: 44)
            }
            .disabled(proManager.isLoading)
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        Text(Strings.oneTimePurchase)
            .font(.caption)
            .foregroundColor(Color(.systemGray3))
            .multilineTextAlignment(.center)
    }

    // MARK: - Actions

    private func purchasePro() {
        Task {
            do {
                try await proManager.purchase()
                await MainActor.run {
                    AnalyticsService.logPaywallPurchase(success: true, productId: "pro")
                    isSuccess = true
                    alertMessage = Strings.youArePro
                    showingAlert = true
                }
                // 구매 완료 직후 리뷰 요청 — 가장 만족도 높은 시점
                try? await Task.sleep(for: .seconds(1.5))
                await ReviewManager.shared.requestReviewAfterPurchase(using: requestReview)
            } catch {
                await MainActor.run {
                    AnalyticsService.logPaywallPurchase(success: false, productId: "pro")
                    AnalyticsService.recordError(error, context: ["op": "pro_purchase"])
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
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)

                if let free = freeLabel, let pro = proLabel {
                    Text(free)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 64, alignment: .center)

                    Text(pro)
                        .font(.caption)
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
                        .font(.system(.subheadline))
                        .foregroundColor(iconColor)
                        .voDecorative()
                }

                // Feature name
                Text(feature)
                    .font(.subheadline)
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
                    .font(.caption2)
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
                            .font(.subheadline)
                            .voDecorative()
                    } else {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                            .voDecorative()
                    }
                    Text(Strings.upgradeToPro)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(displayMessage)
                    .font(.caption)
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
                    .font(.caption)
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
