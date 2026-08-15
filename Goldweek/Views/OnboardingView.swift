//
//  OnboardingView.swift
//  Goldweek
//
//  온보딩 화면 - 앱 첫 실행 시 표시
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isOnboardingComplete: Bool

    @State private var currentPage = 0
    @State private var userName = ""
    @State private var totalLeave: Double = 15
    @State private var yearStartMonth = 1
    @State private var showingSaveError = false
    @FocusState private var isNameFieldFocused: Bool

    private let totalPages = 5

    var body: some View {
        let _ = LanguageManager.shared.currentLanguage
        ZStack {
            // 배경 그라디언트 (페이지마다 미세하게 변화)
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: currentPage)

            VStack(spacing: 0) {
                // 상단 progress bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // 페이지 컨텐츠
                TabView(selection: $currentPage) {
                    HeroPage()
                        .tag(0)

                    ValueDemoPage()
                        .tag(1)

                    FeaturesGridPage()
                        .tag(2)

                    SetupPage(
                        userName: $userName,
                        totalLeave: $totalLeave,
                        yearStartMonth: $yearStartMonth,
                        isNameFocused: $isNameFieldFocused
                    )
                    .tag(3)

                    ProShowcasePage(onComplete: completeOnboarding)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // 하단 네비게이션 (Pro 페이지는 자체 버튼 보유)
                if currentPage < totalPages - 1 {
                    bottomNav
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
        }
        .onTapGesture {
            isNameFieldFocused = false
        }
        .onChange(of: currentPage) { _, newPage in
            HapticFeedback.selection()
            if newPage != 3 {
                isNameFieldFocused = false
            }
        }
        .alert(Strings.alert, isPresented: $showingSaveError) {
            Button(Strings.retry) { completeOnboarding() }
            Button(Strings.cancel, role: .cancel) { }
        } message: {
            Text(Strings.saveFailed)
        }
    }

    // MARK: - 배경
    private var backgroundGradient: some View {
        let topColor: Color = {
            switch currentPage {
            case 0: return AppTheme.Colors.bonus.opacity(0.18)
            case 1: return AppTheme.Colors.brand.opacity(0.14)
            case 2: return AppTheme.Colors.bonus.opacity(0.10)
            case 3: return AppTheme.Colors.brand.opacity(0.10)
            default: return AppTheme.Colors.bonus.opacity(0.16)
            }
        }()
        return LinearGradient(
            colors: [topColor, Color(.systemGroupedBackground)],
            startPoint: .top,
            endPoint: .center
        )
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= currentPage ? AppTheme.Colors.bonus : Color(.systemGray5))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }

    // MARK: - 하단 버튼
    private var bottomNav: some View {
        HStack(spacing: 12) {
            if currentPage > 0 {
                Button {
                    withAnimation { currentPage -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.brand)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))
                }
            }

            Button {
                isNameFieldFocused = false
                withAnimation { currentPage += 1 }
            } label: {
                Text(currentPage == 0 ? Strings.getStarted : Strings.next)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.bonus, AppTheme.Colors.bonus.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: AppTheme.Colors.bonus.opacity(0.3), radius: 12, y: 6)
            }
        }
    }

    // MARK: - 완료 처리
    private func completeOnboarding() {
        UsageReportingService.record(event: "onboarding_complete")
        let country = Country.fromDeviceLocale()
        switch country {
        case .korea: AppLanguage.current = .korean
        case .japan: AppLanguage.current = .japanese
        case .china: AppLanguage.current = .chinese
        case .usa, .germany, .france: AppLanguage.current = .english
        }

        let profile = UserProfile(
            name: userName.isEmpty ? Strings.defaultUser : userName,
            yearStartMonth: yearStartMonth,
            totalAnnualLeave: totalLeave,
            usedLeave: 0,
            country: country
        )
        modelContext.insert(profile)
        do {
            try modelContext.save()
        } catch {
            // 프로필 없이 온보딩이 끝나면 앱이 깨진 상태가 되므로 완료를 막는다
            modelContext.delete(profile)
            logError("온보딩 프로필 저장 실패: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
            showingSaveError = true
            return
        }

        WidgetService.shared.updateWidgetData(
            profile: profile,
            bonusLeaves: [],
            leaveRecords: []
        )

        HapticFeedback.success()
        withAnimation {
            isOnboardingComplete = true
        }
    }
}

