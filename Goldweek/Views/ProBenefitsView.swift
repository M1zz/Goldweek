//
//  ProBenefitsView.swift
//  Goldweek
//
//  설정 > 이용 중인 등급(플러스 · 프로) > 내 혜택
//

import SwiftUI
import SwiftData

/// **지금 누리고 있는 등급** — 무엇이 열려 있고, 그걸 얼마나 쓰고 있는가.
///
/// ⚠️ 기능 목록만 늘어놓지 않는다. 산 사람이 알고 싶은 것은 **내가 그걸 실제로 얼마나 쓰고 있는가**다.
///    그래서 무료였다면 어디까지였는지 옆에 지금 내 숫자를 세우고, 넘어선 만큼만 따로 짚는다.
/// ⚠️ 등급별 기능 전체는 여기 따로 적지 않는다. 페이월 비교표(`PaywallView.features(of:)`)가 원본이라
///    "전체 보기" 는 그 화면을 그대로 열고, 위 등급에서 더 열리는 것도 그 목록에서 가져온다.
struct ProBenefitsView: View {
    @Query private var leaveRecords: [LeaveRecord]
    @Query private var bonusLeaves: [BonusLeave]
    @Query private var customLeaveTypes: [CustomLeaveType]
    @Query private var schoolBreaks: [SchoolBreak]
    @Query private var anniversaries: [FamilyAnniversary]
    @AppStorage(CalendarService.autoSyncKey) private var calendarAutoSync = false
    @AppStorage("autoDetectLeavesEnabled") private var autoDetectEnabled = true
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// 페이월을 열 때 처음 골라 둘 등급
    @State private var paywallTier: ProTier?

    private var tier: ProTier { ProManager.shared.tier }

    private var recommendationCount: Int {
        ProBenefits.recommendedPlanCount(leaveRecords.map(ProBenefits.Entry.init),
                                         year: Calendar.app.component(.year, from: Date()))
    }

    private var recommendationExtra: Int {
        ProBenefits.extra(used: recommendationCount, freeLimit: ProManager.freeRecommendationAddLimit)
    }

    var body: some View {
        let _ = LanguageManager.shared.currentLanguage
        List {
            heroSection
            limitsSection
            unlockedSection
            if let next = ProBenefits.nextTier(after: tier) {
                upgradeSection(next)
            }
            allFeaturesSection
        }
        .navigationTitle(Strings.benefitsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $paywallTier) { tier in
            PaywallView(initialProductID: PaywallView.defaultProductID(for: tier))
        }
        .task { await ShareSyncService.shared.refreshSharedSchedules() }
    }

    // MARK: - 한 줄 요약

    private var heroSection: some View {
        Section {
            HStack(spacing: 14) {
                Image(systemName: PaywallView.icon(of: tier))
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.Colors.bonus)
                    .voDecorative()
                VStack(alignment: .leading, spacing: 3) {
                    Text("Goldweek \(Strings.trimName(tier))")
                        .font(.headline)
                    Text(recommendationExtra > 0
                         ? Strings.benefitsSummaryExtra(recommendationExtra)
                         : Strings.benefitsAllUnlocked(tier))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 6)
            .accessibilityElement(children: .combine)
        }
    }

    // MARK: - 무료 한도와 비교

