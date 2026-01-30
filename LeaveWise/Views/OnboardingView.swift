//
//  OnboardingView.swift
//  LeaveWise
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
    @State private var selectedCountry: Country = Country.fromDeviceLocale()
    @FocusState private var isNameFieldFocused: Bool

    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)
    private let greenColor = Color(red: 0.15, green: 0.68, blue: 0.38)

    var body: some View {
        let _ = LanguageManager.shared.currentLanguage
        VStack(spacing: 0) {
            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(currentPage == index ? blueColor : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)

            TabView(selection: $currentPage) {
                // 페이지 1: 환영
                WelcomePage()
                    .tag(0)

                // 페이지 2: 기능 소개
                FeaturesPage()
                    .tag(1)

                // 페이지 3: 국가 선택
                CountrySelectionPage(selectedCountry: $selectedCountry)
                    .tag(2)

                // 페이지 4: 이름 입력
                NameInputPage(userName: $userName, isFocused: $isNameFieldFocused)
                    .tag(3)

                // 페이지 5: 연차 설정
                LeaveSetupPage(
                    totalLeave: $totalLeave,
                    yearStartMonth: $yearStartMonth,
                    onComplete: completeOnboarding
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // 하단 버튼
            if currentPage < 4 {
                Button {
                    isNameFieldFocused = false
                    withAnimation {
                        currentPage += 1
                    }
                } label: {
                    Text(currentPage == 0 ? Strings.getStarted : Strings.next)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(blueColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onTapGesture {
            isNameFieldFocused = false
        }
        .onChange(of: currentPage) { _, newPage in
            if newPage != 3 {
                isNameFieldFocused = false
            }
        }
        .onChange(of: selectedCountry) { _, newCountry in
            // Set language based on country
            switch newCountry {
            case .korea: AppLanguage.current = .korean
            case .japan: AppLanguage.current = .japanese
            case .china: AppLanguage.current = .chinese
            case .usa: AppLanguage.current = .english
            }
        }
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            name: userName.isEmpty ? Strings.defaultUser : userName,
            yearStartMonth: yearStartMonth,
            totalAnnualLeave: totalLeave,
            usedLeave: 0,
            country: selectedCountry
        )
        modelContext.insert(profile)
        try? modelContext.save()

        // 위젯 데이터 즉시 업데이트
        WidgetService.shared.updateWidgetData(
            profile: profile,
            bonusLeaves: [],
            leaveRecords: []
        )

        withAnimation {
            isOnboardingComplete = true
        }
    }
}

// MARK: - 환영 페이지
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundStyle(Color(red: 0.0, green: 0.4, blue: 0.9))
                .padding(.bottom, 20)

            Text(Strings.appName)
                .font(.largeTitle.bold())

            Text(Strings.onboardingSubtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - 기능 소개 페이지
struct FeaturesPage: View {
    var features: [(String, String, String)] {
        [
            ("calendar.badge.plus", Strings.featureLeaveManagement, Strings.featureLeaveManagementDesc),
            ("sparkles", Strings.featureAIRecommend, Strings.featureAIRecommendDesc),
            ("gift.fill", Strings.featureBonusLeave, Strings.featureBonusLeaveDesc),
            ("apps.iphone", Strings.featureWidget, Strings.featureWidgetDesc)
        ]
    }

    var body: some View {
        VStack(spacing: 32) {
            Text(Strings.mainFeatures)
                .font(.title.bold())
                .padding(.top, 40)

            VStack(spacing: 20) {
                ForEach(features, id: \.1) { icon, title, description in
                    FeatureRow(icon: icon, title: title, description: description)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Color(red: 0.0, green: 0.4, blue: 0.9))
                .frame(width: 50, height: 50)
                .background(Color(red: 0.0, green: 0.4, blue: 0.9).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 국가 선택 페이지
struct CountrySelectionPage: View {
    @Binding var selectedCountry: Country

    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundStyle(blueColor)

            VStack(spacing: 8) {
                Text(Strings.selectCountry)
                    .font(.title.bold())
                Text(Strings.selectCountryDesc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(Country.allCases) { country in
                    Button {
                        selectedCountry = country
                    } label: {
                        VStack(spacing: 8) {
                            Text(country.flag)
                                .font(.system(size: 40))
                            Text(country.displayName)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(selectedCountry == country ? blueColor : Color(.secondarySystemBackground))
                        .foregroundStyle(selectedCountry == country ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - 이름 입력 페이지
struct NameInputPage: View {
    @Binding var userName: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(red: 0.0, green: 0.4, blue: 0.9))

            VStack(spacing: 8) {
                Text(Strings.enterName)
                    .font(.title.bold())
                Text(Strings.enterNameDesc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField(Strings.name, text: $userName)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused(isFocused)
                .submitLabel(.done)
                .onSubmit {
                    isFocused.wrappedValue = false
                }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused.wrappedValue = false
        }
    }
}

// MARK: - 연차 설정 페이지
struct LeaveSetupPage: View {
    @Binding var totalLeave: Double
    @Binding var yearStartMonth: Int
    let onComplete: () -> Void

    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text(Strings.leaveSetup)
                    .font(.title.bold())
                Text(Strings.leaveSetupDesc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            VStack(spacing: 20) {
                // 총 연차
                VStack(alignment: .leading, spacing: 12) {
                    Text(Strings.totalAnnualLeave)
                        .font(.headline)

                    HStack {
                        Text("\(Int(totalLeave))\(Strings.dayUnitSuffix)")
                            .font(.title.bold())
                            .foregroundStyle(blueColor)

                        Spacer()

                        Stepper("", value: $totalLeave, in: 1...30, step: 1)
                            .labelsHidden()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // 연차 기준월
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(Strings.yearStartMonthLabel)
                            .font(.headline)
                        Spacer()
                        Text(Strings.monthShort(yearStartMonth))
                            .font(.title2.bold())
                            .foregroundStyle(blueColor)
                    }

                    Text(Strings.yearStartMonthDesc)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(1...12, id: \.self) { month in
                            Button {
                                yearStartMonth = month
                            } label: {
                                Text(Strings.monthShort(month))
                                    .font(.subheadline.weight(yearStartMonth == month ? .bold : .regular))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(yearStartMonth == month ? blueColor : Color(.systemGray5))
                                    .foregroundStyle(yearStartMonth == month ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Spacer()

            // 완료 버튼
            Button(action: onComplete) {
                Text(Strings.getStarted)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(blueColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