// MARK: - 페이지 1: Hero
struct HeroPage: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // 골드 그라디언트 원형 + 캘린더 아이콘
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.bonus.opacity(0.35),
                                AppTheme.Colors.bonus.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .scaleEffect(animate ? 1.0 : 0.85)
                    .opacity(animate ? 1.0 : 0.4)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.Colors.bonus, AppTheme.Colors.bonus.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: AppTheme.Colors.bonus.opacity(0.4), radius: 24, y: 12)

                    Image(systemName: "sun.max.fill")
                        .font(.system(.largeTitle, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        .voDecorative()
                }
                .scaleEffect(animate ? 1.0 : 0.7)
                .opacity(animate ? 1.0 : 0.0)
            }

            VStack(spacing: 14) {
                // 배지
                Text(Strings.onboardingHeroBadge)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.bonus)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.bonus.opacity(0.12))
                    .clipShape(Capsule())

                Text(Strings.appName)
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundStyle(.primary)

                Text(Strings.onboardingSubtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
            .opacity(animate ? 1.0 : 0.0)
            .offset(y: animate ? 0 : 20)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animate = true
            }
        }
    }
}

// MARK: - 페이지 2: 가치 데모 (3일 연차로 9일 연휴)
struct ValueDemoPage: View {
    @State private var revealedDays: Set<Int> = []

    // 9일 연휴 시뮬레이션: 토(주말) 일(주말) 월(공휴) 화(연차) 수(연차) 목(공휴) 금(연차) 토(주말) 일(주말)
    private let dayLabels: [(label: String, type: DayType)] = [
        ("S", .weekend),
        ("S", .weekend),
        ("M", .holiday),
        ("T", .leave),
        ("W", .leave),
        ("T", .holiday),
        ("F", .leave),
        ("S", .weekend),
        ("S", .weekend)
    ]

    enum DayType {
        case weekend, holiday, leave
        var color: Color {
            switch self {
            case .weekend: return Color(.systemGray3)
            case .holiday: return AppTheme.Colors.holiday
            case .leave: return AppTheme.Colors.bonus
            }
        }
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // 헤드라인
            VStack(spacing: 8) {
                Text(Strings.onboardingValueTitle)
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.bonus)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text(Strings.onboardingValueDesc)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // 9일 캘린더 그리드
            HStack(spacing: 8) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 6) {
                        Text(day.label)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(day.type.color.opacity(revealedDays.contains(index) ? 1.0 : 0.2))
                                .frame(width: 32, height: 40)

                            if day.type == .leave && revealedDays.contains(index) {
                                Image(systemName: "checkmark")
                                    .font(.body.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .scaleEffect(revealedDays.contains(index) ? 1.0 : 0.9)
                    }
                }
            }
            .padding(.horizontal, 16)

            // 범례
            HStack(spacing: 18) {
                OnboardingLegendItem(color: AppTheme.Colors.bonus, label: Strings.onboardingValueLegendLeave)
                OnboardingLegendItem(color: AppTheme.Colors.holiday, label: Strings.onboardingValueLegendHoliday)
                OnboardingLegendItem(color: Color(.systemGray3), label: Strings.onboardingValueLegendWeekend)
            }
            .padding(.top, 8)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            // 순차적으로 reveal
            for (i, _) in dayLabels.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        _ = revealedDays.insert(i)
                    }
                }
            }
        }
    }
}

private struct OnboardingLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 페이지 3: 4대 기능 그리드
struct FeaturesGridPage: View {
    var features: [(String, String, String, Color)] {
        [
            ("calendar.badge.plus", Strings.featureLeaveManagement, Strings.featureLeaveManagementDesc, AppTheme.Colors.brand),
            ("sparkles", Strings.featureAIRecommend, Strings.featureAIRecommendDesc, AppTheme.Colors.bonus),
            ("gift.fill", Strings.featureBonusLeave, Strings.featureBonusLeaveDesc, AppTheme.Colors.compensatory),
            ("apps.iphone", Strings.featureWidget, Strings.featureWidgetDesc, AppTheme.Colors.success)
        ]
    }

    @State private var animateIndex = -1

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 16)

            Text(Strings.mainFeatures)
                .font(.system(.title, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach(Array(features.indices), id: \.self) { i in
                    let f = features[i]
                    FeatureCard(icon: f.0, title: f.1, description: f.2, accent: f.3)
                        .opacity(animateIndex >= i ? 1.0 : 0.0)
                        .offset(y: animateIndex >= i ? 0 : 16)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            for i in 0..<features.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        animateIndex = i
                    }
                }
            }
        }
    }
}

private struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accent.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - 페이지 4: 셋업 (이름 + 연차 + 기준월)
struct SetupPage: View {
    @Binding var userName: String
    @Binding var totalLeave: Double
    @Binding var yearStartMonth: Int
    var isNameFocused: FocusState<Bool>.Binding

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                // 헤더
                VStack(spacing: 6) {
                    Text(Strings.leaveSetup)
                        .font(.system(.title, weight: .bold))
                    Text(Strings.leaveSetupDesc)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)