    private var limitsSection: some View {
        Section {
            adaptiveRow(symbol: "lightbulb.fill", title: Strings.benefitsRecommendationsRow,
                        detail: Strings.benefitsFreeVsNow(free: ProManager.freeRecommendationAddLimit,
                                                          now: recommendationCount)) {
                // 넘어선 만큼만 짚는다. 한도 안이면 아무것도 달지 않는다.
                if recommendationExtra > 0 {
                    Text(verbatim: "+\(recommendationExtra)")
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.Colors.brand))
                        .accessibilityLabel(Strings.benefitsBeyondFree(recommendationExtra))
                }
            }
        } header: {
            Text(Strings.benefitsLimitsHeader)
        }
    }

    // MARK: - 이 등급으로 열린 기능

    private struct ValueRow: Identifiable {
        var id: String { title }
        let symbol: String
        let title: String
        let value: String
    }

    /// 등급이 여는 기능과 **지금 그걸 쓰는 모습**(켜짐·개수·사람 수).
    private var unlockedRows: [ValueRow] {
        var rows: [ValueRow] = []
        if tier >= .plus {
            rows += [
                ValueRow(symbol: "sparkles", title: Strings.proFeatureAIAnnualPlanner, value: Strings.stateAvailable),
                ValueRow(symbol: "calendar", title: Strings.featOtherYears, value: Strings.stateAvailable),
                ValueRow(symbol: "calendar.badge.plus", title: Strings.calendarExportToggle,
                         value: calendarAutoSync ? Strings.stateOn : Strings.stateOff),
            ]
        }
        if tier >= .pro {
            rows += [
                ValueRow(symbol: "gift.fill", title: Strings.bonusLeaveManagement,
                         value: Strings.itemCount(bonusLeaves.count)),
                ValueRow(symbol: "gauge.with.needle", title: Strings.paywallAllowanceFeature,
                         value: Strings.itemCount(customLeaveTypes.filter(\.hasAllowance).count)),
                ValueRow(symbol: "doc.viewfinder", title: Strings.schoolImportTitle,
                         value: Strings.itemCount(schoolBreaks.filter { $0.kind != .blackout }.count)),
                ValueRow(symbol: "calendar.badge.clock", title: Strings.autoDetectSettingTitle,
                         value: autoDetectEnabled ? Strings.stateOn : Strings.stateOff),
                ValueRow(symbol: "person.2.fill", title: Strings.benefitsFamilyMembers,
                         value: Strings.peopleCount(ShareSyncService.shared.sharedSchedules.count)),
                ValueRow(symbol: "heart.fill", title: Strings.familyAnniversariesTitle,
                         value: Strings.itemCount(anniversaries.count)),
            ]
        }
        return rows
    }

    private var unlockedSection: some View {
        Section {
            ForEach(unlockedRows) { row in
                adaptiveRow(symbol: row.symbol, title: row.title, detail: nil) {
                    Text(row.value)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        } header: {
            Text(Strings.benefitsUnlockedHeader(tier))
        }
    }

    // MARK: - 위 등급

    /// 낮은 등급을 산 사람에게 위 등급에서 **더** 열리는 것을 차분히 한 칸. 고르면 기존 페이월로 간다.
    private func upgradeSection(_ next: ProTier) -> some View {
        Section {
            ForEach(PaywallView.features(of: next).filter { !$0.isSummary }, id: \.self) { feature in
                Label {
                    Text(feature.title)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: feature.icon)
                        .foregroundStyle(feature.color)
                }
            }
            Button {
                paywallTier = next
            } label: {
                Label(Strings.benefitsExplore(next), systemImage: PaywallView.icon(of: next))
            }
        } header: {
            Text(Strings.benefitsMoreHeader(next))
        }
    }

    // MARK: - 전체 보기

    private var allFeaturesSection: some View {
        Section {
            Button {
                HapticFeedback.selection()
                paywallTier = tier
            } label: {
                HStack {
                    Label {
                        Text(Strings.benefitsSeeAll)
                            .foregroundStyle(Color.primary)
                    } icon: {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .voDecorative()
                }
            }
        }
    }

    // MARK: - 행

    /// 아이콘 · 제목(· 설명) · 오른쪽 값. 아주 큰 글씨에서는 값을 제목 아래로 내린다 — 옆에 두면 제목이 한 글자씩 꺾인다.
    @ViewBuilder
    private func adaptiveRow<Trailing: View>(symbol: String, title: String, detail: String?,
                                             @ViewBuilder trailing: () -> Trailing) -> some View {
        let label = HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(AppTheme.Colors.brand)
                .frame(width: 24)
                .voDecorative()
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
                if let detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 6) {
                    label
                    trailing().padding(.leading, 36)
                }
            } else {
                HStack {
                    label
                    Spacer(minLength: 8)
                    trailing()
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

extension ProTier: Identifiable {
    var id: Int { rawValue }
}