                // 이름 카드
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(Strings.enterName, systemImage: "person.crop.circle")
                            .font(.headline)
                        Spacer()
                        Text(Strings.onboardingNameOptional)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }

                    TextField(Strings.name, text: $userName)
                        .font(.body)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .focused(isNameFocused)
                        .submitLabel(.done)
                        .onSubmit { isNameFocused.wrappedValue = false }
                }
                .padding(18)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // 총 연차 카드
                VStack(alignment: .leading, spacing: 14) {
                    Label(Strings.totalAnnualLeave, systemImage: "calendar")
                        .font(.headline)

                    HStack(alignment: .lastTextBaseline) {
                        Text("\(Int(totalLeave))")
                            .font(.system(.largeTitle, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.bonus)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: totalLeave)
                        Text(Strings.dayUnitSuffix)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Stepper("", value: $totalLeave, in: 1...30, step: 1)
                            .labelsHidden()
                    }
                }
                .padding(18)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // 연차 기준월 카드
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(Strings.yearStartMonthLabel, systemImage: "arrow.clockwise")
                            .font(.headline)
                        Spacer()
                        Text(Strings.monthShort(yearStartMonth))
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.Colors.bonus)
                    }

                    Text(Strings.yearStartMonthDesc)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 6), spacing: 6) {
                        ForEach(1...12, id: \.self) { month in
                            Button {
                                HapticFeedback.selection()
                                yearStartMonth = month
                            } label: {
                                Text(Strings.monthShort(month))
                                    .font(.body.weight(yearStartMonth == month ? .bold : .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(yearStartMonth == month ? AppTheme.Colors.bonus : Color(.systemGray6))
                                    .foregroundStyle(yearStartMonth == month ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .voButton(Strings.monthShort(month))
                            .voSelected(yearStartMonth == month)
                        }
                    }
                }
                .padding(18)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - 페이지 5: Pro 안내
struct ProShowcasePage: View {
    let onComplete: () -> Void

    @State private var proManager = ProManager.shared
    @State private var animateFeatures = false

    private var proFeatures: [(String, String, String, Color)] {
        [
            ("lightbulb.fill", Strings.proFeatureRecommendTitle, Strings.proFeatureRecommendDesc, AppTheme.Colors.bonus),
            ("gift.fill", Strings.proFeatureBonusTitle, Strings.proFeatureBonusDesc, AppTheme.Colors.compensatory),
            ("calendar", Strings.proFeatureMultiYearTitle, Strings.proFeatureMultiYearDesc, AppTheme.Colors.brand),
            ("calendar.badge.plus", Strings.proFeatureCalendarTitle, Strings.proFeatureCalendarDesc, AppTheme.Colors.success)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                // 크라운 + 헤드라인
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.Colors.bonus.opacity(0.35),
                                        AppTheme.Colors.bonus.opacity(0.0)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.bonus, AppTheme.Colors.bonus.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 84, height: 84)
                            .shadow(color: AppTheme.Colors.bonus.opacity(0.4), radius: 16, y: 8)

                        Image(systemName: "crown.fill")
                            .font(.system(.largeTitle))
                            .foregroundStyle(.white)
                            .voDecorative()
                    }

                    VStack(spacing: 6) {
                        Text(Strings.goldweekPro)
                            .font(.system(.title, weight: .bold))
                        Text(Strings.proOnboardingSubtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 8)

                // Pro 기능 리스트
                VStack(spacing: 10) {
                    ForEach(Array(proFeatures.indices), id: \.self) { i in
                        let f = proFeatures[i]
                        ProFeatureRow(icon: f.0, title: f.1, description: f.2, accent: f.3)
                            .opacity(animateFeatures ? 1.0 : 0.0)
                            .offset(y: animateFeatures ? 0 : 12)
                            .animation(.spring(response: 0.5, dampingFraction: 0.85).delay(Double(i) * 0.07), value: animateFeatures)
                    }
                }
                .padding(.horizontal, 24)

                // 가격
                if !proManager.proPrice.isEmpty {
                    VStack(spacing: 4) {
                        Text(proManager.proPrice)
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.Colors.bonus)
                        Text(Strings.oneTimePurchase)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }

                // CTA
                VStack(spacing: 10) {
                    Button(action: onComplete) {
                        Text(Strings.getStarted)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.Colors.bonus, AppTheme.Colors.bonus.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: AppTheme.Colors.bonus.opacity(0.3), radius: 12, y: 6)
                    }

                    Button(action: onComplete) {
                        Text(Strings.proOnboardingSkip)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation { animateFeatures = true }
        }
    }
}

private struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let accent: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(.body))
                    .foregroundStyle(accent)
                    .voDecorative()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(accent)
                .font(.system(.title3))
                .voDecorative()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
